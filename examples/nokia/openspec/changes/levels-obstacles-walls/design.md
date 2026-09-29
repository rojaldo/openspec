# Design

## Context

Ver `proposal.md` para la motivación y `openspec/changes/levels-obstacles-walls/specs/` para el comportamiento. El estado actual está en `scripts/logic/snake_game.gd`, `scripts/logic/grid_config.gd`, `scripts/screens/game_screen.gd`, `scripts/board_view.gd` y `scripts/main.gd`.

Estado del que se parte, verificado:

- `snake_game.gd` tiene el tablero cableado a constantes globales (`GridConfig.WIDTH/HEIGHT/CELL`) y llama siempre a `GridConfig.wrap_cell()` en el tick. No conoce mapas ni niveles.
- `grid_config.gd` son 16 líneas de constantes; el tablero es 20x20 fijo.
- No existe ninguna noción de nivel, obstáculo ni pared.
- La partida es infinita: no hay condición de victoria.
- `_spawn_food()` recorre todo el tablero y elige una celda que no ocupe la serpiente.
- `snake-render` (interpolación + ghost del wrap) está implementada y verificada; el ghost solo se dispara cuando hay salto de orilla a orilla, así que en un nivel sin wrap nunca se activa.

## Goals / Non-Goals

**Goals:**

- Modelo de nivel como dato, sin assets externos, editable y verificable.
- Borde y dificultad como propiedades del nivel, no constantes globales.
- Diez niveles que se puedan validar automáticamente (inicio seguro, comida alcanzable, dificultad no decreciente).
- Mantener intacta la calidad ya conseguida: simulación determinista, render fluido, persistencia robusta.

**Non-Goals:**

- Selección de nivel por el jugador, vidas múltiples, guardado de progreso a medias.
- Obstáculos móviles, destructibles o con comportamiento propio.
- Power-ups, múltiples frutas, sonido.
- Cambiar `snake-render`.

## Decisions

### El tablero y sus dimensiones pasan a ser del nivel (en vez de constantes globales)

Hoy `GridConfig` fija 20x20 y `snake_game` lo lee directamente. Con 10 mapas distintos, el tablero es una propiedad más del nivel. `GridConfig` conserva solo lo verdaderamente global: el tamaño de celda en píxeles y las dimensiones por defecto. El nivel aporta su mapa, su borde, su inicio y su objetivo.

Alternativa descartada: mantener 20x20 fijo y cambiar solo el patrón de sólidos. Sería menos cambio, pero deja los 10 niveles con el mismo espacio y limita la curva; además obliga a que "tamaño de tablero" siga siendo una constante del motor en vez de un parámetro de contenido.

### Los mapas son texto dentro del proyecto (en vez de assets o de construir sólidos por código)

Cada nivel se declara como una rejilla de caracteres legible:

```text
"####################",
"#..................#",
"#....##......##....#",
"#....##......##....#",
"#........@.........#",    <- @ = inicio (cabeza), cuerpo se coloca detras
"#..................#",
"####################",
```

Un símbolo por celda: `.` libre, `#` sólido, `@` inicio. La dirección inicial es un campo aparte. Ventajas: se revisa de un vistazo, se edita sin herramientas, no es un asset binario, y los tests pueden parsearlo y validarlo.

Alternativa descartada: construir los sólidos con código (bucles, rectángulos, generadores). Es más compacto para patrones regulares, pero un nivel se vuelve difícil de leer y de validar visualmente, y los errores de diseño se esconden.

### Borde como propiedad del nivel, resuelto en un solo punto (en vez de ramas repartidas)

El tick consulta dos cosas del nivel: si la celda destino es sólida y si el borde es mortal. El `wrap` deja de aplicarse siempre y pasa a aplicarse solo si el nivel lo permite:

```text
nueva = cabeza + direccion
si sale del tablero:
    si el nivel es mortal   -> muerte
    si no                   -> nueva = wrap(nueva)
si el nivel marca `nueva` como solida -> muerte
```

Centralizarlo aquí, y no en el render ni en el input, evita que el comportamiento divergencie entre capas. El ghost del render no necesita cambios: en un nivel mortal nunca hay salto de orilla a orilla.

### Sólidas como conjunto consultable (en vez de lista)

El mapa se convierte en un `Dictionary` de celdas sólidas al cargar. Las consultas del tick (¿es sólida la celda destino?) y del render (¿qué celdas pinto?) son O(1) y el mapa en texto se parsea una sola vez. Los 400 máximos hacen que cualquier estructura valga, pero un diccionario deja el tick libre de recorrer nada.

### Objetivo y progreso por nivel, con la puntuación acumulando aparte

El nivel lleva `target` (por defecto 5). La puntuación de la partida acumula entre niveles, pero el progreso del objetivo es por nivel. Son dos contadores distintos a propósito:

```text
score           -> acumulado de la partida (lo que se guarda en la tabla)
nivel_comidos   -> cocos comidos en el nivel actual (contra el target)
```

Es el punto donde es fácil equivocarse: si se reutilizara `score` contra `target`, el nivel 2 empezaría ya superado por los cocos del nivel 1.

