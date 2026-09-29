# Spec Delta

## Purpose

Definir cómo el jugador controla la pieza activa con el teclado, de forma que mover, rotar y acelerar la caída correspondan a las teclas esperadas y respondan con soltura.

## ADDED Requirements

### Requirement: Rotación

El sistema SHALL rotar la pieza activa en sentido horario cuando el jugador pulsa la tecla de espacio o la flecha arriba.

#### Scenario: Rotar con la barra espaciadora

- **WHEN** el jugador pulsa espacio durante la partida
- **THEN** la pieza activa rota en sentido horario si el resultado encaja

#### Scenario: Rotar con la flecha arriba

- **WHEN** el jugador pulsa la flecha arriba durante la partida
- **THEN** la pieza activa rota en sentido horario si el resultado encaja

#### Scenario: Rotación bloqueada

- **WHEN** el jugador rota y la forma resultante no encaja en la posición actual
- **THEN** la pieza no cambia de orientación

### Requirement: Movimiento horizontal

El sistema SHALL desplazar la pieza activa una columna a la izquierda o a la derecha con las flechas correspondientes.

#### Scenario: Desplazamiento lateral

- **WHEN** el jugador pulsa la flecha izquierda o la flecha derecha
- **THEN** la pieza se desplaza una columna en esa dirección

#### Scenario: Desplazamiento repetido al mantener

- **WHEN** el jugador mantiene pulsada una flecha lateral
- **THEN** la pieza se sigue desplazando una columna por cada repetición, tras un retardo inicial

#### Scenario: Desplazamiento bloqueado

- **WHEN** el jugador intenta desplazarse hacia el borde o sobre piezas fijadas
- **THEN** la pieza no se mueve y no se fija por ello

### Requirement: Aceleración de la caída

El sistema SHALL acelerar la caída de la pieza activa mientras el jugador mantiene pulsada la flecha abajo.

#### Scenario: Caída acelerada

- **WHEN** el jugador mantiene pulsada la flecha abajo
- **THEN** la pieza desciende con una cadencia claramente mayor que la velocidad de caída normal

#### Scenario: Caída acelerada hasta aterrizar

- **WHEN** el jugador mantiene pulsada la flecha abajo hasta que la pieza no puede bajar más
- **THEN** la pieza se fija y el juego continúa

### Requirement: Caída automática

El sistema SHALL hacer descender la pieza activa una fila por sí sola con la periodicidad que fije la velocidad de caída vigente, sin que el jugador intervenga.

#### Scenario: Caída sin intervención

- **WHEN** el jugador no pulsa ninguna tecla
- **THEN** la pieza desciende sola una fila cada intervalo de la velocidad vigente

### Requirement: Teclas inactivas fuera de la partida

El sistema SHALL ignorar las teclas de control de la pieza cuando la partida no está en curso.

#### Scenario: Teclas en el menú o tras el fin de partida

- **WHEN** la pantalla de inicio o la capa de fin de partida están visibles y el jugador pulsa las teclas de juego
- **THEN** ninguna pieza responde a esas teclas
