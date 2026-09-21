# Módulo 8 — Stores: planificación multi-repo (beta)

> **Objetivo:** entender cuándo y cómo usar Stores para equipos y features que cruzan varios
> repos.

---

## 8.1 El problema en equipo

En solitario, OpenSpec mantiene a tu IA honesta en un solo repo. En un equipo, la parte difícil
cambia: una feature abarca el servidor de API, la web app y una librería compartida; los
requisitos los posee un equipo y los consumen otros; la planificación empieza antes de que
exista cualquier código.

## 8.2 La solución: Stores

**Stores** son la respuesta: planificar en un **repo propio**. La misma forma `openspec/` que ya
conoces (specs y changes), compartida por `git push` como cualquier otra cosa. **Una fuente de
verdad** que todo tu equipo y cada agente de codificación pueden leer, a través de cada repo.

### Beneficios

- **Features cross-repo** — un change, un plan, aunque el código aterrice en tres repos.
- **Requisitos compartidos** — un equipo de plataforma es dueño de las specs; los equipos de
  producto las referencian de solo lectura, justo donde su agente de codificación puede leerlas.
  Sin wiki a la deriva.
- **Plan antes que código** — captura el plan en el store ahora; los repos de código se ponen
  al día después.

## 8.3 Cuándo vale la pena

- Multi-repo (varios repos que usan la misma planificación).
- Mantener la planificación **fuera** del repo por completo.
- Equipos donde los requisitos son propiedad de un equipo y consumidos por otros.

Para un solo repo, la configuración por defecto (specs y changes junto al código) es suficiente.

## 8.4 Cómo funciona

- **`openspec store`** — crea y gestiona stores: repos OpenSpec independientes registrados en
  tu máquina.
- **`openspec doctor`** — reporta la salud de relaciones para la raíz OpenSpec resuelta.
- **`openspec context`** — imprime el contexto de trabajo para la raíz resuelta.
- **`openspec workset`** — compone, mantiene y abre vistas de trabajo personales.

Los comandos de changes/specs aceptan `--store <id>` para usar un store registrado como raíz
en vez del proyecto actual.

> ⚠️ **Stores están en beta.** Empieza con la
> [Stores User Guide](https://github.com/Fission-AI/OpenSpec/blob/main/docs/stores-beta/user-guide.md).

---

## ✅ Checkpoint del módulo 8

1. ¿Qué problema resuelven los Stores?
2. ¿Qué es un store y cómo se comparte?
3. Nombra tres beneficios de los Stores.
4. ¿Cuándo NO necesitas un store?
5. ¿Qué comando crea y gestiona stores?

**Siguiente:** [Módulo 9 — Buenas Prácticas](09-buenas-practicas.md)
