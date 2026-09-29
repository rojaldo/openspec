# Spec Delta

## Purpose

Componer la altura ocupada del tablero: al aterrizar una pieza la fija con las ya existentes, resuelve las líneas completas, comunica el resultado a los indicadores y determina cuándo la partida termina.

## ADDED Requirements

### Requirement: Tablero de dos zonas

El tablero SHALL tener una zona visible de 10 columnas por 20 filas y una zona oculta por encima de ella en la que una pieza puede seguir avanzando sin verse.

#### Scenario: La pieza entra desde la zona oculta

- **WHEN** aparece una pieza nueva
- **THEN** la pieza se coloca de forma que asome inmediatamente en la parte superior de la zona visible

### Requirement: Composición de la pieza al aterrizar

Cuando la pieza activa no puede seguir bajando, el sistema SHALL fijarla, trasladando sus celdas ocupadas a la altura ocupada del tablero.

#### Scenario: La pieza se une a las anteriores

- **WHEN** la pieza activa queda apoyada sobre el suelo o sobre piezas ya fijadas
- **THEN** sus celdas pasan a formar parte de la altura ocupada y deja de existir como pieza activa

#### Scenario: Rechazo de descenso tras el aterrizaje

- **WHEN** la pieza activa ya está apoyada
- **THEN** intentar bajarla de nuevo no la mueve y provoca su fijación

### Requirement: Detección y eliminación de líneas

Tras fijar una pieza, el sistema SHALL detectar las filas visibles que han quedado completamente ocupadas, eliminarlas y compactar la altura ocupada desplazando hacia abajo lo que había por encima.

#### Scenario: Línea completa

- **WHEN** al fijar una pieza una fila visible queda completamente ocupada
- **THEN** esa fila se elimina y las filas superiores descienden una posición

#### Scenario: Varias líneas simultáneas

- **WHEN** al fijar una pieza varias filas visibles quedan completamente ocupadas
- **THEN** todas se eliminan y la altura ocupada se compacta una sola vez

#### Scenario: Sin líneas

- **WHEN** al fijar una pieza ninguna fila queda completamente ocupada
- **THEN** no se elimina ninguna fila y el contador de líneas no cambia

### Requirement: Notificación del resultado

El sistema SHALL notificar el número de líneas eliminadas y si la jugada ha sido un tetris (cuatro líneas a la vez), para que la puntuación y los indicadores reaccionen.

#### Scenario: Aviso de líneas eliminadas

- **WHEN** se eliminan una o más líneas
- **THEN** se emite un aviso con el número de líneas y si han sido cuatro

#### Scenario: Marcado de tetris

- **WHEN** se eliminan exactamente cuatro líneas de una vez
- **THEN** el aviso indica que ha sido un tetris

### Requirement: Solicitud de la pieza siguiente

Tras fijar y resolver una pieza, el sistema SHALL solicitar la siguiente pieza para que el juego continúe sin intervención del jugador.

#### Scenario: Encadenado de piezas

- **WHEN** una pieza se ha fijado y las líneas se han resuelto
- **THEN** aparece una pieza nueva como pieza activa

### Requirement: Condición de fin de partida

El sistema SHALL declarar el fin de partida en cuanto una celda fijada queda en la zona oculta, es decir, cuando la altura ocupada supera la zona visible.

#### Scenario: La pila invade la zona oculta

- **WHEN** al fijar una pieza alguna de sus celdas queda por encima de la zona visible
- **THEN** el sistema declara el fin de partida

#### Scenario: No se solicita pieza tras el fin de partida

- **WHEN** el fin de partida ha sido declarado
- **THEN** no aparece ninguna pieza nueva y la partida no continúa

### Requirement: Consultas del tablero

El sistema SHALL exponer consultas de colisión y de posición de aterrizaje que permitan resolver el movimiento y la rotación sin conocimiento del dibujado.

#### Scenario: Consulta de encaje

- **WHEN** se pregunta si una forma encaja en una posición
- **THEN** la respuesta es negativa si alguna celda ocupada queda fuera de las columnas, por debajo del suelo o solapa celdas ya ocupadas

#### Scenario: Posición de aterrizaje

- **WHEN** se pregunta dónde aterrizaría la pieza activa
- **THEN** se devuelve la altura más baja que la pieza puede alcanzar sin chocar, para poder mostrarla como previsualización

#### Scenario: Movimiento contra un límite

- **WHEN** el jugador intenta mover o rotar la pieza hacia una posición que no encaja
- **THEN** el movimiento se rechaza y la pieza permanece donde estaba
