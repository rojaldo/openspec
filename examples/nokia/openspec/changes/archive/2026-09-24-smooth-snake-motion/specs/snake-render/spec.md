# Spec Delta

## MODIFIED Requirements

### Requirement: Movimiento continuo interpolado

El dibujado SHALL interpolar la posición de cada segmento entre su celda anterior y su celda actual según el tiempo transcurrido dentro del intervalo entre ticks. Al agotarse el intervalo, cada segmento SHALL coincidir con su celda actual. La posición dibujada SHALL ser monótona dentro de cada tick: MUST NOT retroceder respecto al frame anterior mientras las celdas de la simulación no hayan cambiado.

#### Scenario: Interpolación a mitad de tick

- **WHEN** ha transcurrido la mitad del intervalo entre ticks
- **THEN** cada segmento se dibuja a mitad de camino entre su celda anterior y su celda actual

#### Scenario: Coincidencia al final del intervalo

- **WHEN** el intervalo entre ticks se agota
- **THEN** cada segmento se dibuja exactamente sobre su celda actual

#### Scenario: El dibujado se ajusta al cambio de velocidad

- **WHEN** el intervalo entre ticks cambia por haber comido
- **THEN** el movimiento dibujado sigue siendo continuo, sin acelerones ni saltos

#### Scenario: La posición dibujada no retrocede

- **WHEN** se suceden frames dentro de un mismo tick, sin que la simulación haya avanzado
- **THEN** la posición dibujada de cada segmento avanza o se mantiene, nunca retrocede

#### Scenario: Sin salto al expirar el intervalo

- **WHEN** un tick se agota y la simulación avanza a la celda siguiente
- **THEN** la posición dibujada continúa desde donde estaba, sin volver a la celda anterior

#### Scenario: La velocidad creciente no reintroduce el temblor

- **WHEN** la serpiente come repetidamente y el intervalo se reduce
- **THEN** no aparece ningún retroceso de la posición dibujada
