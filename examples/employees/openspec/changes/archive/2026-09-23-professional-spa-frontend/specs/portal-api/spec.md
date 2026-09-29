# Spec Delta

## Purpose

Exponer por HTTP en formato JSON los datos y operaciones del portal de empleados (catálogo de capacidades, empleados, asignación con nivel y búsqueda) para que un cliente SPA pueda consultarlos y modificarlos, con validación y errores definidos.

## ADDED Requirements

### Requirement: Listado del catálogo de capacidades por API

El sistema SHALL exponer un endpoint de lectura que devuelva en JSON todas las capacidades del catálogo, cada una con un identificador y un nombre. La respuesta SHALL poder consumirse sin estado de sesión.

#### Scenario: Listado con capacidades

- **WHEN** un cliente solicita el listado de capacidades y el catálogo tiene entradas
- **THEN** el sistema responde con éxito y un arreglo JSON de capacidades, cada una con identificador y nombre

#### Scenario: Listado con catálogo vacío

- **WHEN** un cliente solicita el listado de capacidades y el catálogo no tiene entradas
- **THEN** el sistema responde con éxito y un arreglo JSON vacío, sin error

### Requirement: Alta de capacidad por API

El sistema SHALL exponer un endpoint que cree una capacidad a partir de un nombre recibido en el cuerpo de la petición. El sistema SHALL rechazar un nombre vacío y un nombre ya existente en el catálogo, informando del motivo.

#### Scenario: Alta correcta

- **WHEN** un cliente envía un nombre de capacidad que no existe en el catálogo
- **THEN** el sistema crea la capacidad y responde con éxito devolviendo la capacidad creada con su identificador

#### Scenario: Nombre duplicado

- **WHEN** un cliente envía un nombre de capacidad que ya existe en el catálogo
- **THEN** el sistema rechaza la petición con un error que indica que la capacidad ya existe, y el catálogo no cambia

#### Scenario: Nombre vacío o ausente

- **WHEN** un cliente envía una petición de alta sin nombre o con un nombre vacío
- **THEN** el sistema rechaza la petición con un error de validación y no crea ninguna capacidad

### Requirement: Baja de capacidad por API

El sistema SHALL exponer un endpoint que elimine una capacidad del catálogo. Al eliminarla, el sistema SHALL eliminar también sus asignaciones existentes a empleados.

#### Scenario: Baja correcta

- **WHEN** un cliente solicita eliminar una capacidad existente
- **THEN** el sistema elimina la capacidad y responde con éxito

#### Scenario: Baja elimina asignaciones

- **WHEN** se elimina una capacidad que estaba asignada a uno o varios empleados
- **THEN** el sistema deja de devolver esas asignaciones para esos empleados y ninguna asignación apunta a la capacidad eliminada

#### Scenario: Baja de capacidad inexistente

- **WHEN** un cliente solicita eliminar una capacidad que no existe
- **THEN** el sistema rechaza la petición con un error que indica que la capacidad no existe

### Requirement: Listado y ficha de empleados por API

El sistema SHALL exponer un endpoint que devuelva en JSON el listado de empleados y un endpoint que devuelva la ficha de un empleado concreto, incluyendo sus capacidades asignadas con el nivel de cada una.

#### Scenario: Listado de empleados

- **WHEN** un cliente solicita el listado de empleados
- **THEN** el sistema responde con éxito y un arreglo JSON de empleados con su identificador y nombre

#### Scenario: Ficha de empleado con sus capacidades

- **WHEN** un cliente solicita la ficha de un empleado que tiene capacidades asignadas
- **THEN** el sistema responde con éxito y devuelve el empleado junto con la lista de sus capacidades, cada una con nombre y nivel

#### Scenario: Ficha de empleado sin capacidades

- **WHEN** un cliente solicita la ficha de un empleado sin capacidades asignadas
- **THEN** el sistema responde con éxito y devuelve el empleado con una lista vacía de capacidades

#### Scenario: Ficha de empleado inexistente

- **WHEN** un cliente solicita la ficha de un empleado que no existe
- **THEN** el sistema responde con un error que indica que el empleado no existe

### Requirement: Alta de empleado por API

El sistema SHALL exponer un endpoint que cree un empleado a partir de un nombre recibido en el cuerpo de la petición, y SHALL rechazar un nombre vacío o ausente con un error de validación.

#### Scenario: Alta correcta

