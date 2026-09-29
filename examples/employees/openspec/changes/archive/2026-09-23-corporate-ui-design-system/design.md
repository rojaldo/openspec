# Design

## Context

Ver `proposal.md` para la motivación. El estado de partida que condiciona el diseño:

- El diseño actual vive en dos archivos: `web/src/styles/tokens.css` (36 líneas de custom properties) y `app.css` (278 líneas de primitivas). No hay `DESIGN.md` ni capa de componentes reutilizable fuera de cinco primitivas en `web/src/components/`.
- La pila tipográfica es la del sistema, la escala de texto va de 12 a 20 px y los pesos usados son 400/500/600. El máximo de la escala (20 px) es el `h1`: no existe un nivel de display.
- La paleta son neutros fríos + un único acento azul. Los bordes de control miden **1.57:1** sobre blanco y los separadores de tabla **1.25:1** — por debajo del umbral de un límite de componente distinguible.
- Cinco pantallas (`Home`, `Capabilities`, `Employees`, `EmployeeDetail`, `Search`) comparten las mismas primitivas, así que un cambio en la capa de estilos propaga a todas.
- Medición de partida sobre el build servido: en los cuatro formularios el botón de envío cae **22 px por debajo** del control, porque `.form-row` usa `align-items: flex-end` y alinea el pie del botón con el pie del `.field` (label + control + pista). En Empleados, con una sola columna, la regla `.table th:last-child` alinea los datos a la derecha y deja la mitad de la fila vacía. El área clicable de un registro es de **24 x 18 px** en una fila de 928 px.
- `db.py` y `app.py` no se tocan: la API y el comportamiento funcional quedan intactos.

## Goals / Non-Goals

**Goals:**

- Un contrato de diseño (`web/DESIGN.md`) que sea la fuente de verdad de tokens, primitivas y estados, y que exista antes de escribir las primitivas.
- Reemplazar la superficie heredada por un lenguaje visual corporativo: neutros unificados, un acento, escala tipográfica con rango real y superficies con profundidad por capa tonal.
- Convertir la fila de listado en la superficie interactiva y eliminar la apariencia de hipervínculo del texto de registro.
- Un componente propio para el nivel 1-5 que haga memorable el dato central del dominio.
- Dejar cada pantalla con estados de carga, vacío y error diseñados, no frases sueltas.

**Non-Goals:**

- Reescritura funcional: endpoints, flujos, validaciones y mensajes del servidor no cambian.
- Modo oscuro, temas alternativos, internacionalización o layout con navegación lateral.
- Adoptar framework CSS, librería de componentes o sistema de iconos pesado.
- Auditoría de accesibilidad como fin (el contraste, el foco y los objetivos táctiles se tratan como parte del contrato visual, no como una revisión WCAG formal).

## Decisions

### 1. `DESIGN.md` como contrato previo a las primitivas

Se escribe `web/DESIGN.md` con las secciones de tokens, tipografía, primitivas, movimiento, responsive, accesibilidad y deuda aceptada, y **se escribe antes** de tocar las primitivas. Cada valor de `tokens.css` debe existir antes en el documento.

*Alternativa:* mantener los tokens como única fuente (hoy es lo que hay). Se descarta porque un archivo de custom properties no expresa intención, estados ni reglas de uso — solo valores — y es exactamente lo que ha permitido que la UI derive sin contrato.

### 2. Dirección visual: enterprise operativo, no marketing

Se adopta una dirección **operativa y de alta densidad** (familia de herramientas internas tipo Linear/IBM Carbon) y **no** una dirección de marketing. Consecuencias concretas: sin gradientes decorativos, sin ilustraciones de hero, sin animación ambiental; la jerarquía se construye con escala tipográfica, peso, capa tonal y espacio.

*Alternativa:* una dirección premium tipo Stripe/Apple (más expresiva). Se descarta porque el brief es un portal interno de un operador, donde la densidad y la claridad superan a la expresividad, y porque la librería de diseño advierte que el gradiente azul/púrpura es la huella genérica de IA.

*Alternativa:* dirección editorial con serifas (tipo Notion). Se descarta por el mismo motivo: añade carácter que no aporta a una herramienta de datos.

### 3. Paleta: neutros fríos unificados + un solo acento

Se reemplazan los neutros actuales por una rampa fría coherente, con dos decisiones clave: el `--color-border` sube hasta un valor que distingue el límite del control del fondo (objetivo ≥3:1 sobre blanco) y el acento se desatura ligeramente para no dominar. Los estados semánticos (éxito, aviso, peligro) se definen como pares de color y fondo teñido, no solo como color de texto.

*Alternativa:* conservar el azul `#2f5fd0` y solo oscurecer bordes. Se descarta porque la paleta heredada mezcla neutros sin criterio y no define pares semánticos.

### 4. Tipografía: una familia con carácter y una escala de siete pasos

