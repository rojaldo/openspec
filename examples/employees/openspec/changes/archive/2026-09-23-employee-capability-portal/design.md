# Design

## Context

Proyecto greenfield: no hay código previo, ni dependencias declaradas, ni stack fijado (el `openspec/config.yaml` no define `context`). El cambio añade un data model nuevo y una interfaz, así que el diseño sí aplica. Ver `proposal.md` para la motivación y `specs/employee-capability-portal/spec.md` para los requisitos; este documento decide el *cómo*.

Restricciones que condicionan el diseño:

- Un único operador (el dueño del portal), sin autenticación ni roles. No hay concurrencia de escritura relevante ni multi-tenant.
- Catálogo de capacidades cerrado: no hay ingesta desde fuentes externas.
- La búsqueda es siempre por una sola capacidad con umbral opcional: una única consulta parametrizable, sin motor de matching.
- Sin entidad "proyecto" ni integraciones: el alcance es persistencia + interfaz.

## Goals / Non-Goals

**Goals:**

- Persistir capacidades, empleados y la relación (empleado, capacidad, nivel) con las invariantes del spec garantizadas por el propio almacén.
- Exponer tres operaciones de gestión (catálogo, empleados, asignación) y una de búsqueda.
- Mantener el despliegue en un solo proceso y un solo fichero de datos, sin servicios externos que operar.

**Non-Goals:**

- Multi-usuario, autenticación, permisos o auditoría de quién evalúa.
- Búsqueda por varias capacidades (AND/OR), ranking o matching contra proyectos.
- Historial de evaluaciones o versionado de niveles.
- Campos de empleado más allá de lo básico (nombre como mínimo).

## Decisions

### 1. Stack: aplicación web mínima con SQLite

Un único proceso que sirve HTML y persiste en un fichero SQLite local. Se usa **Python 3 + Flask + SQLite** (sin ORM: SQL directo), por ser el camino más corto a algo ejecutable y por encajar en un repo de ejemplos.

*Por qué no alternativas:* un framework con ORM (Django, Rails) añade capas que este modelo de tres tablas no necesita; un frontend SPA separado introduce un segundo despliegue y una API para un solo operador, que es más superficie sin beneficio. Flask se eligió sobre la librería estándar (`http.server`) porque el enrutado, las plantillas y el manejo de formularios ya vienen resueltos y no aportan superficie adicional relevante.

*Entorno de ejecución:* el proyecto se ejecuta dentro de un **entorno virtual gestionado por `uv`** (`.venv/`, Python 3.12), declarado en `pyproject.toml` y fijado en `uv.lock`. Esto evita el `pip` del sistema (bloqueado por PEP 668) y hace la instalación reproducible con un solo `uv sync`. Las dependencias se declaran en `pyproject.toml`; `requirements.txt` ya no existe porque sería una segunda fuente de verdad contradictoria. Comandos: `uv sync` para instalar y `uv run app.py` para arrancar.

### 2. Modelo de datos relacional con invariantes en el esquema

```
capability
  id          INTEGER PRIMARY KEY
  name        TEXT NOT NULL UNIQUE          -- nombre único del catálogo

employee
  id          INTEGER PRIMARY KEY
  name        TEXT NOT NULL                 -- mínimo viable; ampliable después

employee_capability
  employee_id INTEGER NOT NULL REFERENCES employee(id)
  capability_id INTEGER NOT NULL REFERENCES capability(id)
  level       INTEGER NOT NULL CHECK (level BETWEEN 1 AND 5)
  PRIMARY KEY (employee_id, capability_id)  -- impide duplicar capacidad
```

Las tres reglas del spec se garantizan en el almacén, no solo en la interfaz:

| Regla del spec | Mecanismo |
|---|---|
| Nombre de capacidad único | `UNIQUE(name)` |
| Capacidad no repetible por empleado | `PRIMARY KEY(employee_id, capability_id)` |
| Nivel entero 1-5 | `CHECK(level BETWEEN 1 AND 5)` |
| Empleado con 0 capacidades | Ausencia de filas en `employee_capability` (sin obligación de insertar) |

*Alternativas consideradas:* guardar las capacidades en un campo JSON del empleado (rompe la unicidad y el rango, y complica la búsqueda por índice) o un nivel por capacidad como texto libre (permite "alto"/"4" mezclados). El esquema relacional hace imposibles por construcción los cuatro casos de error que el spec exige rechazar.

### 3. Búsqueda como una sola consulta parametrizable

La búsqueda es un `JOIN` de `employee_capability` contra `employee`, filtrando por `capability_id` y, opcionalmente, por `level >= :min`. El caso "cualquier nivel" es simplemente no añadir el predicado de nivel, no una consulta distinta.

```sql
SELECT e.id, e.name, ec.level
FROM employee e
JOIN employee_capability ec ON ec.employee_id = e.id
WHERE ec.capability_id = :capability_id
  -- se añade solo si el nivel mínimo está presente:
  AND ec.level >= :min_level
ORDER BY ec.level DESC;
```

El error "capacidad fuera del catálogo" se detecta antes de la consulta (comprobar que el `capability_id` existe) para distinguir "capacidad inexistente" de "capacidad sin empleados", que el spec trata como casos distintos.

### 4. Interfaz: cuatro pantallas, sin estado de sesión

- Catálogo: listar, alta y baja de capacidades.
- Empleados: listar y alta.
- Ficha de empleado: asignar capacidad + nivel, y ver las asignadas.
- Buscador: selector de capacidad + campo de nivel mínimo opcional + resultados.

Sin sesión ni login: al ser un operador único no hay estado de usuario que conservar.

## Risks / Trade-offs

- **[Stack asumido y no confirmado]** → El lenguaje (Python/Flask) es un supuesto, no una decisión del usuario. Mitigación: el modelo, las invariantes y la forma de las tareas son independientes del lenguaje; cambiarlo afecta a la capa de servidor, no al diseño de datos ni a los escenarios del spec.
- **[Dependencia de `uv` en el flujo de trabajo]** → El proyecto requiere el binario `uv` para crear el venv y sincronizar dependencias. Mitigación: `pyproject.toml` y `uv.lock` son estándar; sin `uv` pueden usarse con `python -m venv .venv && pip install -e .` dentro del venv, así que no hay lock-in real.
- **[SQLite y concurrencia]** → SQLite serializa escrituras. Con un único operador es irrelevante; si en el futuro hay varios evaluadores, habría que revisar el motor o añadir control de concurrencia. Mitigación diferida: no se aborda ahora porque el spec fija un operador único.
- **[Baja de capacidad con asignaciones existentes]** → Eliminar una capacidad del catálogo deja huérfanas sus filas en `employee_capability`. Mitigación: al dar de baja una capacidad, borrar también sus asignaciones (baja en cascada) para que ninguna fila apunte a una capacidad inexistente. El spec no obliga a preservar el histórico.
- **[Crecimiento del catálogo y de empleados]** → A la escala esperada (decenas/cientos) los `JOIN` por índice son inmediatos; no se optimiza por adelantado.

## Open Questions

- Nombre y lenguaje exactos del stack quedan abiertos y no cambian los escenarios del spec. Se asume Python/Flask; cualquier alternativa que sirva HTML y use un almacén relacional encaja sin tocar requisitos ni el desglose de tareas. (Implementado con Flask dentro de un venv `uv`; ver Decisión 1.)
- Campos adicionales de empleado (email, puesto, alta/baja) se difieren: el spec solo exige un nombre como mínimo, y añadir columnas no altera el modelo de capacidades.
