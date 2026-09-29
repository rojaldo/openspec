# Design

## Context

Ver `proposal.md` para la motivación. Puntos de partida que condicionan el diseño:

- La lógica de datos vive en `db.py` (SQLite, 13 funciones: `add_capability`, `list_capabilities`, `delete_capability`, `add_employee`, `list_employees`, `get_employee`, `employee_capabilities`, `assign_capability`, `search`, más helpers de existencia y `connect`/`init_db`). Es la capa que **no se toca**: sus funciones ya devuelven lo que la API necesita.
- Hoy `app.py` mezcla 9 rutas HTML con el HTML y el CSS embebidos en un string de Python (`PAGE`). Eso desaparece.
- El spec de comportamiento (`employee-capability-portal`) es independiente de la interfaz y no cambia.
- El nuevo contrato observable es la API JSON, especificado en `specs/portal-api/spec.md`.

## Goals / Non-Goals

**Goals:**

- Un frontend SPA con aspecto corporativo minimalista y un lenguaje visual propio y documentado.
- Un contrato HTTP JSON estable y tipado que la SPA consume.
- Un único despliegue en producción: Flask sirve API + build estático.
- Mantener intacta la capa de datos y el comportamiento funcional.

**Non-Goals:**

- Autenticación, roles o sesiones (sigue habiendo un operador único; la API no se autentica).
- Estado global complejo, caché de servidor o SSR/hidratación.
- Librería de componentes externa (el design system es propio).
- Rediseñar el modelo de datos o añadir capacidades funcionales nuevas.

## Decisions

### 1. SPA con React 19 + TypeScript + Vite 8

React 19 y TypeScript como estándar corporativo y empleable; Vite 8 como bundler/dev server (versiones confirmadas en el registro). TypeScript se justifica porque la API define formas concretas (`Employee`, `Capability`, `Assignment`, `SearchResult`) y el tipado las hace verificables en compilación.

*Alternativas:* Vue 3.5 y Svelte 5 serían técnicamente más ligeros, pero se eligió React por el criterio acordado (estándar de industria). Sin SSR/hidratación (Next.js): la app es interna, de un operador, y el SSR no aporta aquí.

*Estado:* se usa estado local por pantalla más un pequeño cliente de API compartido. No se añade gestor de estado global (Redux/Zustand): cinco pantallas de CRUD no lo justifican.

### 2. Estructura del repositorio: `web/` como proyecto separado

```
   /                       Flask (uv): API + sirve el build
   ├── db.py               SIN CAMBIOS
   ├── app.py              reescrito: rutas /api/* + estáticos + fallback SPA
   ├── pyproject.toml      backend (uv)
   └── web/                frontend (npm)
       ├── package.json
       ├── vite.config.ts  proxy /api -> http://127.0.0.1:8000 en dev
       ├── tsconfig.json
       ├── index.html
       └── src/
           ├── main.tsx / App.tsx / router.tsx
           ├── api/client.ts        (cliente tipado)
           ├── styles/tokens.css    (el design system)
           ├── components/          (Nav, Table, Button, Field, Alert, Toast)
           └── pages/               (Home, Capabilities, Employees,
                                     EmployeeDetail, Search)
```

El build de Vite se emite a `web/dist/`, servido por Flask. En desarrollo, dos procesos (`uv run app.py` + `npm run dev`) con proxy; en producción, uno.

*Alternativa:* colocar el frontend en `static/` y servirlo sin build. Requeriría renunciar a React/TS, que es una decisión ya tomada.

### 3. API JSON: rutas bajo `/api`, errores uniformes

La API expone el comportamiento ya especificado en `portal-api`. Formas de respuesta y códigos:

| Operación | Método y ruta | Éxito | Errores |
|---|---|---|---|
| Listar capacidades | `GET /api/capabilities` | 200 arreglo | — |
| Crear capacidad | `POST /api/capabilities` | 201 objeto | 400 vacío, 409 duplicado |
| Borrar capacidad | `DELETE /api/capabilities/<id>` | 204 | 404 inexistente |
| Listar empleados | `GET /api/employees` | 200 arreglo | — |
| Crear empleado | `POST /api/employees` | 201 objeto | 400 vacío |
| Ficha de empleado | `GET /api/employees/<id>` | 200 objeto | 404 inexistente |
| Asignar capacidad | `POST /api/employees/<id>/capabilities` | 201 | 400 nivel, 404 empleado/capacidad, 409 ya asignada |
| Buscar | `GET /api/search?capability_id=&min_level=` | 200 arreglo | 400 no numérico, 404 capacidad inexistente |

Los errores devuelven siempre `{"error": "<mensaje>"}` con el código adecuado. **Esta uniformidad es lo que permite que la SPA muestre el motivo real** (p. ej. "La capacidad 'Java' ya existe") en lugar de un mensaje genérico. Las funciones de `db.py` ya lanzan `ValueError` con esos textos; la capa de API solo los mapea a códigos.

*Alternativa:* reutilizar los códigos de estado para distinguir el motivo (404 vs 409 vs 400) y un mensaje genérico. Se descarta porque el mensaje concreto ya existe en `db.py` y perderlo empeora la UX sin ganar nada.

### 4. Design system: tokens como única fuente de verdad

