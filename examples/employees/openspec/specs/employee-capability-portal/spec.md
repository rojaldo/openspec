# employee-capability-portal Specification

## Purpose

Permitir a un operador único mantener un catálogo cerrado de capacidades, registrar empleados con un nivel de dominio de 1 a 5 por capacidad, y encontrar empleados por capacidad con un umbral de nivel mínimo opcional.

## Requirements

### Requirement: Gestión del catálogo de capacidades

El sistema SHALL permitir al administrador del portal dar de alta, listar y eliminar capacidades de un catálogo cerrado. Cada capacidad SHALL tener un nombre único, y el sistema SHALL rechazar el alta de una capacidad con un nombre ya existente en el catálogo.

#### Scenario: Alta de una capacidad nueva

- **WHEN** el administrador crea una capacidad con un nombre que no existe en el catálogo
- **THEN** el sistema añade la capacidad al catálogo y la deja disponible para asignarla a empleados y para buscarla

#### Scenario: Alta de una capacidad duplicada

- **WHEN** el administrador intenta crear una capacidad con un nombre ya existente en el catálogo
- **THEN** el sistema rechaza la operación e informa de que la capacidad ya existe

#### Scenario: Listado del catálogo

- **WHEN** el administrador solicita el listado de capacidades
- **THEN** el sistema devuelve todas las capacidades registradas en el catálogo

### Requirement: Registro de empleados

El sistema SHALL permitir al administrador dar de alta y listar empleados, cada uno con sus datos básicos de identificación (al menos un nombre). Un empleado SHALL poder existir sin ninguna capacidad asignada.

#### Scenario: Alta de empleado sin capacidades

- **WHEN** el administrador registra un empleado con sus datos básicos
- **THEN** el sistema crea la ficha del empleado, que queda con cero capacidades asignadas

#### Scenario: Listado de empleados

- **WHEN** el administrador solicita el listado de empleados
- **THEN** el sistema devuelve todos los empleados registrados

### Requirement: Asignación de capacidades con nivel a un empleado

El sistema SHALL permitir al administrador asignar a un empleado una o varias capacidades del catálogo, cada una con un nivel de dominio entero entre 1 y 5 inclusive. Un empleado SHALL poder tener cualquier número de capacidades, sin límite superior. El sistema SHALL impedir que la misma capacidad se asigne dos veces al mismo empleado y SHALL rechazar niveles fuera del rango 1 a 5.

#### Scenario: Asignación de una capacidad con nivel válido

- **WHEN** el administrador asigna a un empleado una capacidad del catálogo con un nivel entre 1 y 5
- **THEN** el sistema registra esa capacidad y nivel en la ficha del empleado

#### Scenario: Empleado con múltiples capacidades

- **WHEN** el administrador asigna sucesivamente varias capacidades distintas al mismo empleado
- **THEN** el sistema conserva todas ellas con sus respectivos niveles, sin límite en el número de capacidades

#### Scenario: Capacidad repetida para el mismo empleado

- **WHEN** el administrador intenta asignar a un empleado una capacidad que ese empleado ya tiene
- **THEN** el sistema rechaza la operación e informa de que la capacidad ya está asignada a ese empleado

#### Scenario: Nivel fuera de rango

- **WHEN** el administrador intenta asignar a un empleado una capacidad con un nivel menor que 1 o mayor que 5
- **THEN** el sistema rechaza la operación e informa de que el nivel debe estar entre 1 y 5

### Requirement: Búsqueda de empleados por capacidad

El sistema SHALL permitir buscar empleados indicando una capacidad del catálogo. Sin nivel mínimo, la búsqueda SHALL devolver todos los empleados que tengan esa capacidad, cualquiera que sea su nivel. La búsqueda SHALL operar sobre una única capacidad por consulta.

#### Scenario: Búsqueda sin nivel mínimo

- **WHEN** el administrador busca por una capacidad sin indicar nivel mínimo
- **THEN** el sistema devuelve todos los empleados que tienen asignada esa capacidad, sea cual sea el nivel de cada uno

#### Scenario: Capacidad sin empleados

- **WHEN** el administrador busca por una capacidad que ningún empleado tiene asignada
- **THEN** el sistema devuelve un resultado vacío sin error

#### Scenario: Capacidad fuera del catálogo

- **WHEN** el administrador busca por una capacidad que no existe en el catálogo
- **THEN** el sistema rechaza la búsqueda e informa de que la capacidad no existe

### Requirement: Búsqueda de empleados por capacidad con nivel mínimo

El sistema SHALL permitir buscar empleados indicando una capacidad del catálogo y un nivel mínimo. La búsqueda SHALL devolver únicamente los empleados que tengan asignada esa capacidad con un nivel mayor o igual al mínimo indicado.

#### Scenario: Búsqueda con nivel mínimo

- **WHEN** el administrador busca por una capacidad con un nivel mínimo indicado
- **THEN** el sistema devuelve solo los empleados que tienen esa capacidad con un nivel igual o superior al mínimo

#### Scenario: Ningún empleado alcanza el nivel mínimo

- **WHEN** el administrador busca por una capacidad con un nivel mínimo que ningún empleado alcanza
- **THEN** el sistema devuelve un resultado vacío sin error

### Requirement: Ciclo de vida completo de las entidades

El sistema SHALL permitir al administrador, además de dar de alta y consultar, editar y eliminar tanto capacidades como empleados, y completar el ciclo de vida de las asignaciones corrigiendo el nivel de una capacidad ya asignada y quitando una capacidad asignada.

#### Scenario: Edición de una capacidad

- **WHEN** el administrador edita el nombre de una capacidad existente
- **THEN** el sistema conserva la capacidad con el nombre nuevo y sus asignaciones siguen apuntando a ella

#### Scenario: Baja de un empleado con capacidades

- **WHEN** el administrador elimina un empleado que tenía capacidades asignadas
- **THEN** el sistema elimina al empleado y sus asignaciones, y el empleado deja de aparecer en listados y búsquedas

#### Scenario: Corrección del nivel de una capacidad asignada

- **WHEN** el administrador corrige el nivel de una capacidad ya asignada a un empleado
- **THEN** el sistema conserva una única asignación para esa capacidad con el nivel nuevo

#### Scenario: Desasignación de una capacidad

- **WHEN** el administrador quita a un empleado una capacidad que tenía asignada
- **THEN** el sistema elimina esa asignación y el empleado conserva las demás capacidades

#### Scenario: El empleado conserva sus capacidades al ser editado

- **WHEN** el administrador edita los datos básicos de un empleado que tiene capacidades asignadas
- **THEN** el sistema conserva todas sus capacidades con sus niveles

### Requirement: Las operaciones requieren un administrador autenticado

Toda operación del sistema SHALL realizarse en nombre de un administrador autenticado. El sistema SHALL rechazar cualquier operación solicitada sin una sesión válida, y SHALL rechazar las operaciones reservadas al administrador cuando la sesión pertenezca a un rol que no lo sea.

#### Scenario: Operación sin sesión

- **WHEN** se solicita cualquier operación del sistema sin una sesión válida
- **THEN** el sistema rechaza la operación sin ejecutar efecto alguno sobre los datos

#### Scenario: Operación con rol no autorizado

- **WHEN** la sesión activa pertenece a un rol distinto del administrador y se solicita una operación reservada al administrador
- **THEN** el sistema rechaza la operación sin ejecutar efecto alguno sobre los datos
