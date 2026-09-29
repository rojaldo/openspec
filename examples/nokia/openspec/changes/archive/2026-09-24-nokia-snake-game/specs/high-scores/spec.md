# Spec Delta

## Purpose

Define el registro persistente de puntuaciones: qué se guarda al terminar cada partida, cómo se ordena y limita la tabla, y cómo se presenta al jugador. Es el comportamiento observable del historial de puntuaciones entre partidas y entre ejecuciones.

## ADDED Requirements

### Requirement: Persistencia de puntuaciones

Al terminar una partida el sistema SHALL registrar su puntuación y el nombre del jugador en almacenamiento local del usuario. Las puntuaciones registradas SHALL conservarse entre ejecuciones del juego.

#### Scenario: Registro al terminar la partida

- **WHEN** la partida termina
- **THEN** la puntuación y el nombre del jugador quedan registrados

#### Scenario: Persistencia entre ejecuciones

- **WHEN** el juego se cierra y se vuelve a abrir
- **THEN** las puntuaciones registradas previamente siguen disponibles

#### Scenario: Almacenamiento local

- **WHEN** se registra una puntuación
- **THEN** se almacena en el área local del usuario y no requiere ningún servicio externo

### Requirement: Tabla ordenada y limitada

Las puntuaciones SHALL presentarse ordenadas de mayor a menor. La tabla SHALL conservar como máximo un número fijo de mejores entradas y descartar las que no alcanzan ese conjunto.

#### Scenario: Orden descendente

- **WHEN** se muestra la tabla de puntuaciones
- **THEN** las entradas aparecen de mayor a menor puntuación

#### Scenario: Límite de entradas

- **WHEN** el número de puntuaciones registradas supera el máximo de la tabla
- **THEN** solo se conservan las mejores hasta ese máximo

#### Scenario: Puntuación que no entra en la tabla

- **WHEN** una puntuación no alcanza el conjunto de mejores de la tabla
- **THEN** no aparece en la tabla y no desplaza a ninguna entrada existente

### Requirement: Presentación de la tabla

La pantalla de puntuaciones SHALL mostrar las entradas de la tabla con su nombre, su puntuación y su posición. Si no hay ninguna puntuación registrada, SHALL indicarlo en lugar de mostrar una tabla vacía.

#### Scenario: Tabla con entradas

- **WHEN** existen puntuaciones registradas
- **THEN** se muestran su nombre, su puntuación y su posición

#### Scenario: Tabla vacía

- **WHEN** no existe ninguna puntuación registrada
- **THEN** se indica que todavía no hay puntuaciones, sin mostrar una tabla vacía
