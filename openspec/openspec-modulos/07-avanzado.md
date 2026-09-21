# Módulo 7 — OpenSpec Avanzado

> **Objetivo:** sacar más partido a OpenSpec: workflows extra, edición de changes, adopción
> en brownfield y personalización.

---

## 7.1 Workflows opcionales (profiles)

El perfil por defecto (`core`) instala: `propose`, `explore`, `apply`, `update`, `sync` y
`archive`. Hay **doce workflows** en total. Los opcionales incluyen:

- **`openspec-verify-change`** — verifica que la implementación coincide con el plan antes de
  archivar. No se instala por defecto.
- **`openspec-bulk-archive-change`** — archiva varios changes a la vez. No se instala por defecto.

Para el conjunto expandido (`/opsx:new`, `/opsx:continue`, `/opsx:ff`, `/opsx:verify`,
`/opsx:bulk-archive`, `/opsx:onboard`):

```bash
openspec config profile
```

Selecciona el perfil expandido y aplica con:

```bash
openspec update
```

> Los cambios de config no llegan a los proyectos hasta que ejecutas `openspec update`.

## 7.2 Editar un change en marcha

Los artefactos son Markdown plano y **los archivos son el plan**. Puedes revisar cualquiera en
cualquier momento:

- **Edita el archivo tú mismo.**
- **Dile a tu agente qué está mal** y que revise los artefactos.

Flujos comunes:
- **Plan resultó mal durante apply** → arregla los artefactos, luego continúa aplicando.
- **Interrumpido / sin contexto** → abre sesión nueva y pide aplicar de nuevo; reanuda en la
  primera tarea sin marcar.
- **El progreso vive en los checkboxes de `tasks.md`.** No hay estado oculto.

## 7.3 Adoptar OpenSpec en un proyecto existente (brownfield)

OpenSpec está construido para brownfield. Los **delta specs** significan que puedes especificar
un cambio en una app de 50,000 líneas **sin documentar primero todo el sistema**.

Estrategia de adopción:
1. `openspec init` en el repo existente (no toca tu código).
2. Empieza con un cambio pequeño y de bajo riesgo para aprender el flujo.
3. Deja que `specs/` crezca orgánicamente: cada archive fusiona los deltas y documenta el sistema
   poco a poco.
4. Usa `/opsx:explore` para que el agente lea el codebase y te ayude a entender qué hay antes
   de proponer.

## 7.4 Personalización

- **`openspec config profile`** — cambia delivery (both/skills/commands) y el conjunto de workflows.
- **`openspec schema`** (experimental) — inspecciona, bifurca o crea un schema de workflow.
- **`openspec schemas`** — lista los schemas disponibles.
- **Bundles de schema de terceros** — repos independientes que integran OpenSpec con otras
  herramientas (similar al catálogo de extensiones de github/spec-kit). Ver
  [customization docs](https://github.com/Fission-AI/OpenSpec/blob/main/docs/customization.md).

## 7.5 Multi-lenguaje

OpenSpec soporta **multi-lenguaje** — puedes escribir specs y artefactos en varios idiomas.
Ver [multi-language docs](https://github.com/Fission-AI/OpenSpec/blob/main/docs/multi-language.md).

## 7.6 Modelos y contexto

- **Modelos:** OpenSpec funciona mejor con modelos de alto razonamiento. Se recomiendan
  Codex 5.5 y Opus 4.7 tanto para planificar como para implementar.
- **Higiene de contexto:** OpenSpec se beneficia de una ventana de contexto limpia. Limpia tu
  contexto antes de empezar la implementación y mantén buena higiene durante la sesión.

## 7.7 Telemetría

OpenSpec recoge estadísticas de uso anónimas: **solo nombres de comandos y versión**. Sin
argumentos, rutas, contenido ni PII. Se desactiva automáticamente en CI.

Para optar fuera (cualquiera basta):
```bash
openspec config set telemetry.enabled false
# o
export OPENSPEC_TELEMETRY=0
# o
export DO_NOT_TRACK=1
```

---

## ✅ Checkpoint del módulo 7

1. ¿Qué dos workflows opcionales no se instalan por defecto?
2. ¿Cómo se activa el perfil expandido de workflows?
3. ¿Por qué OpenSpec es bueno para brownfield?
4. ¿Qué modelos se recomiendan para OpenSpec?
5. ¿Qué datos recoge la telemetría y cómo se desactiva?

**Siguiente:** [Módulo 8 — Stores](08-stores.md)
