# Proposal

## Why

La serpiente delata un temblor visual: avanza y retrocede unas dos celdas antes de hacer el movimiento correcto, y el descontrol se acentúa conforme come. Es el reloj del dibujado, no la simulación: el render lee `timer.time_left`, que el `Timer` reinicia antes de que la simulación avance, así que en ese frame la vista dibuja las celdas viejas con el progreso a cero y salta hacia atrás. Se midió sobre el juego real con dos relojes comparados en 500 frames: el reloj actual produjo 21 retrocesos visuales frente a 1 del reloj monótono.

## What Changes

- **BREAKING (interno)**: el reloj del dibujado deja de leer `timer.time_left`. La interpolación pasa a calcularse con un **acumulador propio** que se incrementa con el delta de frame y se ancla al mismo paso en el que la simulación avanza.
- Se elimina el nodo `Timer` de la pantalla de juego: el avance de la simulación lo marca el propio acumulador, de modo que hay **una sola fuente de tiempo** y no dos que puedan desincronizarse.
- El movimiento sigue siendo **por rejilla**: la lógica continúa avanzando celdas enteras y el dibujado interpola entre la celda anterior y la actual, exactamente como hasta ahora.
- Se añade un invariante explícito al comportamiento del dibujado: **la posición dibujada no retrocede dentro de un tick**, y al comer no se produce salto ni acelerón.
- La puntuación, el juego, las pantallas y la persistencia no cambian.

## Capabilities

### New Capabilities
<!-- Ninguna: no se introduce ninguna capacidad nueva. -->

### Modified Capabilities
- `snake-render`: el requisito **Movimiento continuo interpolado** cambia de comportamiento observable. Hoy exige interpolación entre celdas y coincidencia al final del intervalo; pasa a exigir además que la posición dibujada sea **monótona dentro del tick** (nunca retrocede) y que el cambio de intervalo al comer no produzca salto. Los requisitos de wrap, segmentos independientes y coherencia con la simulación no cambian.

## Impact

- Código afectado: `scripts/screens/game_screen.gd` (llevar el acumulador y prescindir del `Timer`) y `scripts/board_view.gd` (recibir el progreso en lugar de calcularlo desde el `Timer`).
- Simulación (`snake_game.gd`), tablero, puntuaciones y las tres pantallas quedan intactas.
- Sin dependencias nuevas, sin cambios de assets ni de configuración del proyecto.
- Regresión a cubrir: el temblor debe quedar a cero retrocesos visuales medidos frame a frame, y ese conteo debe quedar como test.
- Fuera de alcance: cualquier cambio de reglas (velocidad, wrap, crecimiento, colisión), sonido, y la redundancia de las señales `ate`/`died` de `snake_game.gd`, que se detectó pero no se toca aquí.
