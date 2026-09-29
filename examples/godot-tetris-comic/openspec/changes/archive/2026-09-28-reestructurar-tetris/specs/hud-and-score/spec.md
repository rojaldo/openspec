# Spec Delta

## Purpose

Informar al jugador, durante la partida, de su puntuación, de las líneas que lleva y de la pieza que viene a continuación, y convertir las líneas completadas en puntos.

## ADDED Requirements

### Requirement: Indicadores de la partida

El sistema SHALL mostrar, en la parte derecha de la pantalla de juego, la puntuación, el número de líneas completadas y la siguiente pieza, con valores reales de la partida en curso.

#### Scenario: Los indicadores existen durante la partida

- **WHEN** una partida está en curso
- **THEN** se muestran la puntuación, las líneas y la siguiente pieza

#### Scenario: Los indicadores empiezan a cero

- **WHEN** comienza una partida
- **THEN** la puntuación y las líneas muestran cero y la siguiente pieza se anuncia

### Requirement: Maquetación de los indicadores

El sistema SHALL maquetar el bloque de indicadores centrado verticalmente en la pantalla y el panel centrado horizontalmente en la franja a la derecha del tablero, con una separación equilibrada a ambos lados.

#### Scenario: Centrado vertical del bloque

- **WHEN** una partida está en curso
- **THEN** el conjunto de las tres tarjetas queda centrado respecto a la altura de la pantalla, y no colgando desde el borde superior

#### Scenario: Centrado horizontal del panel

- **WHEN** una partida está en curso
- **THEN** el panel queda centrado en la franja entre el borde del tablero y el marco del fondo, con márgenes comparables a cada lado, y no pegado al marco

### Requirement: Actualización de la puntuación y las líneas

El sistema SHALL incrementar la puntuación y el contador de líneas en cuanto el tablero notifica líneas eliminadas, sin que el jugador haga nada más.

#### Scenario: Subida tras eliminar líneas

- **WHEN** el tablero elimina una o más líneas
- **THEN** el contador de líneas aumenta en ese número y la puntuación aumenta según el reparto

### Requirement: Reparto de puntos por líneas

El sistema SHALL asignar 100 puntos por una línea, 300 por dos, 500 por tres y 800 por cuatro, y SHALL no otorgar puntos por la mera caída de piezas.

#### Scenario: Eliminación simple

- **WHEN** se elimina una línea
- **THEN** la puntuación aumenta en 100

#### Scenario: Eliminación doble

- **WHEN** se eliminan dos líneas a la vez
- **THEN** la puntuación aumenta en 300

#### Scenario: Eliminación triple

- **WHEN** se eliminan tres líneas a la vez
- **THEN** la puntuación aumenta en 500

#### Scenario: Tetris

- **WHEN** se eliminan cuatro líneas a la vez
- **THEN** la puntuación aumenta en 800

#### Scenario: Sin puntos por caída

- **WHEN** una pieza desciende y se fija sin completar ninguna línea
- **THEN** la puntuación no cambia

### Requirement: Anuncio de la siguiente pieza

El sistema SHALL mostrar como siguiente pieza exactamente el tipo que el sistema de generación entregará a continuación, reflejando su forma y su color.

#### Scenario: La previsualización se actualiza

- **WHEN** la pieza anunciada pasa a ser la pieza activa
- **THEN** el indicador de siguiente pieza muestra una pieza nueva, que es la que aparecerá después

#### Scenario: Reintento limpio del panel

- **WHEN** se empieza una partida nueva
- **THEN** la puntuación y las líneas vuelven a cero y la siguiente pieza mostrada corresponde a la nueva partida
