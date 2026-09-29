# Spec Delta

## Purpose

Define los niveles como dato: qué compone cada nivel (mapa, celdas sólidas, borde, inicio y objetivo) y cómo se ordenan en una curva de dificultad creciente. Es la definición de contenido, no el comportamiento de la partida, que vive en `game-loop`.

## ADDED Requirements

### Requirement: Definición de un nivel

Cada nivel SHALL definir su mapa de celdas sólidas, el comportamiento de su borde (atravesable o mortal), la posición y la dirección iniciales de la serpiente, y su objetivo de cocos. El conjunto de niveles SHALL estar disponible para el juego como datos del proyecto, sin depender de assets externos.

#### Scenario: Un nivel declara sus elementos

- **WHEN** se carga un nivel
- **THEN** quedan definidos su mapa, su borde, su inicio y su objetivo

#### Scenario: El mapa define las celdas sólidas

- **WHEN** se carga el mapa de un nivel
- **THEN** las celdas marcadas como pared u obstáculo son sólidas y el resto son transitables

### Requirement: Diez niveles en dificultad creciente

El juego SHALL ofrecer diez niveles. La dificultad SHALL crecer de forma acumulativa a lo largo de la secuencia, por el mayor número de celdas sólidas y el mayor objetivo de cocos, y por la pérdida del borde atravesable a partir de un nivel intermedio.

#### Scenario: Existen diez niveles

- **WHEN** se consulta la secuencia de niveles
- **THEN** contiene exactamente diez niveles

#### Scenario: La dificultad no decrece

- **WHEN** se comparan dos niveles consecutivos
- **THEN** el nivel posterior no es más fácil que el anterior

#### Scenario: Pérdida del borde atravesable

- **WHEN** se avanza desde los niveles iniciales a los avanzados
- **THEN** los niveles iniciales usan borde atravesable y los avanzados borde mortal

### Requirement: Inicio de nivel seguro

La posición y la dirección iniciales de cada nivel SHALL cumplir un invariante de seguridad: las celdas del cuerpo inicial están libres, la celda frente a la cabeza está libre, y existe al menos una celda perpendicular libre a la que girar. Este invariante SHALL verificarse para los diez niveles.

#### Scenario: Cuerpo inicial libre

- **WHEN** empieza un nivel
- **THEN** ninguna de las celdas que ocupa la serpiente al inicio es sólida

#### Scenario: Frente despejado

- **WHEN** empieza un nivel y el jugador no cambia de dirección
- **THEN** el primer tick no hace que la cabeza choque contra una celda sólida ni contra el borde mortal

#### Scenario: Escape disponible

- **WHEN** empieza un nivel
- **THEN** existe al menos una dirección perpendicular libre a la que el jugador puede girar

#### Scenario: El invariante se comprueba en todos los niveles

- **WHEN** se validan los diez niveles
- **THEN** cada uno satisface las tres condiciones del inicio seguro
