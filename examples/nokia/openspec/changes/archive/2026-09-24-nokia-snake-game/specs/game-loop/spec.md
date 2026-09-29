# Spec Delta

## Purpose

Define la simulación de la partida de Snake: la serpiente avanza por celdas de un tablero fijo, come cocos que aparecen al azar, crece y acelera, y termina al chocar contra su propio cuerpo. Es el comportamiento observable que el juego debe cumplir, independiente de cómo se dibuje.

## ADDED Requirements

### Requirement: Avance por ticks sobre rejilla

La simulación SHALL avanzar sobre una rejilla de celdas de tamaño fijo, moviendo la cabeza exactamente una celda por tick y en una sola dirección a la vez. El intervalo entre ticks SHALL ser el único parámetro que determina la velocidad de simulación.

#### Scenario: Avance de una celda por tick

- **WHEN** transcurre un tick
- **THEN** la cabeza de la serpiente ocupa la celda adyacente en su dirección actual

#### Scenario: Un solo avance por tick

- **WHEN** transcurre un tick
- **THEN** la cabeza avanza exactamente una celda, nunca dos, con independencia de la duración del intervalo

### Requirement: Wrap-around en los bordes

El tablero SHALL comportarse como un toro: cuando la cabeza sale por un borde entra por el borde opuesto. La partida MUST NOT terminar por contacto con los bordes.

#### Scenario: Salir por la izquierda y entrar por la derecha

- **WHEN** la cabeza avanza hacia la izquierda desde la primera columna
- **THEN** la cabeza pasa a ocupar la última columna de la misma fila

#### Scenario: Salir por la derecha y entrar por la izquierda

- **WHEN** la cabeza avanza hacia la derecha desde la última columna
- **THEN** la cabeza pasa a ocupar la primera columna de la misma fila

#### Scenario: Salir por arriba y entrar por abajo

- **WHEN** la cabeza avanza hacia arriba desde la primera fila
- **THEN** la cabeza pasa a ocupar la última fila de la misma columna

#### Scenario: Salir por abajo y entrar por arriba

- **WHEN** la cabeza avanza hacia abajo desde la última fila
- **THEN** la cabeza pasa a ocupar la primera fila de la misma columna

### Requirement: Aparición de cocos en celdas libres

El juego SHALL mantener exactamente un coco sobre el tablero en todo momento. La posición del coco SHALL elegirse de forma aleatoria entre las celdas que no están ocupadas por la serpiente.

#### Scenario: Coco en una celda libre

- **WHEN** aparece un coco
- **THEN** su celda no coincide con ninguna celda ocupada por el cuerpo de la serpiente

#### Scenario: Un solo coco a la vez

- **WHEN** la serpiente come el coco
- **THEN** aparece un nuevo coco y en ningún momento existen dos cocos simultáneos

### Requirement: Crecimiento al comer

Cuando la cabeza ocupa la celda del coco, la serpiente SHALL crecer exactamente una celda. El crecimiento SHALL producirse por no liberar la cola durante ese tick, de modo que el cuerpo aumenta en una celda y no más.

#### Scenario: La serpiente crece una celda

- **WHEN** la cabeza ocupa la celda del coco
- **THEN** la longitud del cuerpo aumenta en una celda respecto al tick anterior

#### Scenario: La cola no se libera el tick de comer

- **WHEN** la serpiente come en un tick
- **THEN** la celda que ocupaba la cola sigue formando parte del cuerpo al terminar ese tick

### Requirement: Velocidad progresiva

Cada coco comido SHALL reducir el intervalo entre ticks, aumentando la dificultad de forma acumulativa. El intervalo SHALL tener un valor mínimo a partir del cual no siga reduciéndose.

#### Scenario: Comer reduce el intervalo

- **WHEN** la serpiente come un coco
- **THEN** el intervalo entre ticks del siguiente tramo es menor que antes de comer

#### Scenario: Tope mínimo de intervalo

- **WHEN** el intervalo alcanza su valor mínimo
- **THEN** comer más cocos no reduce el intervalo por debajo de ese valor

### Requirement: Control de dirección

El jugador SHALL poder fijar la dirección de avance en las cuatro direcciones ortogonales. El sistema SHALL ignorar un cambio a la dirección opuesta a la actual. La dirección SHALL aplicarse al inicio de un tick, no a mitad de intervalo.

#### Scenario: Cambio de dirección válido

- **WHEN** el jugador solicita una dirección distinta de la actual y no opuesta a ella
- **THEN** la cabeza avanza en esa dirección en el siguiente tick

#### Scenario: Giro de 180 grados ignorado

- **WHEN** el jugador solicita la dirección opuesta a la actual
- **THEN** la serpiente mantiene su dirección y el giro no se aplica

#### Scenario: La dirección se aplica en el tick

- **WHEN** el jugador solicita una dirección a mitad del intervalo entre ticks
- **THEN** la nueva dirección se aplica al comenzar el siguiente tick

### Requirement: Fin de partida por auto-colisión

La partida SHALL terminar cuando la cabeza ocupa una celda que pertenece al cuerpo y que no se libera en ese mismo tick. La puntuación final SHALL ser igual al número de cocos comidos durante la partida.

#### Scenario: Colisión contra el cuerpo

- **WHEN** la cabeza pasa a ocupar una celda ocupada por el cuerpo que no se libera ese tick
- **THEN** la partida termina

#### Scenario: La celda de cola liberada no mata

- **WHEN** la cabeza pasa a ocupar la celda que la cola libera en el mismo tick
- **THEN** la partida continúa

#### Scenario: Puntuación final

- **WHEN** la partida termina
- **THEN** la puntuación final es igual al número de cocos comidos
