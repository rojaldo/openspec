# Módulo 9 — Buenas Prácticas y Errores Comunes

> **Objetivo:** aplicar OpenSpec con disciplina y evitar los errores típicos.

---

## 9.1 Buenas prácticas

### Empieza explorando cuando dudes
`/opsx:explore` es un compañero de pensamiento sin riesgo: lee tu código, plantea opciones y
convierte una idea difusa en un plan concreto **antes** de que exista cualquier artefacto. Es
el mejor antídoto contra una IA que construirá algo a partir de un prompt vago.

### Revisa el plan antes de construir
Lee en orden: `proposal.md` (¿problema correcto, tamaño correcto?), `specs/` (¿aceptarías estos
requisitos como "hecho"?), `tasks.md` (¿cubren las specs y nada más?). Corregir un párrafo es
gratis; corregir 400 líneas de código no.

### Mantén los changes enfocados
Como nada te fuerza hacia adelante, la disciplina es tuya: **mantén un change enfocado** en vez
de dejar que se desparrame. Un change, una feature.

### Usa sesiones limpias para implementar
La implementación va mejor con una ventana de contexto limpia. Empieza una sesión de chat nueva
para `/opsx:apply` y mantén buena higiene de contexto.

### Escribe criterios de aceptación estructurados
Los agentes alucinan requisitos cuando la spec es vaga. Usa Given/When/Then en los
`acceptanceCriteria` para darles una checklist explícita de aprobado/fallo.

### Usa shared patterns para evitar style drift
Da a los agentes una única fuente de verdad para convenciones de código, imports comunes y
tipos de retorno. Sin esto, cada agente inventa las suyas.

### Mantén los blueprints versionados
Los artefactos de diseño que viven fuera de la spec se pierden o quedan obsoletos. Guárdalos
como blueprints, enlazados a los tickets que los implementan.

### Declara dependencias explícitas
Sin datos de dependencia, un motor podría empezar un ticket cuyos prerrequisitos no están hechos.
Usa `requires`/`blocks` y deja que el validador detecte ciclos y referencias colgantes.

### Haz commit de todo
Commit de la carpeta `openspec/` y de los archivos de workflow como parte de tu código fuente.
Seis meses después, la spec te dice *por qué* el sistema funciona como funciona.

### Usa modelos de alto razonamiento
OpenSpec funciona mejor con modelos de alto razonamiento (se recomiendan Codex 5.5 y Opus 4.7)
tanto para planificar como para implementar.

---

## 9.2 Errores comunes

### ❌ Saltarse el plan e ir directo a aplicar
El valor de OpenSpec está en el acuerdo previo. Si aplicas sin revisar el plan, vuelves al
problema original: la IA construye lo que le pides vagamente.

### ❌ Reescribir toda la spec en un change
No reescribas el mundo. Escribe **deltas** (ADDED/MODIFIED/REMOVED). Ese es el truco que hace
que OpenSpec funcione en brownfield.

### ❌ Confundir dónde corren los comandos
`openspec init` corre en la **terminal**; `/opsx:propose` corre en el **chat de tu agente**.
Es la fuente de confusión más común.

### ❌ No ejecutar `openspec update` tras cambiar la config
Los cambios de config no llegan a los proyectos hasta que ejecutas `openspec update`.

### ❌ Usar OpenSpec para todo
Para un fix trivial de una línea, la ceremonia puede no pagar. OpenSpec es ligero, pero no es
gratis. Úsalo donde el acuerdo importe.

### ❌ Ignorar los "archive merge findings" de `validate`
`openspec validate` reporta conflictos de merge potenciales (p. ej. un MODIFIED cuyo target
falta) como INFO. Revísalos: pueden indicar que un change hermano aún no ha archivado.

### ❌ Dejar que un change se desparrame
Como nada te obliga a avanzar, un change sin disciplina crece sin control. Mantén el scope
ajustado y actualiza el `proposal` si el scope debe encogerse.

### ❌ No declarar dependencias entre tickets
Un motor podría empezar un ticket cuyos prerrequisitos no están hechos. Declara `requires`/`blocks`
y deja que el validador detecte ciclos.

---

## 9.3 Checklist de un change saludable

- [ ] `proposal.md` describe el problema correcto, con el tamaño correcto.
- [ ] `specs/` tiene requisitos con criterios de aceptación Given/When/Then.
- [ ] `tasks.md` cubre las specs, y nada más.
- [ ] Los deltas son ADDED/MODIFIED/REMOVED, no reescrituras completas.
- [ ] Las dependencias entre tickets están declaradas.
- [ ] Los blueprints están versionados y referenciados.
- [ ] `openspec validate` pasa sin findings críticos.
- [ ] Cada checkbox de `tasks.md` está marcado antes de archivar.
- [ ] El change está archivado y los deltas fusionados en `specs/`.

---

## ✅ Checkpoint del módulo 9

1. ¿Por qué conviene empezar con `/opsx:explore` cuando dudas?
2. ¿Qué es el *style drift* y cómo lo previenen los shared patterns?
3. ¿Cuál es la fuente de confusión más común sobre los comandos?
4. ¿Cuándo NO conviene usar OpenSpec?
5. Nombra tres errores comunes y cómo evitarlos.

**Siguiente:** [Proyecto práctico](../proyecto/00-enunciado.md)
