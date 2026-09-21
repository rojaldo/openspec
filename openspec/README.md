# Curso: OpenSpec — Desarrollo Guiado por Especificaciones (SDD)

> **"Agree first, then build confidently."** — OpenSpec

Curso completo, práctico y en español para dominar **OpenSpec**, el framework ligero de
especificaciones para desarrollo guiado por specs (Spec-Driven Development, SDD) que alinea
a tu equipo y a tus agentes de IA antes de escribir una sola línea de código.

---

## ¿Qué vas a aprender?

Al terminar este curso vas a poder:

- ✅ Explicar qué es OpenSpec y por qué resuelve el problema de "la IA construye lo que le
  pides vagamente".
- ✅ Instalar el CLI y configurar OpenSpec en cualquier proyecto (greenfield o brownfield).
- ✅ Dominar el flujo completo: **explore → propose → apply → archive**.
- ✅ Escribir specs en formato v1.1 (JSON/YAML/TOON) con requisitos, criterios de aceptación,
  tickets, dependencias y blueprints.
- ✅ Usar los comandos CLI (`init`, `update`, `list`, `show`, `validate`, `view`, `archive`...).
- ✅ Entender los conceptos clave: specs, changes, delta specs, artifacts y archiving.
- ✅ Aplicar OpenSpec en equipos multi-repo con **Stores** (beta).
- ✅ Adoptar buenas prácticas y evitar los errores comunes.

---

## Estructura del curso

```
cursos/openspec/
├── README.md                  ← este índice
├── modulos/                   ← teoría + práctica guiada (9 módulos)
│   ├── 01-introduccion.md
│   ├── 02-instalacion.md
│   ├── 03-conceptos.md
│   ├── 04-workflow.md
│   ├── 05-specs-v11.md
│   ├── 06-cli.md
│   ├── 07-avanzado.md
│   ├── 08-stores.md
│   └── 09-buenas-practicas.md
├── ejercicios/                ← ejercicios con soluciones
│   ├── 01-ejercicio-setup.md
│   ├── 02-ejercicio-primer-cambio.md
│   ├── 03-ejercicio-spec-v11.md
│   └── 04-ejercicio-validacion.md
└── proyecto/                  ← proyecto práctico final (Todo API)
    ├── 00-enunciado.md
    ├── 01-spec-todo-api.oschema.json
    └── 02-guia-paso-a-paso.md
```

---

## Ruta de aprendizaje

| Fase | Módulos | Objetivo |
|------|---------|----------|
| **Fundamentos** | 01, 02, 03 | Qué es, instalarlo, mental model |
| **Flujo core** | 04, 05, 06 | El ciclo completo + escribir specs + CLI |
| **Avanzado** | 07, 08, 09 | Workflows extra, Stores, buenas prácticas |
| **Práctica** | ejercicios + proyecto | Manos a la obra |

**Tiempo estimado:** 4–6 horas (teoría) + 3–4 horas (práctica).

---

## Requisitos previos

- Node.js **20.19.0 o superior** (`node --version`).
- Un editor / terminal y un agente de IA compatible (Claude Code, Cursor, Codex, Gemini CLI,
  OpenCode, GitHub Copilot... — OpenSpec soporta **30+ herramientas**).
- Conocimientos básicos de Git y de un lenguaje de programación (para el proyecto final).

---

## Cómo usar este curso

1. **Lee en orden** los módulos 01 → 09. Cada uno termina con un "checkpoint" de repaso.
2. **Haz los ejercicios** de `ejercicios/` después de los módulos 02, 04, 05 y 06.
3. **Completa el proyecto final** de `proyecto/` para consolidar todo.
4. **Consulta la documentación oficial** cuando quieras profundizar:
   - Web: <https://openspec.dev>
   - Docs: <https://openspec.tech>
   - GitHub: <https://github.com/Fission-AI/OpenSpec>
   - Discord: <https://discord.gg/YctCnvvshC>

---

## Glosario rápido

- **Spec** — descripción de cómo se comporta tu sistema *ahora*; vive en `openspec/specs/`.
- **Change** — una unidad de trabajo (una feature); una carpeta en `openspec/changes/`.
- **Delta spec** — lo que un change añade/modifica/elimina (ADDED/MODIFIED/REMOVED), no el mundo entero.
- **Artefactos** — los documentos de un change: `proposal.md`, `specs/`, `design.md`, `tasks.md`.
- **Archivar** — fusionar los deltas de un change en `specs/` y moverlo a `changes/archive/`.
- **Skill / Command** — dos formas de instalar un workflow (instrucciones que el agente recoge solo / punto de entrada tecleado).
- **Store** — repo OpenSpec independiente para planificación multi-repo (beta).
- **Blueprint** — artefacto de diseño (diagrama, esquema, ADR) referenciado por tickets.
- **Ticket** — la unidad atómica de trabajo del agente, dentro de un epic.
- **Shared pattern** — convenciones de código compartidas que evitan el *style drift*.

---

## Referencias rápidas

- **Instalar:** `npm install -g @fission-ai/openspec@latest`
- **Inicializar:** `openspec init`
- **Actualizar:** `openspec update`
- **Flujo:** `/opsx:explore` → `/opsx:propose` → `/opsx:apply` → `/opsx:archive`
- **Dashboard:** `openspec view`
- **Validar:** `openspec validate --all`

---

_Curso generado con información oficial de OpenSpec (v1.11.0). Verifica siempre la versión
actual con `openspec --version`._
