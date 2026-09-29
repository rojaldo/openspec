# Proposal

## Why

El juego tiene hoy un único escenario sin obstáculos ni paredes: la serpiente cruza los bordes y reaparece en el lado opuesto, así que la única dificultad es la velocidad y crecer. Se quiere convertirlo en un juego de **10 niveles de dificultad creciente** con obstáculos y paredes, donde el borde pueda ser atravesable o mortal según el nivel, y donde el jugador avance de nivel al comer un número de cocos.

## What Changes

- Nuevo **sistema de niveles**: una partida recorre los 10 niveles en orden, con una sola vida. Cada nivel define su mapa (paredes, obstáculos, punto de inicio, dirección inicial), su borde y su objetivo.
- **Paredes y obstáculos**: celdas sólidas. Entrar en una celda sólida termina la partida, igual que chocar contra el cuerpo. Paredes y obstáculos comparten comportamiento; se distinguen por su posición y su dibujado.
- **Borde condicional por nivel**: unos niveles conservan el wrap-around y otros usan borde mortal, **BREAKING** respecto al requisito actual *Wrap-around en los bordes*, que pasa de regla global a propiedad del nivel.
- **Objetivo por nivel**: comer N cocos para superar el nivel (N por defecto 5, configurable por nivel). Completar el nivel 10 termina la partida en victoria.
- **Reinicio de estado al empezar cada nivel**: la serpiente vuelve a su tamaño original (3 celdas) y la velocidad vuelve al intervalo base (el mismo en todos los niveles). La puntuación **sí acumula** entre niveles.
- **Velocidad progresiva por nivel**: comer acelera la serpiente dentro del nivel, con un incremento mayor en niveles avanzados; el intervalo base es idéntico en los 10 niveles, de modo que el jugador reconoce cada mapa con calma antes de que suba la presión.
- **Inicio de nivel seguro**: cada nivel fija la posición y dirección iniciales con un invariante de jugabilidad (cuerpo libre, celda frontal libre, un escape perpendicular libre), para que nunca aparezca un sólido pegado a la cabeza.
- **Comida siempre alcanzable**: el coco se elige entre las celdas alcanzables desde la cabeza, de modo que un mapa mal cerrado nunca deje el nivel sin completar.
- **Progresión visible**: el nivel actual y el progreso del objetivo se muestran en la pantalla de juego, con un rótulo breve al empezar cada nivel y al superarlo.
- **Puntuaciones con nivel alcanzado**: cada entrada de la tabla guarda además el nivel alcanzado.

## Capabilities

### New Capabilities
- `level-design`: definición de los 10 niveles (mapa, borde, inicio, dirección y objetivo) y su curva de dificultad creciente.

### Modified Capabilities
- `game-loop`: el borde pasa a ser propiedad del nivel (wrap o mortal); las celdas sólidas terminan la partida; el objetivo por nivel sustituye a la partida infinita; el inicio y el reinicio de estado por nivel cambian las reglas de arranque.
- `game-screens`: la pantalla de juego muestra el nivel y el progreso; se añade la transición entre niveles y la secuencia de victoria al superar el nivel 10.
- `high-scores`: cada entrada registra también el nivel alcanzado y la tabla lo presenta.

## Impact

- Código afectado: `scripts/logic/snake_game.gd` (borde condicional, sólidas, objetivo, reinicio), `scripts/logic/grid_config.gd` (de constantes globales a datos por nivel), `scripts/logic/scores.gd` y `scripts/screens/scores_screen.gd` (campo nivel), `scripts/screens/game_screen.gd` (nivel, objetivo, transición), `scripts/board_view.gd` (dibujado de sólidas y borde), `scripts/main.gd` (progresión de niveles).
- Capacidad nueva de datos: los mapas viven como datos del proyecto (texto), sin assets externos.
- `snake-render` queda intacta: el dibujado interpolado y el ghost del cruce de borde siguen siendo correctos; en niveles sin wrap el cruce no se produce y el ghost no se activa.
- Los tests existentes de wrap y de partida única cambian de sentido: pasan a verificar el borde según el nivel.
- Fuera de alcance: selección de nivel por el jugador, varias vidas, guardado de progreso a medias, obstáculos móviles o destructibles, power-ups y sonido.
