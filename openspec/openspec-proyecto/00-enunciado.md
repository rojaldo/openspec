# Proyecto Práctico Final — Todo API con OpenSpec

> **Objetivo:** consolidar todo el curso construyendo una API de todos completa, guiada por
> especificaciones, de principio a fin.

**Duración estimada:** 3–4 horas

---

## Enunciado

Vas a construir una **Todo API** (servicio HTTP stateless con base de datos relacional) usando
el flujo completo de OpenSpec. El objetivo no es solo escribir el código, sino **demostrar que
dominas el proceso**: especificar, planificar, implementar y archivar.

### Requisitos funcionales

1. **Crear un todo** — `POST /todos` con un título. Devuelve `201` con el todo creado (id generado).
2. **Listar todos** — `GET /todos` devuelve todos en orden de creación.
3. **Rechazar input inválido** — un payload sin título devuelve `400`.
4. **Completar un todo** — `PATCH /todos/:id` marca un todo como completado.
5. **Eliminar un todo** — `DELETE /todos/:id`.

### Requisitos no funcionales

- Los todos deben **sobrevivir a un reinicio** del servicio (persistencia).
- La API debe exponer un **contrato estable** y documentado.

### Fuera de alcance

- Autenticación y cuentas multi-usuario.

---

## Entregables

1. **Spec v1.1** (`todo-api.oschema.json`) — ver `01-spec-todo-api.oschema.json` como referencia.
2. **Un change** con `proposal.md`, `specs/`, `design.md` y `tasks.md`.
3. **La implementación** del servicio (lenguaje a tu elección).
4. **El change archivado** con los deltas fusionados en `specs/`.

---

## Pasos sugeridos

1. **Explora** la idea con `/opsx:explore` (o directamente propón si lo tienes claro).
2. **Propón** el cambio con `/opsx:propose`.
3. **Revisa y corrige** el plan.
4. **Aplica** con `/opsx:apply` (sesión limpia).
5. **Valida** con `openspec validate --all`.
6. **Archiva** con `/opsx:archive-change`.
7. **Verifica** con `openspec list --specs` y `openspec view`.

---

## Criterios de evaluación

- [ ] La spec v1.1 es válida y tiene todos los campos obligatorios.
- [ ] Los requirements tienen `acceptanceCriteria` Given/When/Then.
- [ ] Hay al menos un epic con tickets y dependencias declaradas.
- [ ] El change pasó por propose → apply → archive.
- [ ] `openspec validate --all` pasa sin findings críticos.
- [ ] La API implementada cumple los requisitos funcionales y no funcionales.

---

**Siguiente:** [Spec de referencia](01-spec-todo-api.oschema.json) · [Guía paso a paso](02-guia-paso-a-paso.md)
