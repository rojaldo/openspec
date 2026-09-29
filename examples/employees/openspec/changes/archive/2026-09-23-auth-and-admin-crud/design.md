# Design

## Context

Ver `proposal.md` para la motivación. Estado de partida que condiciona el diseño:

- `db.py` es una capa de datos SQLite sin ORM, con 13 funciones y un esquema de tres tablas (`capability`, `employee`, `employee_capability`). Su docstring declara invariantes de esquema, y tres changes consecutivos fijaron "`db.py` no se modifica" como restricción. **Ese cambio la revisa** (ver Decisión 1).
- `employee_capability` ya tiene `ON DELETE CASCADE` y `PRAGMA foreign_keys = ON`, así que la baja de un empleado o de una capacidad limpia sus asignaciones sin código adicional.
- `app.py` expone 9 rutas bajo `/api/*` más el servicio de estáticos con fallback a `index.html`. Ninguna comprueba identidad. El fallback actual responde al documento SPA a **cualquier** ruta no encontrada, incluidas las de la API.
- `test_api.py` (28 pruebas) usa `test_client()` **sin autenticarse**; `test_portal.py` (19 pruebas) ataca `db.py` directamente y por tanto no le afecta la sesión.
- El cliente SPA tiene un router con cinco rutas y ningún concepto de sesión ni de usuario.
- Flask ya trae `werkzeug` (hashing de contraseñas, scrypt por defecto) e `itsdangerous` (sesiones firmadas por cookie). **No hace falta ninguna dependencia nueva.**

## Goals / Non-Goals

**Goals:**

- Una puerta de entrada real: sin sesión válida no se lee ni se escribe nada.
- Autorización efectiva **en el servidor**; la guardia del cliente es solo experiencia de usuario.
- Un modelo de usuarios con rol y `parent_id` que admita jerarquía futura sin migración de esquema.
- CRUD completo de empleados, capacidades y asignaciones, de forma aditiva.
- Que las 19 pruebas de `db.py` sigan pasando sin cambios, como prueba de que la capa de datos no se rompió.

**Non-Goals:**

- Implementar roles distintos de administrador, o gestión de usuarios desde la interfaz.
- Registro público, recuperación de contraseña, MFA, bloqueo por intentos fallidos, política de complejidad de contraseñas.
- Árbol jerárquico operativo: el modelo lo admite, pero no se expone ni se recorre.
- Modo oscuro y cualquier trabajo de superficie.

## Decisions

### 1. `db.py` se extiende de forma aditiva (la invariante se revisa, no se rompe)

Se añade a `db.py` la tabla `user` y las funciones nuevas (`add_user`, `get_user_by_username`, `set_password`, `ensure_admin`, `update_capability`, `update_employee`, `delete_employee`, `update_assignment_level`, `unassign_capability`). **Ninguna de las 13 funciones existentes se modifica**, así que `test_portal.py` sigue pasando intacto.

La invariante histórica pasa de *"`db.py` no se modifica"* a *"no se rompe lo existente: solo se añade"*. El CRUD pedido **no era posible** sin tocarla — faltaban funciones de actualización y borrado de empleado — así que se documenta la revisión en lugar de esconderla.

*Alternativa:* un `auth.py` con su propio esquema para los usuarios. Se descarta porque fragmenta la capa de datos en una aplicación de este tamaño, obliga a coordinar dos conexiones y deja dos fuentes de verdad; además `db.py` ya es "la capa de datos" por su propio docstring.

### 2. Autenticación en un módulo propio, con sesión por cookie firmada

`auth.py` agrupa las rutas de acceso (`/auth/login`, `/auth/logout`, `/auth/me`, `/auth/password`). La sesión se guarda en la cookie de sesión de Flask (firmada por `itsdangerous`, con `SECRET_KEY`), con `SameSite=Lax` y `HttpOnly`. El guardado de identidad en la sesión es mínima: `user_id`.

*Alternativa:* token JWT propio o Bearer en cabecera. Se descarta: la SPA y la API son **mismo origen** y Flask ya resuelve la sesión firmada; un token en cabecera obligaría a gestionarlo en el cliente y a inventar revocación que la cookie ya cubre.

*Alternativa:* guardar el rol y el nombre de usuario en la sesión. Se descarta: la sesión solo lleva `user_id` y el usuario se relee en cada petición. Así un cambio de rol o una baja de usuario surten efecto sin esperar a que caduque la cookie.

### 3. La exigencia de sesión se implementa como intercepción global sobre `/api/*`

Un `before_request` en `app.py` rechaza todo acceso a `/api/*` que no venga de un administrador autenticado: **401** si no hay sesión válida y **403** si la sesión pertenece a un rol distinto del administrador. Un punto único protege **todo** lo presente y lo futuro, en vez de repetir una comprobación por ruta (donde basta olvidar una para dejar un agujero).

El rol se comprueba aquí y no solo en la guardia del cliente porque el spec exige rechazar la operación: una sesión válida de un rol no autorizado no debe poder operar, aunque el cliente la deje navegar.

El rechazo lleva el mismo formato de error uniforme que el resto de la API (`{"error": ...}`), y se añade también el manejador de 404/405 JSON para rutas de API inexistentes o con método no permitido.

*Alternativa:* decorador por ruta. Se descarta por el riesgo de olvido; la intercepción global es verificable de una vez con una prueba que recorra las rutas.

### 4. La guardia del cliente es UX, no seguridad

