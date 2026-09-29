"""Capa de acceso a datos del portal de empleados (SQLite, sin ORM).

Invariantes garantizadas por el esquema:
  - nombre de capacidad único            -> UNIQUE(name)
  - capacidad no repetible por empleado  -> PRIMARY KEY(employee_id, capability_id)
  - nivel entero entre 1 y 5             -> CHECK(level BETWEEN 1 AND 5)
  - empleado con 0 capacidades           -> ausencia de filas en employee_capability
  - nombre de usuario único              -> UNIQUE(username)

Las funciones existentes (dominio de capacidades y empleados) no se han
modificado; la capa de usuarios y el CRUD se han añadido de forma aditiva.
"""
import sqlite3

from werkzeug.security import check_password_hash, generate_password_hash

SCHEMA = """
CREATE TABLE IF NOT EXISTS capability (
    id   INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE
);
CREATE TABLE IF NOT EXISTS employee (
    id   INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS employee_capability (
    employee_id   INTEGER NOT NULL REFERENCES employee(id)   ON DELETE CASCADE,
    capability_id INTEGER NOT NULL REFERENCES capability(id) ON DELETE CASCADE,
    level         INTEGER NOT NULL CHECK (level BETWEEN 1 AND 5),
    PRIMARY KEY (employee_id, capability_id)
);
CREATE TABLE IF NOT EXISTS user (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    username      TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    role          TEXT NOT NULL DEFAULT 'admin',
    parent_id     INTEGER REFERENCES user(id) ON DELETE SET NULL
);
"""


def connect(db_path):
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON")
    return conn


def init_db(conn):
    conn.executescript(SCHEMA)
    conn.commit()


# --- catálogo de capacidades ---------------------------------------------

def add_capability(conn, name):
    name = (name or "").strip()
    if not name:
        raise ValueError("El nombre de la capacidad es obligatorio.")
    try:
        cur = conn.execute("INSERT INTO capability (name) VALUES (?)", (name,))
    except sqlite3.IntegrityError:
        raise ValueError("La capacidad '%s' ya existe en el catálogo." % name)
    conn.commit()
    return cur.lastrowid


def list_capabilities(conn):
    return conn.execute("SELECT id, name FROM capability ORDER BY name").fetchall()


def capability_exists(conn, capability_id):
    return conn.execute(
        "SELECT 1 FROM capability WHERE id = ?", (capability_id,)
    ).fetchone() is not None


def delete_capability(conn, capability_id):
    # ON DELETE CASCADE (con foreign_keys=ON) elimina las asignaciones huérfanas.
    conn.execute("DELETE FROM capability WHERE id = ?", (capability_id,))
    conn.commit()


# --- empleados ------------------------------------------------------------

def add_employee(conn, name):
    name = (name or "").strip()
    if not name:
        raise ValueError("El nombre del empleado es obligatorio.")
    cur = conn.execute("INSERT INTO employee (name) VALUES (?)", (name,))
    conn.commit()
    return cur.lastrowid


def list_employees(conn):
    return conn.execute("SELECT id, name FROM employee ORDER BY name").fetchall()


def get_employee(conn, employee_id):
    return conn.execute(
        "SELECT id, name FROM employee WHERE id = ?", (employee_id,)
    ).fetchone()


def employee_exists(conn, employee_id):
    return conn.execute(
        "SELECT 1 FROM employee WHERE id = ?", (employee_id,)
    ).fetchone() is not None


# --- asignación de capacidades con nivel ----------------------------------

def assign_capability(conn, employee_id, capability_id, level):
    try:
        level = int(level)
    except (TypeError, ValueError):
        raise ValueError("El nivel debe ser un número entero entre 1 y 5.")
    if not 1 <= level <= 5:
        raise ValueError("El nivel debe estar entre 1 y 5.")
    if not employee_exists(conn, employee_id):
        raise ValueError("El empleado no existe.")
    if not capability_exists(conn, capability_id):
        raise ValueError("La capacidad no existe en el catálogo.")
    try:
        conn.execute(
            "INSERT INTO employee_capability (employee_id, capability_id, level)"
            " VALUES (?, ?, ?)",
            (employee_id, capability_id, level),
        )
    except sqlite3.IntegrityError:
        raise ValueError("Ese empleado ya tiene asignada esa capacidad.")
    conn.commit()


def employee_capabilities(conn, employee_id):
    return conn.execute(
        """SELECT c.id AS capability_id, c.name AS capability_name, ec.level
             FROM employee_capability ec
             JOIN capability c ON c.id = ec.capability_id
            WHERE ec.employee_id = ?
            ORDER BY c.name""",
        (employee_id,),
    ).fetchall()


# --- búsqueda -------------------------------------------------------------

def search(conn, capability_id, min_level=None):
    """Empleados con la capacidad dada; si min_level se indica, solo level >= min."""
    if not capability_exists(conn, capability_id):
        raise ValueError("La capacidad no existe en el catálogo.")
    sql = (
        "SELECT e.id, e.name, ec.level"
        "  FROM employee e"
        "  JOIN employee_capability ec ON ec.employee_id = e.id"
        " WHERE ec.capability_id = ?"
    )
    params = [capability_id]
    if min_level is not None and str(min_level).strip() != "":
        sql += " AND ec.level >= ?"
        params.append(int(min_level))
    sql += " ORDER BY ec.level DESC, e.name"
    return conn.execute(sql, params).fetchall()


