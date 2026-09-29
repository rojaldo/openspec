# Design

## Context

Ver `proposal.md` para la motivación. El comportamiento exacto está en `openspec/changes/smooth-snake-motion/specs/snake-render/spec.md` y el estado actual del render en `scripts/board_view.gd` y `scripts/screens/game_screen.gd`.

El defecto se reprodujo y midió sobre el juego real antes de decidir nada:

```
Frame del salto (prev_cells y cells SIN cambiar entre los dos frames):
  ANTERIOR: progress=0.998  time_left=0.180  cells=(3,10)->(4,10)  drawn=4.00
  ACTUAL  : progress=0.000  time_left=0.173  cells=(3,10)->(4,10)  drawn=3.00

Comparación de dos relojes sobre el mismo juego (500 frames):
  reloj actual (timer.time_left)     -> 21 retrocesos visuales
  reloj monótono (acumulador delta)  ->  1 retroceso visual
```

Restricciones que condicionan el enfoque:

- El movimiento debe seguir siendo por rejilla; la interpolación es solo presentación.
- No se tocan las reglas del juego ni los requisitos de wrap, segmentos independientes o coherencia con la simulación.
- Godot 4.7, GDScript. Sin dependencias nuevas.

## Goals / Non-Goals

**Goals:**

- Eliminar el temblor por construcción: la posición dibujada avanza siempre, nunca retrocede.
- Que el cambio de intervalo al comer no introduzca salto.
- Dejar el conteo de retrocesos como test de regresión.

**Non-Goals:**

- Cambiar la simulación, la velocidad, el wrap, la colisión o la puntuación.
- Introducir suavizado, aceleración/deceleración o movimiento subcelular en la lógica.
- Añadir easing, animaciones o efecto de estela.

## Decisions

### Reloj monótono con acumulador, anclado al avance de la simulación (en vez de leer `timer.time_left`)

La interpolación se calcula con un acumulador propio que crece con el delta de frame y se reinicia en la **misma operación** en la que la simulación avanza un tick. El progreso es `acc / intervalo`, y el sobrante del tick se acarrea en lugar de descartarse.

```text
_process(delta):
    acc += delta
    mientras acc >= intervalo:      # normalmente 0 o 1 vez
        simular_tick()              # avanza la rejilla y ancla prev_cells
        acc -= intervalo            # acarreo del sobrante
    dibujar(prev_cells, cells, acc / intervalo)
```

Alternativa descartada: leer `timer.time_left` como hasta ahora. Es la causa raíz: el `Timer` reinicia su cuenta y emite el tick en pasos separados, así que existe un frame en el que el reloj ya es cero pero la simulación aún no ha avanzado, y la vista dibuja las celdas viejas con progreso nulo. Es aritmética correcta gobernada por un reloj que no está sincronizado con lo que pretende medir.

Alternativa descartada: interpolar sin acumulador, con un `tween` o un `AnimationPlayer` por tick. Añade nodos y estado por segmento, y sigue necesitando resolver qué pasa cuando el intervalo cambia a mitad de tramo.

### Una sola fuente de tiempo: se elimina el nodo `Timer`

El acumulador vive en el controlador de la pantalla de juego y es el que marca el ritmo; el `Timer` desaparece. Dos relojes independientes para el mismo suceso es justo lo que permitía la desincronización, y el `timer.start()` que se añadió para reiniciar `time_left` al comer era en sí mismo una fuente de tirón.

Alternativa considerada: conservar el `Timer` para el tick y que la vista lleve su propio acumulador reiniciado en `_on_tick`. Es un diff de dos líneas y funciona, pero mantiene dos relojes que hay que recordar resetear juntos; se descarta a favor de eliminar la dualidad por construcción.

### La vista recibe el progreso, no lo calcula

`BoardView` deja de leer el `Timer` y pasa a exponer un `progress` que le entrega el controlador. La matemática de interpolación (`board_render.gd`) no cambia: sigue recibiendo `(prev, cells, t)` y sigue devolviendo una o dos posiciones según haya cruce de borde. Se preserva el ghost del wrap tal cual.

Alternativa descartada: mover también la interpolación de posición a la lógica. No aporta nada al defecto y ensuciaría la separación actual, que funciona bien.

### El acarreo del sobrante evita el salto al comer

Al comer, el intervalo baja. Con `acc -= intervalo_viejo`, el sobrante ya transcurrido se conserva y el primer frame del tramo nuevo parte de una fracción coherente; si en su lugar se reiniciara el reloj a cero, ese frame daría un micro-retroceso. Por eso el acarreo no es un detalle de precisión: es parte del arreglo del síntoma "acelerón al comer".

### Tope de tramos por frame

Para que una pausa larga o un `delta` grande no disparen muchos ticks de golpe, el bucle de simulación procesa como máximo un número pequeño y fijo de ticks por frame, y en ese caso descarta el acarreo restante. Es una salvaguarda de estabilidad, no un cambio de reglas.

### Test de regresión

El test mide lo mismo que midió el diagnóstico: durante N frames, con comidas forzadas, cuenta cuántas veces la posición dibujada de la cabeza retrocede respecto a la dirección de avance. El requisito es **cero retrocesos**. Se apoya en la sonda ya usada, convertida en test permanente.

## Risks / Trade-offs

- [El delta de frame es variable] → El acumulador lo absorbe; el tope de tramos por frame acota el peor caso tras una pausa.
- [Cambio de intervalo al comer] → Mitigado por el acarreo del sobrante; un test con comidas repetidas lo cubre.
- [Se elimina un nodo del árbol] → `game_screen.gd` y el test de movimiento existente referencian el `Timer`; hay que actualizarlos en el mismo cambio o la suite no compila.
- [La spec aún no existe como principal] → El delta se formula como cambio del requisito y se aplica cuando `nokia-snake-game` esté archivado; ver Open Questions.

## Open Questions

- **Secuencia de archivo.** `openspec validate --strict` avisa: "Archive would refuse this delta: snake-render: target spec does not exist; only ADDED requirements are allowed for new specs." La spec `snake-render` no existe todavía como principal porque `nokia-snake-game` está `complete` pero sin archivar. Este delta `MODIFIED` requiere archivar `nokia-snake-game` (o sincronizar sus specs) antes de poder archivar `smooth-snake-motion`. No cambia el diseño ni las tareas; sí cambia el orden de archivo, y se resolverá al archivar, no antes.
