# Design

## Context

Proyecto Godot 4.7 nuevo, sin código previo ni `project.godot`. La motivación y el alcance están en `proposal.md`; el comportamiento exacto en `openspec/changes/nokia-snake-game/specs/`. Este documento fija las decisiones técnicas que hacen que esos requisitos sean implementables.

Restricciones que condicionan el enfoque:

- El motor es Godot 4.7 en GDScript.
- El movimiento debe verse continuo aunque la simulación avance por celdas (requisito `snake-render`).
- El wrap-around permite que la serpiente quede partida en dos orillas, y el dibujado no puede trazar unión entre ellas (requisito `snake-render`).
- La velocidad sube con cada coco, lo que a valores altos descarta enfoques basados en física continua.

## Goals / Non-Goals

**Goals:**

- Un bucle de simulación determinista, testeable, con velocidad como único parámetro de dificultad.
- Un render interpolado y desacoplado de la simulación, sin salto en el cruce de borde.
- Tres pantallas con un flujo de escenas claro y persistencia local de puntuaciones.

**Non-Goals:**

- Sonido, vibración y efectos animados.
- Laberintos, obstáculos, power-ups o varias frutas.
- Cualquier red o servicio externo.
- Separar la lógica en un addon o runtime independiente del motor.

## Decisions

### Rejilla + tick como modelo de simulación (en vez de movimiento continuo con física)

La simulación vive en un tablero de celdas y avanza un tick cada `wait_time` de un `Timer`. La velocidad es ese intervalo: comer lo reduce con un mínimo (`time = max(MIN_TICK, BASE_TICK - STEP * cocos)`), propuesta `max(0.07, 0.18 - 0.004 * cocos)`.

Alternativa descartada: mover la cabeza por píxeles con `delta` y detectar colisión con `Area2D`. A intervalos cortos el cuerpo continuo atraviesa su propia cola entre frames (*tunneling*), justo cuando la dificultad creciente aprieta. En rejilla la colisión es comparar celdas: determinista y testeable.

### Render interpolado por segmentos independientes (en vez de `Line2D`)

Cada segmento se dibuja con `_draw()` en `lerp(from, to, t) * CELL`, donde `t = 1 - timer.time_left / timer.wait_time`. La cola se dibuja quieta el tick que come, y por eso el crecimiento se ve de forma natural.

Alternativa descartada: un `Line2D` continuo. Con wrap la serpiente puede quedar en dos orillas a la vez y `Line2D` dibujaría una línea recta cruzando el tablero entre ambas. Segmentos sueltos además encajan con el look de bloques del Nokia y evitan nodos por celda o *pooling*.

### Cruce de borde dibujado con "ghost" a ambos lados

**Default adoptado (no confirmado explícitamente por el usuario).** El tick en que un segmento cruza el borde, ese segmento se pinta dos veces: una interpolando hacia fuera de la orilla de salida y otra entrando desde fuera en la orilla opuesta. Como la cabeza avanza una celda por tick, como máximo cruza un segmento por tick, así que es un caso especial de una sola celda, no un sistema general.

Alternativas: *snap* (aparece de golpe al otro lado) es menos código pero incumple "sin golpes" en las orillas; un campo de visión repetido (dibujar el tablero 3x3 veces) es más robusto pero desproporcionado para un cruce por tick.

### Crecer = no liberar la cola (en vez de insertar un segmento)

El cuerpo es una lista ordenada de celdas, de cabeza a cola. Cada tick: calcular nueva cabeza, quitarla del final solo si **no** se come, y comprobar colisión contra el cuerpo ya recortado. Comer no inserta nada: es la cola la que no se quita, así la longitud crece exactamente una celda.

Alternativa descartada: al comer, insertar una celda extra en la cola. El tick que come la serpiente avanzaría dos celdas y el cuerpo tendría una celda fantasma.

### Orden de la colisión

La colisión se comprueba **después** de recortar la cola y **antes** de encadenar el nuevo segmento. Así entrar en la celda que la cola acaba de liberar es legal, y el tick que come (cola no liberada) sí puede morder. Es la regla clásica y la que evita falsos "he muerto en la última celda de la cola".

### Input en el tick, no en el frame

La dirección se guarda como intención y se aplica al inicio de cada tick. Un giro a mitad de interpolación dibujaría la cabeza girando desde media celda. Se ignora la dirección opuesta a la actual para no chocar con el cuello.

### Cocos por lista de celdas libres

En cada aparición se construyen las celdas no ocupadas (tablero de 20x20 = 400) y se elige una al azar. Evita el rechazo por muestreo cuando la serpiente es larga. Se mantiene un solo coco a la vez.

### Escenas, nodos y señales

```
Main (Node)                         <- autoload de flujo de pantallas
 |
 +-- StartScreen (Control)          [Jugar] --signal--> game
 |
 +-- GameScreen (Control)           instancia GameBoard
 |    +-- GameBoard (Node2D)
 |         +-- Timer (autoload tick)
 |         +-- Snake (Node2D, _draw)
 |         +-- Cocos (Node2D, _draw)
 |
 +-- ScoresScreen (Control)         LineEdit nombre + tabla + [Reintentar][Menu]
```

- `Snake` es dueño de la lista de celdas; expone una señal `died` y `ate(cocos)`. Nadie más muta el cuerpo.
- `Main` escucha `died` y decide el cambio de escena.
- La puntuación vive en el estado de la partida; `ScoresScreen` la recibe al entrar y solo entonces la persiste, ya con el nombre.
- Persistencia: `user://scores.json` con lista de objetos `{name, score}`, top 10, escritura y lectura propias. Nada de `ResourceSaver` ni addons.

### Estilo visual

Paleta monocroma verde tipo LCD. Sprite/fuente de píxel del propio proyecto (sin assets externos), rejilla visible y borde del tablero. Las tres pantallas comparten tema.

### Tests

GDScript puro sobre la lógica de rejilla, sin depender del render: avance, wrap, elección de celda libre, crecimiento unitario, regla de cola liberada, tope de velocidad y orden de la tabla. Los casos de la spec ya son la lista de tests.

## Risks / Trade-offs

- [Ghost solo cubre un segmento por tick] → Es una garantía del modelo (una celda por tick), no una limitación; si en el futuro el paso fuese mayor, habría que generalizarlo.
- [Velocidad como único eje de dificultad] → Satura en el tope mínimo; es lo que pide el clásico. Si se quiere más dificultad, sería un cambio de spec aparte.
- [Render acoplado al `Timer`] → Si el `wait_time` cambia al comer a mitad de tick, la interpolación puede dar un salto; mitigación: aplicar el cambio de intervalo al inicio del siguiente tick.
- [Persistencia JSON propia] → Sin versionado de formato; mitigación: tolerar lectura inválida tratándola como tabla vacía.
- [LineEdit en la pantalla final] → Mantiene las tres pantallas pedidas, a costa de que el nombre se pida en el mismo sitio donde ya se ve el resultado.

## Open Questions

Ninguna abierta: las dos que quedaban (cruce de borde y dónde se pide el nombre) se han resuelto como *ghost* y *LineEdit en la pantalla final*, respectivamente. Ambas quedan marcadas arriba como adoptadas por defecto, por si se quiere cambiarlas antes de implementar.
