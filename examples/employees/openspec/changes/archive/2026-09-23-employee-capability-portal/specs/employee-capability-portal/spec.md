# Spec Delta

## Purpose

Permitir a un operador único mantener un catálogo cerrado de capacidades, registrar empleados con un nivel de dominio de 1 a 5 por capacidad, y encontrar empleados por capacidad con un umbral de nivel mínimo opcional.

## ADDED Requirements

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
