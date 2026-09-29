# Tasks

## 1. Desbloquear la ejecución del proyecto (requisito previo)

- [x] 1.1 Eliminar los `textures/*.png.import` versionados y dejar que el motor reimporte; verificar que `godot --headless --import` termina sin fallo y genera los `.ctex` en `.godot/imported/`
- [x] 1.2 Verificar que `godot --quit-after 120` arranca el proyecto y sale con código 0 sin fallo de segmentación
- [x] 1.3 Corregir o retirar `gen_imports.py` para que no vuelva a emitir `.import` malformados; verificar que una segunda ejecución del script sobre el proyecto no rompe el arranque

## 2. Núcleo sin nodos

- [x] 2.1 Crear la bolsa de 7 (`Bag`) con barajado y rebarajado; verificar con una comprobación ejecutable que 70 extracciones dan exactamente 10 de cada tipo y que cada 7 consecutivas contienen los 7 tipos
- [x] 2.2 Verificar que el orden dentro del ciclo varía entre ciclos (dos ciclos comparados no coinciden siempre) mediante la misma comprobación
- [x] 2.3 Crear la pieza activa (`ActivePiece`: tipo, forma, posición) y su rotación horaria reutilizando `Tetromino`; verificar con comprobación ejecutable que rotar y rotar de nuevo no rompe la forma y que una forma conocida rota como se espera
- [x] 2.4 Crear la factory (`PieceFactory`) que entrega pieza y "siguiente" desde la bolsa; verificar con comprobación ejecutable que el tipo anunciado como siguiente es el que se entrega a continuación
- [x] 2.5 Crear el tablero de 22 filas (2 ocultas) con las consultas de encaje y de posición de aterrizaje; verificar con comprobación ejecutable que una forma no encaja fuera de columnas, bajo el suelo ni solapando celdas ocupadas
- [x] 2.6 Implementar en el tablero la fijación de la pieza al aterrizar y la solicitud de pieza siguiente; verificar con comprobación ejecutable que tras fijar, la pieza anterior no se mueve y aparece una pieza nueva
- [x] 2.7 Implementar la detección y eliminación de líneas visibles con compactado; verificar con comprobación ejecutable que una fila completa desaparece, que varias a la vez se resuelven en una sola compactación y que sin líneas no cambia nada
- [x] 2.8 Implementar la notificación del resultado (número de líneas, si es tetris) y la puntuación por líneas 100/300/500/800; verificar con comprobación ejecutable que cada caso suma lo esperado y que fijar sin líneas no suma
- [x] 2.9 Implementar la condición de fin de partida por celda fijada en la zona oculta; verificar con comprobación ejecutable que se declara al invadir la zona oculta y que no se solicita pieza nueva después
- [x] 2.10 Implementar la velocidad de caída como función de las líneas con suelo 0.08 s/fila; verificar con comprobación ejecutable que a 0 líneas vale 0.8, que crece de forma monótona y que nunca baja de 0.08

## 3. Vista de la pantalla de juego

- [x] 3.1 Crear la vista del tablero que dibuja fondo, rejilla, celdas fijadas, pieza activa y previsualización de aterrizaje, leyendo del core sin mutarlo; verificar visualmente que el tablero aparece a 320x640 en x=24..344, y=40..680 y que la previsualización coincide con dónde aterriza la pieza
- [x] 3.2 Montar el fondo `bg_paper.png` a pantalla completa con el tablero y el rail como viñetas dibujadas encima; verificar visualmente que el marco del papel (x=10..469, y=10..709) queda visible y que ninguna viñeta lo tapa
- [x] 3.3 Crear el panel de indicadores (SCORE, LINES, NEXT) en el rail de x=360..464 con valores vivos y previsualización con `piece_*.png`; verificar visualmente que los tres indicadores muestran valores reales y que NEXT dibuja la pieza anunciada con su forma
- [x] 3.4 Conectar el reparto de puntos y el contador de líneas del core con el panel; verificar que al limpiar una línea el panel sube 100 y +1, y al limpiar cuatro sube 800 con la onomatopeya de tetris

## 4. Entrada del jugador y flujo de pantallas

- [x] 4.1 Enrutar la entrada: flechas izquierda/derecha mover con auto-repeat, espacio y flecha arriba rotar, flecha abajo acelerar; verificar en partida que las cuatro acciones responden y que rotar funciona con ambas teclas
- [x] 4.2 Ignorar las teclas de juego fuera de `PLAYING`; verificar que en la pantalla de inicio y en la capa de fin de partida ninguna pieza responde
- [x] 4.3 Crear la raíz de flujo con los estados START, PLAYING y GAMEOVER y sus transiciones; verificar que empezar lleva a la partida y que el fin de partida la detiene
- [x] 4.4 Crear la pantalla de inicio con `bg_sky_pop.png` y el título `hud_tetris.png`; verificar visualmente que se muestra al arrancar y que al activar empezar comienza una partida
- [x] 4.5 Verificar que cada partida nueva (inicio y reintento) arranca con tablero vacío, puntuación y líneas a cero y velocidad mínima

## 5. Fin de partida y onomatopeya

- [x] 5.1 Crear la capa de fin de partida superpuesta e inmovilizar el tablero dejando la pila visible; verificar que al perder se ve la pila, que la puntuación es visible y que las piezas dejan de caer
- [x] 5.2 Añadir las acciones reintentar y volver al menú; verificar que reintentar empieza partida nueva sin pasar por el inicio y que menú vuelve a la pantalla de inicio
- [x] 5.3 Ajustar la onomatopeya al zoom dinámico de aparición, asentamiento y desvanecido, con un único elemento reutilizado; verificar visualmente que crece desde pequeño, se estabiliza y desaparece, y que limpiar líneas seguidas no apila onomatopeyas
- [x] 5.4 Verificar que la onomatopeya distingue el tetris de las jugadas menores y que no aparece al fijar sin completar línea
- [x] 5.5 Verificación de integración: jugar una partida completa comprobando el ciclo fijar → limpiar → puntuar → siguiente pieza, el aumento de velocidad por líneas y el fin de partida con reintento y vuelta al menú

## 6. Limpieza

- [x] 6.1 Retirar `Board.gd` y la lógica antigua de `Game.gd` sustituidos por el nuevo núcleo y la raíz de flujo; verificar que el proyecto arranca y se juega igual sin referencias a los scripts eliminados
- [x] 6.2 Actualizar `README.md` con la nueva estructura de scripts, escenas y controles; verificar que la sección de controles refleja mando, rotación y aceleración reales
