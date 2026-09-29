"""Tests de la API JSON contra los escenarios de portal-api.

Ejecutar:  uv run python -m unittest -v test_api

Las rutas de /api/* exigen sesión válida, así que cada prueba establece sesión
con el administrador sembrado antes de operar: la precondición del contrato
es ahora llegar autenticado, no que la API sea anónima.
"""
import os
import tempfile
import unittest

import app as app_module
import db


class ApiTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.tmp = tempfile.NamedTemporaryFile(suffix=".db", delete=False)
        cls.tmp.close()
        app_module.DB_PATH = cls.tmp.name
        app_module.app.config["DB_PATH"] = cls.tmp.name
        conn = db.connect(cls.tmp.name)
        db.init_db(conn)
        db.ensure_admin(conn)
        conn.close()

    @classmethod
    def tearDownClass(cls):
        os.unlink(cls.tmp.name)

    def setUp(self):
        conn = db.connect(app_module.DB_PATH)
        try:
            conn.executescript(
                "DELETE FROM employee_capability; DELETE FROM employee;"
                " DELETE FROM capability; DELETE FROM user;"
            )
            conn.commit()
            db.ensure_admin(conn)
        finally:
            conn.close()
        self.client = app_module.app.test_client()
        self.login()

    def login(self, username="admin", password="admin"):
        return self.client.post(
            "/auth/login", json={"username": username, "password": password}
        )

    def _user(self, username="operador", password="clave", role="user"):
        conn = db.connect(app_module.DB_PATH)
        try:
            return db.add_user(conn, username, password, role=role)
        finally:
            conn.close()

    def _capability(self, name="Java"):
        return self.client.post("/api/capabilities", json={"name": name}).get_json()["id"]

    def _employee(self, name="Ana"):
        return self.client.post("/api/employees", json={"name": name}).get_json()["id"]


    # --- listado de capacidades -----------------------------------------
    def test_listado_capacidades_con_datos(self):
        self._capability("Java")
        r = self.client.get("/api/capabilities")
        self.assertEqual(r.status_code, 200)
        self.assertEqual([c["name"] for c in r.get_json()], ["Java"])

    def test_listado_capacidades_vacio(self):
        r = self.client.get("/api/capabilities")
        self.assertEqual(r.status_code, 200)
        self.assertEqual(r.get_json(), [])

    # --- alta de capacidad ----------------------------------------------
    def test_alta_capacidad_correcta(self):
        r = self.client.post("/api/capabilities", json={"name": "Java"})
        self.assertEqual(r.status_code, 201)
        self.assertEqual(r.get_json()["name"], "Java")
        self.assertIn("id", r.get_json())

    def test_alta_capacidad_duplicada(self):
        self._capability("Java")
        r = self.client.post("/api/capabilities", json={"name": "Java"})
        self.assertEqual(r.status_code, 409)
        self.assertIn("error", r.get_json())
        self.assertEqual(len(self.client.get("/api/capabilities").get_json()), 1)

    def test_alta_capacidad_nombre_vacio(self):
        r = self.client.post("/api/capabilities", json={"name": "  "})
        self.assertEqual(r.status_code, 400)
        self.assertIn("error", r.get_json())
        self.assertEqual(self.client.get("/api/capabilities").get_json(), [])

    def test_alta_capacidad_sin_cuerpo(self):
        r = self.client.post("/api/capabilities")
        self.assertEqual(r.status_code, 400)

    # --- baja de capacidad ----------------------------------------------
    def test_baja_capacidad_correcta(self):
        cid = self._capability("Java")
        r = self.client.delete("/api/capabilities/%d" % cid)
        self.assertEqual(r.status_code, 204)
        self.assertEqual(self.client.get("/api/capabilities").get_json(), [])

    def test_baja_capacidad_elimina_asignaciones(self):
        cid = self._capability("Java")
        eid = self._employee("Ana")
        self.client.post(
            "/api/employees/%d/capabilities" % eid,
            json={"capability_id": cid, "level": 4},
        )
        self.client.delete("/api/capabilities/%d" % cid)
        ficha = self.client.get("/api/employees/%d" % eid).get_json()
        self.assertEqual(ficha["capabilities"], [])

    def test_baja_capacidad_inexistente(self):
        r = self.client.delete("/api/capabilities/9999")
        self.assertEqual(r.status_code, 404)
        self.assertIn("error", r.get_json())

    # --- empleados --------------------------------------------------------
    def test_listado_empleados(self):
        self._employee("Ana")
        self._employee("Luis")
        r = self.client.get("/api/employees")
        self.assertEqual(r.status_code, 200)
        self.assertEqual([e["name"] for e in r.get_json()], ["Ana", "Luis"])

    def test_ficha_empleado_con_capacidades(self):
        cid = self._capability("Java")
        eid = self._employee("Ana")
        self.client.post(
            "/api/employees/%d/capabilities" % eid,
            json={"capability_id": cid, "level": 5},
        )
        r = self.client.get("/api/employees/%d" % eid)
        self.assertEqual(r.status_code, 200)
        caps = r.get_json()["capabilities"]
        self.assertEqual([(c["name"], c["level"]) for c in caps], [("Java", 5)])

    def test_ficha_empleado_sin_capacidades(self):
        eid = self._employee("Ana")
        r = self.client.get("/api/employees/%d" % eid)
        self.assertEqual(r.status_code, 200)
        self.assertEqual(r.get_json()["capabilities"], [])

    def test_ficha_empleado_inexistente(self):
        r = self.client.get("/api/employees/9999")
        self.assertEqual(r.status_code, 404)
        self.assertIn("error", r.get_json())

    def test_alta_empleado_correcta(self):
        r = self.client.post("/api/employees", json={"name": "Ana"})
        self.assertEqual(r.status_code, 201)
        self.assertIn("id", r.get_json())

    def test_alta_empleado_nombre_vacio(self):
        r = self.client.post("/api/employees", json={"name": ""})
        self.assertEqual(r.status_code, 400)
        self.assertIn("error", r.get_json())

    # --- asignación -------------------------------------------------------
    def test_asignacion_correcta(self):
        cid = self._capability()
        eid = self._employee()
        r = self.client.post(
            "/api/employees/%d/capabilities" % eid,
            json={"capability_id": cid, "level": 3},
        )
        self.assertEqual(r.status_code, 201)

    def test_asignacion_nivel_fuera_de_rango(self):
        cid = self._capability()
        eid = self._employee()
        for bad in (0, 6):
            r = self.client.post(
                "/api/employees/%d/capabilities" % eid,
                json={"capability_id": cid, "level": bad},
            )
            self.assertEqual(r.status_code, 400)
            self.assertIn("error", r.get_json())

    def test_asignacion_nivel_no_numerico(self):
        cid = self._capability()
        eid = self._employee()
        r = self.client.post(
            "/api/employees/%d/capabilities" % eid,
            json={"capability_id": cid, "level": "alto"},
        )
        self.assertEqual(r.status_code, 400)

    def test_asignacion_empleado_inexistente(self):
        cid = self._capability()
        r = self.client.post(
            "/api/employees/9999/capabilities",
            json={"capability_id": cid, "level": 3},
        )
        self.assertEqual(r.status_code, 404)

    def test_asignacion_capacidad_inexistente(self):
        eid = self._employee()
        r = self.client.post(
            "/api/employees/%d/capabilities" % eid,
            json={"capability_id": 9999, "level": 3},
        )
        self.assertEqual(r.status_code, 404)

    def test_asignacion_capacidad_ya_asignada(self):
        cid = self._capability()
        eid = self._employee()
        self.client.post(
            "/api/employees/%d/capabilities" % eid,
            json={"capability_id": cid, "level": 3},
        )
        r = self.client.post(
            "/api/employees/%d/capabilities" % eid,
            json={"capability_id": cid, "level": 4},
        )
        self.assertEqual(r.status_code, 409)
        self.assertIn("error", r.get_json())

    # --- búsqueda ---------------------------------------------------------
    def test_busqueda_sin_nivel(self):
        cid = self._capability("Java")
        ana, luis = self._employee("Ana"), self._employee("Luis")
        for eid, lvl in ((ana, 5), (luis, 3)):
            self.client.post(
                "/api/employees/%d/capabilities" % eid,
                json={"capability_id": cid, "level": lvl},
            )
        r = self.client.get("/api/search?capability_id=%d" % cid)
        self.assertEqual(r.status_code, 200)
        self.assertEqual([(x["name"], x["level"]) for x in r.get_json()],
                         [("Ana", 5), ("Luis", 3)])

    def test_busqueda_con_nivel_minimo(self):
        cid = self._capability("Java")
        ana, luis = self._employee("Ana"), self._employee("Luis")
        for eid, lvl in ((ana, 5), (luis, 3)):
            self.client.post(
                "/api/employees/%d/capabilities" % eid,
                json={"capability_id": cid, "level": lvl},
            )
        r = self.client.get("/api/search?capability_id=%d&min_level=4" % cid)
        self.assertEqual(r.status_code, 200)
        self.assertEqual([x["name"] for x in r.get_json()], ["Ana"])

    def test_busqueda_sin_coincidencias(self):
        cid = self._capability("Rust")
        r = self.client.get("/api/search?capability_id=%d" % cid)
        self.assertEqual(r.status_code, 200)
        self.assertEqual(r.get_json(), [])

    def test_busqueda_nivel_minimo_que_ninguno_alcanza(self):
        cid = self._capability("Java")
        eid = self._employee("Ana")
        self.client.post(
            "/api/employees/%d/capabilities" % eid,
            json={"capability_id": cid, "level": 5},
        )
        r = self.client.get("/api/search?capability_id=%d&min_level=6" % cid)
        self.assertEqual(r.status_code, 200)
        self.assertEqual(r.get_json(), [])

    def test_busqueda_capacidad_inexistente(self):
        r = self.client.get("/api/search?capability_id=9999")
        self.assertEqual(r.status_code, 404)
        self.assertIn("error", r.get_json())

    def test_busqueda_nivel_no_numerico(self):
        cid = self._capability()
        r = self.client.get("/api/search?capability_id=%d&min_level=alto" % cid)
        self.assertEqual(r.status_code, 400)
        self.assertIn("error", r.get_json())

    # --- formato de error uniforme ---------------------------------------
    def test_todos_los_errores_devuelven_cuerpo_error(self):
        cases = [
            ("post", "/api/capabilities", {"json": {"name": ""}}, 400),
            ("post", "/api/capabilities", {"json": {"name": "X"}}, 201),
            ("delete", "/api/capabilities/9999", {}, 404),
            ("get", "/api/employees/9999", {}, 404),
            ("get", "/api/search?capability_id=9999", {}, 404),
            ("get", "/api/search?capability_id=abc", {}, 400),
        ]
        for method, path, kwargs, expected in cases:
            response = getattr(self.client, method)(path, **kwargs)
            self.assertEqual(response.status_code, expected, path)

    def test_error_tiene_clave_error_y_mensaje(self):
        self._capability("Java")
        r = self.client.post("/api/capabilities", json={"name": "Java"})
        payload = r.get_json()
        self.assertIn("error", payload)
        self.assertTrue(payload["error"])

    # --- sesión exigida ---------------------------------------------------
    def test_todas_las_rutas_de_api_rechazan_sin_sesion(self):
        anon = app_module.app.test_client()
        routes = [
            ("get", "/api/capabilities"),
            ("post", "/api/capabilities"),
            ("put", "/api/capabilities/1"),
            ("delete", "/api/capabilities/1"),
            ("get", "/api/employees"),
            ("post", "/api/employees"),
            ("get", "/api/employees/1"),
            ("put", "/api/employees/1"),
            ("delete", "/api/employees/1"),
            ("post", "/api/employees/1/capabilities"),
            ("put", "/api/employees/1/capabilities/1"),
            ("delete", "/api/employees/1/capabilities/1"),
            ("get", "/api/search?capability_id=1"),
        ]
        for method, path in routes:
            response = getattr(anon, method)(path)
            self.assertEqual(response.status_code, 401, "%s %s" % (method, path))
            self.assertIn("error", response.get_json())

    def test_sin_sesion_no_modifica_datos(self):
        cid = self._capability("Java")
        anon = app_module.app.test_client()
        anon.post("/api/capabilities", json={"name": "Intruso"})
        anon.delete("/api/capabilities/%d" % cid)
        self.assertEqual(
            [c["name"] for c in self.client.get("/api/capabilities").get_json()], ["Java"]
        )

    def test_rol_no_admin_es_rechazado(self):
        """La spec exige rechazar el rol distinto de administrador."""
        self._user("operador", "clave", role="user")

        cl = app_module.app.test_client()
        self.assertEqual(
            cl.post("/auth/login", json={"username": "operador", "password": "clave"}).status_code,
            200,
        )
        routes = [
            ("get", "/api/capabilities"),
            ("post", "/api/capabilities"),
            ("put", "/api/capabilities/1"),
            ("delete", "/api/capabilities/1"),
            ("get", "/api/employees"),
            ("post", "/api/employees"),
            ("get", "/api/employees/1"),
            ("put", "/api/employees/1"),
            ("delete", "/api/employees/1"),
            ("get", "/api/search?capability_id=1"),
        ]
        for method, path in routes:
            response = getattr(cl, method)(path)
            self.assertEqual(response.status_code, 403, "%s %s" % (method, path))
            self.assertIn("error", response.get_json())

    def test_rol_no_admin_conserva_su_identidad(self):
        """Consultar la propia identidad no es una operación de administrador."""
        self._user("operador", "clave", role="user")
        cl = app_module.app.test_client()
        cl.post("/auth/login", json={"username": "operador", "password": "clave"})
        r = cl.get("/auth/me")
        self.assertEqual(r.status_code, 200)
        self.assertEqual(r.get_json()["role"], "user")

    def test_cierre_de_sesion_invalida_la_operacion(self):
        self.assertEqual(self.client.get("/api/capabilities").status_code, 200)
        self.client.post("/auth/logout")
        self.assertEqual(self.client.get("/api/capabilities").status_code, 401)

    def test_ruta_de_api_inexistente_devuelve_json(self):
        r = self.client.get("/api/no-existe")
        self.assertEqual(r.status_code, 404)
        self.assertTrue(r.is_json)
        self.assertIn("error", r.get_json())

    # --- autenticación ----------------------------------------------------
    def test_login_correcto_devuelve_identidad_y_rol(self):
        anon = app_module.app.test_client()
        r = anon.post("/auth/login", json={"username": "admin", "password": "admin"})
        self.assertEqual(r.status_code, 200)
        self.assertEqual(r.get_json()["username"], "admin")
        self.assertEqual(r.get_json()["role"], "admin")

    def test_login_fallido_no_revela_el_motivo(self):
        anon = app_module.app.test_client()
        mala = anon.post("/auth/login", json={"username": "admin", "password": "mala"})
        inexistente = anon.post("/auth/login", json={"username": "nadie", "password": "x"})
        self.assertEqual(mala.status_code, 401)
        self.assertEqual(mala.get_json(), inexistente.get_json())

    def test_login_sin_datos(self):
        anon = app_module.app.test_client()
        self.assertEqual(anon.post("/auth/login", json={}).status_code, 400)

    def test_me_sin_sesion(self):
        self.assertEqual(app_module.app.test_client().get("/auth/me").status_code, 401)

    def test_cambio_de_password(self):
        anon = app_module.app.test_client()
        self.assertEqual(
            anon.post(
                "/auth/password", json={"current_password": "admin", "new_password": "nueva"}
            ).status_code,
            401,
        )
        self.assertEqual(
            self.client.post(
                "/auth/password", json={"current_password": "mal", "new_password": "x"}
            ).status_code,
            400,
        )
        self.assertEqual(
            self.client.post(
                "/auth/password", json={"current_password": "admin", "new_password": "  "}
            ).status_code,
            400,
        )
        self.assertEqual(
            self.client.post(
                "/auth/password", json={"current_password": "admin", "new_password": "nueva"}
            ).status_code,
            204,
        )
        # restaurar para no romper el resto de las pruebas
        self.assertEqual(self.login("admin", "nueva").status_code, 200)
        self.client.post(
            "/auth/password", json={"current_password": "nueva", "new_password": "admin"}
        )

    # --- edición de capacidad ---------------------------------------------
    def test_edicion_de_capacidad(self):
        cid = self._capability("Java")
        r = self.client.put("/api/capabilities/%d" % cid, json={"name": "Java 21"})
        self.assertEqual(r.status_code, 200)
        self.assertEqual(r.get_json()["name"], "Java 21")
        self.assertEqual(
            [c["name"] for c in self.client.get("/api/capabilities").get_json()], ["Java 21"]
        )

    def test_edicion_de_capacidad_conserva_asignaciones(self):
        cid = self._capability("Java")
        eid = self._employee("Ana")
        self.client.post(
            "/api/employees/%d/capabilities" % eid, json={"capability_id": cid, "level": 4}
        )
        self.client.put("/api/capabilities/%d" % cid, json={"name": "Java 21"})
        caps = self.client.get("/api/employees/%d" % eid).get_json()["capabilities"]
        self.assertEqual([(c["name"], c["level"]) for c in caps], [("Java 21", 4)])

    def test_edicion_de_capacidad_duplicada(self):
        cid = self._capability("Java")
        self._capability("Rust")
        r = self.client.put("/api/capabilities/%d" % cid, json={"name": "Rust"})
        self.assertEqual(r.status_code, 409)
        self.assertIn("error", r.get_json())

    def test_edicion_de_capacidad_vacia_e_inexistente(self):
        cid = self._capability("Java")
        self.assertEqual(
            self.client.put("/api/capabilities/%d" % cid, json={"name": ""}).status_code, 400
        )
        self.assertEqual(
            self.client.put("/api/capabilities/9999", json={"name": "X"}).status_code, 404
        )

    # --- edición y baja de empleado ---------------------------------------
    def test_edicion_de_empleado_conserva_capacidades(self):
        cid = self._capability("Java")
        eid = self._employee("Ana")
        self.client.post(
            "/api/employees/%d/capabilities" % eid, json={"capability_id": cid, "level": 3}
        )
        r = self.client.put("/api/employees/%d" % eid, json={"name": "Ana López"})
        self.assertEqual(r.status_code, 200)
        self.assertEqual(r.get_json()["name"], "Ana López")
        self.assertEqual(len(self.client.get("/api/employees/%d" % eid).get_json()["capabilities"]), 1)

    def test_edicion_de_empleado_vacia_e_inexistente(self):
        eid = self._employee("Ana")
        self.assertEqual(
            self.client.put("/api/employees/%d" % eid, json={"name": ""}).status_code, 400
        )
        self.assertEqual(
            self.client.put("/api/employees/9999", json={"name": "X"}).status_code, 404
        )

    def test_baja_de_empleado_elimina_asignaciones_y_desaparece(self):
        cid = self._capability("Java")
        eid = self._employee("Ana")
        self.client.post(
            "/api/employees/%d/capabilities" % eid, json={"capability_id": cid, "level": 5}
        )
        self.assertEqual(self.client.delete("/api/employees/%d" % eid).status_code, 204)
        self.assertEqual(self.client.get("/api/employees/%d" % eid).status_code, 404)
        self.assertEqual(self.client.get("/api/employees").get_json(), [])
        self.assertEqual(self.client.get("/api/search?capability_id=%d" % cid).get_json(), [])

    def test_baja_de_empleado_inexistente(self):
        self.assertEqual(self.client.delete("/api/employees/9999").status_code, 404)

    # --- corrección de nivel y desasignación ------------------------------
    def test_correccion_de_nivel(self):
        cid = self._capability("Java")
        eid = self._employee("Ana")
        self.client.post(
            "/api/employees/%d/capabilities" % eid, json={"capability_id": cid, "level": 2}
        )
        r = self.client.put(
            "/api/employees/%d/capabilities/%d" % (eid, cid), json={"level": 5}
        )
        self.assertEqual(r.status_code, 200)
        caps = self.client.get("/api/employees/%d" % eid).get_json()["capabilities"]
        self.assertEqual([(c["name"], c["level"]) for c in caps], [("Java", 5)])

    def test_correccion_de_nivel_fuera_de_rango(self):
        cid = self._capability("Java")
        eid = self._employee("Ana")
        self.client.post(
            "/api/employees/%d/capabilities" % eid, json={"capability_id": cid, "level": 2}
        )
        for bad in (0, 6, "alto"):
            r = self.client.put(
                "/api/employees/%d/capabilities/%d" % (eid, cid), json={"level": bad}
            )
            self.assertEqual(r.status_code, 400, bad)

    def test_correccion_de_nivel_no_asignada(self):
        cid = self._capability("Java")
        eid = self._employee("Ana")
        r = self.client.put(
            "/api/employees/%d/capabilities/%d" % (eid, cid), json={"level": 3}
        )
        self.assertEqual(r.status_code, 404)

    def test_desasignacion(self):
        cid = self._capability("Java")
        otra = self._capability("Rust")
        eid = self._employee("Ana")
        for cap in (cid, otra):
            self.client.post(
                "/api/employees/%d/capabilities" % eid, json={"capability_id": cap, "level": 3}
            )
        self.assertEqual(
            self.client.delete("/api/employees/%d/capabilities/%d" % (eid, cid)).status_code,
            204,
        )
        caps = self.client.get("/api/employees/%d" % eid).get_json()["capabilities"]
        self.assertEqual([c["name"] for c in caps], ["Rust"])

    def test_desasignacion_no_asignada(self):
        cid = self._capability("Java")
        eid = self._employee("Ana")
        self.assertEqual(
            self.client.delete("/api/employees/%d/capabilities/%d" % (eid, cid)).status_code, 404
        )


if __name__ == "__main__":
    unittest.main()
