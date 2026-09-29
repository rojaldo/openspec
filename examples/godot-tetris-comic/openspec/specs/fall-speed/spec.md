# fall-speed Specification
## Purpose

Regular la cadencia con la que las piezas descienden, de forma que la dificultad aumente a medida que el jugador completa líneas y nunca resulte injugable.

## Requirements
### Requirement: Velocidad inicial

El sistema SHALL hacer descender las piezas a la velocidad mínima al comenzar una partida, antes de que se haya completado ninguna línea.

#### Scenario: Primera pieza a velocidad mínima

- **WHEN** comienza una partida
- **THEN** la caída de la pieza usa la velocidad más lenta del juego

### Requirement: Velocidad incremental por líneas completadas

El sistema SHALL aumentar la velocidad de caída a medida que el jugador completa líneas, de modo que la velocidad dependa de las líneas acumuladas y no de la puntuación.

#### Scenario: Más líneas, más velocidad

- **WHEN** el jugador completa líneas
- **THEN** la velocidad de caída posterior es mayor que la anterior

#### Scenario: Progresión continua

- **WHEN** el jugador completa una sola línea
- **THEN** la velocidad aumenta de inmediato, sin esperar a completar un múltiplo de líneas

#### Scenario: Independencia de la puntuación

- **WHEN** la puntuación cambia sin que cambien las líneas completadas
- **THEN** la velocidad de caída no varía

### Requirement: Velocidad de referencia de la partida

El sistema SHALL partir de una caída de referencia de 0,8 segundos por fila y SHALL no superar nunca una caída de referencia de 0,08 segundos por fila.

#### Scenario: Cota superior de velocidad

- **WHEN** el jugador acumula suficientes líneas para alcanzar la caída de referencia mínima
- **THEN** la velocidad no sigue aumentando por más líneas que complete

### Requirement: Velocidad mínima jugable

El sistema SHALL garantizar que la velocidad máxima alcanzable deja al jugador capacidad de reacción para mover y rotar la pieza.

#### Scenario: La partida sigue siendo jugable al máximo

- **WHEN** la velocidad está en su valor más alto
- **THEN** la pieza puede moverse y rotarse antes de que se fije, porque la cadencia del jugador es independiente de la caída
