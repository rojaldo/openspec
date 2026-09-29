# Design

## Context

Ver `proposal.md` para la motivación. Lo que condiciona el diseño:

- **Assets ya generados y fijos.** Los fondos son 480x720, exactamente el viewport (`project.godot`). Los paneles de HUD traen cifras impresas (`042750`, `07`, `148`), los 7 sprites de piezas y las 7 onomatopeyas están sin usar, y `block_*_64.png` (64x64) es el bloque que usa el código.
- **Estado actual del código** (medido, no supuesto):
  - `Board.gd` (169 líneas, `Node2D`) mezcla lógica de juego y `_draw()`.
  - `Game.gd` instancia a mano `TetrisBoard` y `SfxPopup`; no hay máquina de estados.
  - `ComicHud` no se instancia en ninguna escena ni script.
  - No existe condición de game over: `spawn()` solo hace `push_warning`.
  - La generación es `TYPES[rng.randi() % 7]`, azar uniforme.
  - `scenes/Main.tscn` es la única escena.
- **`bg_paper.png` medido**: el marco oscuro va de x=10..469 e y=10..709. No es una tarjeta interior, es la página completa con borde fino.
- **Presupuesto de espacio**: 20 filas x 64 px = 640 y 10 columnas x 32 = 320. Con `CELL=32` el tablero mide 320x640, que cabe en el interior del papel (459x699). Un rail de 104 px queda a la derecha.

## Goals / Non-Goals

**Goals:**

- Separar reglas de juego de presentación, de forma que el núcleo se pueda ejecutar sin ventana ni nodos.
- Fijar la geometría de la pantalla de juego (tablero, rail, fondos) para que el resto de decisiones (tamaño de onomatopeya, panel) salgan de ella.
- Definir la curva de velocidad y el modelo del tablero (2 filas ocultas) con valores concretos.
- Aprovechar los assets existentes sin regenerar arte.

**Non-Goals:**

- No se regenera ni modifica ningún PNG ni SVG.
- No se añade nivel visible, hard drop, rotación antihoraria, lock-delay, wall kicks avanzados, hold, ni marcador de puntuación máxima.
- No se corrige aquí el defecto de importación de texturas (ver `proposal.md` - Impact); es requisito previo, no parte de este cambio.
- No se decide el estilo tipográfico definitivo del panel más allá de reproducir el look cómic con texto vivo.

## Decisions

### D1. Núcleo sin nodos frente a una escena que lo haga todo

El núcleo (`PieceFactory`, `Bag`, `BoardBuilder`, `ActivePiece`, `Tetromino`) son `RefCounted`, sin dependencia de `Node`. La vista (`BoardView`, `StatsPanel`, `StartScreen`, `SfxPopup`, `GameRoot`) son nodos que consultan y reaccionan.

- **Por qué**: es lo que arregla el "no me convence" del estado actual. Permite probar el juego sin abrir ventana y aísla la causa del fallo de arranque.
- **Alternativas**: dejar `Board.gd` como `Node2D` y añadir un `Builder` como nodo hermano. Rechazada: mantiene dos fuentes de verdad sobre la rejilla y sigue sin ser testeable sin motor.

### D2. `BoardBuilder` como autoridad única de la altura ocupada

El builder es el único dueño de la rejilla y del estado de la partida (pieza activa, líneas, fin de partida), y expone señales. La vista no muta nunca la rejilla.

- **Por qué**: el builder es exactamente la pieza que falta hoy; centraliza "compone + calcula + notifica + pide pieza".
- **Alternativas**: repartir la responsabilidad entre un `Board` (colisión) y un `Builder` (líneas). Rechazada: dos objetos que comparten la rejilla es la mezcla que se quiere eliminar.

### D3. Tablero de 22 filas (2 ocultas), no 20

`ROWS_TOTAL = 22`, `ROWS_HIDDEN = 2`. Render: fila `f` se dibuja en `y = (f - 2) * CELL`. Fin de partida: una celda fijada en fila `< 2`.

- **Por qué**: implementa la condición que pediste ("la pila supera la altura del canvas") sin el efecto feo de perder al nacer. Es el modelo estándar.
- **Alternativas**: (a) 20 filas sin buffer, fin de partida cuando la pieza nueva no cabe. (b) buffer de 4 filas. Se descartó (a) por no poder expresar la regla pedida y (b) por coste sin beneficio.
- **Detalle del spawn**: la pieza nace con su **borde inferior en la fila 2** (la primera visible), no con su esquina en una fila abstracta. Así siempre asoma algo en pantalla al aparecer, sin depender del alto de cada forma.

