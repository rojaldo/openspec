# Tasks

## 1. Modelo de nivel

- [x] 1.1 Crear `scripts/logic/level.gd` con la clase de nivel (mapa, borde, inicio, dirección, objetivo y paso de velocidad) y verificar con test que un nivel declara y devuelve cada uno de esos campos
- [x] 1.2 Implementar el parseo del mapa desde texto (`.` libre, `#` sólido, `@` inicio) a celdas y conjunto de sólidas, y verificar con test que cuenta sólidas correctamente y localiza el inicio
- [x] 1.3 Implementar la validación de formato de un nivel (filas de igual ancho, un solo `@`, objetivo por defecto 5) y verificar con test que un mapa mal formado se rechaza

## 2. Los diez niveles

- [x] 2.1 Definir el nivel 1 (borde atravesable, sin sólidos, objetivo 5) y verificar con test que su inicio y su objetivo son los declarados
- [x] 2.2 Definir los niveles 2 a 4 (borde atravesable, sólidos crecientes) y verificar con test que el número de sólidas no decrece entre ellos
- [x] 2.3 Definir los niveles 5 a 7 (borde mortal, sólidos crecientes) y verificar con test que pasan a borde mortal y que las sólidas no decrecen
- [x] 2.4 Definir los niveles 8 a 10 (borde mortal, laberintos densos) y verificar con test que el objetivo y las sólidas no decrecen respecto al nivel anterior
- [x] 2.5 Implementar `scripts/logic/levels.gd` con la secuencia completa y verificar con test que contiene exactamente diez niveles y que el paso de velocidad crece con el índice
- [x] 2.6 Verificar el invariante de inicio seguro en los diez niveles (cuerpo libre, celda frontal libre, escape perpendicular libre) y comprobar que la suite falla si se introduce un nivel con un sólido delante de la cabeza

## 3. Simulación: sólidas y borde por nivel

- [x] 3.1 Refactorizar `scripts/logic/grid_config.gd` para que las dimensiones del tablero vengan del nivel, conservando solo el tamaño de celda como constante global, y verificar que el juego arranca con el tablero del nivel 1
- [x] 3.2 Implementar en `snake_game.gd` la colisión con celdas sólidas y verificar con test que entrar en una sólida termina la partida
- [x] 3.3 Implementar el borde como propiedad del nivel en el tick, sustituyendo el `wrap_cell` incondicional, y verificar con test que un nivel mortal muere al salir y uno atravesable hace wrap por los cuatro lados
- [x] 3.4 Implementar el arranque de nivel con posición, dirección y cuerpo de 3 celdas fijados por el nivel, y verificar con test que la serpiente empieza donde el nivel dice y mide 3 celdas
- [x] 3.5 Implementar el contador de progreso del nivel separado del score acumulado, y verificar con test que al empezar el nivel 2 el progreso es cero y la puntuación acumulada se conserva
- [x] 3.6 Implementar la comida solo en celdas alcanzables desde la cabeza (BFS sobre celdas transitables), y verificar con test que en un mapa con un bolsillo cerrado el coco nunca aparece dentro
- [x] 3.7 Implementar la velocidad con intervalo base uniforme y paso por nivel, y verificar con test que el intervalo de arranque es el mismo en el nivel 1 y en el 10 y que comer acelera más en el nivel avanzado
- [x] 3.8 Implementar la superación del nivel al alcanzar el objetivo y el avance al siguiente, y verificar con test que al comer el último coco del objetivo se pasa al nivel siguiente con cuerpo de 3 celdas y velocidad base

## 4. Render

- [x] 4.1 Dibujar las celdas sólidas en `board_view.gd` y verificar visualmente que las paredes y obstáculos del nivel se ven sobre el tablero
- [x] 4.2 Dibujar el borde según el nivel (muro cuando es mortal, sin borde cuando es atravesable) y verificar visualmente que un nivel mortal y uno atravesable se distinguen
- [x] 4.3 Verificar que el ghost del cruce de borde sigue funcionando en niveles atravesables y que no se activa en niveles mortales
- [x] 4.4 Ajustar el tamaño del tablero al nivel si sus dimensiones cambian, y verificar visualmente que la rejilla y el borde encajan con el tablero del nivel

## 5. Pantallas y progresión

- [x] 5.1 Mostrar el nivel actual y el progreso del objetivo en la pantalla de juego, y verificar visualmente que ambos se ven durante la partida
- [x] 5.2 Implementar el aviso de inicio de nivel (número y objetivo) sin pantalla adicional, y verificar visualmente que aparece antes de que la serpiente se mueva
- [x] 5.3 Implementar la transición al superar un nivel y verificar que la partida continúa en el nivel siguiente tras el aviso
- [x] 5.4 Implementar la secuencia de victoria al completar el nivel 10, con la puntuación final, y verificar que ofrece volver al inicio o jugar de nuevo
- [x] 5.5 Conectar la muerte en cualquier nivel con la pantalla de puntuaciones llevando la puntuación y el nivel alcanzado, y verificar que el nivel alcanzado llega correctamente

## 6. Persistencia

- [x] 6.1 Añadir el campo `nivel` a las entradas de `scores.gd` y verificar con test que se guarda y se lee
- [x] 6.2 Tolerar entradas antiguas sin campo `nivel` en la lectura, y verificar con test que una entrada sin ese campo se lee sin error
- [x] 6.3 Mostrar el nivel alcanzado en la tabla de puntuaciones, y verificar visualmente que la tabla lo incluye en cada fila

## 7. Actualizar los tests existentes

- [x] 7.1 Reescribir el test de wrap de `run_tests.gd` para verificar el borde según el nivel en vez de como regla global, y verificar que la suite de lógica pasa en verde
- [x] 7.2 Actualizar `run_integration.gd` y `run_motion.gd` al nuevo arranque por nivel y verificar que ambas suites pasan en verde

## 8. Verificación de integración

- [x] 8.1 Ejecutar la suite completa (lógica, integración, movimiento) y verificar que pasa en verde
- [x] 8.2 Jugando en ventana, completar el nivel 1 y el 2, comprobando que la serpiente reinicia a 3 celdas, que la velocidad vuelve al inicio y que el nivel y el objetivo se ven en pantalla
- [x] 8.3 Jugando en ventana, morir contra un obstáculo y contra el borde mortal y verificar que se llega a puntuaciones con el nivel alcanzado
- [x] 8.4 Completar los diez niveles y verificar que se llega a la secuencia de victoria
