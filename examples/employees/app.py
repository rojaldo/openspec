"""API JSON del portal de empleados + entrega del cliente SPA.

Ejecutar:  uv run app.py     (http://127.0.0.1:8000)
La capa de datos vive en db.py; las funciones de dominio no se han modificado
(solo se han añadido la tabla de usuarios y las operaciones de edición y baja).
"""
import os

from flask import Flask, jsonify, request, send_from_directory

import auth
import db

DB_PATH = os.environ.get("PORTAL_DB", "portal.db")
DIST_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "web", "dist")

# Credencial sembrada para desarrollo local; ver deuda aceptada en el design.
SEED_USERNAME = "admin"
SEED_PASSWORD = "admin"

# Único rol con acceso a las operaciones del portal. El modelo de usuarios
# admite más roles y jerarquía (parent_id), pero solo se implementa este.
ADMIN_ROLE = "admin"

app = Flask(__name__, static_folder=None)
app.config["DB_PATH"] = DB_PATH
app.config["SECRET_KEY"] = os.environ.get("SECRET_KEY") or "dev-insecure-key"
app.config["SESSION_COOKIE_HTTPONLY"] = True
app.config["SESSION_COOKIE_SAMESITE"] = "Lax"


def connect():
    return db.connect(DB_PATH)


def row_to_dict(row):
    return dict(row)


def fail(message, status):
    return jsonify({"error": message}), status


def body():
    return request.get_json(silent=True) or {}


@app.before_request
def require_session():
    """Exige sesión válida y rol de administrador para toda operación de /api/*.

    Un único punto protege lo presente y lo futuro, en lugar de repetir la
    comprobación por ruta, donde basta olvidar una para dejar un agujero.
    Sin sesión se responde 401; con sesión de un rol no autorizado, 403.
    Las rutas de acceso viven bajo /auth/* y no se ven afectadas.
    """
    if not request.path.startswith("/api/"):
        return None
    user = auth.current_user()
    if user is None:
        return fail("Se requiere autenticación.", 401)
    if user["role"] != ADMIN_ROLE:
        return fail("Se requieren permisos de administrador.", 403)
    return None


@app.errorhandler(404)
def not_found(error):
    """Las rutas de la API devuelven JSON; el resto, el documento SPA."""
    if request.path.startswith("/api/"):
        return fail("Ruta de API inexistente.", 404)
    return spa(request.path.lstrip("/") or "")


@app.errorhandler(405)
def method_not_allowed(error):
    """Un método no permitido bajo la API también responde JSON, no HTML."""
    if request.path.startswith("/api/"):
        return fail("Método no permitido para esta ruta de API.", 405)
    return error


@app.get("/api/capabilities")
def list_capabilities():
    conn = connect()
    try:
        return jsonify([row_to_dict(r) for r in db.list_capabilities(conn)])
    finally:
        conn.close()


@app.post("/api/capabilities")
def create_capability():
    name = (body().get("name") or "").strip()
    if not name:
        return fail("El nombre de la capacidad es obligatorio.", 400)
    conn = connect()
    try:
        try:
            capability_id = db.add_capability(conn, name)
        except ValueError as exc:
            return fail(str(exc), 409)
        row = conn.execute(
            "SELECT id, name FROM capability WHERE id = ?", (capability_id,)
        ).fetchone()
        return jsonify(row_to_dict(row)), 201
    finally:
        conn.close()


@app.delete("/api/capabilities/<int:capability_id>")
def delete_capability(capability_id):
    conn = connect()
    try:
        if not db.capability_exists(conn, capability_id):
            return fail("La capacidad no existe en el catálogo.", 404)
        db.delete_capability(conn, capability_id)
        return "", 204
    finally:
        conn.close()


@app.put("/api/capabilities/<int:capability_id>")
def update_capability(capability_id):
    name = (body().get("name") or "").strip()
    if not name:
        return fail("El nombre de la capacidad es obligatorio.", 400)
    conn = connect()
    try:
        if not db.capability_exists(conn, capability_id):
            return fail("La capacidad no existe en el catálogo.", 404)
        try:
            db.update_capability(conn, capability_id, name)
        except ValueError as exc:
            return fail(str(exc), 409)
        row = conn.execute(
            "SELECT id, name FROM capability WHERE id = ?", (capability_id,)
        ).fetchone()
        return jsonify(row_to_dict(row)), 200
    finally:
        conn.close()


@app.get("/api/employees")
def list_employees():
    conn = connect()
    try:
        return jsonify([row_to_dict(r) for r in db.list_employees(conn)])
    finally:
        conn.close()


@app.post("/api/employees")
def create_employee():
    name = (body().get("name") or "").strip()
    if not name:
        return fail("El nombre del empleado es obligatorio.", 400)
    conn = connect()
    try:
        employee_id = db.add_employee(conn, name)
        row = db.get_employee(conn, employee_id)
        return jsonify(row_to_dict(row)), 201
    finally:
        conn.close()


@app.get("/api/employees/<int:employee_id>")
def get_employee(employee_id):
    conn = connect()
    try:
        employee = db.get_employee(conn, employee_id)
        if employee is None:
            return fail("El empleado no existe.", 404)
        capabilities = [
            {
                "capability_id": c["capability_id"],
                "name": c["capability_name"],
                "level": c["level"],
            }
            for c in db.employee_capabilities(conn, employee_id)
        ]
        return jsonify(
            {
                "id": employee["id"],
                "name": employee["name"],
                "capabilities": capabilities,
            }
        )
    finally:
        conn.close()


