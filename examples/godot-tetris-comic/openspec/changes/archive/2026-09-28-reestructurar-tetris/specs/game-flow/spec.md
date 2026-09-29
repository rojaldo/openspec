# Spec Delta

## Purpose

Define el flujo de pantallas del juego y las transiciones entre la pantalla de inicio, la partida en curso y el fin de partida, de modo que el jugador siempre sepa en qué estado está y qué puede hacer a continuación.

## ADDED Requirements

### Requirement: Pantalla de inicio

El sistema SHALL mostrar, al arrancar, una pantalla de inicio visualmente atractiva con un título del juego y una indicación de cómo empezar la partida.

#### Scenario: Arranque en la pantalla de inicio

- **WHEN** se inicia la aplicación
- **THEN** se muestra la pantalla de inicio, no la partida en curso

#### Scenario: Empezar una partida

- **WHEN** el jugador activa la acción de empezar en la pantalla de inicio
- **THEN** la pantalla de inicio desaparece y comienza una partida nueva

### Requirement: Pantalla de juego

Durante una partida, el sistema SHALL mostrar la pantalla de juego con el tablero a la izquierda, donde caen y se fijan las piezas, y los indicadores a la derecha.

#### Scenario: Composición de la pantalla de juego

- **WHEN** una partida está en curso
- **THEN** el tablero aparece en la parte izquierda y los indicadores en la parte derecha

### Requirement: Fin de partida superpuesto

El sistema SHALL declarar el fin de partida cuando el tablero detecta que se ha superado la altura visible, y SHALL mostrar una capa de fin de partida superpuesta al tablero congelado en ese instante.

#### Scenario: Se alcanza el fin de partida

- **WHEN** el tablero detecta que la pila supera la altura visible
- **THEN** la partida se detiene y se muestra la capa de fin de partida sobre el tablero

#### Scenario: El tablero queda congelado

- **WHEN** la capa de fin de partida está visible
- **THEN** las piezas dejan de caer, la pila que provocó el fin de partida sigue visible y las teclas de juego no producen movimiento

#### Scenario: Puntuación final visible

- **WHEN** la capa de fin de partida se muestra
- **THEN** la puntuación obtenida en la partida es visible

### Requirement: Acciones tras el fin de partida

La capa de fin de partida SHALL ofrecer dos acciones: reintentar y volver al menú.

#### Scenario: Reintentar

- **WHEN** el jugador elige reintentar en la capa de fin de partida
- **THEN** comienza una partida nueva con el marcador a cero, sin pasar por la pantalla de inicio

#### Scenario: Volver al menú

- **WHEN** el jugador elige volver al menú en la capa de fin de partida
- **THEN** se muestra la pantalla de inicio

### Requirement: Inicio limpio de cada partida

Cada partida nueva SHALL empezar con el tablero vacío, el marcador a cero y la velocidad de caída en su valor inicial.

#### Scenario: Estado inicial de la partida

- **WHEN** comienza una partida, ya sea desde el inicio o desde reintentar
- **THEN** el tablero está vacío, la puntuación y las líneas están a cero y la pieza cae a la velocidad mínima
