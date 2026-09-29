# Spec Delta

## ADDED Requirements

### Requirement: Celdas sólidas

El mapa de un nivel SHALL poder contener celdas sólidas, que son las paredes y los obstáculos. Una celda sólida MUST NOT ser transitable: la serpiente no puede ocuparla ni la comida puede aparecer en ella. A efectos de comportamiento, paredes y obstáculos son la misma clase de celda.

#### Scenario: El mapa declara celdas sólidas

- **WHEN** un nivel define paredes u obstáculos
- **THEN** esas celdas se consideran sólidas y no transitables

#### Scenario: Paredes y obstáculos comparten comportamiento

- **WHEN** la serpiente entra en una celda marcada como pared o como obstáculo
- **THEN** el efecto es el mismo: la partida termina

### Requirement: Fin de partida por colisión con celdas sólidas

La partida SHALL terminar cuando la cabeza pasa a ocupar una celda sólida del mapa o una celda del borde en un nivel de borde mortal. La puntuación final SHALL ser la acumulada hasta ese momento.

#### Scenario: Colisión con un obstáculo

- **WHEN** la cabeza pasa a ocupar una celda sólida
- **THEN** la partida termina

#### Scenario: Colisión con el borde mortal

- **WHEN** la cabeza intenta cruzar el borde en un nivel de borde mortal
- **THEN** la partida termina

#### Scenario: Puntuación final tras colisión

- **WHEN** la partida termina por una celda sólida o por el borde mortal
- **THEN** la puntuación final es la acumulada durante la partida

### Requirement: Objetivo por nivel

Cada nivel SHALL tener un objetivo expresado como número de cocos a comer. Superar el objetivo SHALL completar el nivel y dar paso al siguiente. Completar el objetivo del último nivel SHALL terminar la partida en victoria. El objetivo por defecto SHALL ser 5 cocos.

#### Scenario: Objetivo alcanzado

- **WHEN** la serpiente come el último coco del objetivo del nivel
- **THEN** el nivel se considera superado y se pasa al siguiente

#### Scenario: Objetivo por defecto

- **WHEN** un nivel no define un objetivo propio
- **THEN** su objetivo es de 5 cocos

#### Scenario: Victoria en el último nivel

- **WHEN** se completa el objetivo del nivel 10
- **THEN** la partida termina en victoria

#### Scenario: Progreso del objetivo

- **WHEN** la partida está en curso
- **THEN** el progreso del objetivo (cocos comidos del nivel y total a comer) es observable

### Requirement: Reinicio de estado al empezar cada nivel

Al empezar cada nivel la serpiente SHALL restablecerse al tamaño inicial de 3 celdas, con independencia del tamaño que tuviera en el nivel anterior. El intervalo base de la velocidad SHALL restablecerse al mismo valor en todos los niveles. La puntuación acumulada SHALL conservarse entre niveles.

#### Scenario: Tamaño inicial en cada nivel

- **WHEN** empieza un nivel nuevo
- **THEN** la serpiente mide exactamente 3 celdas

#### Scenario: La longitud no se arrastra entre niveles

- **WHEN** el jugador llega a un nivel con la serpiente larga del nivel anterior
- **THEN** la serpiente del nivel nuevo vuelve a medir 3 celdas

#### Scenario: Velocidad restablecida

- **WHEN** empieza un nivel nuevo
- **THEN** el intervalo de la velocidad es el intervalo base, el mismo en todos los niveles

#### Scenario: La puntuación se conserva

- **WHEN** se pasa de un nivel al siguiente
- **THEN** la puntuación acumulada se mantiene

#### Scenario: Posición y dirección iniciales fijadas por el nivel

- **WHEN** empieza un nivel
- **THEN** la serpiente ocupa la posición y la dirección iniciales definidas por ese nivel, no las del nivel anterior

## MODIFIED Requirements

### Requirement: Wrap-around en los bordes

El comportamiento del borde SHALL ser una propiedad del nivel. En un nivel de **borde atravesable**, el tablero SHALL comportarse como un toro: cuando la cabeza sale por un borde entra por el borde opuesto, y la partida MUST NOT terminar por contacto con los bordes. En un nivel de **borde mortal**, la cabeza MUST NOT cruzar el borde, y ocupar una celda del borde SHALL terminar la partida.

#### Scenario: Salir por la izquierda y entrar por la derecha

- **WHEN** en un nivel de borde atravesable la cabeza avanza hacia la izquierda desde la primera columna
- **THEN** la cabeza pasa a ocupar la última columna de la misma fila

#### Scenario: Salir por la derecha y entrar por la izquierda

- **WHEN** en un nivel de borde atravesable la cabeza avanza hacia la derecha desde la última columna
- **THEN** la cabeza pasa a ocupar la primera columna de la misma fila

#### Scenario: Salir por arriba y entrar por abajo

- **WHEN** en un nivel de borde atravesable la cabeza avanza hacia arriba desde la primera fila
- **THEN** la cabeza pasa a ocupar la última fila de la misma columna

#### Scenario: Salir por abajo y entrar por arriba

- **WHEN** en un nivel de borde atravesable la cabeza avanza hacia abajo desde la última fila
- **THEN** la cabeza pasa a ocupar la primera fila de la misma columna

#### Scenario: El borde mortal detiene a la serpiente

- **WHEN** en un nivel de borde mortal la cabeza intenta salir del tablero
- **THEN** la partida termina sin que la cabeza llegue a cruzar el borde

### Requirement: Aparición de cocos en celdas libres

El juego SHALL mantener exactamente un coco sobre el tablero en todo momento. La posición del coco SHALL elegirse de forma aleatoria entre las celdas que no están ocupadas por la serpiente ni son sólidas, y SHALL ser alcanzable desde la cabeza de la serpiente.

#### Scenario: Coco en una celda libre

- **WHEN** aparece un coco
- **THEN** su celda no coincide con ninguna celda ocupada por el cuerpo de la serpiente ni con una celda sólida

#### Scenario: Un solo coco a la vez

- **WHEN** la serpiente come el coco
- **THEN** aparece un nuevo coco y en ningún momento existen dos cocos simultáneos

#### Scenario: El coco nunca queda encerrado

- **WHEN** aparece un coco en un mapa con paredes u obstáculos
- **THEN** existe un camino desde la cabeza de la serpiente hasta la celda del coco

### Requirement: Velocidad progresiva

Cada coco comido SHALL reducir el intervalo entre ticks, aumentando la dificultad dentro del nivel. El incremento de velocidad por coco SHALL ser mayor en los niveles más avanzados. El intervalo SHALL tener un valor mínimo, y al empezar cada nivel SHALL restablecerse al intervalo base.

#### Scenario: Comer reduce el intervalo

- **WHEN** la serpiente come un coco
- **THEN** el intervalo entre ticks del siguiente tramo es menor que antes de comer

#### Scenario: Tope mínimo de intervalo

- **WHEN** el intervalo alcanza su valor mínimo
- **THEN** comer más cocos no reduce el intervalo por debajo de ese valor

#### Scenario: La rampa crece con el nivel

- **WHEN** se come un coco en un nivel avanzado
- **THEN** la reducción del intervalo es mayor que la de comer un coco en un nivel inicial

#### Scenario: La velocidad vuelve al intervalo base

- **WHEN** empieza un nivel nuevo
- **THEN** el intervalo vuelve al intervalo base
