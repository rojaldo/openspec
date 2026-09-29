# DESIGN.md — Portal de empleados

Contrato de diseño del portal. Es la **fuente de verdad**: todo color, tamaño, espacio, radio y
duración de transición de la interfaz sale de un token declarado aquí. Si un valor no está en este
documento, no puede aparecer en el código.

Dirección: **enterprise operativo** (familia Carbon / herramientas internas). Densidad y claridad
por encima de expresividad. Sin gradientes decorativos, sin sombras de tarjeta, sin animación
ambiental. Base de referencia: IBM Carbon (`ibm.md`) como sistema de marca, con la escala
tipográfica y los pares semánticos adaptados a este proyecto.

---

## 1. Color

Neutros fríos unificados + **un solo acento**. La jerarquía no se construye con color.

### Superficies (profundidad por capa tonal, nunca por sombra)

| Token | Valor | Uso |
|---|---|---|
| `--color-canvas` | `#f4f6f8` | Fondo de la aplicación |
| `--color-surface` | `#ffffff` | Superficie base: tarjetas, tablas, cabecera |
| `--color-surface-2` | `#f9fafb` | Superficie alterna: fila cebrada, zona hundida |
| `--color-surface-elevated` | `#eceff3` | Elemento elevado sobre `surface` (hover de fila, panel) |

Ratio `canvas`↔`surface`: **1.08:1** (separación tonal deliberadamente sutil).

### Bordes

| Token | Valor | Uso | Contraste |
|---|---|---|---|
| `--color-border-subtle` | `#dfe4e9` | Divisores internos, separador de filas | 1.28:1 sobre `surface` (no es límite de control) |
| `--color-border` | `#7d8590` | **Límite de control**: borde de input, select, botón secundario | **3.44:1** sobre `canvas`, **3.73:1** sobre `surface` |
| `--color-border-strong` | `#6f7782` | Énfasis de límite (hover de control) | 4.18:1 sobre `canvas` |

Regla: cualquier borde que delimite un **control interactivo** usa `--color-border` o superior.
`--color-border-subtle` es solo decorativo y nunca delimita algo operable.

### Texto

| Token | Valor | Uso | Contraste |
|---|---|---|---|
| `--color-text` | `#16181d` | Texto principal, cifras, encabezados | 17.76:1 sobre `surface` |
| `--color-text-muted` | `#525252` | Texto secundario, pistas, metadatos | 7.81:1 sobre `surface` |
| `--color-text-disabled` | `#8d8d8d` | Texto de control deshabilitado | 3.32:1 sobre `surface` |
| `--color-text-inverse` | `#ffffff` | Texto sobre acento o superficie oscura | — |

### Acento (único)

| Token | Valor | Uso | Contraste |
|---|---|---|---|
| `--color-accent` | `#1c54c9` | Acción primaria, indicador de foco, enlace en prosa | 6.64:1 sobre `surface` |
| `--color-accent-hover` | `#1746ab` | Hover del primario | 8.40:1 |
| `--color-accent-active` | `#123a8f` | Activo/presionado | 10.36:1 |
| `--color-accent-tint` | `#eaf0fd` | Fondo teñido de selección | 1.14:1 (fondo) |
| `--color-accent-contrast` | `#ffffff` | Texto sobre `--color-accent` | 6.64:1 |

**El acento es exclusivo de la acción.** El texto de un registro, una celda o un encabezado usa
`--color-text`, nunca el acento. Un enlace dentro de prosa (no un control ni una fila) sí usa el
acento y se subraya.

### Semánticos (siempre par texto + fondo teñido)

| Token | Valor | Uso |
|---|---|---|
| `--color-danger` | `#b42318` | Texto/icono de error y peligro (6.57:1) |
| `--color-danger-bg` | `#fdecea` | Fondo de aviso de error (texto sobre él: 5.75:1) |
| `--color-danger-border` | `#f0b5b0` | Borde del aviso de error |
| `--color-success` | `#067647` | Texto/icono de éxito (5.69:1) |
| `--color-success-bg` | `#e7f6ef` | Fondo de aviso de éxito (texto sobre él: 5.10:1) |
| `--color-success-border` | `#a9d9c2` | Borde del aviso de éxito |

Un estado semántico **nunca se comunica solo por color**: siempre lleva texto y, cuando aplica, icono.

### Foco

| Token | Valor | Uso |
|---|---|---|
| `--color-focus` | `#1c54c9` | Anillo de foco |
| `--focus-ring` | `0 0 0 2px var(--color-surface), 0 0 0 4px var(--color-focus)` | Anillo de 2px separado de la superficie |

El foco es **siempre visible** en todo elemento interactivo, incluidos los que lo reciben por
programación al cambiar de pantalla. Nunca se elimina sin sustituirlo por un indicador equivalente.

