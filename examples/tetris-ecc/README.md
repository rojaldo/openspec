# Tetris Comic — Godot 4

Tetris con estética cómic pop-art, construido **desde cero** en GDScript sobre el
motor Godot 4, usando los assets del pack `tetris-comic` tal y como están pensados
(bloques glossy, fondos de viñeta, paneles de HUD, onomatopeyas).

## Cómo ejecutar

1. Abre esta carpeta con Godot 4 (Project Manager → *Import* → `project.godot`).
2. Pulsa **F5**. La escena principal es `scenes/Main.tscn`.

### Controles
- **← / →** mover la pieza
- **↑** rotar
- **↓** bajar rápido (soft drop)
- **Espacio** caída instantánea (hard drop)
- **Enter** iniciar / reiniciar partida
- **Esc** volver al título (desde GAME OVER)

> Las teclas de inicio/reinicio (**Enter**) y de hard drop (**Espacio**) están
> **separadas a propósito** (decisión I3): `ui_accept` en Godot incluye Espacio,
> y reutilizarlo haría que la misma tecla que suelta una pieza reiniciase la
> partida. Por eso `start` es una acción propia en `project.godot`.

### Tests (headless)
```bash
godot --headless --path . --script res://tests/smoke_test.gd        # lógica + patrones
godot --headless --path . --script res://tests/fsm_test.gd          # máquina de estados (patrón 7)
godot --headless --path . --script res://tests/flow_test.gd         # gobernanza FSM (GameFlow)
godot --headless --path . --script res://tests/hud_test.gd          # pantallas del HUD
godot --headless --path . --script res://tests/integration_test.gd  # flujo completo + cableado
```

## Patrones de diseño y dónde viven

| # | Patrón | Script | Responsabilidad |
|---|--------|--------|-----------------|
| 5 | **Orbol** | `scripts/orbol.gd` | Genera y distribuye piezas con **bolsa de 7**: garantiza 10 de cada tipo por cada 70 tiradas. |
| 1 | **Factory** | `scripts/piece_factory.gd` | Elige y crea (`Piece`) la siguiente pieza a caer. |
| 6 | **Command** | `scripts/piece_command.gd` | `SetNextPieceCommand` comunica al canvas (HUD) la pieza siguiente. |
| 2 | **Composite** | `scripts/composite_pile.gd` | `Cell` (hoja) + `Pile` (compuesto): la pila + la pieza nueva se tratan como **una unidad cohesiva**. |
| 3 | **Builder** | `scripts/line_builder.gd` | Detecta y elimina la(s) fila(s) completa(s) y colapsa la pila. |
| 4 | **Observer** | `scripts/line_subject.gd` + `scripts/score_observer.gd` | El sujeto notifica la línea eliminada; `ScoreObserver` sube score/líneas/nivel; el HUD también observa. |
| 7 | **State (FSM)** | `scripts/game_state_machine.gd` | Gobierna el ciclo de vida con 3 estados (START/PLAYING/GAME_OVER) y una tabla de transiciones válidas. Añadido por requisito explícito del usuario. |

El flujo del enunciado se orquesta en dos capas:

- `scripts/game_flow.gd` — **gobernanza pura** (RefCounted, sin escena): es el
  *composition root* de los 6 patrones + el FSM, y la **autoridad única** del
  estado del juego. Expone `press_start()`, `return_to_title()`, `tick()`,
  `move()`, `rotate()`, `hard_drop()`.
- `scripts/game_controller.gd` — **adaptador fino** (Node): traduce input/frames
  a llamadas sobre `GameFlow` y refleja el estado en la vista. No tiene lógica
  de juego.

Flujo: `Orbol → Factory → Command → caída → Composite → Builder → Observer →
siguiente pieza → fin de partida (el modelo avisa; el FSM pasa a GAME_OVER)`.

### Máquina de estados (patrón 7)

| Estado | Significado | Pantalla |
|---|---|---|
| `START` | Pantalla inicial; el juego aún no existe | Título + "PULSA ENTER" |
| `PLAYING` | Partida en curso | Tablero + marcador |
| `GAME_OVER` | Partida terminada; tablero congelado | Explosión + "GAME OVER" + "ENTER: JUGAR  ESC: TÍTULO" |

