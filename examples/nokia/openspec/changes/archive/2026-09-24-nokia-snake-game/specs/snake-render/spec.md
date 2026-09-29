# Spec Delta

## Purpose

Define cómo se presenta en pantalla el estado de la simulación: la serpiente se dibuja de forma continua entre ticks, sin moverse a golpes, y sin saltos visuales cuando cruza el borde del tablero. Es el comportamiento observable del dibujado, independiente del motor o de las técnicas concretas.

## ADDED Requirements

### Requirement: Movimiento continuo interpolado

El dibujado SHALL interpolar la posición de cada segmento entre su celda anterior y su celda actual según el tiempo transcurrido dentro del intervalo entre ticks. Al agotarse el intervalo, cada segmento SHALL coincidir con su celda actual.

#### Scenario: Interpolación a mitad de tick

- **WHEN** ha transcurrido la mitad del intervalo entre ticks
- **THEN** cada segmento se dibuja a mitad de camino entre su celda anterior y su celda actual

#### Scenario: Coincidencia al final del intervalo

- **WHEN** el intervalo entre ticks se agota
- **THEN** cada segmento se dibuja exactamente sobre su celda actual

#### Scenario: El dibujado se ajusta al cambio de velocidad

- **WHEN** el intervalo entre ticks cambia por haber comido
- **THEN** el movimiento dibujado sigue siendo continuo, sin acelerones ni saltos

### Requirement: Dibujo sin salto al cruzar el borde

Cuando un segmento cruza el borde del tablero entre dos ticks, el dibujado SHALL representarlo de forma continua, apareciendo a la vez en el lado por el que sale y en el lado por el que entra. En los ticks en que no hay cruce, cada segmento SHALL dibujarse una sola vez.

#### Scenario: Segmento que cruza el borde

- **WHEN** un segmento pasa de un borde del tablero al borde opuesto entre dos ticks
- **THEN** se dibuja de forma continua a ambos lados del borde, sin salto visible

#### Scenario: Sin duplicado cuando no hay cruce

- **WHEN** ningún segmento cruza el borde entre dos ticks
- **THEN** cada segmento se dibuja exactamente una vez

### Requirement: Serpiente dibujada como segmentos independientes

La serpiente SHALL dibujarse como segmentos independientes por celda. Cuando el wrap-around la deja repartida a ambos lados del borde, el dibujado MUST NOT trazar una unión continua a través del tablero entre las partes.

#### Scenario: Serpiente partida por el borde

- **WHEN** parte de la serpiente queda junto a un borde y otra parte junto al borde opuesto
- **THEN** se dibujan ambas partes separadas, sin una línea que las una cruzando el tablero

### Requirement: Coherencia entre dibujado y simulación

El dibujado SHALL representar el estado de la simulación sin modificarlo. La posición dibujada MUST NOT alterar las celdas ocupadas, la dirección ni la puntuación.

#### Scenario: El dibujado no altera la simulación

- **WHEN** transcurre un frame de dibujado
- **THEN** las celdas ocupadas, la dirección y la puntuación permanecen sin cambios
