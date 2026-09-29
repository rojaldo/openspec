# Spec Delta

## MODIFIED Requirements

### Requirement: Pantalla de juego

Durante la partida SHALL mostrarse la pantalla de juego, con el tablero, la serpiente, el coco, las celdas sólidas, el nivel actual, el progreso del objetivo y la puntuación actual. Al terminar la partida por colisión SHALL pasarse a la pantalla de puntuaciones.

#### Scenario: Estado visible durante la partida

- **WHEN** la partida está en curso
- **THEN** se muestran el tablero, la serpiente, el coco, las celdas sólidas, el nivel actual, el progreso del objetivo y la puntuación actual

#### Scenario: El borde refleja el comportamiento del nivel

- **WHEN** el nivel usa borde mortal
- **THEN** el borde se representa como un muro, de forma distinguible de un nivel de borde atravesable

#### Scenario: Fin de partida

- **WHEN** la partida termina por colisión con el cuerpo, con una celda sólida o con el borde mortal
- **THEN** se pasa a la pantalla de puntuaciones con la puntuación final y el nivel alcanzado

### Requirement: Pantalla de puntuaciones

La pantalla de puntuaciones SHALL mostrar la puntuación final de la partida recién terminada, el nivel alcanzado y la tabla de mejores puntuaciones. SHALL ofrecer una opción para jugar otra partida y otra para volver a la pantalla de inicio.

#### Scenario: Puntuación final visible

- **WHEN** se llega a la pantalla de puntuaciones
- **THEN** se muestra la puntuación final de la partida terminada

#### Scenario: Nivel alcanzado visible

- **WHEN** se llega a la pantalla de puntuaciones
- **THEN** se muestra el nivel alcanzado en la partida terminada

#### Scenario: Jugar otra partida

- **WHEN** el jugador elige jugar otra partida
- **THEN** se pasa a la pantalla de juego con una partida nueva desde el primer nivel

#### Scenario: Volver al inicio

- **WHEN** el jugador elige volver al inicio
- **THEN** se pasa a la pantalla de inicio

## ADDED Requirements

### Requirement: Transición entre niveles

Al superar un nivel SHALL indicarse brevemente el paso al siguiente, con su número y su objetivo, sobre la propia pantalla de juego, sin exigir una pantalla adicional.

#### Scenario: Aviso al empezar el nivel

- **WHEN** empieza un nivel
- **THEN** se indica su número y su objetivo de cocos antes de que la serpiente empiece a moverse

#### Scenario: Paso al nivel siguiente

- **WHEN** se completa el objetivo de un nivel
- **THEN** se indica el paso al nivel siguiente y la partida continúa en él

### Requirement: Secuencia de victoria

Al completar el objetivo del último nivel SHALL mostrarse el final de la partida como victoria, con la puntuación final, y ofrecerse volver al inicio o jugar de nuevo.

#### Scenario: Victoria al completar el último nivel

- **WHEN** se completa el objetivo del nivel diez
- **THEN** se muestra el final de partida como victoria con la puntuación final

#### Scenario: Salida tras la victoria

- **WHEN** el jugador elige continuar tras la victoria
- **THEN** puede volver a la pantalla de inicio o empezar una partida nueva