Transiciones válidas (tabla explícita en `game_state_machine.gd`):

```
START     -> PLAYING            (Enter)
PLAYING   -> GAME_OVER          (la pila invade el buffer)
GAME_OVER -> PLAYING            (Enter, reinicia)
GAME_OVER -> START              (Esc, vuelve al título)
```

Todo lo demás es **ilegal** (p.ej. `PLAYING -> START`, no se aborta a mitad) e
idempotente (`X -> X` no emite nada). El tablero solo existe durante PLAYING:
cada entrada a PLAYING construye una partida **limpia** (tablero y marcador a
cero), así el reinicio es real.

## Decisiones razonadas (ambigüedades resueltas)

- **Uniformidad "10 de cada tipo por cada 70"** → bolsa de 7 (7-bag). Cualquier
  bloque de 7 tiradas contiene una de cada; cualquier bloque de 70 contiene 10 de
  cada. Uniforme *y* sin sequías.
- **Buffer de seguridad de 2 celdas** → el grid tiene **22 filas**: 2 de buffer
  invisibles arriba + 20 visibles. El buffer lo usan el spawn y los *wall kicks*,
  de modo que una pieza nunca puede salir por arriba.
- **Fin de partida** → cuando una celda depositada ocupa el buffer, o una pieza
  nueva no cabe al aparecer.
- **Puntuación** → 100/300/500/800 (×nivel) para 1/2/3/4 filas; nivel = 1 + líneas/10.
- **El FSM es la autoridad única (A2)** → se eliminó `model.is_over`. El modelo
  solo *detecta* el fin de partida y emite `game_over`; el estado lo mantiene
  `GameStateMachine`. Grep de `is_over` → 0 referencias vivas.
- **Teclas separadas (I3)** → `start` (Enter) para iniciar/reiniciar; Espacio
  sigue siendo hard drop. Evita el choque "la tecla que suelta la pieza reinicia".
- **Tablero gobernado por el FSM (S1)** → `board_view.show_board`: oculto en
  START, visible en PLAYING y GAME_OVER (tablero congelado bajo la explosión).
- **GAME OVER persistente (G1)** → se dibuja por estado, no como banner
  transitorio; `flash_banner` conserva solo su uso para "tetris".

## Estructura

```
project.godot          # 480×720, filtro Nearest, gl_compatibility
scenes/Main.tscn       # GameController + BoardView + Hud + SfxLayer
scripts/
  tetromino.gd         # datos de las 7 piezas (tipos, formas, colores, texturas)
  orbol.gd             # [5 ORBOL]
  piece.gd             # producto del Factory
  piece_factory.gd     # [1 FACTORY]
  piece_command.gd     # [6 COMMAND]
  composite_pile.gd    # [2 COMPOSITE]
  line_builder.gd      # [3 BUILDER]
  line_subject.gd      # [4 OBSERVER]  (sujeto)
  score_observer.gd    # [4 OBSERVER]  (observador)
  board_model.gd       # reglas + orquestación de los 6 patrones
  board_view.gd        # "canvas": dibuja tablero, pila, fantasma, pieza activa
  hud.gd               # marcador + NEXT (observador y receptor del Command)
  sfx_popup.gd         # onomatopeya comic animada al limpiar líneas
  game_state_machine.gd # [7 STATE/FSM] tabla de transiciones del juego
  game_flow.gd         # gobernanza pura: compone 6 patrones + FSM
  game_controller.gd   # adaptador fino: input/frames -> GameFlow -> vista
tests/
  smoke_test.gd        # aserciones de lógica y patrones
  fsm_test.gd          # tabla de transiciones del FSM
  flow_test.gd         # gobernanza FSM (GameFlow puro)
  hud_test.gd          # pantallas del HUD + gate del tablero
  integration_test.gd  # flujo completo + cableado de la escena
textures/              # PNG del pack (usados tal cual)
assets/                # fuentes SVG del pack (sin tocar)
```

## Notas de compatibilidad

Los ficheros `.import` que traía el pack (generados para Godot 4.2) hacían
crashear el escáner de Godot 4.7; se eliminaron a propósito y Godot los regenera
al abrir el proyecto por primera vez.
