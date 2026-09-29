# Tasks

## 1. Backend: API JSON

- [x] 1.1 Reescribir `app.py` con los endpoints de `portal-api` que reutilizan `db.py` sin modificarlo y verificar que `GET /api/capabilities` y `GET /api/employees` devuelven 200 con un arreglo JSON
- [x] 1.2 Implementar los endpoints de alta y baja de capacidad (`POST`/`DELETE /api/capabilities`) y verificar los códigos de éxito (201/204) y los errores (400 nombre vacío, 409 duplicado, 404 inexistente)
- [x] 1.3 Implementar el alta de empleado y la ficha de empleado (`POST /api/employees`, `GET /api/employees/<id>`) y verificar 201/200 y el 404 de empleado inexistente, incluyendo ficha sin capacidades con lista vacía
- [x] 1.4 Implementar la asignación por API (`POST /api/employees/<id>/capabilities`) y verificar 201 y los errores 400 nivel fuera de rango, 404 empleado/capacidad inexistente y 409 capacidad ya asignada
- [x] 1.5 Implementar la búsqueda por API (`GET /api/search`) con nivel mínimo opcional y verificar 200 sin nivel, 200 con nivel, 200 vacío sin coincidencias, 404 capacidad inexistente y 400 nivel no numérico
- [x] 1.6 Unificar el formato de error `{"error": "<mensaje>"}` en todas las rutas de la API y verificar con un test que cada código de error devuelve ese cuerpo con el mensaje de motivo
- [x] 1.7 Servir el build estático desde Flask con fallback a `index.html` para rutas del router y verificar que la raíz y una ruta profunda devuelven el documento del SPA mientras `/api/*` devuelve JSON

## 2. Frontend: scaffolding

- [x] 2.1 Crear el proyecto `web/` (Vite 8 + React 19 + TypeScript) y verificar que `npm run build` genera `web/dist/` sin errores de tipos
- [x] 2.2 Configurar el proxy de desarrollo `/api` hacia Flask y verificar que `npm run dev` sirve la app y que una llamada a `/api/capabilities` a través del dev server alcanza el backend
- [x] 2.3 Añadir `web/node_modules/` y `web/dist/` al `.gitignore` y verificar que no aparecen en el estado de git
- [x] 2.4 Definir los tipos de dominio del cliente (`Capability`, `Employee`, `Assignment`, `SearchResult`, `ApiError`) contra el contrato del spec y verificar que `tsc` compila sin `any` implícitos
- [x] 2.5 Implementar el cliente de API tipado (una función por operación) que propague el `{"error"}` del servidor y verificar con la app en marcha que un alta duplicada produce un error legible en el cliente

## 3. Design system

- [x] 3.1 Escribir `src/styles/tokens.css` con las custom properties del design (color, espaciado, tipografía, radios, foco) y verificar que la única fuente de valores visuales son los tokens
- [x] 3.2 Implementar la primitiva `.nav` y verificar de forma observable que la navegación entre las cinco pantallas funciona y el foco es visible al tabular
- [x] 3.3 Implementar `.table` (encabezado en `--color-muted`, separador fino entre filas, sin bordes de celda) y verificar de forma observable que las tablas de catálogo, empleados y resultados se leen con la densidad definida
- [x] 3.4 Implementar `.field` (label, input/select, mensaje de error) y verificar de forma observable que un formulario muestra el error del servidor bajo el campo correspondiente
- [x] 3.5 Implementar `.btn` con variantes `--primary`, `--danger` y `--ghost` y verificar los estados normal, hover, foco y deshabilitado en las tres variantes
- [x] 3.6 Implementar `.alert` con variantes `--error`/`--success` y un contenedor de toasts y verificar de forma observable que una operación correcta y una fallida muestran el mensaje devuelto por la API
- [x] 3.7 Añadir los estados de carga, vacío y error para listados y verificar de forma observable los tres estados en la pantalla de catálogo con y sin datos

## 4. Pantallas de la SPA

- [x] 4.1 Implementar el router y el layout con la navegación y verificar que cada ruta muestra su pantalla y que una recarga directa de una ruta profunda funciona
- [x] 4.2 Implementar la pantalla de catálogo (listar, alta, baja) y verificar de forma observable que las tres operaciones se reflejan en la lista
- [x] 4.3 Implementar la pantalla de empleados (listar, alta) y verificar que un empleado nuevo aparece en la lista
- [x] 4.4 Implementar la ficha de empleado (asignar capacidad + nivel, ver las asignadas) y verificar de forma observable que una asignación correcta aparece con su nivel y que un nivel inválido no se acepta
- [x] 4.5 Implementar el buscador (selector de capacidad, nivel mínimo opcional, resultados) y verificar de forma interactiva que sin nivel devuelve todos y con nivel filtra por el mínimo

## 5. Verificación de extremo a extremo

- [x] 5.1 Verificar la accesibilidad básica del SPA: foco visible en todos los interactivos, navegación por teclado entre pantallas y anuncio del cambio de ruta
- [x] 5.2 Ejecutar una prueba E2E en navegador real que recorra alta de capacidad, alta de empleado, dos asignaciones con niveles distintos y búsqueda con y sin umbral, comprobando que los resultados coinciden con los escenarios del spec
- [x] 5.3 Verificar el comportamiento de error E2E: capacidad duplicada, capacidad ya asignada y nivel fuera de rango muestran el mensaje de motivo en la interfaz
- [x] 5.4 Ejecutar los tests de `db.py` existentes y verificar que siguen pasando sin cambios, confirmando que la capa de datos no se alteró
