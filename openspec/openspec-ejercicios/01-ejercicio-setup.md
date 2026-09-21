# Ejercicio 1 — Setup

> **Objetivo:** instalar OpenSpec y configurar tu primer proyecto.

**Duración estimada:** 15–20 min

---

## Instrucciones

1. **Comprueba tu versión de Node.js:**
   ```bash
   node --version
   ```
   Debe ser `v20.19.0` o superior. Si no, instala una versión más nueva.

2. **Instala el CLI globalmente:**
   ```bash
   npm install -g @fission-ai/openspec@latest
   ```

3. **Verifica la instalación:**
   ```bash
   openspec --version
   ```

4. **Crea un proyecto de prueba y configúralo:**
   ```bash
   mkdir -p ~/openspec-lab && cd ~/openspec-lab
   git init
   openspec init
   ```
   Elige tu herramienta de IA en el selector (o usa `--tools none` si no quieres archivos de tool).

5. **Inspecciona lo que se creó:**
   ```bash
   tree openspec/          # o: ls -R openspec/
   cat openspec/config.yaml
   ```

6. **Comprueba el dashboard:**
   ```bash
   openspec view
   ```

## Preguntas de verificación

1. ¿Qué versión de Node.js necesitas y por qué?
2. ¿Qué dos cosas crea `openspec init`?
3. ¿Qué contiene `openspec/config.yaml`?
4. ¿Qué muestra `openspec view` cuando no hay changes ni specs?

## Solución (referencia)

- La carpeta `openspec/` debe tener `config.yaml`, `specs/` (vacía) y `changes/` (vacía, con
  `archive/`).
- `openspec view` muestra un dashboard con 0 specs, 0 draft changes, 0 active, 0 completed.
- Si elegiste una tool, verás skills/commands en `.claude/`, `.agents/`, etc.

> **Siguiente:** [Ejercicio 2 — Primer cambio](02-ejercicio-primer-cambio.md)
