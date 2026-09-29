# Tasks

## 1. Reloj monótono en el controlador

- [x] 1.1 En `scripts/screens/game_screen.gd`, sustituir el `Timer` por un acumulador (`_acc`) que se incrementa con el delta de frame y llama a `game.tick()` cuando alcanza el intervalo, y verificar que la partida avanza sin el nodo `Timer` en el árbol
- [x] 1.2 Acarrear el sobrante del tick (`_acc -= intervalo`) en lugar de reiniciar el reloj a cero, y verificar con test que al comer no se produce salto de progreso
- [x] 1.3 Acotar el número de ticks procesados por frame (tope fijo) y verificar que un delta grande no dispara una ráfaga de ticks
- [x] 1.4 Emitir `game_over` cuando `game.alive` pasa a falso tras un tick, y verificar que se conserva el flujo a la pantalla de puntuaciones

## 2. La vista recibe el progreso

- [x] 2.1 En `scripts/board_view.gd`, quitar la lectura de `timer.time_left` y usar el `progress` que le entrega el controlador, y verificar que la vista ya no depende del `Timer`
- [x] 2.2 Entregar el progreso desde `game_screen.gd` a la vista en cada frame (`progress = _acc / intervalo` acotado a 0..1) y verificar que la serpiente se dibuja entre celdas
- [x] 2.3 Preservar el ghost del cruce de borde y los segmentos independientes sin cambios y verificar que siguen funcionando con el nuevo reloj

## 3. Actualizar lo que dependía del Timer

- [x] 3.1 Actualizar `tests/run_motion.gd`, que referencia `screen.timer`, para que use el nuevo reloj y verificar que la suite de movimiento pasa en verde

## 4. Test de regresión de monotonía

- [x] 4.1 Añadir al test de movimiento el conteo de retrocesos visuales (posición dibujada de la cabeza que retrocede respecto a la dirección) durante N frames con comidas forzadas, y verificar que el resultado es cero retrocesos
- [x] 4.2 Verificar que el test falla si se reintroduce el reloj antiguo leyendo `timer.time_left` (comprobar que detecta el defecto, no que pasa por casualidad)

## 5. Verificación

- [x] 5.1 Ejecutar la suite completa (lógica, integración, movimiento) y verificar que pasa en verde
- [x] 5.2 Arrancar el juego en ventana, jugar comiendo varios cocos y verificar visualmente que la serpiente avanza fluida, sin temblor ni retrocesos, también a velocidad alta