- **WHEN** un cliente envía un nombre de empleado válido
- **THEN** el sistema crea el empleado y responde con éxito devolviendo el empleado creado con su identificador y cero capacidades

#### Scenario: Nombre vacío o ausente

- **WHEN** un cliente envía una petición de alta sin nombre o con un nombre vacío
- **THEN** el sistema rechaza la petición con un error de validación y no crea ningún empleado

### Requirement: Asignación de capacidad con nivel por API

El sistema SHALL exponer un endpoint que asigne a un empleado una capacidad del catálogo con un nivel entero entre 1 y 5. El sistema SHALL rechazar un nivel fuera de rango, un empleado inexistente, una capacidad inexistente y una capacidad ya asignada a ese empleado, informando del motivo en cada caso.

#### Scenario: Asignación correcta

- **WHEN** un cliente asigna a un empleado existente una capacidad existente con un nivel entre 1 y 5
- **THEN** el sistema registra la asignación y responde con éxito

#### Scenario: Nivel fuera de rango

- **WHEN** un cliente intenta asignar un nivel menor que 1 o mayor que 5
- **THEN** el sistema rechaza la petición con un error que indica que el nivel debe estar entre 1 y 5 y no registra ninguna asignación

#### Scenario: Empleado o capacidad inexistente

- **WHEN** un cliente intenta asignar una capacidad a un empleado que no existe, o una capacidad que no existe
- **THEN** el sistema rechaza la petición con un error que indica cuál de los dos identificadores no existe

#### Scenario: Capacidad ya asignada

- **WHEN** un cliente intenta asignar a un empleado una capacidad que ese empleado ya tiene
- **THEN** el sistema rechaza la petición con un error que indica que el empleado ya tiene esa capacidad

### Requirement: Búsqueda por API con nivel mínimo opcional

El sistema SHALL exponer un endpoint de búsqueda que reciba una capacidad y, opcionalmente, un nivel mínimo, y devuelva los empleados que cumplen el criterio. Sin nivel mínimo SHALL devolver los empleados de cualquier nivel con esa capacidad; con nivel mínimo SHALL devolver solo los que alcanzan ese nivel o más. Si la capacidad no existe en el catálogo, el sistema SHALL responder con un error diferenciado de un resultado vacío.

#### Scenario: Búsqueda sin nivel mínimo

- **WHEN** un cliente busca por una capacidad existente sin indicar nivel mínimo
- **THEN** el sistema responde con éxito y devuelve todos los empleados que tienen esa capacidad, con el nivel de cada uno

#### Scenario: Búsqueda con nivel mínimo

- **WHEN** un cliente busca por una capacidad existente indicando un nivel mínimo
- **THEN** el sistema devuelve solo los empleados cuyo nivel en esa capacidad es igual o superior al mínimo

#### Scenario: Búsqueda sin coincidencias

- **WHEN** un cliente busca por una capacidad existente que ningún empleado tiene, o con un nivel mínimo que ninguno alcanza
- **THEN** el sistema responde con éxito y un arreglo JSON vacío, sin error

#### Scenario: Búsqueda de capacidad inexistente

- **WHEN** un cliente busca por una capacidad que no existe en el catálogo
- **THEN** el sistema responde con un error que indica que la capacidad no existe, distinto de una respuesta vacía

#### Scenario: Nivel mínimo no numérico

- **WHEN** un cliente busca indicando un nivel mínimo que no es un número entero
- **THEN** el sistema rechaza la petición con un error de validación

### Requirement: Entrega del cliente SPA desde un único despliegue

El sistema SHALL servir el build estático del cliente SPA y SHALL responder con el documento principal del SPA a las rutas del router que no correspondan a un fichero estático de la API, para que las rutas profundas del cliente sean accesibles y recargables.

#### Scenario: Raíz sirve la aplicación

- **WHEN** un cliente solicita la ruta raíz
- **THEN** el sistema responde con el documento principal del SPA

#### Scenario: Ruta profunda del router

- **WHEN** un cliente solicita directamente una ruta gestionada por el router del SPA que no corresponde a la API ni a un fichero estático
- **THEN** el sistema responde con el documento principal del SPA en lugar de un error, de modo que el cliente pueda resolver la ruta

#### Scenario: Separación de la API

- **WHEN** un cliente solicita una ruta de la API
- **THEN** el sistema responde con datos JSON y no con el documento del SPA
