# Tasks

## 1. Proyecto Godot

- [x] 1.1 Crear el proyecto Godot 4.7 con `project.godot` (nombre, resolución, renderer 2D) y verificar que abre sin errores en el editor
- [x] 1.2 Crear la estructura de carpetas (`scenes/`, `scripts/`, `scripts/logic/`, `tests/`, `theme/`) y verificar que existe cada directorio
- [x] 1.3 Definir en el mapa de entrada las cuatro acciones de dirección (arriba, abajo, izquierda, derecha) y verificar que cada acción responde a su tecla
- [x] 1.4 Configurar el tamaño de celda y las dimensiones del tablero (20x20) como constantes compartidas y verificar que simulación y render usan el mismo valor

## 2. Simulación sobre rejilla

- [x] 2.1 Implementar el tipo de celda y el tablero con `wrap` de coordenadas y verificar con test que salir por cada uno de los cuatro bordes entra por el opuesto
- [x] 2.2 Implementar el estado de la serpiente (lista de celdas cabeza→cola, dirección actual, intención de dirección) y verificar con test que la cabeza avanza exactamente una celda por tick
- [x] 2.3 Implementar el control de dirección ignorando el giro de 180° y verificar con test que la dirección opuesta no se aplica y que la válida sí
- [x] 2.4 Implementar la elección de celda libre para el coco (lista de celdas no ocupadas) y verificar con test que el coco nunca cae sobre el cuerpo y que solo existe uno a la vez
- [x] 2.5 Implementar el crecimiento como "no liberar la cola el tick que come" y verificar con test que la longitud aumenta exactamente una celda y que la cola no se libera ese tick
- [x] 2.6 Implementar la velocidad progresiva sobre el intervalo del tick con tope mínimo y verificar con test que comer reduce el intervalo y que no baja del mínimo
- [x] 2.7 Implementar la detección de auto-colisión contra el cuerpo ya recortado y verificar con test que morir ocurre al ocupar una celda no liberada y que la celda de cola liberada es legal
- [x] 2.8 Implementar la puntuación como número de cocos comidos y verificar con test que coincide con los cocos comidos al terminar

## 3. Render interpolado

- [x] 3.1 Implementar el reloj de interpolación a partir del `Timer` y verificar que a mitad de intervalo cada segmento se dibuja a mitad de camino y al final sobre su celda
- [x] 3.2 Dibujar la serpiente y el coco con `_draw()` por segmentos independientes y verificar visualmente que no se traza ninguna unión a través del tablero cuando la serpiente está partida por el borde
- [x] 3.3 Implementar el dibujado "ghost" del segmento que cruza el borde (salida y entrada a la vez) y verificar visualmente que no hay salto en las orillas
- [x] 3.4 Aplicar el cambio de intervalo al inicio del siguiente tick y verificar que al comer el movimiento sigue siendo continuo, sin acelerón ni salto

## 4. Pantallas y flujo

- [x] 4.1 Crear la pantalla de inicio con la opción de empezar partida y verificar que al pulsarla se pasa a la pantalla de juego con partida nueva
- [x] 4.2 Crear la pantalla de juego con tablero, serpiente, coco y puntuación actual y verificar que se muestran durante la partida
- [x] 4.3 Conectar la señal de muerte de la serpiente con el cambio a la pantalla de puntuaciones y verificar que al morir se llega a ella con la puntuación final
- [x] 4.4 Crear la pantalla de puntuaciones con puntuación final, tabla, `LineEdit` de nombre y las opciones de reintentar y volver al menú, y verificar que ambas opciones llevan a la pantalla correcta

## 5. Persistencia de puntuaciones

- [x] 5.1 Implementar la lectura y escritura de `user://scores.json` tolerando archivo ausente o inválido y verificar con test que un archivo inválido se trata como tabla vacía
- [x] 5.2 Implementar la inserción ordenada con límite de la tabla (top 10) y verificar con test el orden descendente, el recorte al máximo y que una puntuación baja no desplaza entradas
- [x] 5.3 Registrar la puntuación con el nombre introducido y con nombre por defecto si está vacío, y verificar que al reabrir el juego la entrada sigue presente
- [x] 5.4 Mostrar la tabla con nombre, puntuación y posición, y verificar que sin entradas se indica que aún no hay puntuaciones en lugar de una tabla vacía

## 6. Estilo visual

- [x] 6.1 Aplicar la paleta monocroma verde tipo LCD, la fuente de píxel y el tema compartido a las tres pantallas y verificar que se ven coherentes entre sí
- [x] 6.2 Dibujar el borde del tablero y la rejilla y verificar visualmente que el escenario fijo es visible y legible

## 7. Verificación de integración

- [x] 7.1 Ejecutar la suite de tests de lógica de GDScript y verificar que pasa en verde
- [x] 7.2 Jugar una partida completa: comer varios cocos, cruzar los cuatro bordes, morir por auto-colisión y registrar la puntuación con nombre, y verificar que el recorrido inicio → juego → puntuaciones se cumple sin salto visual en los bordes
- [x] 7.3 Reabrir el juego y verificar que la tabla de puntuaciones conserva la entrada registrada
