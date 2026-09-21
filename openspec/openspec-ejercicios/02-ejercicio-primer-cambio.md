# Ejercicio 2 — Primer cambio completo

> **Objetivo:** recorrer el flujo completo explore → propose → apply → archive.

**Duración estimada:** 30–45 min

---

## Contexto

Tienes un proyecto (el de `~/openspec-lab` del Ejercicio 1, o cualquier repo con OpenSpec
inicializado). Vas a añadir una feature sencilla: **modo oscuro** en una app web.

## Instrucciones

1. **Explora la idea** (en el chat de tu agente de IA):
   ```
   /openspec-explore how dark mode should work in this app
   ```
   Deja que el agente lea el codebase y plantee opciones. No debe escribir código ni archivos.

2. **Propón el cambio:**
   ```
   /openspec-propose add-dark-mode
   ```
   El agente creará `openspec/changes/add-dark-mode/` con `proposal.md`, `specs/`, `design.md`
   y `tasks.md`.

3. **Revisa el plan.** Lee en orden:
   - `proposal.md` — ¿problema correcto, tamaño correcto?
   - `specs/` — ¿aceptarías estos requisitos como "hecho"?
   - `tasks.md` — ¿cubren las specs y nada más?

4. **Corrige el plan** si hace falta (edita los archivos o dile al agente qué está mal).

5. **Aplica el cambio** (en una sesión de chat nueva):
   ```
   /openspec-apply-change add-dark-mode
   ```
   El agente implementa las tareas y marca los checkboxes de `tasks.md`.

6. **Verifica el estado:**
   ```bash
   openspec list
   openspec view
   ```

7. **Archiva el cambio:**
   ```
   /openspec-archive-change add-dark-mode
   ```

8. **Comprueba el resultado:**
   ```bash
   openspec list --specs
   openspec view
   ```

## Preguntas de verificación

1. ¿Qué archivos crea `/opsx:propose`?
2. ¿Dónde vive el progreso de la implementación?
3. ¿Qué dos cosas hace archivar un cambio?
4. ¿Dónde quedó la carpeta del cambio tras archivar?

## Solución (referencia)

- `propose` crea `proposal.md`, `specs/`, `design.md` (solo si hace falta) y `tasks.md`.
- El progreso vive en los checkboxes de `tasks.md` (no hay estado oculto).
- Archivar fusiona los deltas en `specs/` y mueve la carpeta a `changes/archive/` con fecha.
- Tras archivar, `openspec list --specs` muestra la spec de dark mode con sus requisitos.

> **Siguiente:** [Ejercicio 3 — Spec v1.1](03-ejercicio-spec-v11.md)
