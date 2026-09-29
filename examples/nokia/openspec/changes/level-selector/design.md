# Design

## Context

Ver `proposal.md` para la motivación y `openspec/changes/level-selector/specs/game-screens/spec.md` para el comportamiento. El estado actual está en `scripts/main.gd`, `scripts/screens/start_screen.gd`, `scripts/screens/game_screen.gd` y `scripts/screens/screen_layout.gd`.

Estado del que se parte, verificado:

- `main.gd` tiene tres estados como pantallas instanciadas: inicio, juego y puntuaciones. No hay enum de estados; "estado" es "pantalla hija activa".
- `start_screen.gd` tiene una sola opción, `EMPEZAR PARTIDA`, y emite `play_requested`.
- `game_screen.gd` llama a `game.start()` sin argumento, así que siempre arranca en el nivel 1.
- El motor **ya sabe arrancar en un nivel**: `snake_game.start(seed, start_level)` llama a `load_level(start_level)`, y `load_level` deja cuerpo de 3 celdas, dirección y velocidad base del nivel. Nadie lo usa desde la UI.
- `levels.gd` expone `count()`, `at(i)` y `all()`; cada nivel tiene `target`.
- `screen_layout.gd` da el fondo, la fuente de píxeles y una columna centrada reutilizable, más `center_row()`, `label()` y `button()`.

## Goals / Non-Goals

**Goals:**

- Añadir el selector como un estado más, sin reestructurar el flujo de pantallas.
- No tocar el motor, los niveles, la persistencia ni el render.
- Que el arranque por nivel elegido se comporte igual que el arranque normal, solo desde otro punto.

**Non-Goals:**

- Desbloqueo progresivo de niveles o progreso guardado.
- Acceso al selector desde la pantalla de puntuaciones.
- Cambiar reglas, dificultad, puntuación o puntuaciones máximas.

## Decisions

### El selector es una pantalla más, no un enum de estados (en vez de formalizar una máquina de estados)

El código no tiene una máquina de estados explícita: `main.gd` instancia una pantalla hija y libera la anterior. Añadir un "estado select" es añadir una rama `_show_level_select()` y su pantalla. Formalizar un enum ahora sería un refactor grande para un cambio pequeño, y dejaría dos mecanismos conviviendo.

Alternativa descartada: introducir un enum `EstadoPantalla` y un despachador. Es más "correcto" en abstracto, pero reestructura los tres estados existentes para ganar nada que este cambio necesite. Si algún día hay más estados, ese refactor se justifica solo.

### La pantalla recibe el nivel por propiedad antes de `add_child` (en vez de parámetro en `_ready`)

`_ready()` corre dentro de `add_child`, y en Godot no se puede pasar argumentos a `_ready`. La forma limpia es una propiedad pública que `main` fija antes de añadir el nodo:

```gdscript
var screen = GameScreen.new()
screen.start_level = elegido
add_child(screen)          # _ready lee start_level
```

Un parámetro en el constructor tampoco vale: `GameScreen.new()` es el constructor de la clase, y la pantalla se configura con las señales después. La propiedad es explícita y testeable.

Alternativa descartada: que `main` llame a un método `screen_play_level(n)` tras `add_child`. Funciona, pero obliga a `game_screen` a arrancar en el nivel 1 y reiniciar, con un tick de más y estado a medias. La propiedad antes de añadir no tiene ese hueco.

### `start_level` por defecto 0: el arranque normal no cambia

`game_screen.start_level` vale 0 por defecto y `_ready` hace `game.start(0, start_level)`. Así el flujo actual (`EMPEZAR PARTIDA`) no cambia de comportamiento y los tests existentes siguen valiendo sin tocarlos.

### El selector genera sus botones desde `Levels` (en vez de diez botones a mano)

Un bucle sobre `Levels.count()` crea los diez botones y los coloca en una rejilla de 2 filas por 5 columnas. La etiqueta sale del propio nivel: `"%d · %d" % [i+1, lvl.target]`, es decir número y objetivo. Ventaja: si mañana cambia el número de niveles u objetivos, el selector se adapta; y no hay diez líneas repetidas que mantener.

Alternativa descartada: diez botones escritos a mano. Se rompe en cuanto cambia la cantidad de niveles y no aporta control que el bucle no dé.

### La progresión desde el nivel elegido no necesita código

`load_level` ya encadena: al completar el objetivo llama a `load_level(index+1)` y en el último marca la partida como terminada. Arrancar en el 7 es llamar a `load_level(7)`; de ahí en adelante todo es el comportamiento que ya existe. Por eso la spec de arranque por nivel no exige tocar el motor, solo usarlo.

### La puntuación acumula desde el nivel elegido

Si se arranca en el nivel 7, el score empieza en 0 y acumula desde ahí. No se "regala" la puntuación de los niveles 1 a 6. Es coherente con que el score mida lo comido en la partida y con que el nivel alcanzado guardado sea ≥ 7. Queda escrito en la spec para que sea explícito, no un efecto colateral.

### Tests

Integración headless sobre el flujo: inicio → selector → elegir 7 → juego en el nivel 7 → completar → nivel 8. Y el arranque normal sigue yendo al nivel 1. La lógica de niveles y el motor no necesitan tests nuevos: no cambian.

## Risks / Trade-offs

- [Arrancar en un nivel avanzado con score bajo] → Es el comportamiento pedido; la tabla ordena por score, así que una partida corta desde el nivel 10 no desplazará a una completa. No requiere acción.
- [El selector y el juego comparten el nombre de nivel] → El selector solo pasa un índice; el rótulo de nivel lo sigue poniendo la pantalla de juego. Sin estado duplicado.
- [`levels.gd` cambia de tamaño o de objetivos] → El selector se genera desde `Levels`, así que se adapta sin tocar código.
- [La spec principal de `game-screens` está desactualizada] → `levels-obstacles-walls` sigue sin archivar, así que le faltan los requisitos de transición y victoria. Este delta se aplicará por encima; conviene archivar aquel cambio antes de archivar este, para no fusionar contra una versión vieja.

## Open Questions

- **Acceso al selector desde la pantalla de puntuaciones.** El flujo actual de puntuaciones ofrece "jugar otra" (va al nivel 1) y "menú" (va al inicio). Si se quisiera ofrecer también "elegir nivel" desde ahí, sería un requisito más de este cambio; de momento queda fuera de alcance por decisión de alcance, no por bloqueo técnico. No cambia el diseño ni el desglose si se añade después: es una conexión de señal más.
