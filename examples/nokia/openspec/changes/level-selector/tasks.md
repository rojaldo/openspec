# Tasks

## 1. Nivel de arranque en la pantalla de juego

- [x] 1.1 Añadir a `game_screen.gd` la propiedad `start_level` (por defecto 0) y usarla en `_ready` al llamar a `game.start`, y verificar con test que arrancar con `start_level` 6 deja la partida en el nivel 7
- [x] 1.2 Verificar con test que sin fijar `start_level` la partida arranca en el nivel 1 como antes, y que el resto de tests de integración siguen pasando

## 2. Pantalla del selector de nivel

- [x] 2.1 Crear `scripts/screens/level_select_screen.gd` con su señal `level_chosen(index)` y `back_requested`, y verificar que se instancia sin errores
- [x] 2.2 Generar los diez botones desde `Levels` con la etiqueta `N · objetivo`, en una rejilla de 2 filas por 5 columnas, y verificar con test que hay diez botones y que cada etiqueta lleva el número y el objetivo del nivel
- [x] 2.3 Añadir el botón de volver al inicio y verificar que emitir `back_requested` llega a quien lo escucha
- [x] 2.4 Verificar con test que pulsar el botón del nivel 7 emite `level_chosen` con el índice 6

## 3. Flujo del estado nuevo

- [x] 3.1 Añadir a `main.gd` la rama `_show_level_select()` y conectar `level_chosen` con el arranque de partida en ese nivel, y verificar con test que la pantalla del selector es la hija activa tras pedirla
- [x] 3.2 Modificar `_show_game()` para aceptar el nivel de arranque (por defecto 0) y fijarlo en la pantalla antes de `add_child`, y verificar con test que al elegir un nivel la partida queda en ese nivel y no en el 1
- [x] 3.3 Conectar la señal `back_requested` del selector con la vuelta al inicio, y verificar con test que vuelve a la pantalla de inicio

## 4. Pantalla de inicio con dos opciones

- [x] 4.1 Añadir a `start_screen.gd` la señal `select_level_requested` y el botón de elegir nivel junto al de empezar partida, y verificar con test que ambos botones existen
- [x] 4.2 Conectar en `main.gd` la señal nueva con `_show_level_select`, y verificar con test que desde el inicio se llega al selector

## 5. Verificación de integración

- [x] 5.1 Añadir al test de integración el recorrido inicio → selector → elegir nivel 7 → juego en el nivel 7, y verificar que pasa
- [x] 5.2 Verificar que desde el nivel elegido la progresión sigue: completar el objetivo del nivel 7 lleva al nivel 8
- [x] 5.3 Verificar que la opción de empezar partida sigue arrancando en el nivel 1 y que el recorrido de victoria desde el selector es alcanzable
- [x] 5.4 Ejecutar la suite completa (lógica, integración, movimiento, niveles) y verificar que pasa en verde
- [x] 5.5 Jugando en ventana, verificar visualmente el selector: los diez botones con número y objetivo, y que elegir uno arranca la partida en ese nivel