### D4. Bolsa de 7 como única fuente de tipos

`Bag` baraja los 7 tipos, los sirve uno a uno y rebaraja al agotarse. `PieceFactory` es la única puerta de entrada a `Bag`, y expone además "siguiente".

- **Por qué**: cumple la justicia pedida (10 de cada tipo por cada 70 piezas) y el anuncio de la pieza siguiente sin lógica duplicada.
- **Alternativas**: cola de 7 con corrección de historial. No aporta sobre la bolsa y complica.

### D5. Velocidad como función continua de las líneas

`intervalo(lineas) = max(0.08, 0.8 * 0.85 ^ (lineas / 10))`.

- **Por qué**: sube en cada línea sin esperar a múltiplos de 10 (tu requisito), y con suelo fijo evita el injugable. Reutiliza el 0.8 s que ya existía y suaviza hacia un 0.08 s alcanzable.
- **Alternativas**: tabla por escalones cada 10 líneas (más "clásico" pero discreto, y no cumple "cada fila"); escala lineal (se siente brusca al principio y pronto imposible).
- **Nota**: el intervalo de caída y la cadencia del jugador (auto-repeat, soft drop) son independientes, por eso la velocidad alta no impide mover/rotar.

### D6. Panel pintado con valores vivos, no los PNG con cifras

El rail derecho se compone de marcos estilo cómic dibujados y texto real. `piece_*.png` se usa para la previsualización (1 sprite en vez de 4 bloques). Los `hud_*` con cifras quedan fuera; `hud_gameover.png` se reutiliza en la capa de fin de partida.

- **Por qué**: es la opción 3 acordada. Los paneles con número impreso no pueden mostrar valores reales.
- **Alternativas**: escalar los PNG a ~0.5x en un rail de 104 px (opción 2) — las cifras impresas caerían a 7-14 px, ilegibles.

### D7. Fin de partida como capa superpuesta, no escena aparte

`bg_action_burst` oscurecido + `hud_gameover.png` + puntuación + dos acciones (reintentar, menú), sobre el tablero congelado.

- **Por qué**: elegiste la opción B y quieres ver la pila que te mató. Además evita reconstruir la escena de juego al reintentar.
- **Alternativas**: cambiar de escena a un game over a pantalla completa. Rechazada: pierde el contexto y duplica el montaje.

### D8. Geometría fijada

```
CELL=32   tablero 320x640 en x=24..344, y=40..680 (centrado vertical)
panel 104 px en x=354..458: SCORE y=196, LINES y=304, NEXT y=392
          bloque de 328 px centrado en y=360 (7 px al tablero, 6 px al marco)
bg_paper.png a pantalla completa; tablero y panel como viñetas dibujadas encima
onomatopeya centrada en la PANTALLA (240,360), no en el tablero
```

- **Por qué**: es la única geometría que da tablero nativo (320) con los assets intactos, como acordamos.
- **Consecuencia aceptada**: el panel es fino (104 px), no un panel grande como en la referencia.
- **Centrado del panel**: los bordes de tinta medidos dejan libre la franja 348..463 (el borde derecho del tablero está en x=347 y el marco del papel empieza en x=464). Con el panel en 354..458 queda a 7 px del tablero y 6 px del marco, equilibrado; en la primera versión (360..464) se pegaba al marco con 5 px.
- **Centrado vertical del bloque**: las tres tarjetas suman 328 px y se centran en y=360 (el centro de la pantalla), no colgando desde el borde superior. En la primera versión ocupaban y=0..328, con el bloque 196 px por encima del centro.
- **Centrado de la onomatopeya**: sobre el centro de la pantalla, no sobre el del tablero. Centrarla en el tablero la dejaba 56 px a la izquierda (184 frente a 240).

### D9. Máquina de estados

```
START --empezar--> PLAYING --fin de partida--> GAMEOVER
  ^                  |                            |
  |                  +-- teclas de juego          |
  |                                               |
  +<---------------- MENU -------- REINTENTAR ---+
                                    (vuelve a PLAYING sin pasar por START)
```

