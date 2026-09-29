# Spec Delta

## MODIFIED Requirements

### Requirement: Persistencia de puntuaciones

Al terminar una partida el sistema SHALL registrar su puntuación, el nombre del jugador y el nivel alcanzado en almacenamiento local del usuario. Las puntuaciones registradas SHALL conservarse entre ejecuciones del juego, y las entradas anteriores sin campo de nivel SHALL seguir siendo legibles.

#### Scenario: Registro al terminar la partida

- **WHEN** la partida termina
- **THEN** la puntuación, el nombre del jugador y el nivel alcanzado quedan registrados

#### Scenario: Persistencia entre ejecuciones

- **WHEN** el juego se cierra y se vuelve a abrir
- **THEN** las puntuaciones registradas previamente siguen disponibles

#### Scenario: Almacenamiento local

- **WHEN** se registra una puntuación
- **THEN** se almacena en el área local del usuario y no requiere ningún servicio externo

#### Scenario: Entradas antiguas siguen leyéndose

- **WHEN** la tabla contiene una entrada guardada antes de existir el nivel alcanzado
- **THEN** esa entrada se lee sin error, con su puntuación y su nombre

### Requirement: Presentación de la tabla

La pantalla de puntuaciones SHALL mostrar las entradas de la tabla con su nombre, su puntuación, su nivel alcanzado y su posición. Si no hay ninguna puntuación registrada, SHALL indicarlo en lugar de mostrar una tabla vacía.

#### Scenario: Tabla con entradas

- **WHEN** existen puntuaciones registradas
- **THEN** se muestran su nombre, su puntuación, su nivel alcanzado y su posición

#### Scenario: Tabla vacía

- **WHEN** no existe ninguna puntuación registrada
- **THEN** se indica que todavía no hay puntuaciones, sin mostrar una tabla vacía
