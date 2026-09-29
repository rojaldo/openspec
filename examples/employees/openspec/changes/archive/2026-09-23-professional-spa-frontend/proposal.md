# Proposal

## Why

La aplicación es funcionalmente correcta, pero su interfaz es un `<style>` inline dentro de un string de Python: no tiene sistema de diseño, no tiene lenguaje visual propio y no se parece a un producto corporativo. Al mismo tiempo, se ha decidido construir una **SPA real (React 19 + TypeScript)** en lugar de seguir con renderizado en servidor, y una SPA necesita un contrato de datos explícito que hoy no existe (Flask devuelve HTML, no JSON).

## What Changes

- **Nueva API HTTP JSON** consumible por la SPA, con endpoints para catálogo de capacidades, empleados, asignación con nivel y búsqueda. Sustituye a las rutas que hoy devuelven HTML.
- **Flask pasa a ser API + servidor de estáticos**: sirve el `dist/` del build y hace fallback a `index.html` para las rutas del router del SPA, manteniendo un único despliegue.
- **Nuevo frontend SPA** en `web/` con **React 19 + TypeScript + Vite 8**: router, cinco pantallas (inicio/panel, catálogo, empleados, ficha de empleado, buscador) y cliente de API tipado.
- **Design system propio** (`~150` líneas de CSS): tokens como custom properties (color, espaciado, tipografía, radios, foco) y cinco primitivas (`.nav`, `.table`, `.field`, `.btn`, `.alert`). Estética corporativa minimalista: neutros + un solo acento, jerarquía por peso y aire, sin sombras ni gradientes.
- **Se elimina el HTML/CSS embebido** (`PAGE` y el string de estilo) de `app.py`; el HTML pasa a componentes del SPA.
- **Las notificaciones cambian de mecanismo**: se pierde el `flash()` de sesión y pasan a feedback en cliente.
- La capa de datos (`db.py`) **no se modifica**: sus funciones se reutilizan tal cual detrás de la API.
- El **comportamiento funcional no cambia**: catálogo cerrado, niveles 1-5, 0..N capacidades por empleado y búsqueda con umbral opcional siguen siendo los mismos.

## Capabilities

### New Capabilities
- `portal-api`: contrato HTTP JSON que expone catálogo de capacidades, empleados, asignación de capacidades con nivel 1-5 y búsqueda por capacidad con nivel mínimo opcional, con validación y errores definidos.

### Modified Capabilities
<!-- Ninguna: el spec de comportamiento (employee-capability-portal) es independiente
     de la interfaz y sus requisitos no cambian. -->

## Impact

- **Código afectado**: `app.py` (reescrito como API + servidor de estáticos), nuevo proyecto `web/` (React/TS/Vite), eliminación de `PAGE` y del CSS inline. `db.py` sin cambios.
- **Nuevas dependencias**: Node toolchain (`npm`/`vite`, React 19, TypeScript) para el frontend; Flask sirve el build resultante. El backend sigue bajo `uv`.
- **Nuevo contrato público**: la API JSON pasa a ser una interfaz observable y estable, por eso merece spec propio.
- **Accesibilidad**: al pasar a SPA, el foco visible y la navegación por teclado pasan a ser responsabilidad del frontend (regla del design system, verificable).
- **Fuera de alcance**: autenticación/roles, entidad proyecto, multi-capacidad en la búsqueda, historial de evaluaciones. Sin cambios respecto al alcance ya decidido.
