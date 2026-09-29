# Curso: OpenSpec — Desarrollo Guiado por Especificaciones (SDD)

> **"Agree first, then build confidently."** — OpenSpec

Curso completo, práctico y en español para dominar **OpenSpec**, el framework ligero de
especificaciones para desarrollo guiado por specs (Spec-Driven Development, SDD) que alinea
a tu equipo y a tus agentes de IA antes de escribir una sola línea de código.

---

## Índice

**Parte I — Fundamentos**

1. [Introducción a OpenSpec](#módulo-1--introducción-a-openspec)
2. [Instalación y Setup](#módulo-2--instalación-y-setup)
3. [Conceptos Clave](#módulo-3--conceptos-clave)
4. [El Workflow: explore → propose → apply → archive](#módulo-4--el-workflow-explore--propose--apply--archive)
5. [Specs v1.1: el formato de especificación](#módulo-5--specs-v11-el-formato-de-especificación)
6. [El CLI de OpenSpec](#módulo-6--el-cli-de-openspec)
7. [OpenSpec Avanzado](#módulo-7--openspec-avanzado)
8. [Stores: planificación multi-repo](#módulo-8--stores-planificación-multi-repo-beta)
9. [Buenas Prácticas y Errores Comunes](#módulo-9--buenas-prácticas-y-errores-comunes)

**Parte II — Práctica**

- [Ejercicio 1 — Setup](#ejercicio-1--setup)
- [Ejercicio 2 — Primer cambio completo](#ejercicio-2--primer-cambio-completo)
- [Ejercicio 3 — Escribir una spec v1.1](#ejercicio-3--escribir-una-spec-v11)
- [Ejercicio 4 — Validación y CLI](#ejercicio-4--validación-y-cli)

**Parte III — Proyecto Final**

- [Enunciado — Todo API](#proyecto-práctico-final--todo-api-con-openspec)
- [Spec de referencia (JSON)](#spec-de-referencia--todo-apioschemajson)
- [Guía Paso a Paso](#guía-paso-a-paso--proyecto-todo-api)

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
- **Web:** <https://openspec.dev> · **Docs:** <https://openspec.tech> · **GitHub:** <https://github.com/Fission-AI/OpenSpec>

---

# PARTE I — FUNDAMENTOS

---

# Módulo 1 — Introducción a OpenSpec

> **Objetivo:** entender qué es OpenSpec, qué problema resuelve y por qué es relevante en la
> era de los agentes de IA.

---

## 1.1 El problema: la IA construye lo que le pides vagamente

Los asistentes de IA para programar (Claude Code, Cursor, Codex, etc.) son increíblemente
poderosos pero **impredecibles cuando los requisitos viven solo en el historial del chat**.

Si le dices a un agente *"añade modo oscuro"*, puede:
- Implementarlo de una forma que no esperabas.
- Olvidar el caso del usuario sin autenticar.
- Inventar requisitos que nunca pediste (los agentes **alucinan requisitos** cuando la spec
  es vaga).
- Cambiar convenciones de estilo del proyecto (cada agente inventa las suyas → *style drift*).

El resultado: código que "funciona" pero no es lo que querías, y que nadie puede explicar
por qué se hizo así seis meses después.

## 1.2 La solución: una capa de especificación ligera

**OpenSpec** añade una capa de especificación entre tú y tu IA. La idea en cinco palabras:

> **Agree first, then build confidently.**
> (Primero acuerda, luego construye con confianza.)

En lugar de que el agente construya desde un prompt vago, tú y el agente **acuerdan un plan
por escrito** (la spec) antes de que exista una sola línea de código. Ese plan:

- Se versiona junto al código (vive en el mismo repo).
- Es revisable (un paquete ordenado, no arqueología de chat).
- Sirve de fuente de verdad para ti, tu equipo y cualquier agente futuro.

## 1.3 ¿Qué es exactamente OpenSpec?

> **OpenSpec** es un framework ligero y configurable para crear y gestionar especificaciones
> de software. Te ayuda a **construir la cosa correcta** (validación) y a **construirla
> correctamente** (verificación).

- Es un **CLI de Node.js** (`@fission-ai/openspec`).
- El flujo de trabajo corre **dentro de tu agente de IA** mediante *skills* y *slash commands*
  (`/opsx:propose`, etc.).
- Funciona con **30+ herramientas de IA** (Claude Code, Cursor, Codex, Gemini CLI, OpenCode,
  GitHub Copilot, Amazon Q...).
- Es **open source** (MIT) y está en GitHub: <https://github.com/Fission-AI/OpenSpec> (~67k stars).

## 1.4 Filosofía

OpenSpec se define por cinco principios:

| Principio | Significado |
|-----------|-------------|
| **Fluid not rigid** | Los artefactos se pueden revisar en cualquier momento; no hay fases rígidas. |
| **Iterative not waterfall** | El orden de los artefactos muestra *qué es posible después*, no *qué estás obligado a hacer*. |
| **Easy not complex** | Ligero; las specs son Markdown plano, sin sintaxis especial que aprender. |
| **Built for brownfield** | Los *delta specs* permiten especificar cambios en apps de 50k líneas sin documentar todo primero. |
| **Scalable** | Desde proyectos personales hasta empresas (con *Stores* multi-repo). |

## 1.5 OpenSpec vs. alternativas

| Herramienta | OpenSpec | Spec Kit (GitHub) | Kiro (AWS) |
|-------------|----------|-------------------|------------|
| Peso | Ligero | Pesado (fases rígidas, mucho Markdown, setup Python) | Potente pero cerrado |
| Flexibilidad | Iteración libre | Fases rígidas | Limitado |
| Herramientas | 30+ agentes | — | Solo su IDE + modelos Claude |
| Curva | Baja | Alta | Media |

**vs. nada:** programar con IA sin specs = prompts vagos y resultados impredecibles. OpenSpec
trae predictibilidad sin ceremonia.

## 1.6 ¿Cuándo usar OpenSpec?

**Úsalo cuando el acuerdo importe** — que es casi siempre que trabajas con una IA que va a
construir con confianza lo que le pidas vagamente:

- Nuevas features.
- Refactors significativos.
- Cambios arquitectónicos.
- Trabajo en equipo donde varios agentes/desarrolladores tocan el mismo código.

**No lo uses** para un fix de una línea o una corrección de typo: la ceremonia no paga.
OpenSpec es ligero, pero no es gratis.

---

## ✅ Checkpoint del módulo 1

1. ¿Cuál es el problema central que resuelve OpenSpec?
2. ¿Qué significa "agree first, then build confidently"?
3. Nombra los 5 principios de la filosofía de OpenSpec.
4. ¿En qué se diferencia OpenSpec de Spec Kit y de Kiro?
5. ¿Cuándo NO conviene usar OpenSpec?


---

# Módulo 2 — Instalación y Setup

> **Objetivo:** instalar el CLI de OpenSpec y configurar tu primer proyecto.

---

## 2.1 Requisitos previos

OpenSpec es un CLI de Node.js. Necesitas **Node.js 20.19.0 o superior**.

```bash
node --version
```

Si imprime `v20.19.0` o superior, estás listo. Si no, instala una versión más nueva desde
[nodejs.org](https://nodejs.org) o con tu gestor de versiones (nvm, fnm, asdf, volta).

> ⚠️ **Nota sobre Bun/Deno:** Bun instala OpenSpec pero **no lo ejecuta** — necesitas Node igualmente.
> Deno necesita flags de permisos explícitos. La vía más simple y recomendada es **npm**.

## 2.2 Instalar el CLI globalmente

```bash
npm install -g @fission-ai/openspec@latest
```

### Otras vías (opcionales)

**Bun** (necesitas Node igualmente):
```bash
bun add -g @fission-ai/openspec
```

**Deno** (con flags de permisos):
```bash
deno install --global \
  --allow-read --allow-write --allow-env --allow-sys=cpus,homedir --allow-net=edge.openspec.dev \
  npm:@fission-ai/openspec@latest
```

**Nix**:
```bash
nix profile install github:Fission-AI/OpenSpec
# o ejecución puntual sin instalar:
nix run github:Fission-AI/OpenSpec -- --version
```

## 2.3 Verificar la instalación

```bash
openspec --version
```

Si imprime un número de versión, el CLI está en tu PATH. Se instala **una vez por máquina**.

## 2.4 Inicializar un proyecto

Con el CLI instalado, navega a la raíz de tu proyecto y ejecuta:

```bash
cd <tu-proyecto>
openspec init
```

`init` te pregunta qué herramientas de IA usas, escribe los archivos de workflow para las que
elijas y te reporta el resultado:

```
OpenSpec Setup Complete

Created: Claude Code
6 skills and 6 commands in .claude/
Config: openspec/config.yaml (schema: spec-driven)

Restart your IDE for the new commands to take effect.
```

### Opciones útiles de `init`

```bash
openspec init --tools claude,cursor   # configurar herramientas concretas, sin prompts
openspec init --tools none            # solo la estructura openspec/, sin archivos de tool
openspec init --force                 # limpiar archivos de versiones antiguas sin preguntar
```

> **Re-ejecutar `init` es seguro:** las herramientas ya configuradas imprimen `Refreshed`
> en vez de `Created`, y añadir una herramienta nueva con `--tools` la agrega sin tocar las demás.

## 2.5 ¿Qué crea `init`?

`init` crea **dos cosas** en tu proyecto:

### 1. La carpeta `openspec/` (en la raíz del repo)

```
openspec/
├── config.yaml        # ajustes del proyecto y contexto para la IA
├── specs/             # tus specs (vacía por ahora)
└── changes/           # cambios en movimiento (vacía por ahora)
    └── archive/       # los cambios completados se mueven aquí
```

### 2. Los archivos de workflow (skills y commands)

Se añaden a la carpeta de tu herramienta de IA (`.agents/`, `.claude/`, etc.):

```
.agents/skills/
├── openspec-explore/          # pensar una idea primero
├── openspec-propose/          # proponer un cambio
├── openspec-apply-change/     # implementar las tareas de un cambio
├── openspec-update-change/    # revisar el plan de un cambio
├── openspec-sync-specs/       # sincronizar deltas de un cambio en specs/
├── openspec-archive-change/   # mover un cambio terminado al archivo
├── openspec-verify-change/    # (opcional) verificar que la implementación coincide
└── openspec-bulk-archive-change/  # (opcional) archivar varios cambios a la vez
```

Cada workflow se instala en **dos formas** (por defecto):
- **Skill** (`openspec-apply-change`): instrucciones que tu agente recoge solo.
- **Command** (`/opsx:apply` en Claude Code): un punto de entrada tecleado para el mismo workflow.

Son funcionalmente idénticos. OpenSpec prefiere skills y planea retirar los commands.

> **Commit todo** (la carpeta `openspec/` y los archivos de workflow) como parte de tu código
> fuente. `init` no cambia nada más en tu repo.

## 2.6 Cambiar el perfil de instalación

Puedes cambiar cómo se instalan los workflows (skills, commands, o ambos) y qué conjunto de
workflows se usa:

```bash
openspec config profile
```

Ejemplo — cambiar a solo skills:

```
Current profile settings
 Delivery: both

? What do you want to configure? Delivery only
? Delivery mode (how workflows are installed): Skills only

Config changes:
 delivery: both -> skills
? Apply changes to this project now? (Y/n) y
```

> Los cambios de config no llegan a los proyectos hasta que ejecutas `openspec update`.

## 2.7 Actualizar OpenSpec

```bash
openspec update
```

- Actualiza los archivos de instrucciones instalados en tu proyecto.
- Si hay una versión más nueva del CLI, te ofrece actualizarla primero (una vez por máquina).
- Cada ejecución refresca los skills y commands generados del proyecto (nunca se actualizan solos).

```bash
openspec update --force   # reescribir archivos aunque estén al día
```

## 2.8 Desinstalar

1. Quita las completions de shell (si las configuraste): `openspec completion uninstall`
2. Quita el paquete: `npm uninstall -g @fission-ai/openspec`
3. Borra lo que quede (opcional): archivos generados en `.claude/`/`.agents/`, la carpeta
   `openspec/` (pausa: `specs/` y `changes/archive/` son tu registro del sistema, Markdown
   plano que se lee sin OpenSpec), y el estado por máquina en `~/.config/openspec/`.

---

## ✅ Checkpoint del módulo 2

1. ¿Qué versión de Node.js necesitas?
2. ¿Cuál es el comando para instalar el CLI globalmente?
3. ¿Qué dos cosas crea `openspec init`?
4. ¿Cuál es la diferencia entre un *skill* y un *command* de workflow?
5. ¿Qué hace `openspec update` y por qué es necesario?

**Ejercicio:** [Ejercicio 1 — Setup](#ejercicio-1--setup)


---

# Módulo 3 — Conceptos Clave

> **Objetivo:** dominar el modelo mental de OpenSpec. Todo lo demás es detalle.

---

OpenSpec se construye sobre **cinco conceptos**. Aprende estos y el resto es fácil.

## 3.1 Concepto 1: Specs son la verdad

Una **spec** describe cómo se comporta tu sistema **ahora mismo**. Vive en `openspec/specs/`,
organizada por dominio (`auth/`, `payments/`, `ui/`).

Las specs están hechas de:
- **Requisitos** (requirements): *"El sistema SHALL expirar las sesiones después de 30 minutos."*
- **Escenarios** (scenarios): ejemplos concretos *given/when/then*.

> Piensa en las specs como la respuesta única y acordada a *"¿qué hace este software?"*

## 3.2 Concepto 2: Un cambio (change) es una unidad de trabajo

Cuando quieres **añadir, modificar o eliminar** comportamiento, creas un **cambio**: una
carpeta en `openspec/changes/` que contiene todo sobre ese trabajo en un solo lugar.

```
openspec/changes/add-dark-mode/
├── proposal.md   # por qué y qué cambia
├── specs/        # qué significa "hecho", como requisitos comprobables
├── design.md     # decisiones técnicas (solo cuando el cambio lo necesita)
└── tasks.md      # la checklist de implementación
```

> Un cambio, una carpeta, una feature.

## 3.3 Concepto 3: Delta specs describen lo que cambia, no el mundo entero

Dentro de un cambio **no reescribes toda la spec**. Escribes un **delta** pequeño:

- **ADDED** este requisito
- **MODIFIED** aquel otro
- **REMOVED** este de más allá

Este es el truco que hace que OpenSpec sea bueno editando sistemas existentes (brownfield),
no solo proyectos nuevos. **Describes el diff, no el destino.**

## 3.4 Concepto 4: Los artefactos se construyen unos sobre otros

Un cambio contiene varios documentos, creados en orden natural, cada uno alimentando al siguiente:

```
proposal ──► specs ──► design ──► tasks ──► implement
  why        what      how       steps      do it
```

Puedes revisar cualquiera de ellos en cualquier momento. **Son habilitadores, no puertas.**
El orden muestra qué es posible después, no a qué estás obligado.

> Descubres durante la implementación que el diseño estaba mal → edita `design.md` y sigue.
> El scope debe encogerse → actualiza el `proposal`. Nada te bloquea.

## 3.5 Concepto 5: Archivar (archive) devuelve el cambio a la verdad

Cuando el trabajo está hecho, **archivas** el cambio. Sus delta specs se fusionan en tus specs
principales, y la carpeta del cambio se mueve a `changes/archive/` con una marca de fecha.

```
┌─────────────────────────────────────────────────────────────┐
│ openspec/                                                    │
│                                                              │
│  ┌──────────────┐          ┌──────────────────────────┐       │
│  │ specs/       │          │ changes/                │       │
│  │              │ ◄──────  │  una carpeta por cambio │       │
│  │ fuente de    │  merge   │  proposal · design ·    │       │
│  │ verdad       │  al      │  tasks · delta specs    │       │
│  │ cómo funciona│  archivar│                         │       │
│  └──────────────┘          └──────────────────────────┘       │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

**Dos carpetas.** `specs/` es lo que es verdad. `changes/` es lo que propones. Archivar mueve
una propuesta a la verdad. El ciclo se cierra y estás listo para el siguiente cambio.

## 3.6 El flujo del día a día

En la configuración por defecto, tu día se ve así:

```
/opsx:explore  →  (opcional) piénsalo con la IA primero
/opsx:propose add-dark-mode  →  la IA redacta proposal, specs, design, tasks
                              (tú lees y ajustas el plan)
/opsx:apply    →  la IA construye, marcando tareas
/opsx:archive  →  specs actualizadas, cambio archivado
```

> **¿Dudas? Empieza explorando.** `/opsx:explore` es un compañero de pensamiento sin riesgo:
> lee tu código, plantea opciones y convierte una idea difusa en un plan concreto antes de que
> exista cualquier artefacto. Es el mejor antídoto contra una IA que construirá algo a partir
> de un prompt vago.

## 3.7 ¿Dónde corren los comandos?

- **Setup** (`openspec init`) corre en tu **terminal**.
- **El flujo** (`/opsx:propose`, etc.) corre en el **chat de tu agente de IA**.

Esta división es la fuente de confusión más común. Los slash commands se teclean en el chat
de tu asistente; el CLI se usa en la terminal.

## 3.8 ¿Qué ganas y qué pagas?

**Ganas:**
- Corriges malentendidos **antes** de que cuesten caro (arreglar un párrafo es gratis;
  arreglar 400 líneas de código, no).
- El plan y el código viven en el mismo repo; seis meses después la spec te dice *por qué*
  el sistema funciona como funciona.
- Los cambios son revisables: lee el proposal, hojea los deltas, revisa las tareas.
- Encaja en codebases existentes gracias a los deltas.

**Pagas:**
- Añades un paso (escribes un plan corto antes de construir).
- Para un fix trivial de una línea, la ceremonia puede no pagar. Y está bien.

---

## ✅ Checkpoint del módulo 3

1. ¿Qué es una spec y dónde vive?
2. ¿Qué es un cambio (change) y qué contiene?
3. ¿Qué es un *delta spec* y por qué es importante para brownfield?
4. Nombra los 5 artefactos de un cambio en orden.
5. ¿Qué hace archivar un cambio?
6. ¿Dónde corre `openspec init` y dónde corre `/opsx:propose`?


---

# Módulo 4 — El Workflow: explore → propose → apply → archive

> **Objetivo:** dominar el ciclo completo de un cambio, de la idea al archivo.

---

Todo cambio pasa por los mismos **cinco pasos**: piensas la idea con tu agente, este redacta
un plan, tú corriges el plan **antes** de que exista código, el agente construye a partir de él,
y archivar actualiza tus specs con lo que se envió.

Cada prompt de abajo va en el **chat de tu IA**, el mismo lugar donde pides código. Cada uno
invoca un skill de OpenSpec por nombre. Una petición simple también funciona (*"propose a
change to add rate limiting"*). Algunas herramientas añaden alias más cortos (`/opsx:propose`
en Claude Code).

---

## 4.1 Paso 0 (opcional): Explore — piénsalo primero

Piensa la idea con tu agente **antes** de pedir un plan:

```
/openspec-explore how rate limiting should work in this app
```

**Explore es un modo de pensamiento.** El agente:
- Investiga tu codebase.
- Hace las preguntas que importan.
- Esboza opciones.
- Desafía tus suposiciones.

**No escribe código ni archivos.** El resultado es una idea más nítida.

Quédate aquí todo el tiempo que el problema necesite. Cuando la forma se sienta bien, pásalo:

```
/openspec-propose
```

Esa línea inicia propose para ti, llevando todo lo que acordaste (te saltas el primer prompt
del paso 2).

---

## 4.2 Paso 1: Propose — convierte la idea en un plan revisable

Viniendo de explore, ya está corriendo. Empezando en frío, cuando el cambio está claro en tu
cabeza, pide directamente:

```
/openspec-propose add rate limiting
```

El agente pregunta lo que necesite y luego escribe una carpeta de cambio:

```
openspec/changes/add-rate-limiting/
├── proposal.md   # por qué, y qué cambia
├── specs/        # qué significa "hecho", como requisitos comprobables
├── design.md    # decisiones técnicas (solo cuando el cambio lo necesita)
└── tasks.md     # la checklist de implementación
```

**Aún no hay código.** Propose se detiene en el plan.

---

## 4.3 Paso 2: Revisa el plan — corrígelo mientras es solo palabras

Arregla el plan mientras sigue siendo palabras y nada está construido. Lee en este orden:

1. **`proposal.md`**: ¿es el problema correcto, con el tamaño correcto?
2. **`specs/`**: la lectura de mayor valor. ¿Aceptarías estos requisitos como "hecho"?
3. **`tasks.md`**: ¿cubren las tareas las specs, y nada más?

Para arreglar algo, cualquiera de las dos funciona:
- **Edita el archivo tú mismo.** Los artefactos son Markdown plano, y los archivos son el plan.
- **Dile a tu agente qué está mal** (*"la spec no cubre el caso sin autenticar"*). Revisa los
  artefactos.

---

## 4.4 Paso 3: Apply — convierte el plan en código

Empieza una **sesión de chat nueva** (la implementación va mejor con una ventana de contexto
limpia):

```
/openspec-apply-change add-rate-limiting
```

El agente lee la carpeta del cambio y trabaja a través de `tasks.md`, marcando cada tarea
según aterriza.

- **¿Interrumpido o sin contexto?** Abre una sesión nueva y pide aplicar de nuevo. Reanuda en
  la primera tarea sin marcar.
- **¿El plan resultó mal?** Arregla los artefactos (como en el paso 3), luego continúa aplicando.
- **El progreso vive en los checkboxes de `tasks.md`.** No hay estado oculto.

---

## 4.5 Paso 4: Archive — devuelve el cambio a la verdad

Archivar hace **dos cosas**:
1. Actualiza tus specs principales con los requisitos del cambio.
2. Mueve la carpeta del cambio a la carpeta de archivo (`openspec/changes/archive/*`).

Cuando **cada** checkbox de `tasks.md` esté marcado:

```
/openspec-archive-change add-rate-limiting
```

### Qué hace archivar, paso a paso

**Paso 1 — El cambio terminado.** La implementación está hecha. El delta spec (lo que este
cambio añade) sigue dentro de la carpeta del cambio; `specs/` todavía no sabe nada de rate
limiting.

```
openspec/
├── specs/                      (sin spec de rate-limiting aún)
└── changes/
    └── add-rate-limiting/
        ├── proposal.md
        ├── tasks.md            (cada checkbox marcado)
        └── specs/
            └── rate-limiting/
                └── spec.md     (el delta: requisitos ADDED)
```

**Paso 2 — Tras archivar.** Los deltas se fusionan en `specs/` y la carpeta se mueve a
`changes/archive/` con fecha.

> **Git es un asunto aparte.** Haz commit de la carpeta del cambio junto con el código, y nada
> más de tu flujo cambia. Cuándo archivar respecto a un PR es una convención de equipo.

---

## 4.6 Resumen del flujo

| Paso | Comando | Qué hace | ¿Escribe código? |
|------|---------|----------|------------------|
| 0 | `/opsx:explore` | Piensa la idea, lee el codebase | No |
| 1 | `/opsx:propose` | Redacta proposal, specs, design, tasks | No |
| 2 | *(revisión)* | Tú corriges el plan | No |
| 3 | `/opsx:apply` | Implementa las tareas | Sí |
| 4 | `/opsx:archive` | Fusiona deltas en specs, archiva | No |

---

## ✅ Checkpoint del módulo 4

1. ¿Qué hace `/opsx:explore` y por qué es útil antes de proponer?
2. ¿Qué archivos crea `/opsx:propose`?
3. ¿En qué orden debes revisar el plan y qué buscas en cada archivo?
4. ¿Por qué conviene empezar una sesión nueva para `/opsx:apply`?
5. ¿Qué dos cosas hace archivar un cambio?
6. ¿Dónde vive el progreso de la implementación?

**Ejercicio:** [Ejercicio 2 — Primer cambio](#ejercicio-2--primer-cambio-completo)


---

# Módulo 5 — Specs v1.1: el formato de especificación

> **Objetivo:** escribir specs en formato v1.1 que cualquier motor compatible con OpenSpec
> pueda parsear, validar y ejecutar.

---

## 5.1 El formato

Un archivo OpenSpec puede ser **JSON, YAML o TOON**. En v1.1 el documento es **una sola
especificación** — no hay wrapper de proyecto ni array de specifications.

La raíz lleva `schemaVersion: "1.1"` más un puñado de campos obligatorios:
`id`, `projectId`, `title`, `status`, `goals`, `requirements`, `architecture`, `scope`,
`techStack`, `folderStructures`, `acceptanceCriteria`, `nonFunctionalRequirements`,
`guardrails`, `epics` y `blueprints`.

### El spec válido más pequeño (Todo API)

```json
{
  "schemaVersion": "1.1",
  "id": "spec-todo-api",
  "projectId": "proj-todo",
  "title": "Todo API",
  "status": "planning",
  "goals": [
    {
      "id": "goal-capture",
      "title": "Capture todos quickly",
      "description": "Let users create and list todos with minimal friction.",
      "type": "user",
      "successCriteria": ["A todo can be created and listed in under one second"]
    },
    {
      "id": "goal-durable",
      "title": "Keep todos durable",
      "description": "Persist todos so they survive restarts.",
      "type": "technical",
      "successCriteria": ["No todo is lost across a service restart"]
    },
    {
      "id": "goal-contract",
      "title": "Expose a stable contract",
      "description": "Offer a predictable REST surface clients can rely on.",
      "type": "business",
      "successCriteria": ["The public endpoints follow a documented contract"]
    }
  ],
  "requirements": [
    {
      "id": "req-create",
      "title": "Create a todo",
      "description": "Clients can create a todo with a title.",
      "type": "functional",
      "acceptanceCriteria": [
        {
          "id": "ac-create",
          "given": "a valid todo payload",
          "when": "the client POSTs to /todos",
          "then": "the todo is stored and returned with a generated id",
          "order": 1
        }
      ]
    },
    {
      "id": "req-list",
      "title": "List todos",
      "description": "Clients can retrieve all todos.",
      "type": "functional",
      "acceptanceCriteria": [
        {
          "id": "ac-list",
          "given": "stored todos exist",
          "when": "the client GETs /todos",
          "then": "all todos are returned in creation order",
          "order": 1
        }
      ]
    },
    {
      "id": "req-validate",
      "title": "Reject invalid input",
      "description": "Malformed payloads are rejected clearly.",
      "type": "business-rule",
      "acceptanceCriteria": [
        {
          "id": "ac-validate",
          "given": "a payload without a title",
          "when": "the client POSTs to /todos",
          "then": "the request is rejected with a 400",
          "order": 1
        }
      ]
    }
  ],
  "architecture": "A stateless HTTP service backed by a relational database, exposing a small REST API for todos.",
  "scope": {
    "inScope": ["Creating todos", "Listing todos", "Input validation"],
    "outOfScope": ["Authentication and multi-user accounts"]
  },
  "techStack": [],
  "folderStructures": [
    {
      "id": "fs-service",
      "scope": "service",
      "content": "src/\n routes/todos.ts\n db/index.ts\n server.ts"
    }
  ],
  "acceptanceCriteria": [],
  "nonFunctionalRequirements": [],
  "guardrails": [],
  "epics": [],
  "blueprints": []
}
```

Guárdalo como `todo-api.oschema.json`. Ese es un spec OpenSpec válido. Todo lo demás se
construye sobre este esqueleto.

---

## 5.2 Goals y requirements son estructurados

En v1.1, los goals y requirements ya no son strings planos — cada uno es un **objeto tipado**.

- Un **goal** declara un `type` y `successCriteria`.
- Un **requirement** lleva `acceptanceCriteria` escritos como **Given / When / Then**, para que
  un agente tenga una checklist concreta de aprobado/fallo que verificar.

```json
{
  "goals": [
    {
      "id": "goal-capture",
      "title": "Capture todos quickly",
      "description": "Let users create and list todos with minimal friction.",
      "type": "user",
      "successCriteria": ["A todo can be created and listed in under one second"]
    }
  ],
  "requirements": [
    {
      "id": "req-create",
      "title": "Create a todo",
      "description": "Clients can create a todo with a title.",
      "type": "functional",
      "acceptanceCriteria": [
        {
          "id": "ac-create",
          "given": "a valid todo payload",
          "when": "the client POSTs to /todos",
          "then": "the todo is stored and returned with a generated id",
          "order": 1
        }
      ]
    }
  ]
}
```

> **Por qué importa:** los agentes alucinan requisitos cuando la spec es vaga. Los criterios de
> aceptación estructurados les dan una checklist explícita de aprobado/fallo en vez de un
> párrafo que interpretar.

---

## 5.3 Shared patterns — convenciones compartidas

Capturan convenciones que aplican a través de tickets. Evitan el *style drift* dándole a los
agentes una única fuente de verdad para estándares de código, imports comunes y tipos de retorno.

```json
{
  "sharedPatterns": [
    {
      "id": "sp-rest",
      "name": "REST conventions",
      "description": "All endpoints return JSON and use plural resource URLs.",
      "codeStandards": {
        "naming": "camelCase for fields, plural nouns for routes",
        "errorHandling": "Return a typed Result at module boundaries"
      },
      "commonImports": ["import { Result, ok, err } from '../shared/result'"],
      "returnTypes": { "handler": "Promise<Result<Response, AppError>>" }
    }
  ]
}
```

> **Por qué importa:** sin shared patterns, cada agente (o desarrollador) inventa sus propias
> convenciones y la spec se vuelve inconsistente con el tiempo.

---

## 5.4 Blueprints — artefactos de diseño

Los blueprints son artefactos de diseño — diagramas, esquemas, ADRs — referenciados por los
tickets. Cada uno tiene una `category`, un `format` y un cuerpo `content`. Mantienen las
decisiones de diseño descubribles en vez de perdidas en logs de chat o carpetas de documentos.

```json
{
  "blueprints": [
    {
      "id": "bp-db-schema",
      "title": "Database schema",
      "category": "erd",
      "format": "mermaid",
      "content": "erDiagram\n TODO {\n  uuid id PK\n  string title\n  bool completed\n }"
    },
    {
      "id": "bp-api-contract",
      "title": "API contract",
      "category": "api",
      "format": "markdown",
      "content": "GET /todos -> 200 [Todo]\nPOST /todos -> 201 Todo"
    }
  ]
}
```

> **Por qué importa:** los artefactos de diseño que viven fuera de la spec se pierden o quedan
> obsoletos. Los blueprints los mantienen versionados y enlazados a los tickets que los
> implementan.

---

## 5.5 Tickets — la unidad atómica del trabajo del agente

Los tickets viven dentro de un **epic** y son la pieza de trabajo más pequeña de una spec.
Cada uno declara un `ticketType`, una `complexity`, un presupuesto `estimatedMinutes`, criterios
de aceptación Given/When/Then, `implementationSteps` ordenados y los archivos que tocará — para
que el agente implementador sepa exactamente qué construir y cómo se comprobará.

```json
{
  "id": "ticket-create-todo",
  "epicId": "epic-core",
  "title": "Implement POST /todos",
  "description": "Create a todo. Validate the title is non-empty. Return 201 with the created resource.",
  "ticketType": "implementation",
  "complexity": "small",
  "estimatedMinutes": 90,
  "acceptanceCriteria": [
    {
      "id": "ac-create-201",
      "given": "a payload with a title",
      "when": "POST /todos is called",
      "then": "a 201 is returned with the created todo",
      "order": 1
    },
    {
      "id": "ac-create-400",
      "given": "a payload without a title",
      "when": "POST /todos is called",
      "then": "a 400 is returned with an error envelope",
      "order": 2
    }
  ],
  "implementationSteps": [
    { "id": "step-1", "text": "Add the POST /todos route handler", "order": 1 },
    { "id": "step-2", "text": "Validate the payload and persist the todo", "order": 2 }
  ],
  "filesToBeCreated": ["src/routes/todos.ts"],
  "blueprintReferences": [
    { "blueprintId": "bp-api-contract", "context": "Create path" }
  ],
  "dependencies": []
}
```

---

## 5.6 Dependencies — el grafo de ejecución

Los tickets pueden declarar dependencias de otros tickets usando un `ticketId` objetivo y un
`type`. OpenSpec soporta dos tipos:

- **`requires`** — este ticket necesita que el otro esté completo antes de empezar.
- **`blocks`** — este ticket impide que el otro empiece hasta que esté completo.

```json
[
  { "id": "ticket-create-todo", "title": "POST /todos", "dependencies": [] },
  {
    "id": "ticket-list-todos",
    "title": "GET /todos",
    "dependencies": [{ "ticketId": "ticket-create-todo", "type": "requires" }]
  },
  {
    "id": "ticket-delete-todo",
    "title": "DELETE /todos/:id",
    "dependencies": [{ "ticketId": "ticket-create-todo", "type": "requires" }]
  }
]
```

> **Por qué importa:** sin datos de dependencia explícitos, un motor podría empezar un ticket
> cuyos prerrequisitos aún no están hechos. El validador detecta dependencias circulares y
> referencias colgantes en tiempo de lint.

### Cómo ve un motor esta spec

```
ticket-create-todo
   │
   ├──► ticket-list-todos
   └──► ticket-delete-todo
```

`ticket-create-todo` no tiene dependencias, así que es accionable de inmediato. Los otros dos
lo requieren, así que esperan.

---

## ✅ Checkpoint del módulo 5

1. ¿Qué formatos soporta un archivo OpenSpec?
2. ¿Qué campos obligatorios lleva la raíz de un spec v1.1?
3. ¿Por qué los goals y requirements son objetos tipados y no strings?
4. ¿Qué son los *shared patterns* y qué problema resuelven?
5. ¿Qué es un *blueprint* y qué campos tiene?
6. ¿Qué campos declara un *ticket*?
7. ¿Cuál es la diferencia entre `requires` y `blocks`?

**Ejercicio:** [Ejercicio 3 — Spec v1.1](#ejercicio-3--escribir-una-spec-v11)


---

# Módulo 6 — El CLI de OpenSpec

> **Objetivo:** dominar los comandos de terminal de OpenSpec.

---

El CLI (`openspec`) se divide en grupos. Tu agente ejecuta la mayoría de los comandos de
workflow; tú usas el CLI para setup, inspección y validación.

## 6.1 Comandos de setup

| Comando | Qué hace |
|---------|----------|
| `openspec init` | Inicializa OpenSpec en un proyecto. |
| `openspec update` | Actualiza los archivos de instrucciones instalados. |
| `openspec config` | Ve y cambia la configuración global. |

### `openspec init`

```bash
openspec init                          # directorio actual, selector interactivo de tools
openspec init --tools claude,cursor    # configurar tools concretas, sin prompts
openspec init --tools none             # solo estructura openspec/, sin archivos de tool
```

- `--tools <tools>`: ids separados por coma, `all` o `none`. Salta el selector.
- `--force`: elimina archivos de layouts antiguos sin preguntar.
- `--profile <profile>`: `core` (conjunto estándar) o `custom`.
- `--no-animation`: pantalla de bienvenida estática.

### `openspec update`

```bash
openspec update          # refresca tools cuyos archivos son más viejos que el CLI
openspec update --force  # reescribe archivos aunque estén al día
```

- Si hay una versión más nueva del CLI, primero ofrece actualizarlo.
- `OPENSPEC_NO_UPDATE_CHECK=1` salta la comprobación de versión.
- Fuera de un proyecto con OpenSpec: `✖ Error: No OpenSpec directory found. Run 'openspec init' first.`

### `openspec config`

```bash
openspec config list                 # ver ajustes actuales
openspec config get delivery         # leer un valor (scriptable)
openspec config set delivery skills  # cambiar un valor
openspec config unset delivery       # quitar una clave (vuelve al default)
openspec config reset --all -y      # resetear todo
openspec config edit                 # abrir el config en $EDITOR
openspec config profile              # selector interactivo de workflows
```

- La config es **global a tu máquina**: `~/.config/openspec/config.json` (o `%APPDATA%` en Windows).
- `set` coacciona tipos (`true` → booleano, `"3"` → número). Usa `--string` para forzar string.
- Claves desconocidas fallan con exit 1 salvo que pases `--allow-unknown`.

---

## 6.2 Comandos de changes y specs

| Comando | Qué hace |
|---------|----------|
| `openspec list` | Lista changes, o specs con `--specs`. |
| `openspec show` | Imprime un change o spec, como markdown o JSON. |
| `openspec view` | Dashboard de una pantalla de specs y changes. |
| `openspec validate` | Comprueba changes y specs por problemas estructurales. |
| `openspec archive` | Mueve un change completado al archivo y actualiza las specs. |

### `openspec list`

```bash
openspec list            # changes, más recientes primero
openspec list --specs    # specs con conteo de requisitos
openspec list --json     # salida JSON, incluye la raíz resuelta
```

- `--sort recent|name` (default: recent; specs siempre por nombre).
- `--store <id>`: usa un store registrado como raíz.

Salida:
```
Changes:
 add-rate-limit   No tasks just now

Specs:
 api   requirements 1
```

### `openspec show`

```bash
openspec show add-rate-limit        # change: imprime proposal.md
openspec show add-rate-limit --diff # change: añade diffs de requisitos
openspec show api                   # spec: imprime spec.md
openspec show api --json            # spec JSON
```

- `--json`: salida estructurada.
- `--type <change|spec>`: desambigua cuando un change y una spec comparten nombre.
- `--diff`: para changes, añade diffs por requisito.
- `-r, --requirement <id>`: para specs JSON, un requisito por posición 1-based.

### `openspec view`

```bash
openspec view
```

Dashboard de una pantalla. Los changes se agrupan por progreso de tareas:
- **Draft** (sin tareas aún)
- **Active** (tareas en curso, con barra de progreso y %)
- **Completed** (cada tarea marcada)

Las specs se listan con conteo de requisitos, las más grandes primero.

### `openspec validate`

```bash
openspec validate add-rate-limit   # un change o spec, por nombre
openspec validate --all            # cada change y spec
openspec validate --changes        # cada change
openspec validate --specs          # cada spec
openspec validate --strict         # tratar warnings como fallos
openspec validate --json           # reporte estructurado
```

- `--archived`: comprueba completitud de tareas en changes archivados.
- `--concurrency <n>`: paralelismo en runs bulk (default: `OPENSPEC_CONCURRENCY`, si no 6).
- `--no-interactive`: un nombre ausente/ambiguo se vuelve error.

Salida bulk:
```
✓ change/add-rate-limit
✓ spec/api
Totals: 2 passed, 0 failed (2 items)
```

> **Archive merge findings:** para changes, `validate` ejecuta el merge builder de archive contra
> las specs actuales sin escribir archivos. Reporta conflictos de merge (p. ej. un MODIFIED cuyo
> target falta) como `INFO`. Los INFO nunca cambian el exit code, ni siquiera con `--strict`.

### `openspec archive`

Mueve un change completado al archivo y actualiza las specs principales con sus deltas.

---

## 6.3 Comandos de workflows y schemas

| Comando | Qué hace |
|---------|----------|
| `openspec new` | Crea un directorio de change nuevo. |
| `openspec status` | Estado de completitud de artefactos de uno o todos los changes activos. |
| `openspec instructions` | Instrucciones para crear un artefacto, aplicar o archivar. |
| `openspec templates` | Rutas de template resueltas para los artefactos de un schema. |
| `openspec schemas` | Lista los schemas de workflow disponibles. |
| `openspec schema` | Inspecciona, bifurca o crea un schema (experimental). |

---

## 6.4 Comandos multi-repo (beta)

| Comando | Qué hace |
|---------|----------|
| `openspec store` | Crea y gestiona stores: repos OpenSpec independientes registrados en tu máquina. |
| `openspec doctor` | Reporta la salud de relaciones para la raíz OpenSpec resuelta. |
| `openspec context` | Imprime el contexto de trabajo para la raíz OpenSpec resuelta. |
| `openspec workset` | Compone, mantiene y abre vistas de trabajo personales. |

---

## 6.5 Utilidades

| Comando | Qué hace |
|---------|----------|
| `openspec feedback` | Envía feedback sobre OpenSpec. |
| `openspec completion` | Instala o genera completions de shell. |

**Deprecados:** `openspec change` y `openspec spec` (formas nominales de show/list/validate).
El CLI avisa y apunta a los comandos verb-first.

---

## 6.6 Flags globales

- `-h, --help` en cada comando.
- `-V, --version`: imprime la versión del CLI.
- `--no-color`: desactiva salida de color.

---

## ✅ Checkpoint del módulo 6

1. ¿Qué hace `openspec init --tools none`?
2. ¿Cuál es la diferencia entre `openspec list` y `openspec view`?
3. ¿Qué hace `openspec validate --all` y qué son los "archive merge findings"?
4. ¿Cómo desambiguas un nombre que es a la vez change y spec en `show`?
5. ¿Dónde vive la config global de OpenSpec?
6. Nombra dos comandos del grupo multi-repo (beta).

**Ejercicio:** [Ejercicio 4 — Validación](#ejercicio-4--validación-y-cli)


---

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


---

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


---

# Módulo 9 — Buenas Prácticas y Errores Comunes

> **Objetivo:** aplicar OpenSpec con disciplina y evitar los errores típicos.

---

## 9.1 Buenas prácticas

### Empieza explorando cuando dudes
`/opsx:explore` es un compañero de pensamiento sin riesgo: lee tu código, plantea opciones y
convierte una idea difusa en un plan concreto **antes** de que exista cualquier artefacto. Es
el mejor antídoto contra una IA que construirá algo a partir de un prompt vago.

### Revisa el plan antes de construir
Lee en orden: `proposal.md` (¿problema correcto, tamaño correcto?), `specs/` (¿aceptarías estos
requisitos como "hecho"?), `tasks.md` (¿cubren las specs y nada más?). Corregir un párrafo es
gratis; corregir 400 líneas de código no.

### Mantén los changes enfocados
Como nada te fuerza hacia adelante, la disciplina es tuya: **mantén un change enfocado** en vez
de dejar que se desparrame. Un change, una feature.

### Usa sesiones limpias para implementar
La implementación va mejor con una ventana de contexto limpia. Empieza una sesión de chat nueva
para `/opsx:apply` y mantén buena higiene de contexto.

### Escribe criterios de aceptación estructurados
Los agentes alucinan requisitos cuando la spec es vaga. Usa Given/When/Then en los
`acceptanceCriteria` para darles una checklist explícita de aprobado/fallo.

### Usa shared patterns para evitar style drift
Da a los agentes una única fuente de verdad para convenciones de código, imports comunes y
tipos de retorno. Sin esto, cada agente inventa las suyas.

### Mantén los blueprints versionados
Los artefactos de diseño que viven fuera de la spec se pierden o quedan obsoletos. Guárdalos
como blueprints, enlazados a los tickets que los implementan.

### Declara dependencias explícitas
Sin datos de dependencia, un motor podría empezar un ticket cuyos prerrequisitos no están hechos.
Usa `requires`/`blocks` y deja que el validador detecte ciclos y referencias colgantes.

### Haz commit de todo
Commit de la carpeta `openspec/` y de los archivos de workflow como parte de tu código fuente.
Seis meses después, la spec te dice *por qué* el sistema funciona como funciona.

### Usa modelos de alto razonamiento
OpenSpec funciona mejor con modelos de alto razonamiento (se recomiendan Codex 5.5 y Opus 4.7)
tanto para planificar como para implementar.

---

## 9.2 Errores comunes

### ❌ Saltarse el plan e ir directo a aplicar
El valor de OpenSpec está en el acuerdo previo. Si aplicas sin revisar el plan, vuelves al
problema original: la IA construye lo que le pides vagamente.

### ❌ Reescribir toda la spec en un change
No reescribas el mundo. Escribe **deltas** (ADDED/MODIFIED/REMOVED). Ese es el truco que hace
que OpenSpec funcione en brownfield.

### ❌ Confundir dónde corren los comandos
`openspec init` corre en la **terminal**; `/opsx:propose` corre en el **chat de tu agente**.
Es la fuente de confusión más común.

### ❌ No ejecutar `openspec update` tras cambiar la config
Los cambios de config no llegan a los proyectos hasta que ejecutas `openspec update`.

### ❌ Usar OpenSpec para todo
Para un fix trivial de una línea, la ceremonia puede no pagar. OpenSpec es ligero, pero no es
gratis. Úsalo donde el acuerdo importe.

### ❌ Ignorar los "archive merge findings" de `validate`
`openspec validate` reporta conflictos de merge potenciales (p. ej. un MODIFIED cuyo target
falta) como INFO. Revísalos: pueden indicar que un change hermano aún no ha archivado.

### ❌ Dejar que un change se desparrame
Como nada te obliga a avanzar, un change sin disciplina crece sin control. Mantén el scope
ajustado y actualiza el `proposal` si el scope debe encogerse.

### ❌ No declarar dependencias entre tickets
Un motor podría empezar un ticket cuyos prerrequisitos no están hechos. Declara `requires`/`blocks`
y deja que el validador detecte ciclos.

---

## 9.3 Checklist de un change saludable

- [ ] `proposal.md` describe el problema correcto, con el tamaño correcto.
- [ ] `specs/` tiene requisitos con criterios de aceptación Given/When/Then.
- [ ] `tasks.md` cubre las specs, y nada más.
- [ ] Los deltas son ADDED/MODIFIED/REMOVED, no reescrituras completas.
- [ ] Las dependencias entre tickets están declaradas.
- [ ] Los blueprints están versionados y referenciados.
- [ ] `openspec validate` pasa sin findings críticos.
- [ ] Cada checkbox de `tasks.md` está marcado antes de archivar.
- [ ] El change está archivado y los deltas fusionados en `specs/`.

---

## ✅ Checkpoint del módulo 9

1. ¿Por qué conviene empezar con `/opsx:explore` cuando dudas?
2. ¿Qué es el *style drift* y cómo lo previenen los shared patterns?
3. ¿Cuál es la fuente de confusión más común sobre los comandos?
4. ¿Cuándo NO conviene usar OpenSpec?
5. Nombra tres errores comunes y cómo evitarlos.


---

# PARTE II — PRÁCTICA

---

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

> **Siguiente:** [Ejercicio 2 — Primer cambio](#ejercicio-2--primer-cambio-completo)

---

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

> **Siguiente:** [Ejercicio 3 — Spec v1.1](#ejercicio-3--escribir-una-spec-v11)

---

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

> **Siguiente:** [Ejercicio 4 — Validación](#ejercicio-4--validación-y-cli)

---

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

> **Siguiente:** [Proyecto práctico](#proyecto-práctico-final--todo-api-con-openspec)

---

# PARTE III — PROYECTO FINAL

---

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


## Spec de referencia — todo-api.oschema.json

```json
{
  "schemaVersion": "1.1",
  "id": "spec-todo-api",
  "projectId": "proj-todo",
  "title": "Todo API",
  "status": "planning",
  "goals": [
    {
      "id": "goal-capture",
      "title": "Capture todos quickly",
      "description": "Let users create and list todos with minimal friction.",
      "type": "user",
      "successCriteria": ["A todo can be created and listed in under one second"]
    },
    {
      "id": "goal-durable",
      "title": "Keep todos durable",
      "description": "Persist todos so they survive restarts.",
      "type": "technical",
      "successCriteria": ["No todo is lost across a service restart"]
    },
    {
      "id": "goal-contract",
      "title": "Expose a stable contract",
      "description": "Offer a predictable REST surface clients can rely on.",
      "type": "business",
      "successCriteria": ["The public endpoints follow a documented contract"]
    }
  ],
  "requirements": [
    {
      "id": "req-create",
      "title": "Create a todo",
      "description": "Clients can create a todo with a title.",
      "type": "functional",
      "acceptanceCriteria": [
        {
          "id": "ac-create",
          "given": "a valid todo payload",
          "when": "the client POSTs to /todos",
          "then": "the todo is stored and returned with a generated id",
          "order": 1
        }
      ]
    },
    {
      "id": "req-list",
      "title": "List todos",
      "description": "Clients can retrieve all todos.",
      "type": "functional",
      "acceptanceCriteria": [
        {
          "id": "ac-list",
          "given": "stored todos exist",
          "when": "the client GETs /todos",
          "then": "all todos are returned in creation order",
          "order": 1
        }
      ]
    },
    {
      "id": "req-validate",
      "title": "Reject invalid input",
      "description": "Malformed payloads are rejected clearly.",
      "type": "business-rule",
      "acceptanceCriteria": [
        {
          "id": "ac-validate",
          "given": "a payload without a title",
          "when": "the client POSTs to /todos",
          "then": "the request is rejected with a 400",
          "order": 1
        }
      ]
    },
    {
      "id": "req-complete",
      "title": "Complete a todo",
      "description": "Clients can mark a todo as completed.",
      "type": "functional",
      "acceptanceCriteria": [
        {
          "id": "ac-complete",
          "given": "an existing todo",
          "when": "the client PATCHes /todos/:id",
          "then": "the todo is marked completed and returned",
          "order": 1
        }
      ]
    },
    {
      "id": "req-delete",
      "title": "Delete a todo",
      "description": "Clients can delete a todo.",
      "type": "functional",
      "acceptanceCriteria": [
        {
          "id": "ac-delete",
          "given": "an existing todo",
          "when": "the client DELETEs /todos/:id",
          "then": "the todo is removed and a 204 is returned",
          "order": 1
        }
      ]
    }
  ],
  "architecture": "A stateless HTTP service backed by a relational database, exposing a small REST API for todos.",
  "scope": {
    "inScope": ["Creating todos", "Listing todos", "Completing todos", "Deleting todos", "Input validation"],
    "outOfScope": ["Authentication and multi-user accounts"]
  },
  "techStack": [],
  "folderStructures": [
    {
      "id": "fs-service",
      "scope": "service",
      "content": "src/\n routes/todos.ts\n db/index.ts\n server.ts"
    }
  ],
  "acceptanceCriteria": [],
  "nonFunctionalRequirements": [
    {
      "id": "nfr-durable",
      "title": "Durability",
      "description": "Todos must survive a service restart.",
      "type": "reliability"
    }
  ],
  "guardrails": [],
  "epics": [
    {
      "id": "epic-core",
      "title": "Core Todo CRUD",
      "description": "Implement the core CRUD operations for todos.",
      "tickets": [
        {
          "id": "ticket-create-todo",
          "epicId": "epic-core",
          "title": "Implement POST /todos",
          "description": "Create a todo. Validate the title is non-empty. Return 201 with the created resource.",
          "ticketType": "implementation",
          "complexity": "small",
          "estimatedMinutes": 90,
          "acceptanceCriteria": [
            {
              "id": "ac-create-201",
              "given": "a payload with a title",
              "when": "POST /todos is called",
              "then": "a 201 is returned with the created todo",
              "order": 1
            },
            {
              "id": "ac-create-400",
              "given": "a payload without a title",
              "when": "POST /todos is called",
              "then": "a 400 is returned with an error envelope",
              "order": 2
            }
          ],
          "implementationSteps": [
            { "id": "step-1", "text": "Add the POST /todos route handler", "order": 1 },
            { "id": "step-2", "text": "Validate the payload and persist the todo", "order": 2 }
          ],
          "filesToBeCreated": ["src/routes/todos.ts"],
          "blueprintReferences": [
            { "blueprintId": "bp-api-contract", "context": "Create path" }
          ],
          "dependencies": []
        },
        {
          "id": "ticket-list-todos",
          "epicId": "epic-core",
          "title": "Implement GET /todos",
          "description": "List all todos in creation order.",
          "ticketType": "implementation",
          "complexity": "small",
          "estimatedMinutes": 60,
          "acceptanceCriteria": [
            {
              "id": "ac-list-200",
              "given": "stored todos exist",
              "when": "GET /todos is called",
              "then": "a 200 is returned with all todos in creation order",
              "order": 1
            }
          ],
          "implementationSteps": [
            { "id": "step-1", "text": "Add the GET /todos route handler", "order": 1 },
            { "id": "step-2", "text": "Query and return all todos in creation order", "order": 2 }
          ],
          "filesToBeCreated": ["src/routes/todos.ts"],
          "blueprintReferences": [
            { "blueprintId": "bp-api-contract", "context": "List path" }
          ],
          "dependencies": [
            { "ticketId": "ticket-create-todo", "type": "requires" }
          ]
        },
        {
          "id": "ticket-complete-todo",
          "epicId": "epic-core",
          "title": "Implement PATCH /todos/:id",
          "description": "Mark a todo as completed.",
          "ticketType": "implementation",
          "complexity": "small",
          "estimatedMinutes": 60,
          "acceptanceCriteria": [
            {
              "id": "ac-complete-200",
              "given": "an existing todo",
              "when": "PATCH /todos/:id is called",
              "then": "a 200 is returned with the completed todo",
              "order": 1
            }
          ],
          "implementationSteps": [
            { "id": "step-1", "text": "Add the PATCH /todos/:id route handler", "order": 1 },
            { "id": "step-2", "text": "Mark the todo completed and persist", "order": 2 }
          ],
          "filesToBeCreated": ["src/routes/todos.ts"],
          "blueprintReferences": [
            { "blueprintId": "bp-api-contract", "context": "Complete path" }
          ],
          "dependencies": [
            { "ticketId": "ticket-create-todo", "type": "requires" }
          ]
        },
        {
          "id": "ticket-delete-todo",
          "epicId": "epic-core",
          "title": "Implement DELETE /todos/:id",
          "description": "Delete a todo.",
          "ticketType": "implementation",
          "complexity": "small",
          "estimatedMinutes": 45,
          "acceptanceCriteria": [
            {
              "id": "ac-delete-204",
              "given": "an existing todo",
              "when": "DELETE /todos/:id is called",
              "then": "a 204 is returned and the todo is removed",
              "order": 1
            }
          ],
          "implementationSteps": [
            { "id": "step-1", "text": "Add the DELETE /todos/:id route handler", "order": 1 },
            { "id": "step-2", "text": "Remove the todo and return 204", "order": 2 }
          ],
          "filesToBeCreated": ["src/routes/todos.ts"],
          "blueprintReferences": [
            { "blueprintId": "bp-api-contract", "context": "Delete path" }
          ],
          "dependencies": [
            { "ticketId": "ticket-create-todo", "type": "requires" }
          ]
        }
      ]
    }
  ],
  "blueprints": [
    {
      "id": "bp-db-schema",
      "title": "Database schema",
      "category": "erd",
      "format": "mermaid",
      "content": "erDiagram\n TODO {\n  uuid id PK\n  string title\n  bool completed\n }"
    },
    {
      "id": "bp-api-contract",
      "title": "API contract",
      "category": "api",
      "format": "markdown",
      "content": "GET /todos -> 200 [Todo]\nPOST /todos -> 201 Todo\nPATCH /todos/:id -> 200 Todo\nDELETE /todos/:id -> 204"
    }
  ]
}
```

---

# Guía Paso a Paso — Proyecto Todo API

> **Objetivo:** recorrer el proyecto final con instrucciones concretas, de la idea al archivo.

---

## Paso 0 — Preparación

Asegúrate de tener:
- Node.js 20.19.0+ y el CLI de OpenSpec instalado (`openspec --version`).
- Un proyecto con OpenSpec inicializado (`openspec init`).

```bash
mkdir -p ~/todo-api && cd ~/todo-api
git init
openspec init
```

---

## Paso 1 — Explora (opcional)

En el chat de tu agente:

```
/openspec-explore how a todo API should be structured in this project
```

Deja que el agente lea el (posiblemente vacío) codebase y plantee opciones de estructura,
stack y persistencia. No debe escribir código.

---

## Paso 2 — Propón

```
/openspec-propose build a todo API
```

El agente creará `openspec/changes/<nombre>/` con:
- `proposal.md` — por qué y qué cambia.
- `specs/` — requisitos con escenarios.
- `design.md` — decisiones técnicas (stack, base de datos).
- `tasks.md` — checklist de implementación.

> 💡 **Tip:** si prefieres partir de una spec v1.1 ya escrita, usa
> `01-spec-todo-api.oschema.json` como referencia y pídele al agente que la use como base.

---

## Paso 3 — Revisa y corrige el plan

Lee en orden:
1. `proposal.md` — ¿problema correcto, tamaño correcto?
2. `specs/` — ¿aceptarías estos requisitos como "hecho"?
3. `tasks.md` — ¿cubren las specs y nada más?

Corrige lo que haga falta (edita los archivos o dile al agente qué está mal). Asegúrate de que
los requisitos cubran: crear, listar, validar, completar y eliminar todos.

---

## Paso 4 — Aplica

Empieza una **sesión de chat nueva** (contexto limpio):

```
/openspec-apply-change <nombre-del-change>
```

El agente implementa las tareas y marca los checkboxes de `tasks.md`. Si se interrumpe, abre
otra sesión y pide aplicar de nuevo: reanuda en la primera tarea sin marcar.

---

## Paso 5 — Valida

```bash
openspec validate --all
openspec view
```

Revisa los "archive merge findings" (conflictos de merge potenciales). Corrige cualquier
problema estructural antes de archivar.

---

## Paso 6 — Archiva

Cuando cada checkbox de `tasks.md` esté marcado:

```
/openspec-archive-change <nombre-del-change>
```

Archivar fusiona los deltas en `specs/` y mueve la carpeta a `changes/archive/` con fecha.

---

## Paso 7 — Verifica

```bash
openspec list --specs
openspec view
```

Deberías ver la spec de la Todo API con sus requisitos, y el change archivado.

---

## Paso 8 — Prueba la API

Levanta el servicio y prueba los endpoints:

```bash
# Crear
curl -X POST http://localhost:3000/todos -H 'Content-Type: application/json' -d '{"title":"Comprar leche"}'
# Listar
curl http://localhost:3000/todos
# Completar
curl -X PATCH http://localhost:3000/todos/<id> -H 'Content-Type: application/json' -d '{"completed":true}'
# Eliminar
curl -X DELETE http://localhost:3000/todos/<id>
# Input inválido (debe dar 400)
curl -X POST http://localhost:3000/todos -H 'Content-Type: application/json' -d '{}'
```

---

## Criterios de éxito

- [ ] La spec v1.1 es válida y tiene todos los campos obligatorios.
- [ ] Los requirements tienen `acceptanceCriteria` Given/When/Then.
- [ ] Hay al menos un epic con tickets y dependencias declaradas.
- [ ] El change pasó por propose → apply → archive.
- [ ] `openspec validate --all` pasa sin findings críticos.
- [ ] La API implementada cumple los requisitos funcionales y no funcionales.

---

## 🎉 ¡Felicidades!

Completaste el curso de OpenSpec. Ahora sabes cómo **acordar primero y construir con confianza**:
especificar, planificar, implementar y archivar cambios de forma predecible con tu agente de IA.

**Siguiente paso:** aplica OpenSpec a un proyecto real. Empieza con un cambio pequeño y de bajo
riesgo para afianzar el flujo.

---

*Curso generado con información oficial de OpenSpec (v1.11.0). Verifica siempre la versión
actual con `openspec --version`.*