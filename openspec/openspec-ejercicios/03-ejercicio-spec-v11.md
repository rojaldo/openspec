# Ejercicio 3 — Escribir una spec v1.1

> **Objetivo:** escribir a mano una spec OpenSpec v1.1 válida.

**Duración estimada:** 30–45 min

---

## Instrucciones

Escribe a mano una spec v1.1 para una **API de notas** (Notes API). Debe incluir:

1. **Campos raíz obligatorios:** `schemaVersion: "1.1"`, `id`, `projectId`, `title`, `status`,
   `goals`, `requirements`, `architecture`, `scope`, `techStack`, `folderStructures`,
   `acceptanceCriteria`, `nonFunctionalRequirements`, `guardrails`, `epics`, `blueprints`.

2. **Al menos 2 goals** con `type` y `successCriteria`.

3. **Al menos 3 requirements** con `acceptanceCriteria` en formato Given/When/Then.

4. **Un `scope`** con `inScope` y `outOfScope`.

5. **Un `folderStructures`** con la estructura de carpetas del servicio.

6. **Un `blueprint`** con el contrato de la API (formato markdown).

7. **Un `epic`** con al menos **2 tickets**, cada uno con:
   - `ticketType`, `complexity`, `estimatedMinutes`
   - `acceptanceCriteria` Given/When/Then
   - `implementationSteps` ordenados
   - `filesToBeCreated`
   - `dependencies` (usa `requires` para que un ticket dependa del otro)

Guárdalo como `notes-api.oschema.json`.

## Pistas

- Usa el spec de Todo API del Módulo 5 como plantilla.
- Los tickets viven dentro de un epic (`epicId`).
- Un ticket sin dependencias es accionable de inmediato; los que dependen de él esperan.

## Preguntas de verificación

1. ¿Qué campos obligatorios lleva la raíz de un spec v1.1?
2. ¿Qué formato tienen los `acceptanceCriteria` y por qué?
3. ¿Cuál es la diferencia entre `requires` y `blocks`?
4. ¿Qué campos declara un ticket?

## Solución (referencia)

Un spec válido tendrá la raíz con `schemaVersion: "1.1"` y todos los campos obligatorios
presentes (aunque sea con arrays vacíos). Los requirements tendrán `acceptanceCriteria`
Given/When/Then. Los tickets estarán dentro de un epic, con dependencias declaradas (p. ej.
`ticket-list-notes` con `requires` de `ticket-create-note`).

> **Siguiente:** [Ejercicio 4 — Validación](04-ejercicio-validacion.md)
