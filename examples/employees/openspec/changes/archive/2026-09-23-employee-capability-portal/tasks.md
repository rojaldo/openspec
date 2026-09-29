# Tasks

## 1. Setup del proyecto

- [x] 1.1 Crear la estructura de la app (punto de entrada, plantillas, módulo de base de datos) y verificar que arranca el servidor y responde en la ruta raíz
- [x] 1.2 Declarar las dependencias de runtime (servidor web + driver de SQLite si aplica) y verificar que la instalación se completa y el servidor arranca sin errores

## 2. Modelo de datos e invariantes

- [x] 2.1 Crear el esquema SQL con las tablas `capability` (`name` UNIQUE), `employee` (`name` NOT NULL) y `employee_capability` (PK compuesta `employee_id, capability_id`, `CHECK(level BETWEEN 1 AND 5)`, FKs) y verificar que la base se crea con las tres tablas y sus índices
- [x] 2.2 Añadir la inicialización automática del esquema si el fichero de datos no existe y verificar que el arranque en limpio crea el esquema sin pasos manuales
- [x] 2.3 Escribir un chequeo de invariantes en base de datos que confirme que insertar un nivel 0 o 6, un nombre de capacidad duplicado y una capacidad repetida para el mismo empleado son rechazados por el esquema, y verificar que las tres operaciones fallan

## 3. Gestión del catálogo de capacidades

- [x] 3.1 Implementar el alta de capacidad con detección de nombre duplicado y verificar el escenario "Alta de una capacidad nueva" y "Alta de una capacidad duplicada" del spec (el duplicado devuelve error informado)
- [x] 3.2 Implementar el listado de capacidades y verificar el escenario "Listado del catálogo"
- [x] 3.3 Implementar la baja de capacidad con borrado en cascada de sus asignaciones y verificar que tras la baja no quedan filas en `employee_capability` apuntando a la capacidad eliminada

## 4. Registro y ficha de empleados

- [x] 4.1 Implementar el alta de empleado (nombre obligatorio) y verificar el escenario "Alta de empleado sin capacidades" (la ficha queda con cero capacidades)
- [x] 4.2 Implementar el listado de empleados y verificar el escenario "Listado de empleados"
- [x] 4.3 Implementar la asignación de una capacidad con nivel a un empleado y verificar el escenario "Asignación de una capacidad con nivel válido"
- [x] 4.4 Verificar el escenario "Empleado con múltiples capacidades": asignar varias capacidades distintas al mismo empleado y comprobar que todas persisten con su nivel, sin límite de número
- [x] 4.5 Verificar que la asignación de una capacidad ya asignada y de un nivel fuera de 1-5 es rechazada con mensaje, cubriendo los escenarios "Capacidad repetida para el mismo empleado" y "Nivel fuera de rango"

## 5. Búsqueda de empleados

- [x] 5.1 Implementar la búsqueda por capacidad sin nivel mínimo (JOIN sin predicado de nivel) y verificar el escenario "Búsqueda sin nivel mínimo" (devuelve todos los niveles)
- [x] 5.2 Añadir el umbral opcional de nivel mínimo (`level >= :min`) y verificar el escenario "Búsqueda con nivel mínimo" (excluye a quien no alcanza el mínimo)
- [x] 5.3 Verificar el escenario "Capacidad sin empleados": una capacidad válida sin asignaciones devuelve resultado vacío sin error
- [x] 5.4 Verificar el escenario "Capacidad fuera del catálogo": buscar un id/valor inexistente devuelve error informado, distinto de "resultado vacío"
- [x] 5.5 Verificar el escenario "Ningún empleado alcanza el nivel mínimo": capacidad con empleados pero con un mínimo superior a todos devuelve resultado vacío sin error

## 6. Interfaz

- [x] 6.1 Construir la pantalla de catálogo (listar, alta, baja) y verificar de forma observable que las tres operaciones se reflejan en la lista
- [x] 6.2 Construir la pantalla de empleados (listar, alta) y verificar que un empleado nuevo aparece en la lista
- [x] 6.3 Construir la ficha de empleado con asignación de capacidad + nivel y verificar que las capacidades asignadas se muestran con su nivel
- [x] 6.4 Construir la pantalla de búsqueda (selector de capacidad, campo opcional de nivel mínimo, resultados) y verificar de forma interactiva que sin nivel devuelve todos y con nivel filtra por el mínimo

## 7. Verificación final

- [x] 7.1 Ejecutar una prueba de extremo a extremo por la interfaz que recorra alta de capacidad, alta de empleado, dos asignaciones con niveles distintos, y búsqueda con y sin umbral, verificando que los resultados coinciden con los escenarios del spec