---

## 2. Tipografía

**Una sola familia variable: Lexend** (autoalojada, subseteada latina, `font-display: swap`).
Fallbacks: `system-ui, -apple-system, "Segoe UI", sans-serif`.

Se usa una sola familia para toda la interfaz. Los datos numéricos (nivel, contadores) usan
`font-variant-numeric: tabular-nums`.

### Escala — siete pasos

| Token | Tamaño | Peso | Interlineado | Uso |
|---|---|---|---|---|
| `--text-display` | 30px | 600 | 1.15 | Cifra o título de impacto (inicio) |
| `--text-h1` | 24px | 600 | 1.2 | Título de página |
| `--text-h2` | 18px | 600 | 1.3 | Encabezado de sección |
| `--text-h3` | 15px | 600 | 1.35 | Encabezado de tarjeta o grupo |
| `--text-body` | 14px | 400 | 1.5 | Cuerpo de texto, celdas |
| `--text-label` | 13px | 500 | 1.4 | Etiqueta de campo, botón, columna |
| `--text-caption` | 12px | 400 | 1.4 | Metadato, pista, fecha |

Pesos permitidos: **500 (medio)** y **600 (seminegrita)** y **400 (regular)**. No se usa 700.

Reglas:
- El título de una página usa `--text-h1` y se distingue del cuerpo por tamaño **y** peso, no solo
  por posición. La escala tiene rango real: `display` (30px) frente a `caption` (12px).
- Interlineado de titulares: 1.15–1.35. Cuerpo: 1.5.
- Ancho de lectura de prosa limitado a ~65 caracteres (`max-width: 65ch`).
- Sin `letter-spacing` en tamaños de display; solo microajuste (0.2px) hasta 13px si la legibilidad
  de la familia lo pide.

---

## 3. Espaciado y forma

Base **4px**. Escala: `--space-1` 4 · `--space-2` 8 · `--space-3` 12 · `--space-4` 16 · `--space-5` 24 ·
`--space-6` 32 · `--space-7` 48 · `--space-8` 64.

| Token | Valor | Uso |
|---|---|---|
| `--radius-sm` | 4px | Controles, botones |
| `--radius-md` | 6px | Tarjetas, superficies |
| `--radius-full` | 999px | Solo pastillas de nivel |

Radios pequeños y deliberados. Cero sombras de tarjeta: la profundidad es por capa tonal (§1).

| Token | Valor | Uso |
|---|---|---|
| `--control-h` | 36px | Altura de input, select y botón en fila de formulario |
| `--control-h-sm` | 32px | Control compacto (botón de fila) |
| `--message-h` | 18px | Altura reservada de pista/error bajo un control |
| `--tap-min` | 40px | Altura mínima de un objetivo interactivo |

---

## 4. Primitivas

Toda primitiva declara sus estados. Ningún componente define valores propios.

### `.app-shell` — contenedor
Ancho máximo **1200px**, centrado, padding lateral `--space-6` (16px en móvil).

### `.page-header` — cabecera de página
Título (`--text-h1`) + zona de acciones a la derecha. Borde inferior `--color-border-subtle`.
Presente en las cinco pantallas; sustituye al `h1` suelto.

### `.nav` — navegación
Enlaces en `--text-label` con `--color-text-muted`; activo en `--color-text` con subrayado de
`--color-accent` de 2px. Estados: reposo, hover (`--color-text`), foco (anillo), activo.
Nunca usa el color de acento para el texto del enlace de navegación.

### `.table` — tabla
Superficie contenida en `--color-surface` con `--color-border-subtle` como separador de filas (sin
bordes de celda). Altura de fila consistente (`--space-2` vertical). Cabecera en `--text-label` y
`--color-text-muted`, distinguida de las celdas por peso y color. Fila cebrada opcional con
`--color-surface-2`.

**Alineación:** el alineado final se aplica **solo a una columna de acciones realmente presente**,
nunca a "la última columna". Una tabla de una sola columna de datos alinea todo al inicio del texto.

### `.row-link` — fila de listado interactiva
El **registro completo es la superficie interactiva**. Anatomía: enlace real que cubre la fila
(patrón de superposición) con `::after` a toda la celda, más una affordance de navegación visible
(chevron) al final de la fila. Estados: reposo, hover (`--color-surface-2`), foco (anillo en la
fila), activo.

Reglas:
- El texto del registro usa `--color-text`, **no** el acento. No aparenta ser un hipervínculo.
- Toda la fila es activable con puntero y con teclado (Tab + Enter).
- El enlace es real, así que admite abrir en pestaña nueva y expone la URL al pasar el cursor.
- Objetivo táctil: la fila completa, con altura ≥ `--tap-min`.