- **Por qué**: mantiene las tres pantallas como estados de una raíz estable, y hace explícito cuándo la entrada de juego está activa (solo en `PLAYING`).

### D10. Zoom de la onomatopeya dentro del ancho de pantalla

Las onomatopeyas son lienzos de 512x214 y la pantalla mide 480: la tinta ya ocupa casi todo el lienzo, así que a escala 1.0 las mayores (`wham` y `boom` llenan los 512 px, `blam` 505, `tetris` 498, `krak` 494) ya tocan o rozan los bordes de la pantalla. Medido con el sprite centrado en x=240, la escala máxima sin recortar ninguna palabra es **0.9375** (la impone `wham`/`boom`).

```
0.7 s, misma velocidad que antes, mas recorrido:
  inicio 0.15  ->  pico 0.93  ->  asienta 0.88
```

- **Por qué**: "más pronunciado" se consigue multiplicando el recorrido por 6 (0.15→0.93 frente a 0.35→1.15) sin pasar del techo de 0.9375, que es donde empieza el recorte. Un pico de 0.95 ya recortaría 6 px de `wham`, `boom` y `blam`.
- **Alternativas**: (a) subir el pico por encima de 0.9375 y aceptar el recorte lateral — es efecto cómic legítimo, pero pierde tinta de la palabra; (b) normalizar cada asset por su caja visible para que todas acaben igual de grandes sin recortar — más código de preparación. Se eligió mantener el techo y estirar el recorrido.
- **Nota**: el zoom es sobre el tamaño natural del asset, no una promesa de igual tamaño entre onomatopeyas; a la misma escala, `zap` (380 px de tinta) se ve más pequeña que `wham` (512 px).

## Risks / Trade-offs

- **[El proyecto no arranca: los `.import` versionados tienen `path=` apuntando al propio PNG, lo que provoca recursión en `realpath()` y aborta el motor]** → Requisito previo bloqueante: borrar los `textures/*.png.import` y dejar que el motor reimporte (`godot --headless --import`) antes de ejecutar o verificar. No es parte del cambio pero sin ello no hay verificación posible.
- **[La pieza puede aparecer total o parcialmente en la zona oculta]** → Aceptado: se ancla el borde inferior a la fila visible 2 para que siempre asome. En el peor caso (pieza alta) asoma menos, nunca cero.
- **[Piezas apiladas que se limpiarían en la zona oculta]** → Las líneas sólo se evalúan y eliminan en filas visibles, con lo que la zona oculta no "regala" líneas. El fin de partida se comprueba sobre celdas fijadas, de modo que un tetris que rellene la oculta no evita la derrota.
- **[Cambio grande: se reescriben las tres piezas de lógica y se toca la escena]** → Mitigación: el núcleo sin nodos se puede validar con comprobaciones ejecutables del 7-bag, la composición y la velocidad antes de tocar la vista.
- **[Onomatopeyas apiladas en cascadas rápidas]** → Mitigación: un solo elemento de onomatopeya reutilizado; al llegar una nueva, reinicia la animación en vez de crear otra.
- **[Rail de 104 px estrecho en pantallas muy pequeñas]** → Mitigación: el viewport es fijo (480x720, `stretch` a keep), así que el rail no se encoge.

## Migration Plan

Cambio de reescritura, sin datos que migrar. Orden de trabajo en `tasks.md`: (1) desbloquear la ejecución del proyecto, (2) núcleo con sus comprobaciones, (3) vista de la pantalla de juego, (4) flujo de pantallas, (5) pulido (onomatopeya y fin de partida). Rollback: el proyecto NO está en git (0 ficheros versionados), así que la vuelta atrás real es un snapshot previo. Se guardó en `/tmp/opencode/pre-reestructurar-tetris/project.tar.gz` antes de tocar nada; contiene los `scripts/` y `scenes/` originales. Si ese snapshot se pierde, la vuelta atrás deja de ser posible.

## Open Questions

- Qué fondo y qué composición exacta de título y textos usa la pantalla de inicio (`bg_sky_pop` está reservado y `hud_tetris.png` trae "TETRIS!" pintado; queda por decidir si se añade un subtítulo y cómo se indica "pulsa para empezar"). No afecta a specs, enfoque ni tareas.
- Estilo tipográfico concreto del panel (reutilizar la fuente de `gen_bg_hud.py` o una del tema por defecto). No afecta a specs ni al desglose de tareas.
