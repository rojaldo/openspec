# Proposal

## Why

La estructura actual del juego no soporta las reglas que debe implementar: `Board.gd` mezcla la lógica del tablero con el dibujado, no existe pantalla de inicio, no existe condición de game over (si una pieza no cabe solo se emite un aviso), no hay generación justa de piezas y los indicadores del HUD nunca se instancian. Se quiere reconstruir la estructura del juego desde cero, conservando los assets existentes (que sí se consideran correctos) y dando a cada responsabilidad un componente propio: una factory de piezas, un builder de tablero, la entrada del jugador y la presentación.

## What Changes

- **BREAKING** Se reestructura el juego en torno a capas separadas: un núcleo de reglas sin nodos (factory, bag, tablero) y una capa de presentación (pantallas, dibujado, HUD, onomatopeyas). El `Board.gd` monolítico se sustituye.
- Se añade una **pantalla de inicio** visualmente atractiva que permite comenzar partida y transita a la pantalla de juego.
- Se añade una **pantalla de juego** con el tablero a la izquierda (las piezas caen y se forman líneas) y los indicadores a la derecha (puntuación, siguiente pieza, contador de líneas).
- Se añade una **factory de piezas** que produce los 7 tipos de tetrominó.
- La generación de piezas pasa a ser **justa mediante un bolsa de 7 (7-bag)**: en cada ciclo de 7 piezas aparece una de cada tipo, con el orden barajado; al agotarse se rebaraja. Se elimina el azar uniforme actual.
- Se añade un **builder de tablero** que, al aterrizar una pieza, la compone con las piezas ya fijadas, calcula si se completan líneas y las elimina, notifica el resultado a los indicadores y a la puntuación, y solicita la siguiente pieza.
- Se añade la **condición de parada**: el builder declara game over cuando la pila ocupa más altura que el lienzo visible.
- La **entrada** pasa a ser: flechas izquierda/derecha para mover, **espacio y flecha arriba para rotar**, flecha abajo para acelerar la caída. **BREAKING** respecto a hoy, donde espacio no se usa y arriba rota.
- La **velocidad de caída es incremental** en función de las líneas completadas: mínima al empezar y creciente a medida que se completan líneas.
- Al completar una línea aparece una **onomatopeya con un zoom dinámico** para dar aspecto de cómic.
- Se añade una **pantalla de fin de partida** como capa superpuesta al tablero congelado, con opción de **reintentar** y de **volver al menú**.

## Capabilities

### New Capabilities

- `game-flow`: máquina de estados de la aplicación (inicio, partida, fin de partida) y sus transiciones, incluyendo el fin de partida superpuesto con reintentar y volver al menú.
- `piece-generation`: la factory de piezas y la bolsa de 7 que garantiza una distribución justa de los 7 tipos.
- `board-builder`: composición de la pieza que aterriza con las ya fijadas, detección y eliminación de líneas, cálculo de puntuación, notificación al panel y condición de game over por altura ocupada.
- `player-input`: mapeo de teclas del jugador, rotación, desplazamiento horizontal y aceleración de la caída.
- `fall-speed`: velocidad de caída de la pieza en función de las líneas completadas.
- `hud-and-score`: indicadores de puntuación, líneas completadas y siguiente pieza, y el reparto de puntos por líneas.
- `line-clear-sfx`: onomatopeya con animación de zoom que se muestra al completar una línea.

### Modified Capabilities

<!-- Ninguna: el proyecto aún no tiene specs (openspec/specs/ está vacío). -->

## Impact

- **Se reescriben**: `scripts/Board.gd` (se divide en núcleo y vista), `scripts/Game.gd` (pasa a ser la raíz de flujo de pantallas) y `scripts/Hud.gd` (panel de indicadores).
- **Se conserva**: `scripts/Tetromino.gd` como catálogo estático de tipos, formas, colores y rotación.
- **Se conserva y reutiliza**: `scripts/SfxPopup.gd` para la onomatopeya, ajustando su animación al zoom solicitado.
- **Escenas**: `scenes/Main.tscn` deja de ser la escena única de juego; se añade la estructura de pantallas.
- **Assets reutilizados sin modificar**: los 7 fondos/paneles de HUD, las 7 onomatopeyas, los 7 sprites de piezas ensambladas y los bloques `block_*_64.png`. Los bloques de 32/128 px y los `hud_*` con cifras impresas quedan sin uso al pasar el panel a pintarse con valores reales.
- **Sin dependencias nuevas**: no se añaden librerías ni servicios externos.
- **Requisito previo conocido (fuera del alcance de este cambio)**: los ficheros `textures/*.png.import` versionados están malformados y provocan que el motor aborte con un fallo de segmentación al abrir o ejecutar el proyecto. Es necesario corregir la importación para poder ejecutar y verificar cualquier trabajo. No es un requisito de comportamiento, por lo que no genera spec.
