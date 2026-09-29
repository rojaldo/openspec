# Tasks

## 1. Capa de datos: usuarios

- [x] 1.1 Añadir la tabla `user` al esquema de `db.py` (id, username único, password_hash, role, parent_id autorreferente con ON DELETE SET NULL) de forma aditiva y verificar que `uv run python -m unittest test_portal` sigue pasando sin haber modificado ninguna prueba existente
- [x] 1.2 Implementar `add_user`, `get_user_by_username` y `set_password` con hashing de contraseñas y verificar que `password_hash` nunca contiene la contraseña en claro ni con una comprobación de que `check_password_hash` valida la correcta y rechaza la incorrecta
- [x] 1.3 Implementar `ensure_admin()` idempotente que cree el administrador `admin` con contraseña `admin` solo si no existe y verificar que un segundo arranque sobre un administrador con contraseña cambiada no la restablece

## 2. Capa de datos: CRUD que falta

- [x] 2.1 Implementar `update_capability` (renombrado) y verificar que rechaza nombre vacío, nombre duplicado y capacidad inexistente, conservando las asignaciones existentes
- [x] 2.2 Implementar `update_employee` y verificar que rechaza nombre vacío y empleado inexistente, y que las capacidades asignadas se conservan tras la edición
- [x] 2.3 Implementar `delete_employee` y verificar que elimina al empleado y sus asignaciones en cascada y que un empleado inexistente da error
- [x] 2.4 Implementar `update_assignment_level` y verificar que corrige el nivel de una asignación existente, rechaza nivel fuera de 1-5 y rechaza una capacidad no asignada a ese empleado
- [x] 2.5 Implementar `unassign_capability` y verificar que quita la asignación, conserva las demás capacidades del empleado y rechaza una asignación inexistente

## 3. Autenticación en el servidor

- [x] 3.1 Crear `auth.py` con la sesión por cookie firmada (solo `user_id` en sesión, secreto desde variable de entorno con aviso si falta) y verificar que la cookie resultante es HttpOnly y SameSite=Lax
- [x] 3.2 Implementar `POST /auth/login` y verificar el acceso correcto, y que contraseña incorrecta y usuario inexistente devuelven el mismo error sin revelar cuál falló, sin establecer sesión
- [x] 3.3 Implementar `GET /auth/me` y `POST /auth/logout` y verificar que la identidad devuelve usuario y rol, que sin sesión da error de autenticación y que tras el cierre de sesión la operación anterior deja de ser aceptada
- [x] 3.4 Implementar `POST /auth/password` y verificar que exige la contraseña actual, rechaza una incorrecta, rechaza una nueva vacía y que la nueva contraseña permite iniciar sesión

## 4. Exigencia de sesión y rutas nuevas

- [x] 4.1 Añadir la intercepción global que rechaza con 401 y JSON toda petición bajo `/api/*` sin sesión, y verificar con una prueba que recorre las rutas existentes que todas rechazan sin sesión y ninguna modifica datos
- [x] 4.2 Añadir el manejador de error JSON para rutas de API inexistentes y verificar que una ruta bajo `/api/` desconocida devuelve JSON de error y no el documento SPA
- [x] 4.3 Implementar `PUT /api/capabilities/<id>` y verificar 200 con el nombre nuevo, 400 nombre vacío, 409 duplicado y 404 inexistente
- [x] 4.4 Implementar `PUT /api/employees/<id>` y `DELETE /api/employees/<id>` y verificar 200/204 de éxito, 400 nombre vacío, 404 inexistente, y que la baja elimina las asignaciones y desaparece de listado y búsqueda
- [x] 4.5 Implementar `PUT /api/employees/<id>/capabilities/<capability_id>` y `DELETE` de la misma ruta y verificar la corrección de nivel (200) con sus errores (400 nivel fuera de rango, 404 asignación inexistente) y la desasignación (204) con su 404
- [x] 4.6 Rechazar con 403 la sesión de un rol distinto de administrador en toda operación de `/api/*`, conservando 401 para la ausencia de sesión y dejando accesibles `/auth/me` y `/auth/logout` a cualquier rol, y verificar con pruebas que ninguna operación acepta un rol no-admin

## 5. Pruebas del contrato

- [x] 5.1 Añadir a `test_api.py` un helper de acceso que autentique el `test_client` en `setUp` y verificar que las 28 pruebas existentes vuelven a pasar conservando cada aserción de comportamiento
- [x] 5.2 Añadir pruebas del 401 sin sesión para cada grupo de rutas y verificar que ninguna devuelve datos ni modifica el almacén
- [x] 5.3 Añadir pruebas de cada operación nueva (edición y baja de capacidad y empleado, corrección de nivel, desasignación, login/logout/me/password) y verificar los códigos de éxito y de error de cada una
- [x] 5.4 Ejecutar la suite completa (`uv run python -m unittest discover`) y verificar que `test_portal.py` sigue pasando sin cambios y que el total sube con las pruebas nuevas

## 6. Cliente: acceso y sesión

- [x] 6.1 Implementar el contexto de sesión y el manejo del 401 en el cliente HTTP (cerrar sesión y volver al acceso) y verificar que una respuesta 401 no deja la interfaz en estado autenticado
- [x] 6.2 Implementar la pantalla de acceso sobre las primitivas del contrato de diseño y verificar que un acceso correcto entra al portal y uno incorrecto muestra el motivo devuelto por la API
- [x] 6.3 Implementar la guardia de rutas que redirige al acceso sin sesión y verificar navegando directamente a una ruta protegida que no se muestra contenido sin sesión
- [x] 6.4 Añadir a la navegación la identidad del usuario activo y la acción de cerrar sesión, y verificar que el cierre devuelve al acceso y que las rutas protegidas dejan de ser accesibles

## 7. Cliente: gestión completa

- [x] 7.1 Añadir la edición de capacidad en la pantalla de catálogo y verificar que el nombre nuevo se refleja en la lista y que un duplicado muestra el motivo del servidor
- [x] 7.2 Añadir la edición y la baja de empleado y verificar que la edición conserva las capacidades asignadas, que la baja pide confirmación explícita y que el empleado desaparece del listado
- [x] 7.3 Añadir la corrección de nivel y la desasignación en la ficha de empleado y verificar que el medidor de nivel refleja el nivel nuevo y que la capacidad desasignada desaparece de la ficha

## 8. Verificación de extremo a extremo

- [x] 8.1 Reconstruir el cliente (`npm run build`) y verificar que `tsc` compila sin errores y que el build se emite
- [x] 8.2 Ampliar el arnés E2E para autenticarse, y verificar que recorriendo los flujos funcionales completos (acceso, alta y edición de capacidad, alta, edición y baja de empleado, asignación, corrección de nivel, desasignación y búsqueda) todas las comprobaciones pasan
- [x] 8.3 Verificar de extremo a extremo que sin sesión no hay acceso a datos: petición directa a la API sin sesión devuelve 401 y navegar a una ruta protegida redirige al acceso
- [x] 8.4 Verificar el arranque limpio: sobre un almacén sin usuarios, el sistema siembra el administrador y permite iniciar sesión con `admin`/`admin`, y un arranque posterior no altera la credencial