`src/styles/tokens.css` es la guía de estilo hecha código. Todo color, espacio y tipografía sale de aquí; ningún componente define valores propios.

```
   :root {
     /* color: neutros + UN acento. Nada mas. */
     --color-bg: #f7f8fa;      --color-surface: #ffffff;
     --color-border: #e3e6ea;  --color-border-strong: #c9cfd6;
     --color-text: #1a1d21;    --color-muted: #6b7280;
     --color-accent: #2f5fd0;  --color-accent-contrast: #ffffff;
     --color-danger: #b42318;  --color-success: #067647;

     /* espacio: una sola escala, multiplos de 4px */
     --space-1: 4px;  --space-2: 8px;  --space-3: 12px;
     --space-4: 16px; --space-5: 24px; --space-6: 32px;

     /* tipografia: del sistema, jerarquia por tamano y peso */
     --font-sans: system-ui, -apple-system, "Segoe UI", sans-serif;
     --text-xs: 12px; --text-sm: 13px; --text-base: 14px;
     --text-lg: 16px; --text-xl: 20px;
     --weight-regular: 400; --weight-medium: 500; --weight-semibold: 600;

     /* forma y foco */
     --radius-sm: 4px; --radius-md: 6px;
     --focus-ring: 0 0 0 2px var(--color-accent);
   }
```

Reglas de la casa (explícitas, verificables):

- **Un solo acento.** El color no es mecanismo de jerarquía; lo son el tamaño, el peso y el espacio.
- **Cero gradientes, cero sombras decorativas.** Profundidad solo por borde fino y, si acaso, un cambio de superficie.
- **Bordes de 1px, radios <= 6px.** Nada de esquinas muy redondeadas.
- **Foco siempre visible** (`--focus-ring`, 2px) y navegación por teclado: es requisito de accesibilidad, no decoración.
- **Densidad alta con respiro**: filas de tabla compactas (padding vertical `--space-2`) pero con separadores finos, no cajas.
- **Tablas sin bordes de celda**: solo separador horizontal entre filas; encabezados en `--color-muted` y `--weight-medium`.

Cinco primitivas cubren todo el inventario de la UI (medido: 1 nav, 4 tablas, 5 formularios, 5 botones, 3 selects, alertas):

`.nav`, `.table`, `.field` (label + input/select + hint/error), `.btn` (con variantes `--primary`/`--danger`/`--ghost`), `.alert` (con variantes `--error`/`--success`).

*Alternativa:* adoptar Pico.css, Tailwind o Bootstrap. Se descarta: el encargo pide definir la guía de estilo propia, y una librería impondría su lenguaje visual (efecto "plantilla") o un build adicional para 10 primitivas.

### 5. Feedback sin `flash()`: toasts y estados por pantalla

El `flash()` de sesión desaparece (no hay sesión ni recarga completa). Cada mutación muestra un toast (`.alert` flotante) con el mensaje devuelto por la API, y cada pantalla maneja explícitamente tres estados: **cargando**, **vacío** y **error**. Es más código que un redirect, no menos, y es coste inherente a la SPA.

### 6. Entrega desde un único despliegue

Flask sirve `web/dist/` como estáticos y aplica fallback a `index.html` para rutas que no son de la API ni un fichero existente, de modo que las rutas profundas del router sean recargables (cubierto en el spec `portal-api`, requisito de entrega). CORS no es necesario: mismo origen.

## Risks / Trade-offs

- **[Rewrite del backend HTTP y pérdida de los `flash()`]** → El feedback pasa a cliente y hay que implementar toasts y estados de carga/error. Mitigación: el spec `portal-api` fija los errores; los toasts consumen el `error` que ya devuelve `db.py`.
- **[Accesibilidad degradada por la SPA]** → Foco, teclado y anuncios de cambio de ruta se rompen fácil. Mitigación: `--focus-ring` y foco visible como regla del design system, y verificación de teclado/foco en la tarea de QA visual.
- **[Dos toolchains (uv + npm)]** → Más superficie de entorno. Mitigación: cada uno en su ámbito (`pyproject.toml` para backend, `package.json` para frontend) y `web/dist/` en `.gitignore`; un solo despliegue en producción.
- **[Build obligatorio para ver el frontend]** → Ya no basta con `uv run app.py` para desarrollo de UI. Mitigación: `npm run dev` con proxy a la API durante el desarrollo; `npm run build` solo para producción.
- **[Deriva entre el tipo de la API y el servidor]** → TypeScript tipa el cliente, pero Flask no valida contra ese tipo. Mitigación: los tipos del cliente se escriben a mano contra el spec y las tareas incluyen tests de la API para cada código de error.
- **[Sin autenticación en una API JSON]** → Hoy no había login porque era una app local de un operador; una API JSON es más fácil de exponer por error. Mitigación: la API escucha en `127.0.0.1` y sigue fuera de alcance añadir auth; se documenta como límite consciente, no se añade alcance.

## Open Questions

- Nombre del paquete/proyecto del frontend y puertos concretos de desarrollo quedan abiertos; no cambian el spec ni las tareas.
- Se difiere el uso de una librería de router (React Router) frente a un router propio mínimo: no cambia el contrato del spec y se decide en implementación según cuántas rutas resulten necesarias.
