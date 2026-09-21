# Spec Kit — Guía Completa: Spec-Driven Development con cualquier agente de IA

> **Spec-Driven Development (SDD) — define qué construir antes de construirlo, con cualquier agente de IA.**
>
> **ÚLTIMA ACTUALIZACIÓN:** Septiembre 4, 2026
> **Alcance:** GitHub Spec Kit (`github/spec-kit`), verificado contra el README oficial, la documentación de github.github.io/spec-kit y el catálogo de extensiones de la comunidad.

Spec Kit es un toolkit open-source de GitHub para construir software de alta calidad con **cualquier agente de IA**. Es un proceso de desarrollo guiado por especificaciones (Spec-Driven Development) listo para usar — o trae el tuyo propio —, infinitamente extensible, impulsado por la comunidad y pensado para toda tu organización. La idea central: **las especificaciones se vuelven ejecutables**, generando implementaciones funcionales directamente en lugar de solo guiarlas.

---

## Tabla de contenidos

- [TL;DR — Spec Kit en una tabla](#tldr--spec-kit-en-una-tabla)
- [¿Qué es Spec-Driven Development?](#qué-es-spec-driven-development)
- [¿Qué es Spec Kit?](#qué-es-spec-kit)
- [Componentes principales](#componentes-principales)
- [Instalación](#instalación)
- [Integraciones con agentes de IA](#integraciones-con-agentes-de-ia)
- [Comandos core (flujo SDD)](#comandos-core-flujo-sdd)
- [Comandos opcionales](#comandos-opcionales)
- [Extensiones: utilidad y popularidad](#extensiones-utilidad-y-popularidad)
- [Presets y Bundles](#presets-y-bundles)
- [Ejemplos prácticos de uso](#ejemplos-prácticos-de-uso)
- [Flujo de trabajo completo (Taskify)](#flujo-de-trabajo-completo-taskify)
- [Corregir bugs con Spec Kit](#corregir-bugs-con-spec-kit)
- [Evaluar ideas con Spec Kit](#evaluar-ideas-con-spec-kit)
- [Filosofía central](#filosofía-central)
- [Comunidad y soporte](#comunidad-y-soporte)
- [Licencia](#licencia)
- [Fuentes](#fuentes)

---

## TL;DR — Spec Kit en una tabla

| Aspecto | Detalle |
|---|---|
| **Qué es** | Toolkit open-source de GitHub para desarrollo guiado por especificaciones (SDD) con cualquier agente de IA |
| **Filosofía** | Las especificaciones se vuelven **ejecutables**: generan implementaciones, no solo las guían |
| **Flujo core** | Constitution → Specify → Plan → Tasks → Implement → Converge |
| **Popularidad** | ~133,000+ ⭐ en GitHub (repo `github/spec-kit`), alcanzó v1.0.0 en su primer aniversario |
| **Integraciones** | 38+ agentes de IA (Copilot, Gemini, Codex, Claude, Cursor, Kilo Code, Zed, Forge, Kiro...) |
| **Extensiones** | 157+ extensiones de la comunidad (90+ autores), 33 presets |
| **Instalación** | `uv tool install specify-cli` + `specify init` |
| **Comandos** | `/speckit.*` (slash) o `$speckit-*` (skills) según el agente |
| **Licencia** | MIT |
| **Organización** | Funciona offline, detrás de firewalls, en Windows/macOS/Linux |

---

## ¿Qué es Spec-Driven Development?

Spec-Driven Development (SDD) **le da la vuelta al desarrollo de software tradicional**. Durante décadas, el código fue el rey — las especificaciones eran solo andamiaje que construíamos y descartábamos una vez empezaba el "trabajo real" de programar. SDD cambia esto: **las especificaciones se vuelven ejecutables**, generando directamente implementaciones funcionales en lugar de solo guiarlas.

### Principios clave

- **Sé explícito** sobre qué estás construyendo y por qué.
- **No te centres en el stack tecnológico** durante la fase de especificación.
- **Itera y refina** tus especificaciones antes de implementar.
- **Valida requisitos y planes** antes de que empiece el código.
- **Deja que el agente de código** maneje los detalles de implementación.

---

## ¿Qué es Spec Kit?

Spec Kit es la implementación concreta de SDD de GitHub. Es un **harness extensible e impulsado por intención** que empuja a cualquier agente de código más allá del código, guiándolo a través de tu SDLC (ciclo de vida de desarrollo de software) o cualquier proceso de negocio.

- **Spec-driven por defecto:** el proceso core SDD viene listo para usar: Spec → Plan → Tasks → Implement. Cada fase produce un artefacto Markdown que alimenta la siguiente, dando a tu agente de IA contexto estructurado en lugar de prompts ad-hoc.
- **Usa cualquier agente:** 38 integraciones — Copilot, Gemini, Codex, Kilo Code, Zed, Claude, Forge, Kiro y más. Cambia de agente con un solo comando, sin lock-in.
- **Hazlo tuyo:** 157 extensiones de la comunidad (90+ autores), 33 presets y creciendo. Ajusta el proceso core con presets, extiéndelo con extensiones, orquestalo con workflows y empaquétalo como bundles compartibles — o reemplaza el proceso por completo.
- **Integra en tu organización:** funciona offline, detrás de firewalls, y en Windows, macOS y Linux. Hospeda tus propios catálogos para curar qué integraciones, extensiones, presets, workflows y bundles descubre y recomienda tu organización.

> **Hito:** un año después del primer commit, Spec Kit alcanzó **v1.0.0**. El mantenedor principal lo definió así: *"ahora es solo un número"* — a medida que los agentes hacen que adaptarse al cambio sea dramáticamente más barato, el valor se mueve de la estabilidad a la adaptabilidad.

---

## Componentes principales

Spec Kit tiene dos componentes clave:

1. **Specify CLI** — un CLI auxiliar que instala Spec Kit en tu proyecto, lo conecta a tu agente de IA y gestiona extensiones, presets e integraciones.
2. **Comandos `/speckit.*`** — los comandos slash (o skills) que tu agente de IA ejecuta para guiar el proceso SDD.

### Estructura de directorios

```
.specify/
├── templates/            # Spec Kit Core — comandos y plantillas SDD integrados
├── extensions/           # Extensiones — añaden nuevas capacidades
│   └── <ext>/
│       ├── <ext>-config.yml          # Config del proyecto (versionada)
│       ├── <ext>-config.local.yml    # Overrides locales (gitignored)
│       └── <ext>-config.template.yml # Plantilla de referencia
├── presets/templates/    # Presets — personalizan core y extensiones
├── extensions.yml        # Extensiones instaladas + hooks
├── feature.json          # Feature activa (estado, no rama git)
└── extension-catalogs.yml # Catálogos de extensiones
```

### Prioridad de resolución

| Prioridad | Tipo de componente | Ubicación |
|---:|---|---|
| ⬆ 1 | Project-Local Overrides | `.specify/templates/overrides/` |
| 2 | Presets — personalizan core y extensiones | `.specify/presets/templates/` |
| 3 | Extensiones — añaden nuevas capacidades | `.specify/extensions/templates/` |
| ⬇ 4 | Spec Kit Core — comandos y plantillas SDD | `.specify/templates/` |

Las plantillas se resuelven en **tiempo de ejecución** (Spec Kit recorre la pila de arriba a abajo y usa la primera coincidencia). Los comandos de extensiones/presets se aplican en **tiempo de instalación**.

---

## Instalación

### 1. Instalar Specify CLI

Requiere **[uv](https://docs.astral.sh/uv/)**. Reemplaza `vX.Y.Z` con el tag de release más reciente (mantén la `v` inicial, p. ej. `v0.12.11`):

```bash
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git@vX.Y.Z
```

O desde PyPI:

```bash
uv tool install specify-cli
```

### 2. Inicializar un proyecto

```bash
specify init my-project --integration copilot
cd my-project
```

Para CI o harnesses de agentes de IA (sin teclado, o un PTY que no puede enviar flechas), pasa `--non-interactive`:

```bash
specify init my-project --non-interactive --ignore-agent-tools
specify init --here --force --non-interactive --integration claude
```

### 3. Autogestión del CLI

```bash
# Comprobar si hay versión más reciente (solo lectura)
specify self check

# Previsualizar lo que haría una actualización
specify self upgrade --dry-run

# Actualizar a la última versión estable
specify self upgrade

# Fijar un tag específico
specify self upgrade --tag vX.Y.Z
```

---

## Integraciones con agentes de IA

Spec Kit funciona con **38+ agentes de IA** — tanto CLIs como asistentes basados en IDE. Cuando ejecutas `specify init`, el CLI configura los archivos de comandos y estructuras de directorio correctos para tu agente elegido.

### Agentes soportados (selección)

| Agente | Key | Notas |
|---|---|---|
| **GitHub Copilot** | `copilot` | Skills por defecto; `--integration-options="--commands"` para layout de comandos |
| **Claude Code** | `claude` | Skills en `.claude/skills` |
| **Codex CLI** | `codex` | Skills en `.agents/skills`, invoca como `$speckit-*` |
| **Gemini CLI** | `gemini` | |
| **Cursor** | `cursor-agent` | |
| **Kilo Code** | `kilocode` | Comandos en `.kilo/commands` |
| **Zed** | `zed` | Skills en `.agents/skills`, invoca como `/speckit-*` |
| **Forge** | `forge` | |
| **Kiro CLI** | `kiro-cli` | |
| **Cline** | `cline` | Agente basado en IDE |
| **opencode** | `opencode` | |
| **Qwen Code** | `qwen` | |
| **Trae** | `trae` | Skills automáticos |
| **Grok Build** | `grok` | Skills en `.grok/skills` |
| **Hermes** | `hermes` | Skills globales en `~/.hermes/skills/` |
| **Devin for Terminal** | `devin` | Skills en `.devin/skills/` |
| **Docker Agent** | `docker-agent` | Skills en `.agents/skills/` |
| **Factory Droid** | `droid` | Skills en `.factory/skills/` |
| **Firebender** | `firebender` | IDE para Android Studio / IntelliJ |
| **IBM Bob** | `bob` | Skills en `.bob/skills/` |
| **Junie** | `junie` | |
| **Kimi Code** | `kimi` | Skills en `.kimi-code/skills/` |
| **Mistral Vibe** | `vibe` | |
| **Muse Code** | `muse` | Skills en `.agents/skills` |
| **Pi Coding Agent** | `pi` | |
| **Qoder CLI** | `qodercli` | |
| **RovoDev** | `rovodev` | |
| **Tabnine CLI** | `tabnine` | |
| **ZCode** | `zcode` | Skills en `.zcode/skills`, invoca como `$speckit-*` |
| **Generic** | `generic` | Trae tu propio agente con `--commands-dir` |

> **Sin lock-in:** puedes cambiar de agente con un solo comando (`specify integration switch <key>`). Si tu agente no está listado, la integración `generic` es la vía de escape para cualquier herramienta.

### Gestión de integraciones

```bash
# Listar integraciones disponibles
specify integration list

# Buscar integraciones
specify integration search [query]

# Instalar una integración adicional
specify integration install <key>

# Cambiar la integración por defecto
specify integration use <key>   # o: switch <key>

# Desinstalar
specify integration uninstall [<key>]

# Actualizar
specify integration upgrade [<key>]

# Estado de la integración
specify integration status
```

---

## Comandos core (flujo SDD)

Después de `specify init`, tu agente de IA tiene acceso a estos comandos slash. Para integraciones con modo skills, pasa `--integration <agent> --integration-options="--skills"` para instalar skills en lugar de archivos de prompt.

| Comando | Agent Skill | Descripción |
|---|---|---|
| `/speckit.constitution` | `speckit-constitution` | Crear o actualizar los principios rectores y guías de desarrollo del proyecto |
| `/speckit.specify` | `speckit-specify` | Definir qué quieres construir (requisitos e historias de usuario) |
| `/speckit.plan` | `speckit-plan` | Crear planes de implementación técnica con tu stack elegido |
| `/speckit.tasks` | `speckit-tasks` | Generar listas de tareas accionables para la implementación |
| `/speckit.taskstoissues` | `speckit-taskstoissues` | Convertir listas de tareas en issues de GitHub |
| `/speckit.implement` | `speckit-implement` | Ejecutar todas las tareas para construir la feature según el plan |
| `/speckit.converge` | `speckit-converge` | Evaluar el codebase contra spec/plan/tasks y añadir el trabajo restante como nuevas tareas |

### Comandos opcionales

| Comando | Agent Skill | Descripción |
|---|---|---|
| `/speckit.clarify` | `speckit-clarify` | Aclarar áreas poco especificadas (recomendado antes de `/speckit.plan`; antes llamado `/quizme`) |
| `/speckit.analyze` | `speckit-analyze` | Análisis de consistencia y cobertura entre artefactos (tras `/speckit.tasks`, antes de `/speckit.implement`) |
| `/speckit.checklist` | `speckit-checklist` | Generar checklists de calidad personalizados que validan completitud, claridad y consistencia de requisitos ("unit tests para inglés") |

---

## Extensiones: utilidad y popularidad

Las **extensiones** añaden nuevas capacidades a Spec Kit — comandos específicos de dominio, integraciones con herramientas externas, gates de calidad y más. Introducen nuevos comandos y plantillas que van más allá del flujo SDD integrado. **Expanden *lo que Spec Kit puede hacer*.**

> **Popularidad:** hay **157+ extensiones de la comunidad** creadas por **90+ autores**. El ecosistema es joven y las extensiones individuales son proyectos independientes (la mayoría con pocas estrellas en GitHub), pero el repo principal de Spec Kit acumula **~133,000 ⭐**. Las extensiones más destacadas por adopción/actividad incluyen Jira, CI Guard, MAQA, Architecture Guard, adrkit y DocGuard.

### Gestión de extensiones

```bash
# Buscar extensiones disponibles
specify extension search [query]

# Instalar una extensión
specify extension add <name>

# Instalar desde URL o directorio local
specify extension add <name> --from <url>
specify extension add <name> --dev

# Listar extensiones instaladas
specify extension list

# Información detallada
specify extension info <name>

# Actualizar (una o todas)
specify extension update [<name>]

# Habilitar / deshabilitar sin eliminar
specify extension enable <name>
specify extension disable <name>

# Cambiar prioridad de resolución
specify extension set-priority <name> <priority>

# Eliminar
specify extension remove <name>
```

### Extensiones destacadas por utilidad

| Extensión | Categoría | Utilidad |
|---|---|---|
| **Jira Integration** (`spec-kit-jira`) | integración | Crea Epics, Stories e Issues de Jira desde specs y desgloses de tareas, con jerarquía configurable y campos personalizados |
| **Jira Mirror** (`spec-kit-jira-mirror`) | integración | Puente Spec Kit ↔ Jira para proyectos team-managed y company-managed: workflows y jerarquías configurables (Scrum/SAFe), multi-proyecto, idempotente |
| **CI Guard** (`spec-kit-ci-guard`) | proceso | Gates de cumplimiento de specs para CI/CD — verifica que las specs existan, detecta drift y bloquea merges en huecos |
| **Architecture Guard** (`architecture-guard`) | proceso | Gobernanza de arquitectura agnóstica al framework — detecta drift, aplica reglas arquitectónicas y genera tareas de refactor accionables |
| **MAQA** (`spec-kit-maqa-ext`) | proceso | Orquestación multi-agente con gates de calidad: flujo Coordinator → feature → QA con implementación paralela basada en worktrees |
| **adrkit** (`adrkit`) | proceso | Memoria de decisiones para SDD — trae las decisiones que gobiernan el trabajo al contexto del agente y redacta un ADR desde un artefacto de plan |
| **DocGuard** (`spec-kit-docguard`) | docs | Motor de integridad documental con servidor MCP, salida SARIF/JUnit y núcleo determinista sin LLM — 27 validadores, traza docs contra código |
| **BDD** (`spec-kit-bdd`) | proceso | Convierte specs a escenarios Gherkin, genera step definitions y verifica cobertura de tests de aceptación |
| **Azure Cosmos DB** (`spec-kit-cosmosdb`) | código | Generación y revisión de código Cosmos DB con mejores prácticas para cualquier agente de IA |
| **Azure DevOps Integration** (`spec-kit-azure-devops`) | integración | Sincroniza historias de usuario y tareas a work items de Azure DevOps con autenticación OAuth |
| **Linear Sync** (`spec-kit-linear-sync`) | integración | Refleja specs en Linear — un issue por spec, un sub-issue por fase de tarea, sincronizado |
| **Cost Tracker** (`spec-kit-cost`) | visibilidad | Rastrea el costo real en dólares de LLM en flujos SDD — presupuestos por feature, comparación por integración, exportaciones listas para finanzas |
| **Analytics** (`spec-kit-analytics`) | visibilidad | Mide qué construye tu IA y cuánto tiempo te ahorra |
| **Checkpoint** (`spec-kit-checkpoint`) | código | Hace commits durante la implementación para no terminar con un solo commit gigante al final |
| **Cleanup** (`spec-kit-cleanup`) | código | Gate de calidad post-implementación: revisa cambios, arregla issues pequeños (scout rule), crea tareas para los medianos y análisis para los grandes |
| **FixIt** (`spec-kit-fixit`) | código | Arreglo de bugs consciente de specs — mapea bugs a artefactos de spec, propone un plan, aplica cambios mínimos |
| **Figma Starter** (`spec-kit-figma-starter`) | integración | Convierte las pantallas de una sección de Figma en archivos spec.md por pantalla, user-stories.md y build-order.md |
| **Confluence** (`spec-kit-confluence`) | integración | Crea un doc en Confluence resumiendo los archivos de especificación y planificación |
| **MarkItDown** (`spec-kit-markitdown`) | docs | Convierte documentos (PDF, Word, PowerPoint, Excel y más) a Markdown para usarlos como material de referencia |
| **Microsoft 365** (`spec-kit-m365`) | integración | Trae mensajes de Teams, transcripciones de reuniones y archivos de SharePoint/OneDrive como Markdown local |
| **EARS Requirements Syntax** (`spec-kit-ears`) | docs | Autor, lint y convierte requisitos usando EARS — los cinco patrones de oración estándar de la industria para requisitos inequívocos y testables |
| **Data Model Diagram** (`spec-kit-data-model-diagram`) | docs | Genera diagramas ER de Mermaid desde los modelos de datos de Spec Kit tras la planificación |
| **ASCII Diagram Renderer** (`spec-kit-ascii-diagram`) | docs | Renderiza diagramas ASCII/Unicode dibujados a mano (state machine, arquitectura, flujo) — texto plano, sin necesidad de Mermaid |
| **LLM Wiki** (`spec-kit-wiki`) | docs | Wiki de proyecto compuesta por LLM: ingesta de fuentes, respuestas citadas y linting de consistencia |
| **Memory MD** (`spec-kit-memory-hub`) | docs | Memoria Markdown nativa del repositorio que captura decisiones duraderas, bugs y contexto del proyecto |
| **Onboard** (`spec-kit-onboard`) | proceso | Onboarding contextual para desarrolladores nuevos en proyectos spec-kit — explica specs, mapea dependencias, valida comprensión |
| **Improve** (`spec-kit-improve`) | proceso | Audita cualquier codebase como asesor senior y escribe prompts de spec priorizados y autocontenidos |
| **Iterate** (`spec-kit-iterate`) | docs | Itera sobre documentos de spec con un flujo define-and-apply en dos fases — refina specs a mitad de implementación |
| **Multi-Model Review** (`multi-model-review`) | proceso | Handoffs de Spec Kit entre modelos para autoría de specs, enrutamiento de implementación y revisión |
| **Loop Engineering** (`spec-kit-loop`) | proceso | Ingeniería de loops autónomos seguros para SDD: split maker/checker, estado de loop externalizado y guardrails contra deuda de comprensión |
| **Agent Assign** (`spec-kit-agent-assign`) | proceso | Asigna agentes especializados de Claude Code a tareas de spec-kit para ejecución dirigida |
| **Archive** (`spec-kit-archive`) | docs | Archiva features fusionadas en la memoria principal del proyecto, resolviendo huecos y conflictos |
| **Blueprint** (`spec-kit-blueprint`) | docs | Revisa un blueprint de código completo para cada tarea desde artefactos de spec antes de que corra `/speckit.implement` |
| **Brownfield Bootstrap** (`spec-kit-brownfield`) | proceso | Bootstrap de spec-kit para codebases existentes — auto-descubre arquitectura y adopta SDD incrementalmente |
| **Bugfix Workflow** (`spec-kit-bugfix`) | proceso | Flujo de bugfix estructurado — captura bugs, traza a artefactos de spec y parchea specs quirúrgicamente |
| **API Evolve** (`spec-kit-api-evolve`) | proceso | Evolución gestionada de contratos de API — detección de breaking changes, enforcement de semver, orquestación de deprecación y gates de ciclo de vida |
| **Branch Convention** (`spec-kit-branch-convention`) | proceso | Convenciones configurables de ramas y carpetas para `/specify` con presets y patrones personalizados |
| **Charter** (`spec-kit-charter`) | proceso | Compone constituciones de proyecto desde registros de fragmentos compartidos |
| **Intake** (`spec-kit-intake`) | docs | Normaliza PRD, diseño, HTML SSOT y evidencia de casos de test en artefactos de intake listos para SDD |
| **Keel Discovery** (`spec-kit-keel`) | proceso | Descubrimiento respaldado por evidencia antes de `/speckit.specify`, más auditoría de drift tras la implementación |
| **Fleet Orchestrator** (`spec-kit-fleet`) | proceso | Orquesta un ciclo de vida completo de feature con gates human-in-the-loop en todas las fases de SpecKit |
| **Golden Demo** (`spec-kit-golden-demo`) | docs | Oráculo determinista de drift de comportamiento — extrae criterios de aceptación, genera vectores de test fuzz y compara implementaciones golden |
| **Multi-Repo Branch Sync** (`multi-repo-sync`) | proceso | Crea la rama de feature en sub-repositorios y submódulos afectados vía hooks de plan/tasks |
| **ContextForge MCP** (`contextforge-mcp`) | código | Integra codebase-memory-mcp + headroom en Spec Kit — inteligencia de código basada en grafos y compresión de contexto |
| **DUBSAR Memory** (`dubsar-memory`) | visibilidad | Memoria local de proyecto con checkpoints explícitos, reanudación cross-session y frescura SHA-256 |
| **AgentPay x402** (`spec-kit-pay-x402`) | integración | Límites de gasto en USDC y pagos x402 a APIs de pago durante la implementación de specs |
| **AgentDocx** (`extension-github-spec-kit`) | integración | Pipeline de especificación multi-agente full-stack con control de extensión VS Code, sync Kanban/Jira y dashboard de monitoreo React |
| **AIDE** (`aide`) | proceso | Flujo estructurado de 7 pasos para construir proyectos nuevos desde cero con asistentes de IA — de la visión a la implementación |
| **Canon** (`spec-kit-canon`) | proceso | Añade flujos canon-driven (baseline-driven): spec-first, code-first, spec-drift |
| **FX→.NET** (`spec-kit-fx-to-net`) | proceso | Orquesta la migración de .NET Framework a .NET moderno en 7 fases, con integración del ciclo de vida SDD |
| **MDE** (`spec-kit-mde`) | proceso | Flujo mínimo de ingeniería dirigida por modelos con comandos setup, next y status |
| **Multi-Sites** (`spec-kit-multi-sites`) | proceso | Comando specify multi-sitio con carpetas de spec por sitio, auto-incremento y soporte Drupal |
| **Evaluator Contract** (`spec-kit-evaluator`) | proceso | Contrato de evaluador neutral al proveedor para evidencia, procedencia, incertidumbre y recuperación |
| **Extensify** (`extensify`) | proceso | Crea y valida extensiones y catálogos de extensiones |
| **MemoryLint** (`memorylint`) | proceso | Comprobador de drift de instrucciones basado en evidencia — audita archivos de memoria del agente |
| **Multi-Model Review** (`multi-model-review`) | proceso | Handoffs cross-model para autoría de specs, enrutamiento de implementación y revisión |
| **OKF Knowledge Bundle** (`speckit_ofk`) | docs | Genera y mantiene un bundle de conocimiento en Open Knowledge Format (OKF v0.1) desde un repositorio de código |

### Modelo de confianza de catálogos

Los catálogos de extensiones controlan dónde buscan `search` y `add`. Hay dos tipos, y la distinción es una **frontera de seguridad**, no una limitación:

- **Install sources** (`install_allowed: true`) — catálogos que confías como lugar desde el que instalar. El catálogo oficial integrado es uno, como cualquier catálogo que autorices y vetes tú mismo.
- **Discovery-only** (`install_allowed: false`) — superficies de búsqueda para encontrar extensiones, pero no instalables. El catálogo `community` integrado es discovery-only y ya está activo para búsqueda.

> ⚠️ **Seguridad:** `community` es discovery-only a propósito porque es una lista abierta y sin vetar. No lo conviertas en `install_allowed`. Para instalar algo encontrado vía community, instala una extensión vetada directamente con `--from` (revisa el archivo de release antes) o cura tu propio catálogo.

---

## Presets y Bundles

### Presets — personalizar flujos existentes

Usa **presets** cuando quieras cambiar *cómo* funciona Spec Kit sin añadir nuevas capacidades. Los presets sobrescriben las plantillas y comandos que vienen con el core *y* con las extensiones instaladas — por ejemplo, imponer un formato de spec orientado a cumplimiento, usar terminología específica de dominio, o aplicar estándares organizacionales a planes y tareas.

```bash
# Buscar presets disponibles
specify preset search

# Instalar un preset
specify preset add <preset-name>
```

Ejemplos de presets: reestructurar plantillas de spec para requerir trazabilidad regulatoria, adaptar el flujo a tu metodología (Agile, Kanban, Waterfall, jobs-to-be-done, domain-driven design), añadir gates de revisión de seguridad obligatorios a los planes, imponer orden test-first, o localizar todo el flujo a otro idioma.

### Bundles — setups basados en roles

Los **bundles** son stacks de rol y equipo compuestos a partir de componentes existentes (extensiones + presets + workflows). Empaquetan una configuración completa y compartible.

### Procesos completos alternativos

Spec Kit no te ata a SDD — el proceso vive en los building blocks. Incluye procesos completamente distintos:

- **AIDE** — ciclo de vida de ingeniería impulsado por IA en 7 pasos
- **Canon** — flujos baseline-driven (spec-first, code-first, spec-drift)
- **Product Forge** — SDD orientado a gestión de producto
- **FX→.NET** — migración end-to-end de .NET Framework en 7 fases
- **MAQA** — orquestación multi-agente con gates de aseguramiento de calidad
- **Fiction Book Writing** — novelas y ficción larga, del story bible a la entrega

---

## Ejemplos prácticos de uso

### Ejemplo 1: Instalación y primer proyecto

```bash
# Instalar el CLI (requiere uv)
uv tool install specify-cli

# Inicializar un proyecto con GitHub Copilot
specify init my-project --integration copilot
cd my-project
```

Lanza tu agente de código en el directorio del proyecto y ejecuta el flujo:

```bash
# 0. Establecer principios del proyecto (una vez por proyecto)
/speckit.constitution Create principles focused on code quality, testing standards, user experience consistency, and performance requirements

# 1. Especificar qué construir
/speckit.specify Build an application that can help me organize my photos in separate photo albums. Albums are grouped by date and can be re-organized by dragging and dropping on the main page. Albums are never in other nested albums. Within each album, photos are previewed in a tile-like interface.

# 2. Plan técnico
/speckit.plan The application uses Vite with minimal number of libraries. Use vanilla HTML, CSS, and JavaScript as much as possible. Images are not uploaded anywhere and metadata is stored in a local SQLite database.

# 3. Desglosar en tareas
/speckit.tasks

# 4. Implementar
/speckit.implement

# 5. Verificar completitud
/speckit.converge
```

> Repite los pasos 4 y 5 hasta que `/speckit.converge` reporte **Converged**.

### Ejemplo 2: Instalar y usar una extensión (Jira)

```bash
# Buscar extensiones de Jira
specify extension search jira

# Instalar la integración de Jira
specify extension add spec-kit-jira

# Verificar que está instalada
specify extension list
```

### Ejemplo 3: Instalar una extensión desde un catálogo de la comunidad

```bash
# Ver el detalle (muestra la URL del archivo candidato)
specify extension info <name>

# Instalar una extensión vetada directamente desde su archivo de release
specify extension add <name> --from <archive-url>
```

### Ejemplo 4: Cambiar de agente de IA

```bash
# Cambiar de Copilot a Claude Code
specify integration switch claude

# O instalar Claude Code como integración adicional
specify integration install claude
```

### Ejemplo 5: Configurar una extensión

```bash
# Copiar la plantilla de configuración
cp .specify/extensions/<ext>/<ext>-config.template.yml \
   .specify/extensions/<ext>/<ext>-config.yml

# Editar la configuración del proyecto
# (los overrides locales van en <ext>-config.local.yml, gitignored)
```

---

## Flujo de trabajo completo (Taskify)

Este es el ejemplo oficial de Spec Kit: **Taskify**, una pequeña plataforma de productividad de equipo. Muestra el flujo completo con el ejemplo de principio a fin.

### Ruta corta (features pequeñas)

```
/speckit.specify → /speckit.plan → /speckit.tasks → /speckit.implement → /speckit.converge
```

### Ruta completa (features de producción, con gates de calidad)

```
/speckit.constitution → /speckit.specify → /speckit.clarify → /speckit.plan
→ /speckit.checklist → /speckit.tasks → /speckit.analyze → /speckit.implement → /speckit.converge
```

### Paso a paso

**Paso 1 — Constitution (reglas del juego):**

```bash
/speckit.constitution Taskify is a "Security-First" application. All user inputs must be validated. We use a microservices architecture. Code must be fully documented.
```

**Paso 2 — Specify (qué construir):**

```bash
/speckit.specify Develop Taskify, a team productivity platform where predefined users create projects, assign tasks, comment, and move tasks across Kanban columns (To Do, In Progress, In Review, Done). Five users (one product manager, four engineers), three sample projects, no login for this first phase.
```

**Paso 3 — Clarify (resolver ambigüedades):**

```bash
/speckit.clarify Focus on task card behavior — status changes, comment permissions, and user assignment.
```

**Paso 4 — Plan (stack tecnológico):**

```bash
/speckit.plan Use .NET Aspire with Postgres. The frontend is Blazor Server with drag-and-drop boards and real-time updates. Expose REST APIs for projects, tasks, and notifications.
```

**Paso 5 — Checklist (validar la spec):**

```bash
/speckit.checklist
```

**Paso 6 — Tasks (desglosar el trabajo):**

```bash
/speckit.tasks
```

**Paso 7 — Analyze (comprobar consistencia):**

```bash
/speckit.analyze
```

**Paso 8 — Implement (construir):**

```bash
/speckit.implement
```

**Paso 9 — Converge (verificar completitud):**

```bash
/speckit.converge
```

> **Tip de contexto:** Spec Kit rastrea la feature activa por el directorio de feature registrado en `.specify/feature.json` (sobrescribible con la variable de entorno `SPECIFY_FEATURE_DIRECTORY`), no por la rama git. La extensión git opcional añade ramas de feature numeradas (p. ej. `001-feature-name`), pero la feature activa es siempre la que apunta ese estado.

---

## Corregir bugs con Spec Kit

Los arreglos de bugs son arriesgados cuando un agente salta directo de un reporte a un parche sin validar el diagnóstico ni confirmar que el fix resuelve el síntoma original. La extensión de bugs integrada (opt-in) proporciona un flujo repetible **assess → fix → test** que mantiene cada fix acotado, basado en evidencia y documentado de la causa raíz a la verificación.

### Quickstart de bug fixing

```bash
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git@vX.Y.Z
specify init my-project --integration copilot
cd my-project
specify extension add bug
```

Lanza tu agente de código en el directorio del proyecto:

```bash
# 1. Evaluar el bug
/speckit-bug-assess "<bug report>" slug=login-crash

# 2. Arreglar la causa evaluada
/speckit-bug-fix slug=login-crash

# 3. Probar el fix
/speckit-bug-test slug=login-crash
```

---

## Evaluar ideas con Spec Kit

Las buenas ideas merecen evidencia antes del compromiso, ya se conviertan o no en software. La extensión `assess` integrada (opt-in) convierte una idea cruda en una decisión documentada **go / needs-clarification / kill** a través de un flujo independiente **intake → research → define → shape → decide**.

### Quickstart de evaluación de ideas

```bash
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git@vX.Y.Z
specify init my-project --integration copilot
cd my-project
specify extension add assess
```

Lanza tu agente de código en el directorio del proyecto:

```bash
# 1. Intake de la idea
/speckit-assess-intake "<idea>" slug=offline-mode

# 2. Investigar evidencia a favor y en contra
/speckit-assess-research slug=offline-mode

# 3. Definir problema, objetivos y métricas de éxito
/speckit-assess-define slug=offline-mode

# 4. Dar forma a soluciones posibles y sus trade-offs
/speckit-assess-shape slug=offline-mode

# 5. Decidir si proceder, aclarar o parar
/speckit-assess-decide slug=offline-mode
```

> La evaluación de ideas es independiente. Si decides construir una idea con decisión **go**, puedes pasarla a `/speckit.specify`.

---

## Filosofía central

- **Las especificaciones son ejecutables** — no andamiaje desechable, sino la fuente directa de la implementación.
- **La intención en el centro** — Spec Kit es un harness impulsado por intención que guía al agente a través de tu SDLC o cualquier proceso de negocio.
- **Sin lock-in** — usa cualquier agente, cambia cuando quieras, extiende el proceso o reemplázalo por completo.
- **La adaptabilidad sobre la estabilidad** — a medida que los agentes abaratan el cambio, el valor se mueve hacia la adaptabilidad.
- **Impulsado por la comunidad** — extensiones, presets, bundles y walkthroughs creados por 90+ autores.
- **Listo para la organización** — funciona offline, detrás de firewalls, con catálogos propios para gobernar qué descubre tu equipo.

---

## Comunidad y soporte

- **Documentación:** https://github.github.io/spec-kit/
- **Repo:** https://github.com/github/spec-kit
- **Video overview:** https://www.youtube.com/watch?v=a9eR1xsfvHg
- **Extensiones de la comunidad:** https://github.github.io/spec-kit/community/extensions.html
- **Presets:** https://github.github.io/spec-kit/community/presets.html
- **Bundles:** https://github.github.io/spec-kit/community/bundles.html
- **Walkthroughs:** https://github.github.io/spec-kit/community/walkthroughs.html
- **Friends:** https://github.github.io/spec-kit/community/friends.html

> ⚠️ Las contribuciones de la comunidad son creadas y mantenidas de forma independiente por sus respectivos autores. Revisa el código fuente antes de instalar y úsalo bajo tu propio criterio.

---

## Licencia

Spec Kit está bajo la **licencia MIT** (ver [LICENSE](https://github.com/github/spec-kit/blob/main/LICENSE)).

---

## Fuentes

- README oficial: https://github.com/github/spec-kit
- Documentación: https://github.github.io/spec-kit/
- Quick Start Guide: https://github.github.io/spec-kit/quickstart.html
- Extensiones (referencia): https://github.github.io/spec-kit/reference/extensions.html
- Extensiones (comunidad): https://github.github.io/spec-kit/community/extensions.html
- Integraciones: https://github.github.io/spec-kit/reference/integrations.html
- Post del mantenedor (v1.0.0): https://www.manorrock.com/blog/2026/08/21/spec_kit_turns_one.html
