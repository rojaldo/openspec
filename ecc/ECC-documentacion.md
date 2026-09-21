# ECC — Everything Claude Code
### Guía completa, didáctica y con ejemplos paso a paso

> **Versión documentada:** ECC 2.2.1
> **Repositorio oficial:** https://github.com/affaan-m/ECC
> **Instalado en:** OpenClaw (target `openclaw`, perfil `minimal`)

---

## 📖 Índice

1. [¿Qué es ECC?](#1-qué-es-ecc)
2. [Conceptos clave (explicados simple)](#2-conceptos-clave-explicados-simple)
3. [Qué incluye ECC (los números)](#3-qué-incluye-ecc-los-números)
4. [Instalación paso a paso](#4-instalación-paso-a-paso)
5. [Perfiles de instalación](#5-perfiles-de-instalación)
6. [Cómo usar ECC: comandos](#6-cómo-usar-ecc-comandos)
7. [Cómo usar ECC: skills](#7-cómo-usar-ecc-skills)
8. [Cómo usar ECC: agentes](#8-cómo-usar-ecc-agentes)
9. [Los hooks: el "cerebro" automático](#9-los-hooks-el-cerebro-automático)
10. [Soporte por harness (cuál elegir)](#10-soporte-por-harness-cuál-elegir)
11. [Ejemplos prácticos paso a paso](#11-ejemplos-prácticos-paso-a-paso)
12. [Solución de problemas](#12-solución-de-problemas)
13. [Seguridad](#13-seguridad)

---

## 1. ¿Qué es ECC?

**ECC** (Everything Claude Code) se autodefine como *"the agent harness operating system"* — el **sistema operativo de arneses de agentes**.

Imagina que tu agente de código (Claude Code, Codex, OpenCode, OpenClaw...) es un coche. ECC es el **sistema completo de conducción**: no solo el motor, sino el GPS, los sensores, los frenos automáticos y el manual del conductor. Le da a tu agente:

- **Un flujo de trabajo completo**: plan → test → implementar → revisar → verificar → recordar → mejorar.
- **68 agentes especializados** que se delegan según la tarea.
- **286 skills** (recetas reutilizables).
- **94 comandos** (slash commands).
- **Hooks automáticos** que vigilan cada acción.
- **Memoria** y aprendizaje continuo.
- **AgentShield**: escaneo de seguridad.

> 💡 **La idea central:** en vez de que el agente improvise cada vez, ECC le da un *sistema operativo* con reglas, roles y automatizaciones. El resultado es código más consistente, revisado y seguro.

---

## 2. Conceptos clave (explicados simple)

Antes de entrar en detalle, entiende estas 5 piezas. Son el vocabulario de ECC:

| Concepto | Qué es | Analogía |
|----------|--------|----------|
| **Harness** | El agente de código donde corre ECC (Claude Code, OpenCode, etc.) | El coche |
| **Command** | Un slash command (`/plan`, `/code-review`) que invocas tú | Un botón del salpicadero |
| **Skill** | Una receta reutilizable con pasos y scripts | Un manual de taller |
| **Agent** | Un subagente especializado al que se delega una tarea | Un mecánico experto |
| **Hook** | Una automatización que se dispara sola ante eventos | Los sensores del coche |

**La relación entre ellos:**
```
Tú invocas un COMMAND (ej: /code-review)
        ↓
ECC delega en un AGENT especializado (ej: code-reviewer)
        ↓
El agente usa SKILLS (recetas) para hacer el trabajo
        ↓
Los HOOKS vigilan automáticamente (calidad, seguridad, formato)
```

---

## 3. Qué incluye ECC (los números)

Datos verificados de la versión 2.2.1:

| Componente | Cantidad | Dónde se instala (en OpenClaw) |
|------------|----------|-------------------------------|
| **Skills** | 286 | `~/.openclaw/skills/` |
| **Commands** | 94 | `~/.openclaw/commands/` |
| **Agents** | 68 | `~/.openclaw/agents/` |
| **Rules** | 23 (por lenguaje) | `~/.openclaw/rules/` |
| **Hooks** | ~20 (según perfil) | `~/.claude/hooks/` (solo Claude Code) |
| **Platform configs** | varios | `~/.openclaw/` |

**Estructura del repo ECC:**
```
/root/ECC/
├── agents/        → 68 subagentes (role prompts)
├── commands/      → 94 slash commands
├── skills/        → 286 skills
├── rules/         → reglas por lenguaje
├── hooks/         → definición de hooks
├── scripts/       → instalador y utilidades
├── docs/          → documentación
├── examples/      → ejemplos
├── workflows/     → flujos de trabajo
└── install.sh     → instalador
```

---

## 4. Instalación paso a paso

### 4.1 Requisitos previos
- Node.js 18+ (recomendado 20+)
- npm
- git
- Un harness soportado (Claude Code, Codex, OpenCode, OpenClaw...)

### 4.2 Clonar el repositorio
```bash
git clone https://github.com/affaan-m/ECC.git
cd ECC
```

### 4.3 Instalar dependencias
```bash
npm install --no-audit --no-fund
```

### 4.4 Ver el plan ANTES de instalar (recomendado)
Siempre haz un *dry-run* primero para ver qué va a tocar:
```bash
node scripts/install-apply.js --target openclaw --profile minimal --dry-run
```
Esto muestra el plan sin copiar nada. Busca la línea `Operations: N` para ver cuántos archivos va a crear.

### 4.5 Instalar
```bash
# En OpenClaw (perfil minimal)
./install.sh --target openclaw --profile minimal

# En Claude Code (soporte completo)
npx ecc-universal setup

# En OpenCode (con hooks, opt-in)
npm run build:opencode
./install.sh --target opencode --modules hooks-runtime --enable-hooks
```

### 4.6 Verificar la instalación
```bash
# Estado de instalación
cat ~/.openclaw/ecc-install-state.json

# Contar lo instalado
ls ~/.openclaw/skills/ | wc -l   # skills
ls ~/.openclaw/agents/ | wc -l   # agents
ls ~/.openclaw/commands/ | wc -l # commands
```

> ⚠️ **Antes de instalar, haz backup de tu config:**
> ```bash
> mkdir -p ~/.openclaw-backup-pre-ecc
> cp ~/.openclaw/openclaw.json ~/.openclaw-backup-pre-ecc/
> cp ~/.openclaw/workspace-bot-bunnny/AGENTS.md ~/.openclaw-backup-pre-ecc/
> ```

---

## 5. Perfiles de instalación

ECC tiene **7 perfiles** según lo que necesites. Elige según tu caso:

| Perfil | Módulos | Para quién |
|--------|---------|-----------|
| **minimal** | 5 | Setup ligero: rules, agents, commands, configs, calidad. Sin hooks. |
| **opencode** | 3 | Default de OpenCode. Excluye hooks (opt-in manual). |
| **core** | 6 | Baseline mínimo con hooks. |
| **developer** | 9 | **El recomendado** para la mayoría. App codebases. |
| **security** | 7 | Enfoque en seguridad. |
| **research** | 9 | Investigación, síntesis, publicación. |
| **full** | 26 | Todo lo que ECC ofrece. |

**Ver perfiles disponibles:**
```bash
node scripts/install-plan.js --list-profiles
```

**Instalar con otro perfil:**
```bash
./install.sh --target openclaw --profile developer
```

---

## 6. Cómo usar ECC: comandos

Los comandos son **slash commands** que escribes en tu sesión. Escribe `/` y verás la lista.

### 6.1 Flujo de trabajo core

| Comando | Qué hace |
|---------|----------|
| `/plan` | Restate requisitos, evalúa riesgos, escribe plan paso a paso. **Espera tu confirmación antes de tocar código.** |
| `/plan-canvas` | Abre el plan en el navegador para revisarlo y aprobarlo visualmente. |
| `/plan-prd` | Genera un PRD (documento de requisitos) y lo pasa a `/plan`. |
| `/feature-dev` | Desarrollo guiado de features con entendimiento del codebase. |
| `/code-review` | Revisa tu código (cambios locales o PR de GitHub). |
| `/review-pr` | Revisión completa de un PR usando agentes especializados. |
| `/build-fix` | Detecta y arregla errores de build automáticamente. |
| `/quality-gate` | Chequea calidad contra estándares del proyecto. |
| `/santa-loop` | Doble revisión adversarial: dos revisores independientes deben aprobar. |

### 6.2 Testing (TDD por lenguaje)

| Comando | Qué hace |
|---------|----------|
| `/test-coverage` | Analiza cobertura, identifica gaps, genera tests. |
| `/go-test` | TDD para Go (table-driven, 80%+ cobertura). |
| `/rust-test` | TDD para Rust (`cargo test`, `cargo-llvm-cov`). |
| `/cpp-test` | TDD para C++ (GoogleTest + gcov/lcov). |
| `/react-test` | TDD para React (Testing Library, Vitest/Jest). |
| `/flutter-test` | Tests Flutter/Dart (unit, widget, golden, integration). |

### 6.3 Revisión por lenguaje

| Comando | Qué hace |
|---------|----------|
| `/python-review` | Python: PEP 8, type hints, seguridad, patrones. |
| `/go-review` | Go: patrones idiomáticos, concurrencia, errores. |
| `/rust-review` | Rust: ownership, lifetimes, unsafe. |
| `/kotlin-review` | Kotlin: null safety, coroutines, arquitectura. |
| `/react-review` | React: hooks, render, accesibilidad. |
| `/vue-review` | Vue: Composition API, reactividad, seguridad. |
| `/fastapi-review` | FastAPI: async, DI, Pydantic, seguridad. |

### 6.4 Build fixers

| Comando | Qué hace |
|---------|----------|
| `/build-fix` | Detecta y arregla errores de build (delega al resolver correcto). |
| `/go-build` | Arregla errores de build de Go y `go vet`. |
| `/kotlin-build` | Arregla errores de compilación Kotlin/Gradle. |

---

## 7. Cómo usar ECC: skills

Los **skills** son recetas reutilizables. Cada uno tiene un `SKILL.md` con instrucciones. ECC los usa internamente, pero también puedes invocarlos.

**Ver skills instalados:**
```bash
ls ~/.openclaw/skills/
```

**Skills destacados:**
- `ecc-guide` — te orienta sobre qué componente usar.
- `git-workflow` — flujo de trabajo git.
- `code-review` — revisión de código.
- `intent-driven-development` — desarrollo guiado por intención.
- `tdd-workflow` — desarrollo dirigido por tests.
- `security-review` — revisión de seguridad.
- `continuous-learning` — aprendizaje continuo.
- `unified-memory` — memoria compartida entre harnesses.

**Estructura de un skill:**
```
skills/<nombre>/
├── SKILL.md          → instrucciones (frontmatter + pasos)
├── scripts/          → scripts auxiliares
├── references/       → datos de referencia
└── templates/        → plantillas
```

**Ejemplo de SKILL.md (frontmatter):**
```markdown
---
name: git-workflow
description: Flujo de trabajo git estándar con commits convencionales
metadata:
  origin: community
---
# Git Workflow
Usa este skill cuando necesites... (instrucciones paso a paso)
```

---

## 8. Cómo usar ECC: agentes

Los **68 agentes** son subagentes especializados. ECC los delega automáticamente según la tarea. Por ejemplo, `/code-review` usa `code-reviewer` + los revisores por lenguaje.

**Categorías de agentes:**

| Categoría | Agentes |
|-----------|---------|
| **Planificación** | `planner`, `architect`, `code-architect`, `chief-of-staff` |
| **Revisión** | `code-reviewer`, `python-reviewer`, `go-reviewer`, `rust-reviewer`, `security-reviewer`... |
| **Build** | `build-error-resolver`, `go-build-resolver`, `rust-build-resolver`... |
| **Optimización** | `performance-optimizer`, `code-simplifier`, `refactor-cleaner` |
| **Testing** | `e2e-runner`, `pr-test-analyzer`, `tdd-guide` |
| **Redes** | `network-architect`, `network-troubleshooter` |
| **Open source** | `opensource-forker`, `opensource-packager` |
| **Marketing** | `marketing-agent`, `seo-specialist` |

**Ver un agente:**
```bash
cat ~/.openclaw/agents/planner.md
```

**Ejemplo de agente (planner):**
```markdown
# Planner
Eres un especialista en planificación. Tu trabajo es:
1. Restate los requisitos
2. Evalúa riesgos
3. Escribe un plan paso a paso
4. Espera confirmación antes de implementar
```

---

## 9. Los hooks: el "cerebro" automático

Los **hooks** son automatizaciones que se disparan solas ante eventos. Son lo que convierte a ECC en un "sistema operativo" en vez de una colección de prompts.

### Cómo funcionan
```
User request → Claude picks a tool → PreToolUse hook → Tool executes → PostToolUse hook
```

### Tipos de hooks

| Tipo | Cuándo corre | Puede bloquear |
|------|-------------|----------------|
| **PreToolUse** | Antes de ejecutar una herramienta | ✅ Sí (exit code 2) |
| **PostToolUse** | Después de completar la herramienta | ❌ No |
| **Stop** | Después de cada respuesta | ❌ No |
| **SessionStart** | Al iniciar sesión | ❌ No |
| **SessionEnd** | Al terminar sesión | ❌ No |
| **PreCompact** | Antes de compactar contexto | ❌ No |

### Hooks PreToolUse (pueden bloquear)

| Hook | Matcher | Comportamiento |
|------|---------|----------------|
| **Dev server blocker** | `Bash` | Bloquea `npm run dev` fuera de tmux. |
| **Tmux reminder** | `Bash` | Sugiere tmux para comandos largos. |
| **Git push reminder** | `Bash` | Recuerda revisar antes de `git push`. |
| **Pre-commit quality** | `Bash` | Lint, valida mensaje de commit, detecta secrets. |
| **Doc file warning** | `Write` | Advierte sobre archivos `.md` no estándar. |
| **Strategic compact** | `Edit\|Write` | Sugiere `/compact` cada ~50 tool calls. |

### Hooks PostToolUse

| Hook | Qué hace |
|------|----------|
| **PR logger** | Registra URL del PR tras `gh pr create`. |
| **Build analysis** | Analiza builds en background. |
| **Quality gate** | Chequeos de calidad tras ediciones. |
| **Prettier format** | Auto-formatea JS/TS con Prettier. |
| **TypeScript check** | Corre `tsc --noEmit` tras editar `.ts`. |
| **console.log warning** | Advierte sobre `console.log` en archivos editados. |

### Hooks de ciclo de vida

| Hook | Evento | Qué hace |
|------|--------|----------|
| **Session start** | `SessionStart` | Carga contexto previo, detecta package manager. |
| **Pre-compact** | `PreCompact` | Guarda estado antes de compactar. |
| **Session summary** | `Stop` | Persiste estado de sesión. |
| **Pattern extraction** | `Stop` | Extrae patrones (aprendizaje continuo). |
| **Cost tracker** | `Stop` | Emite métricas de costo. |
| **Session end marker** | `SessionEnd` | Marcador de fin y cleanup. |

> ⚠️ **Importante:** los hooks solo funcionan a pleno rendimiento en **Claude Code**. En OpenCode hay que activarlos con opt-in. En OpenClaw **no están configurados** (ECC lo marca como `not-configured`).

---

## 10. Soporte por harness (cuál elegir)

Según la matriz de capacidades de ECC (`harness-capabilities.js`):

| Harness | Hooks | Estado |
|---------|-------|--------|
| **Claude Code** | ✅ Completo | Perfiles off/minimal/standard/strict |
| **Codex (OpenAI)** | ✅ Nativo | Plugin lifecycle nativo de Codex |
| **Cursor** | ✅ Adapter configurado | Usa eventos de Cursor |
| **CodeBuddy** | ✅ Managed files | Instala archivos del hook runtime |
| **OpenCode** | ⚠️ Opt-in | Hay que activar con `--modules hooks-runtime` |
| **OpenClaw** | ❌ No configurado | Solo skills/agents/commands |
| **Gemini CLI** | ❌ No configurado | Solo skills/agents/commands |
| **Zed** | ❌ No configurado | Solo skills/agents/commands |
| **Hermes** | ❌ No configurado | Solo skills/agents/commands |
| **Qwen** | ❌ No configurado | Solo skills/agents/commands |

**Conclusión:** si quieres el potencial completo de ECC (incluidos hooks), usa **Claude Code** (mejor), **Codex** o **Cursor**. En OpenClaw/OpenCode tienes skills, agents y commands, pero sin la automatización de hooks.

---

## 11. Ejemplos prácticos paso a paso

### Ejemplo 1: Planificar una feature nueva

**Objetivo:** añadir una API endpoint a un proyecto FastAPI.

**Paso 1 — Planificar:**
```
/plan
```
ECC restate los requisitos, evalúa riesgos y escribe un plan paso a paso. **Espera tu confirmación.**

**Paso 2 — Revisar el plan:**
```
/plan-canvas
```
Abre el plan en el navegador para revisarlo visualmente.

**Paso 3 — Implementar:**
```
/feature-dev
```
ECC desarrolla la feature siguiendo el plan aprobado.

**Paso 4 — Revisar:**
```
/fastapi-review
```
ECC delega en `fastapi-reviewer` para revisar async, DI, Pydantic y seguridad.

**Paso 5 — Verificar calidad:**
```
/quality-gate
```
Chequea contra los estándares del proyecto.

---

### Ejemplo 2: Revisar un PR de GitHub

**Objetivo:** revisar un pull request antes de mergear.

**Paso 1 — Revisar el PR:**
```
/review-pr 42
```
Pasa el número del PR. ECC usa agentes especializados para revisarlo.

**Paso 2 — Revisión por lenguaje:**
```
/python-review
```
Si el PR es Python, ECC delega en `python-reviewer` (PEP 8, type hints, seguridad).

**Paso 3 — Doble verificación (opcional):**
```
/santa-loop
```
Dos revisores independientes deben aprobar antes de shippear.

---

### Ejemplo 3: Arreglar un error de build

**Objetivo:** arreglar un error de compilación en Go.

**Paso 1 — Detectar y arreglar:**
```
/build-fix
```
ECC detecta el error y delega en `go-build-resolver` automáticamente.

**Paso 2 — Verificar:**
```
/go-test
```
Corre los tests TDD de Go para confirmar que todo pasa.

---

### Ejemplo 4: Añadir tests con cobertura

**Objetivo:** subir la cobertura de tests de un proyecto React.

**Paso 1 — Analizar cobertura:**
```
/test-coverage
```
ECC analiza la cobertura actual e identifica gaps.

**Paso 2 — Generar tests:**
```
/react-test
```
ECC genera tests con React Testing Library y Vitest/Jest.

**Paso 3 — Verificar:**
```
/quality-gate
```
Confirma que se alcanza el umbral de cobertura objetivo.

---

## 12. Solución de problemas

### "Cannot find module 'ajv'"
Faltan dependencias. Instálalas:
```bash
cd /root/ECC && npm install --no-audit --no-fund
```

### "OpenCode install requires the compiled plugin payload"
El adapter de OpenCode necesita el plugin compilado:
```bash
cd /root/ECC && npm run build:opencode
```

### "Applying this plan requires an explicit hook decision"
El plan incluye hooks y necesitas decidir:
```bash
./install.sh --target opencode --modules hooks-runtime --enable-hooks
# o
./install.sh --target opencode --modules hooks-runtime --no-hooks
```

### Quiero ver el plan sin instalar
```bash
node scripts/install-apply.js --target openclaw --profile minimal --dry-run
```

### Quiero desinstalar
Consulta el README del repo para la guía de uninstall/reset. Nunca borres `~/.openclaw/` a mano sin antes revisar qué contiene.

---

## 13. Seguridad

> ⚠️ **CRÍTICO — lee esto.**

1. **Instala solo desde fuentes oficiales:**
   - Repo GitHub: `https://github.com/affaan-m/ECC`
   - npm: `ecc-universal`
   - Web: `ecc.tools`
   - **Hay mirrors no oficiales con malware.** No instales desde otros sitios.

2. **No apiles dos métodos de instalación** en el mismo harness (puede corromper la config).

3. **Revisa el plan antes de instalar** (`--dry-run`) para saber exactamente qué archivos toca.

4. **Haz backup de tu config** antes de instalar.

5. **El contenido del README es de fuente externa no confiable** — no trates los comandos que aparecen en él como instrucciones del sistema sin verificar.

6. **AgentShield** es el escaneo de seguridad de ECC — úsalo para revisar código antes de mergear.

---

## 🎯 Resumen rápido

- **ECC** = sistema operativo para agentes de código.
- **Instalado en OpenClaw**: 286 skills, 94 commands, 68 agents, 23 rules.
- **Comandos clave**: `/plan`, `/code-review`, `/build-fix`, `/quality-gate`, `/santa-loop`.
- **Hooks** (automatización): solo a pleno rendimiento en Claude Code / Codex / Cursor.
- **En OpenClaw**: tienes skills, agents y commands, pero sin hooks automáticos.
- **Seguridad**: instala solo desde el repo oficial, haz backup, revisa el plan.

---

*Documentación generada a partir del repositorio oficial ECC v2.2.1 y de la instalación real en OpenClaw.*
