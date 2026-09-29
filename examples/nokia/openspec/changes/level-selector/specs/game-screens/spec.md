# Spec Delta

## MODIFIED Requirements

### Requirement: Pantalla de inicio

Al abrirse el juego SHALL mostrarse la pantalla de inicio, con una opción para empezar partida y una opción para elegir nivel. Elegir empezar partida SHALL llevar a la pantalla de juego con una partida nueva desde el primer nivel. Elegir nivel SHALL llevar al selector de nivel.

#### Scenario: Inicio del juego

- **WHEN** se abre el juego
- **THEN** se muestra la pantalla de inicio con la opción de empezar partida y la de elegir nivel

#### Scenario: Empezar partida

- **WHEN** el jugador elige empezar partida en la pantalla de inicio
- **THEN** se pasa a la pantalla de juego con una partida nueva desde el primer nivel

#### Scenario: Elegir nivel

- **WHEN** el jugador elige la opción de elegir nivel en la pantalla de inicio
- **THEN** se pasa al selector de nivel

## ADDED Requirements

### Requirement: Selector de nivel

El juego SHALL ofrecer un selector de nivel al que se llega desde la pantalla de inicio. El selector SHALL mostrar los diez niveles, todos disponibles para elegir, y SHALL ofrecer una opción para volver a la pantalla de inicio.

#### Scenario: Llegar al selector desde el inicio

- **WHEN** el jugador elige la opción de elegir nivel en la pantalla de inicio
- **THEN** se muestra el selector con los diez niveles

#### Scenario: Todos los niveles disponibles

- **WHEN** se muestra el selector de nivel
- **THEN** los diez niveles aparecen como elegibles, sin ninguno bloqueado

#### Scenario: Cada nivel muestra su objetivo

- **WHEN** se muestra el selector de nivel
- **THEN** cada nivel se presenta con su número y su objetivo de cocos

#### Scenario: Volver al inicio

- **WHEN** el jugador elige volver al inicio en el selector de nivel
- **THEN** se vuelve a la pantalla de inicio

### Requirement: Arranque de partida en el nivel elegido

Al elegir un nivel en el selector, la partida SHALL arrancar en ese nivel con estado nuevo, y SHALL continuar con la progresión normal hacia los niveles siguientes hasta el décimo. Completar el décimo SHALL terminar la partida en victoria. El arranque en un nivel elegido MUST NOT modificar las reglas del juego ni la dificultad de los niveles.

#### Scenario: Arranque en el nivel elegido

- **WHEN** el jugador elige un nivel en el selector
- **THEN** la partida empieza en ese nivel con una serpiente de tamaño inicial y velocidad base

#### Scenario: Progresión desde el nivel elegido

- **WHEN** se completa el objetivo del nivel elegido
- **THEN** la partida continúa con el nivel siguiente

#### Scenario: Victoria desde un nivel elegido

- **WHEN** el jugador elige un nivel y completa hasta el décimo
- **THEN** la partida termina en victoria

#### Scenario: Elegir el primer nivel

- **WHEN** el jugador elige el nivel uno en el selector
- **THEN** la partida arranca igual que con la opción de empezar partida