@app.put("/api/employees/<int:employee_id>")
def update_employee(employee_id):
    name = (body().get("name") or "").strip()
    if not name:
        return fail("El nombre del empleado es obligatorio.", 400)
    conn = connect()
    try:
        if not db.employee_exists(conn, employee_id):
            return fail("El empleado no existe.", 404)
        db.update_employee(conn, employee_id, name)
        row = db.get_employee(conn, employee_id)
        return jsonify(row_to_dict(row)), 200
    finally:
        conn.close()


@app.delete("/api/employees/<int:employee_id>")
def delete_employee(employee_id):
    conn = connect()
    try:
        if not db.employee_exists(conn, employee_id):
            return fail("El empleado no existe.", 404)
        db.delete_employee(conn, employee_id)
        return "", 204
    finally:
        conn.close()


def _parse_level(raw_level):
    """Nivel entero 1-5, o None si no es válido."""
    try:
        level = int(raw_level)
    except (TypeError, ValueError):
        return None
    return level if 1 <= level <= 5 else None


@app.put("/api/employees/<int:employee_id>/capabilities/<int:capability_id>")
def update_assignment(employee_id, capability_id):
    raw_level = body().get("level")
    if raw_level is None:
        return fail("El nivel debe ser un número entero entre 1 y 5.", 400)
    level = _parse_level(raw_level)
    if level is None:
        return fail("El nivel debe estar entre 1 y 5.", 400)
    conn = connect()
    try:
        if not db.employee_exists(conn, employee_id):
            return fail("El empleado no existe.", 404)
        try:
            db.update_assignment_level(conn, employee_id, capability_id, level)
        except ValueError as exc:
            return fail(str(exc), 404)
        return "", 200
    finally:
        conn.close()


@app.delete("/api/employees/<int:employee_id>/capabilities/<int:capability_id>")
def unassign_capability(employee_id, capability_id):
    conn = connect()
    try:
        if not db.employee_exists(conn, employee_id):
            return fail("El empleado no existe.", 404)
        try:
            db.unassign_capability(conn, employee_id, capability_id)
        except ValueError as exc:
            return fail(str(exc), 404)
        return "", 204
    finally:
        conn.close()


@app.post("/api/employees/<int:employee_id>/capabilities")
def assign_capability(employee_id):
    payload = body()
    capability_id = payload.get("capability_id")
    raw_level = payload.get("level")
    if raw_level is None:
        return fail("El nivel debe ser un número entero entre 1 y 5.", 400)
    try:
        level = int(raw_level)
    except (TypeError, ValueError):
        return fail("El nivel debe ser un número entero entre 1 y 5.", 400)
    if not 1 <= level <= 5:
        return fail("El nivel debe estar entre 1 y 5.", 400)
    if capability_id is None:
        return fail("La capacidad no existe en el catálogo.", 404)
    try:
        capability_id = int(capability_id)
    except (TypeError, ValueError):
        return fail("La capacidad no existe en el catálogo.", 404)
    conn = connect()
    try:
        if not db.employee_exists(conn, employee_id):
            return fail("El empleado no existe.", 404)
        if not db.capability_exists(conn, capability_id):
            return fail("La capacidad no existe en el catálogo.", 404)
        try:
            db.assign_capability(conn, employee_id, capability_id, level)
        except ValueError as exc:
            return fail(str(exc), 409)
        return "", 201
    finally:
        conn.close()


@app.get("/api/search")
def search():
    raw_capability = request.args.get("capability_id")
    if raw_capability is None or raw_capability.strip() == "":
        return fail("La capacidad no existe en el catálogo.", 404)
    try:
        capability_id = int(raw_capability)
    except ValueError:
        return fail("El identificador de capacidad no es válido.", 400)

    raw_min = request.args.get("min_level")
    min_level = None
    if raw_min is not None and raw_min.strip() != "":
        try:
            min_level = int(raw_min)
        except ValueError:
            return fail("El nivel mínimo debe ser un número entero.", 400)

    conn = connect()
    try:
        if not db.capability_exists(conn, capability_id):
            return fail("La capacidad no existe en el catálogo.", 404)
        rows = db.search(conn, capability_id, min_level)
        return jsonify(
            [{"id": r["id"], "name": r["name"], "level": r["level"]} for r in rows]
        )
    finally:
        conn.close()


@app.route("/", defaults={"path": ""})
@app.route("/<path:path>")
def spa(path):
    if path.startswith("api/"):
        return fail("Ruta de API inexistente.", 404)
    candidate = os.path.join(DIST_DIR, path)
    if path and os.path.isfile(candidate):
        return send_from_directory(DIST_DIR, path)
    index = os.path.join(DIST_DIR, "index.html")
    if os.path.isfile(index):
        return send_from_directory(DIST_DIR, "index.html")
    return (
        "El cliente SPA no está construido. Ejecuta: cd web && npm install && npm run build",
        503,
    )


def main():
    conn = db.connect(DB_PATH)
    db.init_db(conn)
    db.ensure_admin(conn, SEED_USERNAME, SEED_PASSWORD)
    conn.close()
    if not os.environ.get("SECRET_KEY"):
        print(
            "AVISO: SECRET_KEY no está definida; se usa una de desarrollo. "
            "Defínela antes de exponer el portal fuera de local."
        )
    app.run(host="127.0.0.1", port=8000, debug=False)


auth.configure(app)


if __name__ == "__main__":
    main()
