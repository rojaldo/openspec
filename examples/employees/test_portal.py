"""Chequeo ejecutable de los escenarios del spec.

Ejecutar:  uv run python -m unittest -v test_portal
"""
import sqlite3
import unittest

import db


class PortalTests(unittest.TestCase):
    def setUp(self):
        self.conn = db.connect(":memory:")  # cada test aislado
        db.init_db(self.conn)

    def tearDown(self):
        self.conn.close()

    # --- 2.3 invariantes del esquema -------------------------------------
    def test_esquema_rechaza_nivel_fuera_de_rango(self):
        emp = db.add_employee(self.conn, "Ana")
        cap = db.add_capability(self.conn, "Java")
        for bad in (0, 6, -1, 99):
            with self.assertRaises(sqlite3.IntegrityError):
                self.conn.execute(
                    "INSERT INTO employee_capability VALUES (?,?,?)", (emp, cap, bad))

    def test_esquema_rechaza_capacidad_duplicada_en_empleado(self):
        emp = db.add_employee(self.conn, "Ana")
        cap = db.add_capability(self.conn, "Java")
        self.conn.execute("INSERT INTO employee_capability VALUES (?,?,?)", (emp, cap, 3))
        with self.assertRaises(sqlite3.IntegrityError):
            self.conn.execute(
                "INSERT INTO employee_capability VALUES (?,?,?)", (emp, cap, 4))

    def test_esquema_rechaza_nombre_de_capacidad_duplicado(self):
        db.add_capability(self.conn, "Java")
        with self.assertRaises(sqlite3.IntegrityError):
            self.conn.execute("INSERT INTO capability (name) VALUES ('Java')")

    # --- 3 catálogo ------------------------------------------------------
    def test_alta_de_capacidad_nueva(self):
        db.add_capability(self.conn, "Java")
        self.assertEqual([r["name"] for r in db.list_capabilities(self.conn)], ["Java"])

    def test_alta_de_capacidad_duplicada_informa(self):
        db.add_capability(self.conn, "Java")
        with self.assertRaises(ValueError):
            db.add_capability(self.conn, "Java")

    def test_listado_del_catalogo(self):
        db.add_capability(self.conn, "Java")
        db.add_capability(self.conn, "Liderazgo")
        names = [r["name"] for r in db.list_capabilities(self.conn)]
        self.assertEqual(names, ["Java", "Liderazgo"])

    def test_baja_capacidad_borra_asignaciones(self):
        emp = db.add_employee(self.conn, "Ana")
        cap = db.add_capability(self.conn, "Java")
        db.assign_capability(self.conn, emp, cap, 4)
        db.delete_capability(self.conn, cap)
        left = self.conn.execute("SELECT COUNT(*) FROM employee_capability").fetchone()[0]
        self.assertEqual(left, 0)

    # --- 4 empleados y asignación ---------------------------------------
    def test_alta_empleado_sin_capacidades(self):
        emp = db.add_employee(self.conn, "Ana")
        self.assertEqual(db.employee_capabilities(self.conn, emp), [])

    def test_listado_de_empleados(self):
        db.add_employee(self.conn, "Ana")
        db.add_employee(self.conn, "Luis")
        self.assertEqual([r["name"] for r in db.list_employees(self.conn)], ["Ana", "Luis"])

    def test_asignacion_capacidad_con_nivel_valido(self):
        emp = db.add_employee(self.conn, "Ana")
        cap = db.add_capability(self.conn, "Java")
        db.assign_capability(self.conn, emp, cap, 5)
        caps = db.employee_capabilities(self.conn, emp)
        self.assertEqual([(c["capability_name"], c["level"]) for c in caps], [("Java", 5)])

    def test_empleado_con_multiples_capacidades(self):
        emp = db.add_employee(self.conn, "Ana")
        for name, lvl in [("a", 1), ("b", 2), ("c", 3), ("d", 4), ("e", 5), ("f", 5)]:
            db.assign_capability(self.conn, emp, db.add_capability(self.conn, name), lvl)
        self.assertEqual(len(db.employee_capabilities(self.conn, emp)), 6)

    def test_capacidad_repetida_rechazada(self):
        emp = db.add_employee(self.conn, "Ana")
        cap = db.add_capability(self.conn, "Java")
        db.assign_capability(self.conn, emp, cap, 3)
        with self.assertRaises(ValueError):
            db.assign_capability(self.conn, emp, cap, 4)

    def test_nivel_fuera_de_rango_rechazado(self):
        emp = db.add_employee(self.conn, "Ana")
        cap = db.add_capability(self.conn, "Java")
        for bad in (0, 6):
            with self.assertRaises(ValueError):
                db.assign_capability(self.conn, emp, cap, bad)

    # --- 5 búsqueda ------------------------------------------------------
    def _fixture(self):
        java = db.add_capability(self.conn, "Java")
        ana = db.add_employee(self.conn, "Ana")
        luis = db.add_employee(self.conn, "Luis")
        db.assign_capability(self.conn, ana, java, 5)
        db.assign_capability(self.conn, luis, java, 3)
        return java, ana, luis

    def test_busqueda_sin_nivel_minimo(self):
        java, _, _ = self._fixture()
        results = db.search(self.conn, java)
        self.assertEqual([(r["name"], r["level"]) for r in results], [("Ana", 5), ("Luis", 3)])

    def test_busqueda_con_nivel_minimo(self):
        java, _, _ = self._fixture()
        results = db.search(self.conn, java, 4)
        self.assertEqual([(r["name"], r["level"]) for r in results], [("Ana", 5)])

    def test_capacidad_sin_empleados_devuelve_vacio(self):
        cap = db.add_capability(self.conn, "Rust")
        self.assertEqual(db.search(self.conn, cap), [])

    def test_capacidad_fuera_del_catalogo_da_error(self):
        with self.assertRaises(ValueError):
            db.search(self.conn, 9999)

    def test_ningun_empleado_alcanza_el_minimo(self):
        java, _, _ = self._fixture()
        over_max_level = 6
        self.assertEqual(db.search(self.conn, java, over_max_level), [])


if __name__ == "__main__":
    unittest.main()
