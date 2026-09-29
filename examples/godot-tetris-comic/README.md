# Tetris Comic — Asset Pack para Godot 4

Assets y código para un Tetris con estética **comic pop-art**
(bordes de tinta, glossy, onomatopeyas). Sin dependencias externas.

## Estructura

```
godot-tetris-comic/
├── project.godot              # Config lista (Godot 4.2+)
├── scenes/Main.tscn           # Escena raiz (cablea Game.gd)
├── scripts/
│   ├── Tetromino.gd           # Catálogo: tipos, colores, formas, rotación
│   ├── core/                  # Reglas, sin nodos, testeable en headless
│   │   ├── Bag.gd             # Bolsa de 7: una de cada tipo por ciclo
│   │   ├── PieceFactory.gd    # Fabrica piezas y anuncia la siguiente
│   │   ├── ActivePiece.gd     # Pieza en juego (tipo, forma, posición)
│   │   ├── BoardBuilder.gd    # Grid 10x22, compone, limpia, game over
│   │   ├── FallSpeed.gd       # Intervalo de caída según líneas
│   │   └── Scoring.gd         # Puntos por líneas
│   ├── Game.gd                # Raíz de flujo: START -> PLAYING -> GAMEOVER
│   ├── StartScreen.gd         # Pantalla de inicio
│   ├── PlayScreen.gd          # Pantalla de juego (monta vista + panel)
│   ├── BoardView.gd           # Dibuja el tablero (no muta el core)
│   ├── StatsPanel.gd          # Rail derecho: SCORE / LINES / NEXT
│   ├── GameOverOverlay.gd     # Capa de fin de partida
│   ├── InputRouter.gd         # Teclas -> órdenes, con auto-repeat
│   └── SfxPopup.gd            # Onomatopeya con zoom dinámico
├── tests/godot/               # Comprobaciones ejecutables del core y flujo
├── textures/                  # PNG (bloques, piezas, sfx, fondos, hud)
├── assets/                    # SVG fuente (bloques, piezas, sfx, fondos)
├── gen_png.py                 # Regenera bloques/piezas/sfx
├── gen_bg_hud.py              # Regenera fondos/HUD
└── gen_imports.py             # Regenera los .import de Godot
```

## Cómo usarlo (3 pasos)

1. **Abre** la carpeta `godot-tetris-comic/` con Godot 4.2+ (Project Manager →
   *Import* → selecciona `project.godot`).
2. **Ejecuta** (F5). Pantalla de inicio → **Espacio** para empezar. Controles:
   - ← / → mover · **Espacio o ↑ rotar** · ↓ bajar más rápido
3. **Personaliza**: edita colores en `gen_png.py` (dict `COLORS`) y ejecuta
   `python3 gen_png.py && python3 gen_imports.py`, luego *Reimport* en Godot.

## Comprobaciones

El núcleo no depende de nodos, así que se puede validar sin abrir ventana:

```bash
for t in tests/godot/*Test.gd; do godot --headless --script "$t"; done
```

Cubren la bolsa de 7 (70 piezas → 10 de cada tipo), la rotación, la factory,
el tablero (encaje, líneas, fin de partida, puntuación, velocidad), el flujo de
pantallas y la onomatopeya.

## Notas importantes

- **Filtro de textura = Nearest** (ya puesto en `project.godot`). Con bloques
  vectoriales redondeados quizá prefieras `Linear`; cambia
  `default_texture_filter` a `1` para bordes más suaves.
- **`.import` los escribe Godot**: `gen_imports.py` existe solo para fijar el
  modo de compresión antes de la primera importación. Godot reimporta y
  reescribe estos ficheros al abrir el proyecto; no los edites a mano. Si el
  formato no coincide con el del motor, el proyecto no arranca.
- **El tablero usa Sprite2D, no `draw_texture()`**: en este entorno
  `draw_texture()` pinta las texturas en blanco; `Sprite2D` y `TextureRect`
  sí las pintan bien.
- Los **SVG** de `assets/` son la fuente editable (bloques, piezas, sfx).
  Los PNG se generaron con PIL (gradiente real) porque el renderizador SVG
  de ImageMagick no soporta `linearGradient` correctamente.

## API rápida

```gdscript
# Catálogo
Tetromino.TYPES                    # ["I","O","T","S","Z","J","L"]
Tetromino.color_of("T")            # Color("#b06cff")
Tetromino.shape("S")               # matriz 3x3
Tetromino.rotate_matrix(m, true)   # rota 90º horario
Tetromino.block_texture("T")       # bloque 64px
Tetromino.piece_texture("T")       # tetrominó ensamblado

# Core (sin nodos)
var rng := RandomNumberGenerator.new()
var b := BoardBuilder.new(PieceFactory.new(rng))   # grid 10x22
b.try_move(-1, 0)                  # mover izq
b.try_rotate(true)                 # rotar
b.step_down()                      # baja una fila o fija
b.ghost_y()                        # fila de aterrizaje
b.lines_cleared.connect(_on_lines) # signal(count, is_tetris)
b.game_over.connect(_on_over)      # signal()

FallSpeed.interval(b.lines)        # intervalo de caída (segundos)
Scoring.points(4)                  # 800 por un tetris

# Onomatopeya
var s := SfxPopup.new()
s.pop("tetris", Vector2(240, 300)) # ¡TETRIS! con zoom dinámico
```

## Contenido de texturas/

**Piezas/efectos**
- `block_{I,O,T,S,Z,J,L}{,_32,_64,_128}.png` — bloques glossy
- `piece_*.png` — tetrominós ensamblados
- `sfx_*.png` — onomatopeyas (blam, boom, wham, zap, krak, bam, tetris)

**Fondos** (`bg_*`, 480×720)
- `bg_paper.png` — papel comic con halftone y viñeta
- `bg_sky_pop.png` — cielo pop-art con sol y nubes
- `bg_action_burst.png` — explosión oscura con líneas de acción

**HUD** (`hud_*`)
- `hud_score.png`, `hud_level.png`, `hud_lines.png` — paneles de marcador
- `hud_next.png` — panel NEXT (marco para la pieza siguiente)
- `hud_bar.png` — barra de progreso
- `hud_tetris.png` — banner TETRIS! con chispas
- `hud_gameover.png` — banner GAME OVER en estrella

## SFX disponibles

`blam` · `boom` · `wham` · `zap` · `krak` · `bam` · `tetris`

---
*Generado por Bot Murray. No cruces los streams. O sí, tu decisión.*
