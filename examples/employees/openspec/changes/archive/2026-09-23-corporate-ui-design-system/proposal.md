# Proposal

## Why

La interfaz del portal funciona, pero lee como un CRUD interno apenas estilizado: sin contrato de diseño, sin capa de primitivas y sin jerarquía visual, cada pantalla improvisa sobre un puñado de reglas sueltas. El resultado son enlaces que parecen hipervínculos de documento, tablas sin superficie ni filas clicables, controles sobredimensionados y bordes que no alcanzan el contraste mínimo de un componente de UI. Se necesita una base de diseño corporativa y verificable para que la apariencia deje de ser accidental.

## What Changes

- **Se introduce un contrato de diseño (`web/DESIGN.md`)**: tokens de color, tipografía, espaciado, forma, foco y movimiento, con las primitivas y sus estados nombrados. Es la fuente de verdad: ningún color, tamaño o espacio puede existir fuera de un token.
- **Se sustituye la paleta y la escala tipográfica actuales**: neutros fríos unificados + un solo acento, escala con display real (hoy el máximo es 20px), y una familia con carácter en lugar de la pila del sistema.
- **Se rehacen las primitivas** (`nav`, `table`, `field`, `btn`, `alert`) y se añaden las que faltan (cabecera de página, fila de tabla interactiva, estado vacío, medidor de nivel, aviso de acción).
- **Los enlaces dejan de ser la única superficie interactiva**: en listados, la fila entera pasa a ser clicable con una affordance explícita; el texto recupera el color de texto normal.
- **Se rediseñan las cinco pantallas** (inicio, catálogo, empleados, ficha, buscador) sobre las primitivas nuevas, incluidos los estados de carga, vacío y error.
- **Se corrige el desalineado de los botones** de formulario respecto a su control (medido: 22px por debajo).
- **El comportamiento funcional no cambia**: mismos endpoints, mismos flujos, mismos textos de error del servidor. `app.py` y `db.py` no se tocan.

## Capabilities

### New Capabilities
- `portal-ui`: contrato visual y de componentes del portal (tokens, tipografía, primitivas, estados y patrones de interacción) y su verificación observable en las cinco pantallas.

### Modified Capabilities
<!-- Ninguna: la capa de datos y el contrato de la API JSON no cambian. -->

## Impact

- **Código afectado**: `web/src/styles/tokens.css` y `app.css` (reescritos contra el contrato), `web/src/components/*` (primitivas) y `web/src/pages/*` (las cinco pantallas). Nuevo `web/DESIGN.md`.
- **Sin cambios**: `app.py`, `db.py`, la API JSON y los tests de backend.
- **Nuevas dependencias**: fuentes web self-hosted (variables, `font-display: swap`) y, si se usan iconos, un set SVG. No se introduce framework CSS ni librería de componentes.
- **Riesgo de regresión visual**: es un rediseño de superficie sobre funcionalidad intacta; la red de seguridad es el arnés E2E existente más verificación visual por pantalla.
- **Fuera de alcance**: modo oscuro, temas alternativos, autenticación, navegación lateral, gráficos o paneles de métricas, internacionalización. La accesibilidad se trata solo en lo que toca al contrato de diseño (contraste, foco, objetivos táctiles), no como auditoría WCAG.
