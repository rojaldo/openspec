# Proposal

## Why

Hoy la partida siempre empieza en el nivel 1: la única forma de llegar a un nivel avanzado es jugárselos todos desde el principio. Se quiere poder elegir el nivel de arranque, de forma opcional, sin perder el arranque normal desde el primer nivel. Esto añade un estado nuevo al flujo de pantallas: un selector de nivel al que se llega desde la pantalla de inicio.

## What Changes

- Nuevo **selector de nivel**: una pantalla que muestra los diez niveles y permite elegir uno para empezar la partida en él.
- La **pantalla de inicio** pasa a ofrecer dos opciones: empezar partida (arranca en el nivel 1, como hasta ahora) y elegir nivel (lleva al selector).
- El **selector** ofrece los diez niveles siempre disponibles, sin desbloqueo ni progreso guardado, y una opción para volver al inicio.
- Al elegir un nivel, la partida arranca en ese nivel y **continúa con la progresión normal** hacia los siguientes hasta el décimo, con victoria al completarlo.
- El motor ya sabe arrancar en un nivel concreto; este cambio solo lo usa desde la interfaz.

## Capabilities

### New Capabilities
<!-- Ninguna: no se introduce ninguna capacidad nueva. El selector es una pantalla más de `game-screens`. -->

### Modified Capabilities
- `game-screens`: la pantalla de inicio gana la opción de elegir nivel; se añade el requisito de un selector de nivel al que se llega desde el inicio y desde el que se arranca la partida en el nivel elegido.

## Impact

- Código afectado: `scripts/screens/start_screen.gd` (segunda opción), `scripts/screens/game_screen.gd` (nivel de arranque) y `scripts/main.gd` (estado y transiciones nuevas). Pantalla nueva `scripts/screens/level_select_screen.gd`.
- El motor (`snake_game.gd`), los niveles (`levels.gd`), la persistencia (`scores.gd`) y el render (`board_view.gd`) quedan intactos: el arranque por nivel ya existe.
- No hay cambio de reglas de juego, ni de dificultad, ni de puntuación.
- Fuera de alcance: desbloqueo progresivo de niveles, guardado del nivel alcanzado como progreso, y el acceso al selector desde la pantalla de puntuaciones.
