# Proposal

## Why

Se quiere un juego tipo Snake que emule el clásico de los Nokia: una serpiente que se mueve por un escenario fijo, come elementos que aparecen al azar y crece con cada uno, subiendo de velocidad para aumentar la dificultad, y termina cuando se choca contra su propio cuerpo. La puntuación es el número de elementos comidos y queda registrada con el nombre del jugador. Hoy no existe ni el proyecto Godot ni ninguna especificación; esta propuesta fija el comportamiento antes de implementar.

## What Changes

- Nuevo **bucle de juego sobre rejilla** con avance por *ticks*: la serpiente ocupa celdas de un tablero de tamaño fijo, come cocos que aparecen en posiciones libres aleatorias y crece al comer.
- **Movimiento continuo en pantalla**: aunque la simulación avanza por celdas, el dibujado interpola cada segmento entre su celda anterior y la actual, de modo que la serpiente no se mueve "a golpes".
- **Bordes con wrap-around**: al salir por un lado la serpiente entra por el opuesto. En el render ese cruce se dibuja de forma fluida (el segmento que cruza se pinta a ambos lados del borde), sin salto visual.
- **Dificultad progresiva**: cada coco comido incrementa la puntuación y reduce el intervalo del tick, con un límite mínimo de velocidad para que el juego siga siendo jugable.
- **Fin de partida por auto-colisión**: la partida termina cuando la cabeza ocupa una celda del cuerpo que no acaba de liberarse. No hay paredes mortales.
- **Tres pantallas**: inicio (empezar partida), juego, y puntuaciones (puntuación final + tabla persistente con el nombre del jugador).
- **Persistencia de puntuaciones** en almacenamiento local del usuario (`user://`), con nombre introducido por el jugador en la pantalla final.

## Capabilities

### New Capabilities
- `game-loop`: simulación sobre rejilla (tick, movimiento, wrap-around, comida, crecimiento, velocidad progresiva, entrada de dirección y fin por auto-colisión).
- `snake-render`: presentación visual interpolada de la serpiente entre ticks, incluido el dibujado sin salto al cruzar el borde.
- `game-screens`: flujo de las tres pantallas (inicio, juego, puntuaciones) y sus transiciones.
- `high-scores`: registro persistente de puntuaciones con nombre de jugador y su presentación en la pantalla de puntuaciones.

### Modified Capabilities
<!-- Ninguna: el proyecto no tiene specs previas. -->

## Impact

- Proyecto nuevo sin código ni especificaciones previas: no hay impacto de compatibilidad.
- Requiere crear el proyecto Godot 4.7 (no existe `project.godot`).
- Introduce persistencia local en `user://` para la tabla de puntuaciones.
- Sin dependencias externas ni servicios; todo el alcance vive dentro del proyecto Godot.
- Fuera de alcance: sonido y vibración, niveles con laberinto, power-ups, varias frutas simultáneas, obstáculos móviles, multijugador y clasificación en línea.