### Reinicio explícito de estado al empezar nivel (en vez de arrastrar)

Al empezar nivel se fijan, en una sola operación: cuerpo de 3 celdas en el inicio del nivel, dirección inicial del nivel, intervalo base, y `nivel_comidos = 0`. La puntuación **no** se toca. Es la asimetría que pide el usuario: el score acumula, la serpiente no. Queda escrito en la spec para que no se "corrija" por error.

### Inicio seguro como invariante verificado, no como criterio de diseño

El riesgo real que señaló el usuario: morir al primer tick porque hay un sólido pegado a la cabeza. En vez de confiar en diseñar bien los mapas, se comprueba por test sobre los 10 niveles:

```text
1. las 3 celdas del cuerpo inicial estan libres
2. la celda frente a la cabeza esta libre (el primer tick no mata)
3. existe al menos un giro perpendicular libre
```

Los tres son consultas baratas sobre el mapa. Cualquier mapa que los incumpla falla la suite, así que un mapa mal diseñado no llega a jugarse.

### Comida solo en celdas alcanzables (BFS desde la cabeza)

`_spawn_food` deja de elegir entre todas las celdas y elige entre las **alcanzables** desde la cabeza, con una búsqueda en anchura sobre las celdas transitables. Sin esto, un muro que cierre un bolsillo deja el nivel imposible de completar. Es la protección que hace que el sistema no dependa de que los 10 mapas sean perfectos.

Alternativa descartada: exigir solo mapas conexos y confiar en el diseño. Es más rápido, pero no protege contra un mapa futuro mal editado, y el coste de la BFS (400 celdas como máximo) es despreciable.

### Velocidad base uniforme y rampa por nivel

Todos los niveles arrancan con el mismo intervalo base (`BASE_TICK`), como pidió el usuario, para reconocer el mapa con calma. La rampa de aceleración por coco sí crece con el nivel mediante un `step` propio de cada nivel, de modo que los últimos aprietan más sin arrancar más rápido que el primero.

```text
intervalo = max(MIN_TICK, BASE_TICK - step_del_nivel * nivel_comidos)
```

Con `step` creciente por nivel, el intervalo de fin de nivel baja de ~0.18 (nivel 1) a ~0.07 (nivel 10), que es donde entra el suelo `MIN_TICK`.

Alternativa descartada: subir también `BASE_TICK` por nivel (lo que propuse primero). Se descartó por indicación del usuario: arrancar rápido en niveles avanzados estresa al llegar, justo cuando se está conociendo el mapa.

### Progresión lineal con transición en la propia pantalla

Una partida recorre 1→10. Superar un nivel muestra un aviso breve (número y objetivo) sobre la pantalla de juego y continúa, sin pantalla adicional. Mantiene las tres pantallas existentes. Completar el nivel 10 deriva a la pantalla de puntuaciones en modo victoria, reutilizando esa pantalla con un texto distinto.

Alternativa descartada: pantalla intermedia entre niveles. Añade una cuarta pantalla y una parada extra para algo que se resuelve con un rótulo.

### Persistencia con campo nuevo y compatibilidad hacia atrás

Cada entrada gana `nivel`. Al leer, una entrada sin ese campo se acepta igual (nivel 0 o ausente), para no romper las tablas ya guardadas en `user://scores.json`. Es la misma robustez que ya tiene la lectura ante archivo corrupto.

### Tests

La lógica de niveles es GDScript puro y testeable sin render: validación de los 10 mapas (inicio seguro, dimensiones, objetivo), borde mortal vs atravesable, sólidas, comida alcanzable, reinicio de estado por nivel y rampa de velocidad por nivel. Los tests de wrap existentes se reescriben para verificar el borde **según el nivel** en vez de como regla global.

## Risks / Trade-offs

- [Mapa imposible por bolsillo cerrado] → Mitigado por la comida alcanzable (BFS), que protege incluso con mapas mal editados.
- [Muerte al primer tick] → Mitigado por el invariante de inicio seguro, verificado por test en los 10 niveles.
- [Dos contadores de progreso confundidos] → `score` y `nivel_comidos` son campos separados con nombres distintos; test específico de que el nivel 2 no arranca superado.
- [Tests de wrap existentes quedan obsoletos] → Se reescriben como verificación por nivel; se actualizan en el mismo cambio o la suite no compila.
- [Reinicio de estado incompleto] → Un test que juega dos niveles seguidos comprobando cuerpo de 3 celdas y velocidad base al empezar el segundo.
- [Dificultad que decrece sin querer] → Test que verifica que el número de sólidos y el objetivo no bajan entre niveles consecutivos.

## Open Questions

- **Los mapas concretos de los nueve niveles restantes** (el 1 y los patrones base ya están descritos en este diseño) se diseñan al implementar. No cambian ni el modelo de datos, ni las specs, ni el desglose de tareas: son contenido que se rellena con el formato ya fijado. Si algún patrón resulta injugable al probarlo, se ajusta el mapa, no el diseño.
