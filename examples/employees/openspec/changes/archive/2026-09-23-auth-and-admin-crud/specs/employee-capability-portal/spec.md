# Spec Delta

## ADDED Requirements

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