`AuthContext` mantiene la sesión, `RequireAuth` redirige a `/login` sin sesión, y el cliente interpreta un 401 del servidor cerrando sesión y volviendo al acceso. La autoridad es el 401 del servidor: aunque alguien salte la guardia, no recibe datos.

Se implementa también el manejo del 401 en el cliente HTTP, para que una sesión caducada no deje la interfaz en un estado mentiroso.

### 5. Esquema de usuarios preparado para árbol

```sql
CREATE TABLE IF NOT EXISTS user (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    username      TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    role          TEXT NOT NULL DEFAULT 'admin',
    parent_id     INTEGER REFERENCES user(id) ON DELETE SET NULL
);
```

`role` distingue el rol; `parent_id` representa el responsable jerárquico y es nulable, así que ningún usuario está obligado a tener superior. `ON DELETE SET NULL` evita que borrar un responsable arrastre a sus subordinados. El rol se modela como texto y no como enum de SQLite para poder añadir roles sin migración.

### 6. Contraseñas con hashing de la biblioteca estándar del stack

Se usa `werkzeug.security.generate_password_hash` / `check_password_hash` (scrypt, con sal por contraseña). Nunca se guarda ni se compara la contraseña en claro.

*Alternativa:* `hashlib` con PBKDF2 a mano. Se descarta: reinventar hashing de contraseñas es exactamente donde no se debe ser original, y `werkzeug` ya viene con Flask.

### 7. Credencial de arranque sembrada de forma idempotente

`ensure_admin()` crea el administrador `admin` con contraseña `admin` **solo si no existe ningún usuario con ese nombre**. Es idempotente a propósito: arrancar de nuevo no restablece una contraseña ya cambiada.

*Alternativa:* sembrar siempre (pisando la credencial). Se descarta porque convertiría cada arranque en un reinicio encubierto de contraseña — un fallo de seguridad, no una comodidad.

*Alternativa:* página de registro para el primer administrador. Se descarta porque deja una vía de alta abierta y pide más superficie de la que el alcance necesita.

### 8. Las pruebas de la API se autentican, no se relajan

`test_api.py` gana un helper de acceso en `setUp` que establece sesión en el `test_client` antes de cada prueba. La aserción de comportamiento de cada prueba se conserva: lo que cambia es que ahora el cliente llega autenticado, que es la precondición nueva del contrato. Se añaden pruebas específicas para el 401 sin sesión y para cada operación nueva.

*Alternativa:* eximir `/api/*` de la sesión durante las pruebas. Se descarta: verificaría un sistema que no es el que se despliega.

### 9. La sesión no se guarda en disco ni se expone al JavaScript

La cookie es `HttpOnly` (el JavaScript no la lee) y `SameSite=Lax` (mitiga CSRF en navegación cruzada). No se introduce un almacén de sesiones en servidor: el alcance es un operador y la cookie firmada basta. Se documenta como deuda aceptada que no hay revocación global de sesiones.

## Risks / Trade-offs

- **[Credencial sembrada trivialmente adivinable (`admin`/`admin`)]** → Se siembra solo si no existe, se documenta como deuda aceptada válida para desarrollo local, y se expone un cambio de contraseña autenticado. Si el portal se expone fuera de la máquina local, la siembra debe sustituirse por un alta controlada.
- **[`SECRET_KEY` por defecto en el código permitiría falsificar cookies]** → La clave se lee de una variable de entorno; si falta, se usa una de desarrollo y se emite un aviso visible al arrancar. Se documenta como límite consciente.
- **[Proteger todo `/api/*` rompe las 28 pruebas actuales]** → Se asumen y se adaptan con el helper de acceso, conservando cada aserción. Se añade una prueba que verifica el 401 en las rutas sin sesión.
- **[La intercepción global puede bloquear una ruta que deba ser pública]** → Hoy no existe ninguna ruta pública bajo `/api/*`: las de acceso viven bajo `/auth/*`. La intercepción se limita al prefijo `/api/`.
- **[404 de la API respondiendo con el documento SPA]** → Se corrige con un manejador de error JSON; sin él, un cliente que espera JSON recibiría HTML y fallaría al parsear.
- **[El CRUD de empleado puede borrar datos por error]** → La baja exige confirmación explícita en la interfaz (patrón ya establecido en el catálogo) y el borrado en cascada elimina las asignaciones, que es el comportamiento que el spec ya fija para capacidades.
- **[Deriva entre el tipo del cliente y el servidor]** → Los tipos del cliente se amplían a mano contra el spec y las pruebas cubren cada código de error nuevo.

## Migration Plan

1. Extender `db.py` (tabla `user` + funciones nuevas) y verificar que `test_portal.py` sigue pasando **sin modificar**.
2. Añadir `auth.py` y la intercepción de sesión; verificar el 401 y el acceso.
3. Añadir las rutas de edición y borrado, y el 404 JSON.
4. Adaptar `test_api.py` con el helper de acceso y añadir las pruebas nuevas; verificar la suite completa.
5. Cliente: contexto de sesión, guardia, pantalla de acceso, cierre de sesión y acciones de gestión.
6. Verificación de extremo a extremo con el arnés existente, autenticándose.

*Rollback:* los cambios de datos son aditivos (una tabla nueva) y las funciones nuevas no alteran las existentes. Revertir el código deja la tabla `user` presente pero ignorada, sin pérdida de datos del dominio.

## Open Questions

- Si el guardado del rol debe admitir más de un rol por usuario: no afecta al alcance implementado ni al desglose de tareas, porque solo se implementa administrador.
- El texto exacto de la pantalla de acceso y si admite "recordarme": decisión de superficie que no cambia el contrato ni las tareas.