### `.field` — campo de formulario
Etiqueta (`--text-label`) + control + mensaje (`--text-caption`). El mensaje reserva altura
(`--message-h`) para que el layout no salte al aparecer el error.

**Dimensionado por contenido:** el ancho del campo responde a lo que espera contener.

| Variante | Ancho | Ejemplo |
|---|---|---|
| `--field-narrow` | 160px | Nivel 1–5, cantidad corta |
| `--field-default` | 280px | Nombre corto (capacidad, empleado) |
| `--field-wide` | flexible | Término de búsqueda abierto |

Estados del control: reposo (`--color-border`), hover (`--color-border-strong`), foco
(`--color-focus`), deshabilitado (`--color-surface-2` + `--color-text-disabled`), error
(`--color-danger` en borde y mensaje).

### `.form-row` — fila de formulario
Alinea los hijos por la **caja del control**, no por el pie del `.field`: el botón de envío comparte
la altura y los bordes superior e inferior con el control. Los mensajes de cada campo y el botón
quedan en líneas ópticas distintas **a propósito**, para que el botón coincida con el control.

### `.btn` — botón
Altura `--control-h`. Variantes: `--primary` (fondo `--color-accent`, texto `--color-accent-contrast`),
`--secondary` (superficie + `--color-border`), `--danger` (texto `--color-danger`, borde
`--color-border`), `--ghost` (sin borde, texto acento). Estados: reposo, hover, foco, activo
(`translateY(1px)`), deshabilitado. Transición en `transform`, `background` y `border-color` (120ms).

### `.level-meter` — medidor de nivel 1–5 (firma)
Representa el nivel de dominio como **cinco posiciones** con las activas en `--color-accent` y las
inactivas en `--color-border-subtle`. El valor numérico acompaña al medidor en `--text-label` con
`tabular-nums`, y el conjunto expone `role="img"` con `aria-label="Nivel N de 5"`. Es el único
elemento con tratamiento visual propio; el resto de la interfaz se mantiene disciplinado.

### `.state` — estados de listado
- **Carga:** *skeleton* que preserva la forma del contenido (filas fantasma a la altura real, no un
  spinner genérico).
- **Vacío:** composición centrada con título, una frase de contexto y la acción sugerida
  (p. ej. "Añadir la primera capacidad"). No es una frase suelta en gris.
- **Error:** motivo devuelto por el servidor + acción de reintento. Nunca un `window.confirm` ni un
  `alert` nativo.

### `.alert` — aviso
Variantes `--error` / `--success` usando el par (texto, fondo teñido, borde) de §1. Borde izquierdo
de 3px en el color semántico. `role` según contexto: `alert` para error, `status` para éxito.

---

## 5. Movimiento

| Token | Valor |
|---|---|
| `--duration-fast` | 120ms |
| `--duration-base` | 160ms |
| `--ease` | `cubic-bezier(0.2, 0, 0, 1)` |

Solo se animan `transform`, `opacity`, `background-color` y `border-color` — propiedades compuestas,
nunca `width`, `height`, `top` o `left`. El movimiento sirve a un cambio de estado real: no hay
animación decorativa ni hover que no cambie nada.

`@media (prefers-reduced-motion: reduce)` reduce todas las transiciones a ~0ms.

---

## 6. Responsive

Breakpoints: **640px** (móvil→tableta), **1024px** (tableta→escritorio). Enfoque *mobile-first*.

- El contenedor pasa de ancho completo con padding de 16px a 1200px centrado.
- Las filas de formulario apilan sus campos por debajo de 640px; el botón pasa a ancho completo.
- Las tablas conservan alineación y permiten desplazamiento horizontal en lugar de romper columnas.
- El medidor de nivel reduce el tamaño de sus posiciones pero mantiene los cinco.

---

## 7. Accesibilidad (parte del contrato)

- Contraste: texto ≥4.5:1; límites de control y foco ≥3:1. Valores verificados en §1.
- Foco visible en todo interactivo, incluido el recibido por programación al cambiar de pantalla.
- Objetivos interactivos ≥ `--tap-min` (40px) de alto; las filas usan la fila completa.
- El estado nunca se comunica solo por color.
- Movimiento reducido respetado (§5).
- Un solo `h1` por pantalla, provisto por `.page-header`.

---

## 8. Deuda aceptada

- **Sin modo oscuro.** Los tokens están nombrados por rol para permitir un tema oscuro futuro sin
  refactor, pero no se implementa ahora (fuera de alcance del change).
- **Sin set de iconos completo.** Solo se incorporan los SVG necesarios (chevron de navegación,
  iconos de estado). No se adopta una librería de iconos.
- **Fuente única, sin display alternativo.** Si Lexend resulta poco legible en tablas densas, se
  reevalúa la familia sin cambiar los tokens de tamaño.