Se sustituye la pila del sistema por **una sola familia variable** (Lexend o IBM Plex Sans, recomendadas por la base de diseño para contexto corporate/enterprise) autoalojada con `font-display: swap`. La escala pasa a siete pasos con display real (≈30 px) frente a los cinco actuales con máximo de 20 px. Los datos numéricos (nivel, contadores) usan `font-variant-numeric: tabular-nums`.

*Alternativa:* mantener la pila del sistema. Se descarta porque es una de las señales que hace que la UI lea como prototipo; el cambio de fuente es además la mejora de mayor impacto y menor riesgo según la guía de rediseño.

*Alternativa:* dos familias (display + cuerpo). Se descarta: una herramienta interna con una sola familia bien escalada gana en cohesión y evita peso de carga.

### 5. La fila de listado es la superficie interactiva

Se abandona el patrón "texto azul con enlace" como interacción principal. La fila completa es el objetivo (patrón de fila clicable), con affordance explícita de navegación, estados hover y foco, activación por teclado, y el texto del registro en color de texto normal.

*Alternativa:* mantener el enlace y solo quitar el color azul. Se descarta porque deja el problema real intacto: un objetivo de 24 x 18 px en una fila de 928 px, el peor caso posible para cursor y táctil.

### 6. El medidor de nivel 1-5 es la firma del producto

El único gasto de "atrevimiento" visual se concentra aquí: el nivel de dominio deja de ser un número y pasa a un componente de cinco posiciones (barras o puntos) con el valor siempre comprensible para tecnología de asistencia. Es el dato central del dominio y el elemento por el que la interfaz será reconocible.

*Alternativa:* dejar el nivel como número y gastar el atrevimiento en otro sitio (encabezado, navegación). Se descarta porque ningún otro elemento del producto justifica un tratamiento propio; decorar la navegación sería ornamento sin significado.

### 7. Estados diseñados: vacío con acción, carga con forma

Se reemplazan las frases sueltas ("Cargando…", "Sin resultados") por: *skeleton* que preserva la forma del contenido, estado vacío como composición que explica y propone la acción de crear el primer registro, y estado de error con motivo y acción de reintento.

*Alternativa:* mantener el texto con mejor tipografía. Se descarta porque el estado vacío es una de las superficies más visibles de un CRUD y la guía de rediseño lo marca como oportunidad desperdiciada.

### 8. Corrección de las dos regresiones medidas

El alineado del botón se resuelve en la primitiva de fila de formulario (una regla, no por pantalla) y la alineación de tabla se corrige haciendo que el alineado final dependa de la presencia real de una columna de acciones, no de "ser la última columna". Ambos arreglos entran como parte del rediseño porque la spec los exige.

## Risks / Trade-offs

- **[Regresión visual sobre funcionalidad intacta]** → El arnés E2E existente (`web/e2e.mjs`) sigue ejerciendo los flujos, y cada pantalla se verifica visualmente antes y después. La capa de datos no se toca.
- **[Fuente autoalojada añade peso y riesgo de FOIT]** → Una sola familia variable, subseteada, con `font-display: swap` y `preconnect`. Si el peso resulta inaceptable, se reevalúa sin cambiar los tokens.
- **[Un componente de nivel nuevo en cinco pantallas]** → La spec obliga a coherencia; el componente se implementa una vez como primitiva y las pantallas lo consumen, en lugar de repetir la representación.
- **[La fila completa como enlace puede romper la semántica de tabla]** → Se implementa con un enlace real dentro de la fila y una superficie que lo cubre (patrón de superposición), no con `onClick` sobre `<tr>`, para conservar semántica, foco y "abrir en pestaña nueva".
- **[Dirección minimalista puede quedar plana]** → La profundidad se resuelve por capa tonal (lienzo / superficie / superficie elevada) y no por sombras fuertes; el contrato fija los tres niveles de superficie.
- **[Alcance de accesibilidad ambiguo]** → Se limita explícitamente a lo que el contrato visual necesita (contraste de bordes y foco visibles, objetivos táctiles, movimiento reducido) y se excluye como auditoría formal, tal como fija el proposal.

## Migration Plan

1. Escribir `web/DESIGN.md` (contrato) y, a partir de él, reescribir `tokens.css`.
2. Rehacer las primitivas en `app.css` y añadir las nuevas, verificando cada una en aislamiento.
3. Migrar las cinco pantallas a las primitivas nuevas, una por una, verificando tras cada cambio.
4. Reconstruir (`npm run build`) y verificar de extremo a extremo con el arnés E2E y captura visual por pantalla.

*Rollback:* la capa de estilo está aislada del comportamiento; revertir `tokens.css`, `app.css` y los componentes restaura la superficie anterior sin tocar datos ni API.

## Open Questions

- Elección final de familia tipográfica entre Lexend e IBM Plex Sans: se decide en implementación por legibilidad en tamaños de dato; no altera tokens ni tareas.
- Si el medidor de nivel se representa con barras o con puntos: se decide probando ambas sobre una tabla densa; no altera la spec.
