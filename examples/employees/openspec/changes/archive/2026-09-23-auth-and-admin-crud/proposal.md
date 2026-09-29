# Proposal

## Why

El portal es accesible por cualquiera: no hay puerta de entrada ni identidad, y la API responde a quien pregunte. Al mismo tiempo la gestión de empleados está a medias — se pueden crear y consultar, pero no editar ni borrar, ni corregir un nivel asignado. Este cambio cierra las dos brechas: exige una sesión autenticada para operar y completa el ciclo de vida de las entidades.

## What Changes

- **Nueva autenticación con sesión**: pantalla de acceso, alta de sesión, cierre de sesión y consulta de la identidad activa. Sin sesión válida no se opera.
- **Nuevo rol de administrador**: se introduce un modelo de usuarios con rol y relación jerárquica preparada para árboles de mando, pero **solo se implementa el rol administrador**, que puede realizar todas las operaciones del portal.
- **BREAKING — la API deja de ser anónima**: pasa a requerir sesión. La respuesta deja de "poder consumirse sin estado de sesión", que es justamente lo que hoy declara el contrato de `portal-api`. Las peticiones sin sesión se rechazan antes de ejecutar nada.
- **CRUD completo de empleados**: además de listar, consultar y crear, se añaden editar, borrar y corregir el nivel de una capacidad ya asignada, y quitar una capacidad asignada.
- **CRUD completo de capacidades**: se añade el renombrado, que hoy falta.
- **Capa de datos extendida de forma aditiva**: se añade la tabla de usuarios y las funciones que faltan, **sin modificar ninguna de las funciones existentes**. La invariante histórica "`db.py` no se modifica" se revisa explícitamente a "no se rompe lo existente".
- **Credencial de arranque**: se siembra un administrador inicial con credencial conocida para poder entrar la primera vez, de forma idempotente.
- **El cliente incorpora acceso, guardia de navegación y las acciones de gestión nuevas**. La guardia del cliente es experiencia de usuario; la autorización real ocurre en el servidor.

## Capabilities

### New Capabilities
- `auth`: acceso por sesión autenticada, identidad del usuario activo, cierre de sesión, roles y la exigencia de sesión sobre el resto del sistema.

### Modified Capabilities
- `portal-api`: la API deja de ser anónima y gana las operaciones de edición y borrado que hoy no expone.
- `employee-capability-portal`: el ciclo de vida de empleados y capacidades se completa (editar, borrar, corregir nivel, desasignar) y el actor de las operaciones pasa a ser un administrador autenticado.

## Impact

- **Código afectado**: `db.py` (tabla `user` y funciones nuevas, aditivas), `auth.py` (nuevo), `app.py` (exigencia de sesión + rutas de edición y borrado), `test_api.py` (las pruebas pasan a autenticarse), `test_portal.py` (sin cambios), y en `web/`: contexto de sesión, pantalla de acceso, guardia de rutas, navegación con cierre de sesión y las acciones de gestión.
- **Sin dependencias nuevas**: el hashing de contraseñas y las sesiones firmadas ya vienen con Flask.
- **Contrato público**: la API pasa a tener un estado (sesión), lo que es un cambio incompatible para cualquier cliente que hoy la consuma sin autenticarse.
- **Riesgo de seguridad**: la credencial sembrada es trivialmente adivinable y **se documenta como deuda aceptada**, válida solo para desarrollo local. Si el portal se expone fuera de la máquina local, la siembra debe sustituirse por un alta de administrador controlada.
- **Fuera de alcance**: los demás roles (solo se implementa administrador), la gestión de usuarios desde la interfaz, el registro público de usuarios, la recuperación de contraseña, el árbol jerárquico operativo (solo se prepara el modelo), la autenticación multifactor y el modo oscuro.
