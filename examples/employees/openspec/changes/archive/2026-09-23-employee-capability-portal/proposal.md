# Proposal

## Why

Hoy no existe una forma centralizada de saber qué empleados tienen cada competencia ni con qué nivel. Cuando aparece un proyecto que necesita a alguien con una capacidad concreta (ej. "Java nivel 4 o superior"), la búsqueda se hace de memoria o en hojas sueltas. Un portal único con el catálogo de capacidades, el nivel de cada empleado y un buscador resuelve eso.

## What Changes

- Nuevo **catálogo cerrado de capacidades** gestionado por el administrador del portal (alta, listado, baja). Cada capacidad tiene un nombre único.
- Nuevo **registro de empleados** con sus datos básicos.
- Nueva **asignación de capacidades a empleados** con un **nivel de 1 a 5** por capacidad. Un empleado puede tener 0, 1 o cualquier número de capacidades, sin límite. Una misma capacidad no puede repetirse para el mismo empleado.
- Nuevo **buscador** que filtra empleados por una capacidad (obligatoria) y un **nivel mínimo opcional**: sin nivel devuelve empleados de cualquier nivel; con nivel devuelve solo los que alcanzan ese mínimo o más. Una sola capacidad por búsqueda.
- Sin autenticación ni roles: un único operador (el dueño del portal) gestiona todo.
- Sin entidad "proyecto": el portal solo responde a la búsqueda; el uso posterior de los resultados queda fuera del portal.

## Capabilities

### New Capabilities
- `employee-capability-portal`: catálogo de capacidades, ficha de empleados con niveles 1-5 por capacidad, y búsqueda de empleados por capacidad con umbral de nivel opcional.

### Modified Capabilities
<!-- Ninguna: el proyecto no tiene specs previas. -->

## Impact

- Proyecto nuevo sin código ni especificaciones previas: no hay impacto de compatibilidad.
- Introduce almacenamiento persistente para capacidades, empleados y la relación empleado-capacidad con nivel.
- Sin dependencias externas ni integraciones: alcance limitado al portal y su interfaz.
- Fuera de alcance (decidido): multi-capacidad en la búsqueda, entidad proyecto con requisitos, login/evaluadores múltiples, historial de evaluaciones, campos extra de la ficha más allá de lo básico.
