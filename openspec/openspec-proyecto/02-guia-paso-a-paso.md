# Guía Paso a Paso — Proyecto Todo API

> **Objetivo:** recorrer el proyecto final con instrucciones concretas, de la idea al archivo.

---

## Paso 0 — Preparación

Asegúrate de tener:
- Node.js 20.19.0+ y el CLI de OpenSpec instalado (`openspec --version`).
- Un proyecto con OpenSpec inicializado (`openspec init`).

```bash
mkdir -p ~/todo-api && cd ~/todo-api
git init
openspec init
```

---

## Paso 1 — Explora (opcional)

En el chat de tu agente:

```
/openspec-explore how a todo API should be structured in this project
```

Deja que el agente lea el (posiblemente vacío) codebase y plantee opciones de estructura,
stack y persistencia. No debe escribir código.

---

## Paso 2 — Propón

```
/openspec-propose build a todo API
```

El agente creará `openspec/changes/<nombre>/` con:
- `proposal.md` — por qué y qué cambia.
- `specs/` — requisitos con escenarios.
- `design.md` — decisiones técnicas (stack, base de datos).
- `tasks.md` — checklist de implementación.

> 💡 **Tip:** si prefieres partir de una spec v1.1 ya escrita, usa
> `01-spec-todo-api.oschema.json` como referencia y pídele al agente que la use como base.

---

## Paso 3 — Revisa y corrige el plan

Lee en orden:
1. `proposal.md` — ¿problema correcto, tamaño correcto?
2. `specs/` — ¿aceptarías estos requisitos como "hecho"?
3. `tasks.md` — ¿cubren las specs y nada más?

Corrige lo que haga falta (edita los archivos o dile al agente qué está mal). Asegúrate de que
los requisitos cubran: crear, listar, validar, completar y eliminar todos.

---

## Paso 4 — Aplica

Empieza una **sesión de chat nueva** (contexto limpio):

```
/openspec-apply-change <nombre-del-change>
```

El agente implementa las tareas y marca los checkboxes de `tasks.md`. Si se interrumpe, abre
otra sesión y pide aplicar de nuevo: reanuda en la primera tarea sin marcar.

---

## Paso 5 — Valida

```bash
openspec validate --all
openspec view
```

Revisa los "archive merge findings" (conflictos de merge potenciales). Corrige cualquier
problema estructural antes de archivar.

---

## Paso 6 — Archiva

Cuando cada checkbox de `tasks.md` esté marcado:

```
/openspec-archive-change <nombre-del-change>
```

Archivar fusiona los deltas en `specs/` y mueve la carpeta a `changes/archive/` con fecha.

---

## Paso 7 — Verifica

```bash
openspec list --specs
openspec view
```

Deberías ver la spec de la Todo API con sus requisitos, y el change archivado.

---

## Paso 8 — Prueba la API

Levanta el servicio y prueba los endpoints:

```bash
# Crear
curl -X POST http://localhost:3000/todos -H 'Content-Type: application/json' -d '{"title":"Comprar leche"}'
# Listar
curl http://localhost:3000/todos
# Completar
curl -X PATCH http://localhost:3000/todos/<id> -H 'Content-Type: application/json' -d '{"completed":true}'
# Eliminar
curl -X DELETE http://localhost:3000/todos/<id>
# Input inválido (debe dar 400)
curl -X POST http://localhost:3000/todos -H 'Content-Type: application/json' -d '{}'
```

---

## Criterios de éxito

- [ ] La spec v1.1 es válida y tiene todos los campos obligatorios.
- [ ] Los requirements tienen `acceptanceCriteria` Given/When/Then.
- [ ] Hay al menos un epic con tickets y dependencias declaradas.
- [ ] El change pasó por propose → apply → archive.
- [ ] `openspec validate --all` pasa sin findings críticos.
- [ ] La API implementada cumple los requisitos funcionales y no funcionales.

---

## 🎉 ¡Felicidades!

Completaste el curso de OpenSpec. Ahora sabes cómo **acordar primero y construir con confianza**:
especificar, planificar, implementar y archivar cambios de forma predecible con tu agente de IA.

**Siguiente paso:** aplica OpenSpec a un proyecto real. Empieza con un cambio pequeño y de bajo
riesgo para afianzar el flujo.