# --- edición de capacidades ------------------------------------------------

def update_capability(conn, capability_id, name):
    name = (name or "").strip()
    if not name:
        raise ValueError("El nombre de la capacidad es obligatorio.")
    if not capability_exists(conn, capability_id):
        raise ValueError("La capacidad no existe en el catálogo.")
    try:
        conn.execute("UPDATE capability SET name = ? WHERE id = ?", (name, capability_id))
    except sqlite3.IntegrityError:
        raise ValueError("La capacidad '%s' ya existe en el catálogo." % name)
    conn.commit()


# --- edición y baja de empleados -------------------------------------------

def update_employee(conn, employee_id, name):
    name = (name or "").strip()
    if not name:
        raise ValueError("El nombre del empleado es obligatorio.")
    if not employee_exists(conn, employee_id):
        raise ValueError("El empleado no existe.")
    conn.execute("UPDATE employee SET name = ? WHERE id = ?", (name, employee_id))
    conn.commit()


def delete_employee(conn, employee_id):
    # ON DELETE CASCADE (con foreign_keys=ON) elimina las asignaciones del empleado.
    if not employee_exists(conn, employee_id):
        raise ValueError("El empleado no existe.")
    conn.execute("DELETE FROM employee WHERE id = ?", (employee_id,))
    conn.commit()


# --- ciclo de vida de las asignaciones -------------------------------------

def update_assignment_level(conn, employee_id, capability_id, level):
    try:
        level = int(level)
    except (TypeError, ValueError):
        raise ValueError("El nivel debe ser un número entero entre 1 y 5.")
    if not 1 <= level <= 5:
        raise ValueError("El nivel debe estar entre 1 y 5.")
    if not employee_exists(conn, employee_id):
        raise ValueError("El empleado no existe.")
    if not capability_exists(conn, capability_id):
        raise ValueError("La capacidad no existe en el catálogo.")
    cur = conn.execute(
        "UPDATE employee_capability SET level = ?"
        " WHERE employee_id = ? AND capability_id = ?",
        (level, employee_id, capability_id),
    )
    if cur.rowcount == 0:
        raise ValueError("Ese empleado no tiene asignada esa capacidad.")
    conn.commit()


def unassign_capability(conn, employee_id, capability_id):
    if not employee_exists(conn, employee_id):
        raise ValueError("El empleado no existe.")
    cur = conn.execute(
        "DELETE FROM employee_capability WHERE employee_id = ? AND capability_id = ?",
        (employee_id, capability_id),
    )
    if cur.rowcount == 0:
        raise ValueError("Ese empleado no tiene asignada esa capacidad.")
    conn.commit()


# --- usuarios --------------------------------------------------------------

def add_user(conn, username, password, role="admin", parent_id=None):
    username = (username or "").strip()
    if not username:
        raise ValueError("El nombre de usuario es obligatorio.")
    if not password:
        raise ValueError("La contraseña es obligatoria.")
    try:
        cur = conn.execute(
            "INSERT INTO user (username, password_hash, role, parent_id)"
            " VALUES (?, ?, ?, ?)",
            (username, generate_password_hash(password), role, parent_id),
        )
    except sqlite3.IntegrityError:
        raise ValueError("El usuario '%s' ya existe." % username)
    conn.commit()
    return cur.lastrowid


def get_user_by_username(conn, username):
    return conn.execute(
        "SELECT id, username, password_hash, role, parent_id FROM user WHERE username = ?",
        ((username or "").strip(),),
    ).fetchone()


def get_user(conn, user_id):
    return conn.execute(
        "SELECT id, username, role, parent_id FROM user WHERE id = ?", (user_id,)
    ).fetchone()


def verify_password(conn, username, password):
    """Devuelve la fila del usuario si la credencial es válida; None si no lo es."""
    row = get_user_by_username(conn, username)
    if row is None or not password:
        return None
    if not check_password_hash(row["password_hash"], password):
        return None
    return row


def set_password(conn, user_id, current_password, new_password):
    row = conn.execute(
        "SELECT password_hash FROM user WHERE id = ?", (user_id,)
    ).fetchone()
    if row is None:
        raise ValueError("El usuario no existe.")
    if not current_password or not check_password_hash(
        row["password_hash"], current_password
    ):
        raise ValueError("La contraseña actual no es correcta.")
    if not new_password or not str(new_password).strip():
        raise ValueError("La nueva contraseña no puede estar vacía.")
    conn.execute(
        "UPDATE user SET password_hash = ? WHERE id = ?",
        (generate_password_hash(new_password), user_id),
    )
    conn.commit()


def ensure_admin(conn, username="admin", password="admin"):
    """Siembra idempotente: solo crea el administrador si no existe.

    Un arranque posterior no restablece una credencial ya cambiada.
    """
    if get_user_by_username(conn, username) is not None:
        return None
    return add_user(conn, username, password, role="admin")
