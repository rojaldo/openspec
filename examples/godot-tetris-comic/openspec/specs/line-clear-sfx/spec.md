# line-clear-sfx Specification
## Purpose

Reforzar visualmente la jugada de completar una línea con una onomatopeya de cómic animada, para que el logro se sienta inmediato y llamativo.

## Requirements
### Requirement: Onomatopeya al completar línea

El sistema SHALL mostrar una onomatopeya de cómic en pantalla cada vez que se eliminen una o más líneas.

#### Scenario: Aparece al limpiar una línea

- **WHEN** el tablero elimina al menos una línea
- **THEN** aparece una onomatopeya en pantalla

#### Scenario: No aparece sin líneas

- **WHEN** una pieza se fija sin completar ninguna línea
- **THEN** no aparece ninguna onomatopeya

### Requirement: Zoom dinámico

La onomatopeya SHALL animarse con un zoom dinámico al aparecer, partiendo de un tamaño muy inferior al final y creciendo hasta un pico antes de asentarse, de modo que el recorrido del zoom sea claramente pronunciado.

#### Scenario: Animación de aparición

- **WHEN** la onomatopeya aparece
- **THEN** comienza muy pequeña, crece hasta un pico mayor que su tamaño asentado y luego se estabiliza

#### Scenario: Recorrido pronunciado

- **WHEN** la onomatopeya recorre su animación
- **THEN** el tamaño final es varias veces el inicial, no un cambio sutil

#### Scenario: El pico no supera el ancho de pantalla

- **WHEN** la onomatopeya alcanza su pico de zoom
- **THEN** la tinta visible no desborda el ancho de la pantalla, para no recortar la palabra

#### Scenario: Desaparición

- **WHEN** la animación termina
- **THEN** la onomatopeya se desvanece y desaparece de la pantalla

### Requirement: Centrado en pantalla

La onomatopeya SHALL aparecer centrada respecto a la pantalla, no respecto al tablero.

#### Scenario: Centrado horizontal

- **WHEN** la onomatopeya aparece
- **THEN** su centro coincide con el centro horizontal de la pantalla, y no con el del tablero, que está desplazado a la izquierda

#### Scenario: Centrado vertical

- **WHEN** la onomatopeya aparece
- **THEN** su centro coincide con el centro vertical de la pantalla

### Requirement: Número de onomatopeyas simultáneas

El sistema SHALL evitar que se acumulen onomatopeyas ilegibles cuando se encadenan eliminaciones seguidas.

#### Scenario: Eliminaciones seguidas

- **WHEN** el jugador limpia líneas antes de que la onomatopeya anterior haya terminado
- **THEN** el sistema muestra la nueva jugada sin apilar un número ilimitado de onomatopeyas a la vez

### Requirement: Onomatopeya acorde a la jugada

El sistema SHALL distinguir la jugada de cuatro líneas a la vez de las eliminaciones menores, de modo que el mensaje mostrado corresponda a la magnitud de lo conseguido.

#### Scenario: Jugada de cuatro líneas

- **WHEN** se eliminan cuatro líneas a la vez
- **THEN** la onomatopeya mostrada es la reservada al tetris

#### Scenario: Jugadas menores

- **WHEN** se eliminan una, dos o tres líneas a la vez
- **THEN** la onomatopeya mostrada es una de las de eliminación menor
