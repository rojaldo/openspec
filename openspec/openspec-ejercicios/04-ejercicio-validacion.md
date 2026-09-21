# Ejercicio 4 — Validación y CLI

> **Objetivo:** usar los comandos CLI de inspección y validación.

**Duración estimada:** 20–30 min

---

## Instrucciones

Usando el proyecto del Ejercicio 2 (o uno con un change activo):

1. **Lista los changes:**
   ```bash
   openspec list
   openspec list --json
   ```

2. **Lista las specs:**
   ```bash
   openspec list --specs
   ```

3. **Muestra un change:**
   ```bash
   openspec show <nombre-del-change>
   openspec show <nombre-del-change> --diff
   ```

4. **Muestra una spec:**
   ```bash
   openspec show <nombre-de-la-spec> --json
   ```

5. **Valida todo:**
   ```bash
   openspec validate --all
   openspec validate --all --strict
   openspec validate --all --json
   ```

6. **Mira el dashboard:**
   ```bash
   openspec view
   ```

7. **Experimenta con la config:**
   ```bash
   openspec config list
   openspec config get delivery
   ```

## Preguntas de verificación

1. ¿Qué diferencia hay entre `openspec list` y `openspec view`?
2. ¿Qué hace `openspec show <change> --diff`?
3. ¿Qué son los "archive merge findings" en `validate`?
4. ¿Qué hace `--strict` en `validate`?

## Solución (referencia)

- `list` da filas de changes/specs; `view` da un dashboard de una pantalla con progreso.
- `show <change> --diff` imprime el proposal y luego los diffs por requisito (ADDED/MODIFIED/REMOVED).
- Los "archive merge findings" son conflictos de merge potenciales reportados como INFO
  (p. ej. un MODIFIED cuyo target falta); no cambian el exit code.
- `--strict` trata los warnings como fallos.

> **Siguiente:** [Proyecto práctico](../proyecto/00-enunciado.md)
