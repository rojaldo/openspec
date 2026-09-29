# Spec Delta

## Purpose

Define las tres pantallas del juego y las transiciones entre ellas: inicio para empezar partida, juego para la partida en curso, y puntuaciones para el resultado final. Es el recorrido observable del jugador, no la organización interna de escenas.

## ADDED Requirements

### Requirement: Pantalla de inicio

Al abrirse el juego SHALL mostrarse la pantalla de inicio, con una opción para empezar partida. Elegir esa opción SHALL llevar a la pantalla de juego.

#### Scenario: Inicio del juego

- **WHEN** se abre el juego
- **THEN** se muestra la pantalla de inicio con la opción de empezar partida

#### Scenario: Empezar partida

- **WHEN** el jugador elige empezar partida en la pantalla de inicio
- **THEN** se pasa a la pantalla de juego con una partida nueva

### Requirement: Pantalla de juego

Durante la partida SHALL mostrarse la pantalla de juego, con el tablero, la serpiente, el coco y la puntuación actual. Al terminar la partida por auto-colisión SHALL pasarse a la pantalla de puntuaciones.

#### Scenario: Estado visible durante la partida

- **WHEN** la partida está en curso
- **THEN** se muestran el tablero, la serpiente, el coco y la puntuación actual

#### Scenario: Fin de partida

- **WHEN** la partida termina por auto-colisión
- **THEN** se pasa a la pantalla de puntuaciones con la puntuación final

### Requirement: Pantalla de puntuaciones

La pantalla de puntuaciones SHALL mostrar la puntuación final de la partida recién terminada y la tabla de mejores puntuaciones. SHALL ofrecer una opción para jugar otra partida y otra para volver a la pantalla de inicio.

#### Scenario: Puntuación final visible

- **WHEN** se llega a la pantalla de puntuaciones
- **THEN** se muestra la puntuación final de la partida terminada

#### Scenario: Jugar otra partida

- **WHEN** el jugador elige jugar otra partida
- **THEN** se pasa a la pantalla de juego con una partida nueva

#### Scenario: Volver al inicio

- **WHEN** el jugador elige volver al inicio
- **THEN** se pasa a la pantalla de inicio

### Requirement: Entrada del nombre del jugador

La pantalla de puntuaciones SHALL permitir introducir el nombre del jugador asociado a la puntuación final. Si el jugador no introduce ningún nombre, la puntuación SHALL registrarse con un nombre por defecto.

#### Scenario: Introducir el nombre

- **WHEN** el jugador escribe un nombre en la pantalla de puntuaciones
- **THEN** la puntuación final se registra con ese nombre

#### Scenario: Nombre vacío

- **WHEN** el jugador no introduce ningún nombre
- **THEN** la puntuación se registra con un nombre por defecto
