# piece-generation Specification
## Purpose

Garantiza que la aparición de los 7 tipos de tetrominó sea justa, entregando una de cada tipo en cada ciclo en lugar de depender de un azar uniforme que podría desequilibrar la distribución.

## Requirements
### Requirement: Catálogo de los 7 tipos

El sistema SHALL disponer de exactamente 7 tipos de tetrominó y SHALL poder generar cualquiera de ellos.

#### Scenario: Todos los tipos son generables

- **WHEN** se encadenan suficientes generaciones de piezas
- **THEN** los 7 tipos distintos aparecen y ninguna pieza generada pertenece a un tipo fuera del catálogo

### Requirement: Distribución justa por bolsa de 7

El sistema SHALL generar las piezas en ciclos: cada ciclo contiene exactamente una pieza de cada uno de los 7 tipos, en un orden aleatorio, y al agotarse el ciclo SHALL formar uno nuevo con la misma garantía.

#### Scenario: Un ciclo completo

- **WHEN** se consumen 7 generaciones consecutivas desde el comienzo de un ciclo
- **THEN** entre las 7 hay exactamente una pieza de cada tipo, sin repeticiones ni ausencias

#### Scenario: Ejemplo de 70 piezas

- **WHEN** se generan 70 piezas
- **THEN** hay exactamente 10 piezas de cada tipo

#### Scenario: Rebarajado al agotar el ciclo

- **WHEN** se han entregado las 7 piezas de un ciclo
- **THEN** el siguiente ciclo se forma con una nueva mezcla aleatoria de los 7 tipos

#### Scenario: Independencia entre ciclos

- **WHEN** un ciclo termina y comienza el siguiente
- **THEN** no se impone ninguna restricción entre el último tipo de un ciclo y el primero del siguiente, por lo que pueden coincidir

### Requirement: Pieza siguiente anunciada

El sistema SHALL conocer la siguiente pieza antes de que aparezca, de modo que la pieza anunciada al jugador sea exactamente la que aparecerá después.

#### Scenario: Coincidencia entre lo anunciado y lo entregado

- **WHEN** la pieza activa se fija y aparece una pieza nueva
- **THEN** el tipo de la pieza nueva coincide con el que se anunciaba como siguiente

### Requirement: Aleatoriedad dentro del ciclo

El orden de las piezas dentro de un ciclo SHALL variar entre partidas y entre ciclos, sin que el orden sea fijo ni predecible.

#### Scenario: El orden no es fijo

- **WHEN** se comparan los ciclos consumidos
- **THEN** el orden de los 7 tipos dentro del ciclo no es siempre el mismo
