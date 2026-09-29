# Spec Delta

## MODIFIED Requirements

### Requirement: Listado del catálogo de capacidades por API

El sistema SHALL exponer un endpoint de lectura que devuelva en JSON todas las capacidades del catálogo, cada una con un identificador y un nombre. La respuesta SHALL requerir una sesión autenticada válida.

#### Scenario: Listado con capacidades

- **WHEN** un cliente con sesión válida solicita el listado de capacidades y el catálogo tiene entradas
- **THEN** el sistema responde con éxito y un arreglo JSON de capacidades, cada una con identificador y nombre

#### Scenario: Listado con catálogo vacío

- **WHEN** un cliente con sesión válida solicita el listado de capacidades y el catálogo no tiene entradas
- **THEN** el sistema responde con éxito y un arreglo JSON vacío, sin error

#### Scenario: Listado sin sesión

- **WHEN** un cliente sin sesión válida solicita el listado de capacidades
- **THEN** el sistema rechaza la petición indicando que se requiere autenticación y no devuelve datos del catálogo

## ADDED Requirements

### Requirement: Edición de capacidad por API

El sistema SHALL exponer un endpoint que cambie el nombre de una capacidad existente. El sistema SHALL rechazar un nombre vacío, un nombre ya usado por otra capacidad y una capacidad inexistente, informando del motivo en cada caso.

#### Scenario: Renombrado correcto

- **WHEN** un cliente cambia el nombre de una capacidad existente por uno que no usa ninguna otra
- **THEN** el sistema actualiza la capacidad, devuelve la capacidad con su identificador y el nuevo nombre, y el catálogo refleja el cambio

#### Scenario: Nombre duplicado al renombrar

- **WHEN** un cliente intenta renombrar una capacidad a un nombre que ya usa otra capacidad
- **THEN** el sistema rechaza la petición indicando que ese nombre ya existe y la capacidad conserva su nombre anterior

#### Scenario: Renombrado de capacidad inexistente

- **WHEN** un cliente intenta renombrar una capacidad que no existe
- **THEN** el sistema rechaza la petición indicando que la capacidad no existe

#### Scenario: Renombrado con nombre vacío

- **WHEN** un cliente envía un renombrado sin nombre o con un nombre vacío
- **THEN** el sistema rechaza la petición con un error de validación y la capacidad no cambia

### Requirement: Edición de empleado por API

El sistema SHALL exponer un endpoint que cambie el nombre de un empleado existente. El sistema SHALL rechazar un nombre vacío y un empleado inexistente. La edición SHALL conservar las capacidades asignadas al empleado.

#### Scenario: Edición correcta

- **WHEN** un cliente cambia el nombre de un empleado existente por un nombre válido
- **THEN** el sistema actualiza el empleado, devuelve el empleado con su identificador y el nuevo nombre, y sus capacidades asignadas se conservan

#### Scenario: Edición de empleado inexistente

- **WHEN** un cliente intenta editar un empleado que no existe
- **THEN** el sistema rechaza la petición indicando que el empleado no existe

#### Scenario: Edición con nombre vacío

- **WHEN** un cliente envía una edición sin nombre o con un nombre vacío
- **THEN** el sistema rechaza la petición con un error de validación y el empleado no cambia

### Requirement: Baja de empleado por API

El sistema SHALL exponer un endpoint que elimine un empleado. Al eliminarlo, el sistema SHALL eliminar también sus asignaciones de capacidades. El sistema SHALL rechazar la baja de un empleado inexistente.

#### Scenario: Baja correcta

- **WHEN** un cliente solicita eliminar un empleado existente
- **THEN** el sistema elimina el empleado y responde con éxito, y el empleado deja de aparecer en el listado

#### Scenario: Baja elimina sus asignaciones

- **WHEN** se elimina un empleado que tenía capacidades asignadas
- **THEN** el sistema deja de devolver esas asignaciones y ninguna asignación apunta al empleado eliminado

#### Scenario: Baja de empleado inexistente

- **WHEN** un cliente solicita eliminar un empleado que no existe
- **THEN** el sistema rechaza la petición indicando que el empleado no existe

### Requirement: Corrección del nivel de una capacidad asignada por API

El sistema SHALL exponer un endpoint que cambie el nivel de una capacidad ya asignada a un empleado. El sistema SHALL rechazar un nivel fuera del rango 1 a 5, un empleado inexistente y una capacidad no asignada a ese empleado, informando del motivo en cada caso.

#### Scenario: Corrección correcta

- **WHEN** un cliente cambia el nivel de una capacidad ya asignada a un empleado por otro nivel entre 1 y 5
- **THEN** el sistema actualiza el nivel y la ficha del empleado refleja el nuevo nivel

#### Scenario: Nivel fuera de rango al corregir

- **WHEN** un cliente intenta corregir el nivel a un valor menor que 1 o mayor que 5
- **THEN** el sistema rechaza la petición indicando que el nivel debe estar entre 1 y 5 y la asignación conserva su nivel anterior

#### Scenario: Capacidad no asignada al empleado

- **WHEN** un cliente intenta corregir el nivel de una capacidad que ese empleado no tiene asignada
- **THEN** el sistema rechaza la petición indicando que esa asignación no existe

### Requirement: Desasignación de una capacidad por API

El sistema SHALL exponer un endpoint que quite a un empleado una capacidad que tenía asignada. El sistema SHALL rechazar la operación cuando el empleado no existe o cuando la capacidad no está asignada a ese empleado.

#### Scenario: Desasignación correcta

- **WHEN** un cliente quita a un empleado una capacidad que tenía asignada
- **THEN** el sistema elimina la asignación y la ficha del empleado deja de mostrar esa capacidad

#### Scenario: Desasignación de una capacidad no asignada

- **WHEN** un cliente intenta quitar a un empleado una capacidad que no tiene asignada
- **THEN** el sistema rechaza la petición indicando que esa asignación no existe

#### Scenario: Desasignación con empleado inexistente

- **WHEN** un cliente intenta quitar una capacidad a un empleado que no existe
- **THEN** el sistema rechaza la petición indicando que el empleado no existe

### Requirement: Respuesta JSON ante rutas y errores de la API

El sistema SHALL responder en formato JSON a toda ruta bajo el prefijo de la API, incluidos los errores de enrutado. Una ruta de la API inexistente SHALL devolver una respuesta JSON de error y no el documento del cliente SPA.

#### Scenario: Ruta de API inexistente

- **WHEN** un cliente solicita una ruta bajo el prefijo de la API que no corresponde a ninguna operación
- **THEN** el sistema responde con un error en formato JSON y no con el documento del cliente SPA

#### Scenario: Recurso inexistente en la API

- **WHEN** un cliente solicita una operación sobre un recurso que no existe
- **THEN** el sistema responde con un error en formato JSON con el motivo
