"""Autenticación del portal: rutas de acceso y sesión por cookie firmada.

La sesión guarda únicamente el identificador de usuario; el usuario se relee
en cada petición, de modo que un cambio de rol o una baja surten efecto sin
esperar a que caduque la cookie.

La autorización real vive aquí y en la intercepción de `app.py`, nunca en el
cliente: una guardia de navegación es experiencia de usuario, no seguridad.
"""
from flask import Blueprint, jsonify, request, session

import db

auth = Blueprint("auth", __name__)

_INVALID = "Usuario o contraseña incorrectos."


def _db_path():
    """Ruta de la base de datos resuelta en cada petición.

    Se importa dentro de la función para leer el valor vigente de `app.DB_PATH`,
    que los tests sustituyen por un almacén temporal.
    """
    import app as app_module

    return app_module.DB_PATH


def _connect():
    return db.connect(_db_path())


def _body():
    return request.get_json(silent=True) or {}


def _public_user(row):
    return {"id": row["id"], "username": row["username"], "role": row["role"]}


def current_user():
    """Fila del usuario con sesión activa, o None si no hay sesión válida."""
    user_id = session.get("user_id")
    if user_id is None:
        return None
    conn = _connect()
    try:
        return db.get_user(conn, user_id)
    finally:
        conn.close()


def unauthorized():
    return jsonify({"error": "Se requiere autenticación."}), 401


@auth.post("/auth/login")
def login():
    payload = _body()
    username = payload.get("username")
    password = payload.get("password")
    if not username or not password:
        return jsonify({"error": "Usuario y contraseña son obligatorios."}), 400

    conn = _connect()
    try:
        row = db.verify_password(conn, username, password)
    finally:
        conn.close()

    if row is None:
        # Mismo mensaje para usuario inexistente y contraseña incorrecta:
        # el error no revela cuál de los dos falló.
        return jsonify({"error": _INVALID}), 401

    session.clear()
    session["user_id"] = row["id"]
    return jsonify(_public_user(row)), 200


@auth.post("/auth/logout")
def logout():
    session.clear()
    return "", 204


@auth.get("/auth/me")
def me():
    user = current_user()
    if user is None:
        return unauthorized()
    return jsonify(_public_user(user)), 200


@auth.post("/auth/password")
def change_password():
    user_id = session.get("user_id")
    if user_id is None:
        return unauthorized()

    payload = _body()
    conn = _connect()
    try:
        try:
            db.set_password(
                conn,
                user_id,
                payload.get("current_password"),
                payload.get("new_password"),
            )
        except ValueError as exc:
            return jsonify({"error": str(exc)}), 400
    finally:
        conn.close()

    return "", 204


def configure(app):
    """Registra las rutas de autenticación en la aplicación Flask."""
    app.register_blueprint(auth)
