# auth Specification

## Purpose

Controlar el acceso al portal mediante una sesión autenticada: permitir que un usuario acredite su identidad, conocer quién opera, cerrar la sesión, y exigir una sesión válida antes de permitir cualquier operación sobre el sistema.

## Requirements

### Requirement: Acceso mediante credenciales

El sistema SHALL ofrecer un acceso donde un usuario se identifique con un nombre de usuario y una contraseña. Un acceso con credenciales válidas SHALL establecer una sesión; un acceso con credenciales inválidas SHALL rechazarse con un error que no distinga si el fallo fue el usuario o la contraseña, y SHALL no establecer sesión.

#### Scenario: Acceso correcto

- **WHEN** un usuario envía un nombre de usuario y una contraseña que coinciden con un usuario existente
- **THEN** el sistema establece una sesión para ese usuario y responde con su identidad y su rol

#### Scenario: Contraseña incorrecta

- **WHEN** un usuario envía un nombre de usuario existente con una contraseña que no coincide
- **THEN** el sistema rechaza el acceso, no establece sesión y responde con un error que no revela cuál de los dos datos falló

#### Scenario: Usuario inexistente

- **WHEN** un usuario envía un nombre de usuario que no existe
- **THEN** el sistema rechaza el acceso con el mismo error que ante una contraseña incorrecta, sin establecer sesión

#### Scenario: Acceso sin datos

- **WHEN** se envía una petición de acceso sin nombre de usuario o sin contraseña
- **THEN** el sistema rechaza la petición con un error de validación

### Requirement: Sesión exigida en toda operación

El sistema SHALL exigir una sesión válida para toda operación sobre los datos y SHALL rechazar cualquier petición sin sesión antes de ejecutar efecto alguno. La respuesta de rechazo SHALL ser distinguible de un error de validación o de un recurso inexistente.

#### Scenario: Operación sin sesión

- **WHEN** se solicita una operación sobre los datos sin haber establecido sesión
- **THEN** el sistema rechaza la petición indicando que se requiere autenticación y no modifica ningún dato

#### Scenario: Operación con sesión válida

- **WHEN** se solicita una operación sobre los datos con una sesión establecida
- **THEN** el sistema ejecuta la operación con normalidad

#### Scenario: Sesión inválida o manipulada

- **WHEN** se presenta una sesión que el sistema no puede validar
- **THEN** el sistema la trata como ausencia de sesión y rechaza la operación

### Requirement: Identidad del usuario activo

El sistema SHALL permitir consultar la identidad del usuario que tiene la sesión activa, incluyendo su nombre de usuario y su rol, y SHALL rechazar la consulta si no hay sesión.

#### Scenario: Consulta con sesión

- **WHEN** un usuario con sesión activa consulta su identidad
- **THEN** el sistema responde con su nombre de usuario y su rol

#### Scenario: Consulta sin sesión

- **WHEN** se consulta la identidad sin sesión activa
- **THEN** el sistema rechaza la consulta indicando que se requiere autenticación

### Requirement: Cierre de sesión

El sistema SHALL permitir cerrar la sesión activa. Tras el cierre, la sesión anterior SHALL dejar de permitir cualquier operación.

#### Scenario: Cierre correcto

- **WHEN** un usuario con sesión activa solicita cerrar la sesión
- **THEN** el sistema invalida la sesión y las operaciones posteriores que la usaban son rechazadas

### Requirement: Roles de usuario

El sistema SHALL asociar a cada usuario un rol, y SHALL preparar el modelo de usuarios para representar una relación jerárquica entre ellos, de modo que se puedan definir responsables sobre otros usuarios. En este alcance el sistema SHALL implementar únicamente el rol de administrador, y un usuario con ese rol SHALL poder realizar todas las operaciones del portal.

#### Scenario: El administrador opera el portal

- **WHEN** un usuario con rol de administrador, con sesión activa, realiza cualquier operación del portal
- **THEN** el sistema la acepta

#### Scenario: Modelo preparado para jerarquía

- **WHEN** se registra un usuario
- **THEN** el sistema admite que ese usuario referencie a otro usuario como su responsable, sin exigirlo

#### Scenario: Rol fuera del alcance implementado

- **WHEN** un usuario tiene un rol distinto de administrador
- **THEN** el sistema no le concede las operaciones reservadas al administrador

### Requirement: Administrador inicial

El sistema SHALL disponer de un administrador sembrado en el almacén de datos para poder acceder la primera vez, con nombre de usuario `admin` y contraseña `admin`. La siembra SHALL ser idempotente: si el administrador ya existe, el sistema SHALL no alterar su credencial ni su rol.

#### Scenario: Primer arranque siembra el administrador

- **WHEN** el sistema arranca sobre un almacén sin usuarios
- **THEN** existe un usuario `admin` con rol de administrador que permite iniciar sesión con la contraseña `admin`

#### Scenario: Arranque posterior no altera la credencial

- **WHEN** el sistema arranca sobre un almacén donde el administrador ya existe y su contraseña fue cambiada
- **THEN** el sistema no restablece la contraseña ni modifica el rol

#### Scenario: La contraseña no se almacena en claro

- **WHEN** se inspecciona el registro del administrador en el almacén
- **THEN** la contraseña no aparece en claro

### Requirement: Cambio de contraseña del usuario activo

El sistema SHALL permitir al usuario con sesión activa cambiar su propia contraseña, exigiendo la contraseña actual como confirmación, y SHALL rechazar el cambio si la contraseña actual no coincide o si la nueva no cumple la validación.

#### Scenario: Cambio correcto

- **WHEN** un usuario con sesión activa envía su contraseña actual correcta y una nueva contraseña válida
- **THEN** el sistema actualiza la credencial y la nueva contraseña permite iniciar sesión

#### Scenario: Contraseña actual incorrecta

- **WHEN** un usuario envía una contraseña actual que no coincide
- **THEN** el sistema rechaza el cambio y conserva la credencial anterior

#### Scenario: Nueva contraseña no válida

- **WHEN** el usuario envía una nueva contraseña vacía
- **THEN** el sistema rechaza el cambio y conserva la credencial anterior
