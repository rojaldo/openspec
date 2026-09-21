# 🦞 Curso: OpenClaw Avanzado — De Usuario a Power User (Contenido completo)

> **Material didáctico completo del curso.** Incluye la introducción y los 8 módulos en un solo archivo.

---


<!-- ================================================ -->
<!-- ARCHIVO: 00-introduccion.md -->
<!-- ================================================ -->

# Introducción: Cómo usar este curso

> **Bienvenido/a al curso OpenClaw Avanzado — De Usuario a Power User.** Este es el material didáctico que desarrolla el temario. Léelo en orden: cada módulo se apoya en el anterior.

## Cómo está organizado

El contenido está dividido en archivos (uno por módulo) dentro de esta carpeta:

```
cursos/openclaw-avanzado/
├── README.md                  ← este índice
├── 00-introduccion.md         ← guía de uso y requisitos (este archivo)
├── 01-fundamentos-gateway.md  ← Módulo 1
├── 02-tools-personalizadas.md ← Módulo 2
├── 03-agentes-multiples.md    ← Módulo 3
├── 04-cron-avanzado.md        ← Módulo 4
├── 05-mcp.md                  ← Módulo 5
├── 06-rag-vectores.md         ← Módulo 6
├── 07-docker.md               ← Módulo 7
└── 08-proyecto-final.md       ← Módulo 8 (evaluación)
```

## Formato de cada módulo

Cada archivo de módulo sigue la misma estructura didáctica:

1. **Objetivos** — qué vas a saber hacer al terminar.
2. **Conceptos** — la teoría explicada con **analogías** del mundo real.
3. **Ejemplos prácticos** — bloques de código y comandos que puedes probar.
4. **Errores comunes** — trampas típicas y cómo evitarlas.
5. **Ejercicios** — tareas para afianzar (marcadas como casillas `[ ]`).
6. **Resumen** — lo esencial en pocas líneas.

## Requisitos antes de empezar

- **Node.js** 24.15+ (recomendado) o 22.22.3+.
- **OpenClaw instalado y funcionando** (`npm install -g openclaw@latest`).
- Un **gateway corriendo**: `openclaw onboard --install-daemon` (o al menos `openclaw status` para comprobarlo).
- Acceso a un **CLI** (terminal) y a un editor de texto.
- Conocimientos básicos de **Markdown** y de la **terminal**.

> 💡 **Tip de estudio:** no leas pasivamente. Cada vez que veas un bloque de código, cópialo y pruébalo en tu máquina. Este curso se aprende *haciendo*.

---

## El hilo conductor: una metáfora

Durante todo el curso usaremos una **analogía central** para que los conceptos se te queden:

> **OpenClaw es como una central de mensajería (Gateway) conectada a una oficina de asistentes (agentes).**
> - El **Gateway** es el edificio: recibe cartas (mensajes) de todos los canales y las reparte.
> - Cada **agente** es un empleado con su propio escritorio (workspace) y su propio archivador (memoria).
> - Las **tools/skills** son las herramientas que cada empleado tiene en su cajón.
> - El **cron** es el encargado que pone alarmas y hace tareas a horas fijas.
> - El **MCP** es el teléfono para pedir favores a servicios externos.
> - La **memoria vectorial (RAG)** es el archivo inteligente que encuentra papeles por *significado*, no solo por palabra.
> - **Docker** es el contenedor donde metes toda la oficina para mudarla a cualquier máquina.

A lo largo de los módulos volveremos a esta metáfora. Si en algún momento te pierdes, recuerda el edificio, los empleados y sus cajones. 🏢👔

---

## Glosario rápido

| Término | Qué es (en una línea) |
|---|---|
| **Gateway** | El proceso central de OpenClaw que conecta canales, agentes y herramientas. |
| **Workspace** | La carpeta "hogar" del agente, donde vive y crea archivos. |
| **Sesión** | Una conversación/contexto entre un usuario y un agente. |
| **Tool** | Una capacidad que el agente puede invocar (leer archivos, ejecutar comandos…). |
| **Skill** | Un paquete de instrucciones (con `SKILL.md`) que le enseña al agente a hacer algo. |
| **Cron** | El programador de tareas automáticas del gateway. |
| **MCP** | Model Context Protocol: estándar para conectar herramientas/servicios externos. |
| **Embedding** | Vector numérico que representa el *significado* de un texto. |
| **RAG** | Recuperación aumentada: dar contexto relevante al modelo desde una base. |
| **Docker** | Contenedores para empaquetar y desplegar aplicaciones reproducibles. |

---

*Siguiente: [Módulo 1 — Fundamentos avanzados del gateway](01-fundamentos-gateway.md)*


<!-- ================================================ -->
<!-- ARCHIVO: 01-fundamentos-gateway.md -->
<!-- ================================================ -->

# Módulo 1: Fundamentos avanzados del gateway y la arquitectura

> **Duración:** 1.5 h · **Objetivo:** explicar la arquitectura de OpenClaw y diagnosticar el gateway como operador.

## Objetivos de aprendizaje

Al terminar este módulo podrás:
- Explicar cómo encajan Gateway, agente, workspace, sesiones y canales.
- Leer y modificar `~/.openclaw/openclaw.json` con seguridad.
- Configurar cadenas de fallback de modelos.
- Diagnosticar el gateway (`status`, `doctor`, `logs`).
- Aplicar medidas básicas de seguridad.

---

## 1.1 Arquitectura: el edificio y sus empleados

Recuerda la metáfora: **OpenClaw es una central de mensajería con una oficina de asistentes.**

```
     ┌─────────────────────────────────────────────┐
     │                 GATEWAY                      │
     │   (el edificio / proceso central)            │
     │                                              │
     │   Canales →  Telegram, Discord, Slack,       │
     │               WhatsApp, WebChat, Signal…     │
     │                    │                         │
     │                    ▼                         │
     │   Agentes →  [agente A] [agente B] [agente C]│
     │                 │         │         │        │
     │              workspace  workspace workspace  │
     │              (escritorio propio)             │
     └─────────────────────────────────────────────┘
```

**Piezas clave:**

- **Gateway:** el proceso que corre todo. Es la *única* fuente de verdad para sesiones, rutas y conexiones. Si no corre, nada funciona.
- **Agente (agent runtime):** el "empleado" que usa modelos de IA y herramientas. OpenClaw trae un agente por defecto; puedes definir varios.
- **Workspace:** la carpeta privada de cada agente (`~/.openclaw/workspace` por defecto). Es su escritorio y su memoria. No es un sandbox duro: usa rutas absolutas con cuidado.
- **Sesión:** una conversación con contexto. Cada canal/remitente puede tener su propia sesión.
- **Canal:** la vía de entrada/salida (Telegram, Discord, etc.).

> 💡 **Analogía:** el Gateway es el *interruptor general de luz*. Si lo apagas, toda la oficina se queda a oscuras, sin importar cuántos empleados tengas.

### ¿Dónde está cada cosa?

| Qué | Dónde vive |
|---|---|
| Configuración | `~/.openclaw/openclaw.json` |
| Workspace (hogar del agente) | `~/.openclaw/workspace` |
| Credenciales (API keys, OAuth) | `~/.openclaw/credentials/` y perfiles de auth |
| Sesiones (transcripciones) | `~/.openclaw/agents/<agentId>/sessions/` |
| Config por agente | `~/.openclaw/agents/<agentId>/agent/` |

> ⚠️ **No guardes secretos en el workspace.** API keys y tokens van en `~/.openclaw/` (o variables de entorno), nunca en archivos del workspace ni en git.

---

## 1.2 Configuración profunda: `openclaw.json`

El archivo de configuración es JSON (con soporte de comentarios estilo JSON5). Veamos las secciones que te interesan como power user:

```json5
{
  // Agentes
  agents: {
    defaults: {
      workspace: "~/.openclaw/workspace",
      // sandbox: { enabled: true, ... },   // aislamiento opcional
    },
    list: [
      { id: "soporte", workspace: "~/.openclaw/workspace-soporte" }
    ],
  },

  // Canales
  channels: {
    telegram: { /* token, allowFrom, ... */ },
    whatsapp: { allowFrom: ["+15555550123"] },
  },

  // Mensajes y grupos
  messages: {
    groupChat: { mentionPatterns: ["@openclaw"] },
  },
}
```

**Puntos clave:**
- `agents.defaults.workspace` fija el escritorio del agente por defecto.
- `agents.list[]` define agentes extra, cada uno con su propio workspace.
- `channels.*.allowFrom` restringe quién puede escribir (allowlist).
- El sandboxing (`agents.defaults.sandbox`) aísla las operaciones del agente si lo necesitas.

> 💡 **Analogía:** `openclaw.json` es el *organigrama y el reglamento de la oficina*: quién trabaja dónde y quién tiene llaves de qué puertas.

---

## 1.3 Modelos y fallbacks: no te quedes a oscuras

Un **fallback** es un plan B: si el modelo principal falla (error, límite, caída), el agente prueba el siguiente. Es como tener un segundo empleado entrenado para el mismo puesto.

**Configurar en `openclaw.json`:**

```json5
{
  agents: {
    defaults: {
      model: "anthropic/claude-sonnet-4-5",
      fallbacks: [
        "openai/gpt-4o",
        "openrouter/meta-llama/llama-3.3-70b-instruct:free",
      ],
    },
  },
}
```

**Override por sesión:** puedes cambiar el modelo de una sesión concreta desde el chat (slash command `/model`) o por config, sin tocar el default global. Útil para probar un modelo caro solo en una tarea puntual.

> 💡 **Tip:** elige como fallback modelos *diferentes* en proveedor, para que una caída de un proveedor no tire todo el stack.

---

## 1.4 Diagnóstico: ser el técnico de la oficina

Cuando algo falla, estos comandos son tu linterna:

```bash
openclaw status                # estado general del gateway
openclaw gateway status        # estado específico del gateway
openclaw doctor                # diagnóstico profundo + arreglos
openclaw logs --follow         # ver logs en vivo
```

**Flujo recomendado de resolución de problemas (la "escalera"):**

```bash
openclaw status
openclaw gateway status
openclaw cron status           # si el problema es de tareas programadas
openclaw logs --follow         # mira el error real
openclaw doctor                # deja que diagnostique y proponga arreglos
```

> 💡 **Analogía:** estos comandos son el *fontanero, el electricista y el inspector* de tu edificio. Cuando algo huele raro, primero llamas al inspector (`doctor`), luego ves las tuberías (`logs`).

**Ejercicio guiado:**
```bash
openclaw status
# ¿Ves "Gateway running"? Bien. ¿Hay errores? Anótalos.
openclaw doctor
# Ejecuta los arreglos que proponga si son seguros.
```

---

## 1.5 Seguridad básica: las llaves de la oficina

Como power user, debes controlar el acceso:

- **Tokens y API keys:** van en `~/.openclaw/` (o variables de entorno), nunca en git ni en el workspace.
- **Allowlists:** `channels.<canal>.allowFrom` limita quién puede escribirte. Para grupos, usa `mentionPatterns` (que solo responda si mencionan a tu agente).
- **Permisos de herramientas:** la policy de `tools.exec` (modo, aprobaciones, allowlists por agente) controla qué comandos puede correr el agente. Revisa `tools.exec.mode` y `tools.exec.allow` si quieres restringir.
- **Sandboxing:** `agents.defaults.sandbox` aísla las operaciones del agente del resto del host. Habilítalo en entornos multi-tenant o de alto riesgo.

> ⚠️ **Regla de oro de seguridad:** *menos privilegios, siempre.* Dale al agente solo las herramientas y accesos que necesita para su tarea. Si algo no se usa, se desactiva.

---

## Errores comunes

1. **"No responde nada":** el Gateway está caído. `openclaw status` → reinicia con `openclaw gateway restart`.
2. **Confundir workspace con config:** editar `openclaw.json` cuando querías editar un archivo del workspace (o viceversa).
3. **Guardar secrets en el workspace:** nunca. Usa `~/.openclaw/` o variables de entorno.
4. **Sin fallbacks:** un solo modelo = punto único de fallo. Configura cadenas.

---

## Ejercicios

- [ ] Ejecuta `openclaw status` y `openclaw doctor`. Resuelve al menos un warning.
- [ ] Abre `~/.openclaw/openclaw.json` y localiza: `agents`, `channels`, `tools`. Anota qué hace cada bloque.
- [ ] Configura una cadena de fallbacks de 2 modelos distintos (o pídeselo al agente).
- [ ] Identifica en tu setup qué canales están conectados y qué allowlists tienen.

---

## Resumen

- El **Gateway** es el proceso central; sin él, nada corre.
- El **workspace** es el hogar privado del agente (no es un sandbox duro).
- **`openclaw.json`** es el organigrama: agentes, canales, permisos, modelos.
- **Fallbacks** de modelo = resiliencia (plan B).
- **Diagnóstico:** `status` → `logs` → `doctor`.
- **Seguridad:** menos privilegios, allowlists, sin secrets en el workspace.

---

*Siguiente: [Módulo 2 — Creación de funciones (tools) personalizadas](02-tools-personalizadas.md)*


<!-- ================================================ -->
<!-- ARCHIVO: 02-tools-personalizadas.md -->
<!-- ================================================ -->

# Módulo 2: Creación de funciones (tools) personalizadas

> **Duración:** 2.5 h · **Objetivo:** diseñar, implementar y probar tools propias que el agente pueda invocar.

## Objetivos de aprendizaje

Al terminar este módulo podrás:
- Explicar qué es una tool y cómo el agente la descubre.
- Crear **skills** del workspace (`SKILL.md`) con frontmatter y gating.
- Construir tools combinando `exec`, `apply_patch`, `web_fetch` y scripts propios.
- Seguir buenas prácticas de seguridad y calidad.
- Probar con `openclaw agent --message` y publicar en ClawHub.

---

## 2.1 ¿Qué es una tool y cómo la invoca el agente?

Una **tool** es una *capacidad* que el agente puede usar: leer archivos, ejecutar comandos, buscar en la web, etc. El modelo de IA no ejecuta código directamente: **pide** usar una tool, y OpenClaw la ejecuta y le devuelve el resultado.

> 💡 **Analogía:** el agente es un empleado con un cajón de herramientas. No sabe soldar por sí mismo, pero *sabe cuándo* pedir el soldador y *cómo* usarlo. Las tools son ese cajón.

**El ciclo de una tool:**

1. El modelo ve la lista de tools disponibles (sus descripciones).
2. Decide que necesita una y la invoca con argumentos.
3. OpenClaw ejecuta la tool.
4. El resultado vuelve al modelo, que lo usa para responder.

**Por eso la descripción importa muchísimo:** el modelo "elige" la tool correcta leyendo su descripción. Una descripción vaga = el agente no sabe cuándo usarla.

---

## 2.2 Skills del workspace: el `SKILL.md`

Una **skill** es la forma principal de añadir capacidades/instrucciones al agente. Es una carpeta con un archivo `SKILL.md` (frontmatter YAML + instrucciones en Markdown). Se guardan en `skills/` del workspace.

```
skills/
└── mi-skill/
    └── SKILL.md
```

### Estructura de `SKILL.md`

```markdown
---
name: mi-skill
description: Crea informes semanales en Markdown con métricas.
---

# Mi skill

Cuando el usuario pida un informe semanal:
1. Lee los datos de `data/`.
2. Genera un resumen con métricas.
3. Guárdalo en `informes/YYYY-MM-DD.md`.
```

**Campos del frontmatter:**

| Campo | Obligatorio | Qué hace |
|---|---|---|
| `name` | ✅ | Slug en minúsculas, dígitos y guiones. Debe coincidir con la carpeta. |
| `description` | ✅ | Una línea (<160 caracteres) que el agente usa para saber cuándo aplica. |
| `user-invocable` | No | Si el usuario puede lanzarlo con `/skill`. Por defecto `true`. |
| `disable-model-invocation` | No | Si `true`, el agente NO lo auto-invoca (solo `/skill`). |
| `command-dispatch` | No | Enruta el comando directamente a una tool, sin pasar por el modelo. |

### Gating: que la skill solo cargue si hay requisitos

Puedes hacer que una skill solo se active si hay ciertas condiciones:

```markdown
---
name: gemini-search
description: Busca en la web usando Gemini CLI.
metadata:
  openclaw:
    requires:
      bins: ["gemini"]            # necesita el binario 'gemini' en PATH
      env: ["GEMINI_API_KEY"]     # necesita esa variable de entorno
---
```

> 💡 Si la skill no cumple los requisitos, OpenClaw no la inyecta en el prompt del agente. Ahorra contexto y evita errores.

### Referencias con `{baseDir}`

Para no hardcodear rutas, usa `{baseDir}`, que el agente resuelve contra la carpeta de la skill:

```markdown
Ejecuta el script de ayuda en `{baseDir}/scripts/run.sh`.
```

---

## 2.3 Construir tools: `exec`, `apply_patch`, `web_fetch` y scripts

Una skill "dirige" al agente para que use las tools base. Las tools base más útiles para tu cajón:

### `exec` — ejecutar comandos
```markdown
# Skill: backup
Cuando el usuario pida hacer un backup:
1. Ejecuta: `tar -czf backups/temario-$(date +%F).tar.gz cursos/`
2. Confirma el archivo creado con `ls -la backups/`
```

### `apply_patch` — editar varios archivos de forma estructurada
`apply_patch` aplica cambios a uno o varios archivos en una sola operación (añadir, actualizar, borrar, renombrar). Ideal para editar el temario sin romper el resto:

```text
*** Begin Patch
*** Add File: cursos/mi-curso/02-tools.md
+# Tools personalizadas
+Contenido del módulo 2...
*** Update File: cursos/mi-curso/temario.md
@@
-| 2 | Herramientas | 1 semana |
+| 2 | Herramientas | 2 semanas |
*** End Patch
```

> 💡 `apply_patch` por defecto solo escribe **dentro del workspace** (`workspaceOnly: true`). Es una protección por defecto.

### `web_fetch` — traer contenido de una URL
```markdown
# Skill: resumir-doc
Cuando el usuario pida resumir una URL:
1. Haz `web_fetch` de la URL.
2. Resume los puntos clave en 5 bullets.
```

### Combinando todo en una skill real

Crea `skills/crear-temario/SKILL.md`:

```markdown
---
name: crear-temario
description: Crea el temario de un curso en Markdown con formato estándar.
---

# Crear temario

Cuando el usuario pida crear el temario de un curso:
1. Pregunta por: tema, nivel, duración y objetivo final.
2. Genera el índice con módulos y unidades.
3. Guárdalo en `cursos/<nombre>/temario.md` con `apply_patch`.
4. Usa la plantilla: tabla de contenidos + objetivos + evaluación.
```

> 💡 **Tip:** las skills no deben explicar "cómo ser una IA". Deben decir *qué hacer* con las tools, de forma concisa.

---

## 2.4 Buenas prácticas: seguridad y calidad

1. **Prompts concisos:** la skill instruye *qué* hacer, no diserta.
2. **Control de comandos:** si usas `exec`, no permitas inyección de comandos desde entrada no confiable. Valida/sanitiza argumentos.
3. **Menos privilegios:** la skill solo usa las tools necesarias.
4. **Un archivo por módulo:** temarios en archivos separados = más fácil revisar y reutilizar.
5. **Prueba antes de publicar:** `openclaw agent --message "..."`.

---

## 2.5 Probando tus tools

```bash
# Desde la terminal
openclaw agent --message "crea el temario de un curso de Python"

# O verifica que la skill cargó
openclaw skills list
```

Si creaste una skill en medio de una sesión, el agente puede no verla aún. Haz `/new` (sesión nueva) o reinicia el gateway:

```bash
openclaw gateway restart
```

En el chat, puedes invocar la skill explícitamente con `/skill <nombre>`.

> ⚠️ **Gotcha:** el agente solo "ve" las skills que estaban cargadas al inicio de su sesión. Cambios a mitad de sesión requieren sesión nueva o reinicio.

---

## 2.6 Publicar en ClawHub

ClawHub es el registro público de skills de la comunidad. Publicar la tuya:

```bash
npm i -g clawhub
clawhub login
clawhub skill publish ./skills/mi-skill
```

> 💡 **Antes de construir desde cero, busca en [clawhub.ai](https://clawhub.ai)** — quizá ya existe la skill que necesitas. Reutilizar > reinventar.

---

## Errores comunes

1. **`name` con mayúsculas o espacios:** OpenClaw no la carga. Usa minúsculas + guiones.
2. **`description` muy larga:** debe ser una línea <160 caracteres.
3. **Carpeta y `name` distintos:** deben coincidir.
4. **Skill no visible tras crearla:** falta `/new` o reiniciar el gateway.
5. **Inyección de comandos:** nunca interpoles input no confiable en `exec` sin validar.

---

## Ejercicios

- [ ] Crea una skill `resumir-url` que use `web_fetch` y devuelva un resumen en 5 bullets.
- [ ] Crea una skill `backup-temario` que use `exec` para comprimir tu carpeta de cursos.
- [ ] Prueba ambas con `openclaw agent --message "..."`.
- [ ] (Opcional) Publica una en ClawHub.

---

## Resumen

- Las **tools** son el cajón de herramientas del agente; el modelo decide cuándo usarlas según sus **descripciones**.
- Un **skill** = carpeta + `SKILL.md` (frontmatter + instrucciones).
- El **gating** hace que las skills solo carguen si hay requisitos.
- `exec`, `apply_patch` y `web_fetch` son los ladrillos; los scripts propios los extienden.
- **Prueba siempre** y reinicia/`/new` tras crear skills.
- **ClawHub** para compartir y reutilizar.

---

*Siguiente: [Módulo 3 — Agentes múltiples y rutas de sesión](03-agentes-multiples.md)*


<!-- ================================================ -->
<!-- ARCHIVO: 03-agentes-multiples.md -->
<!-- ================================================ -->

# Módulo 3: Agentes múltiples y rutas de sesión

> **Duración:** 2.0 h · **Objetivo:** configurar varios agentes con workspaces y sesiones aisladas, y enrutar tráfico entre ellos.

## Objetivos de aprendizaje

Al terminar este módulo podrás:
- Configurar múltiples agentes con workspaces aislados.
- Entender la diferencia entre sesiones main, aisladas y persistentes.
- Delegar tareas a subagentes (`sessions_spawn`, `sessions_send`).
- Enrutar canales y remitentes a agentes concretos.
- Coordinar agentes en flujos reales.

---

## 3.1 Multi-agente: cada empleado, su propio escritorio

En la metáfora, cada agente es un **empleado con su propio escritorio (workspace)** y su propio archivador (memoria). Esto evita que un proyecto "ensucie" el contexto de otro.

**Configurar un agente extra en `openclaw.json`:**

```json5
{
  agents: {
    defaults: {
      workspace: "~/.openclaw/workspace",
    },
    list: [
      {
        id: "soporte",
        workspace: "~/.openclaw/workspace-soporte",
      },
      {
        id: "editor",
        workspace: "~/.openclaw/workspace-editor",
      },
    ],
  },
}
```

> 💡 Cada agente con `workspace` propio = **aislamiento de contexto**. El agente "editor" no ve (ni toca) los archivos del agente "soporte".

**¿Por qué separar agentes?**
- Diferentes dominios (soporte vs. edición de contenido).
- Diferentes niveles de permisos o modelos.
- Evitar que un flujo grande contamine el contexto de otro.

> ⚠️ El workspace por defecto (`~/.openclaw/workspace`) es compartido si no defines `workspace` por agente. Define uno explícito si quieres aislamiento real.

---

## 3.2 Sesiones: main, aisladas y persistentes

Una **sesión** es un contexto conversacional. OpenClaw maneja varios tipos:

| Tipo | Qué es | Cuándo usarlo |
|---|---|---|
| **Main** | La sesión principal del agente (DMs) | Conversaciones normales contigo |
| **Aislada** | Contexto fresco, sin historial previo | Tareas puntuales que no deben contaminar |
| **Persistente** | Sesión nombrada que acumula historial | Flujos que construyen sobre resúmenes previos |
| **Por canal/grupo** | Cada grupo de chat tiene su sesión | Separar contextos por grupo |

> 💡 **Analogía:** la sesión main es tu escritorio habitual; una sesión aislada es un *cuarto de trabajo desechable* donde el empleado entra, hace su tarea y se va sin dejar papeles; una persistente es un *proyecto en curso* que retoma donde lo dejó.

**En la práctica:** cuando creas un subagente o un job de cron aislado, trabajas en una sesión aislada. Cuando quieres que un flujo recurrente "recuerde" lo anterior, usas una persistente (`session:<id>`).

---

## 3.3 Subagentes y delegación: `sessions_spawn` y `sessions_send`

Un **subagente** es un agente hijo que lanzas para una tarea concreta, con su propio contexto limpio. Es como enviar a un becario a investigar en una sala aparte: no interrumpe tu mesa de trabajo.

**Lanzar un subagente (`sessions_spawn`):**

```text
sessions_spawn(
  task: "Investiga y resume la doc oficial sobre MCP en OpenClaw.
         Devuelve un resumen de 10 líneas con los pasos de configuración.",
  taskName: "investigador-mcp",
  mode: "run"        // one-shot: corre y termina
)
```

**Resultado:** un agente hijo hace la tarea y devuelve el resultado. Tú sigues con tu contexto intacto.

**Comunicar entre sesiones (`sessions_send`):**

```text
sessions_send(
  sessionKey: "<sesión destino>",
  message: "¿Terminaste el resumen de MCP?"
)
```

> 💡 **Tip de orquestación:** delega tareas largas, paralelas o de lectura masiva a subagentes; así no llenas tu contexto principal. Usa `sessions_yield` para esperar resultados sin bloquear.

**Cuándo delegar:**
- Lectura/análisis de muchos archivos.
- Búsquedas web múltiples.
- Tareas que generan mucho texto intermedio.

**Cuándo NO delegar:**
- Consultas rápidas o de una sola lectura (sobrecarga innecesaria).

---

## 3.4 Enrutamiento por canal y por remitente

Puedes decidir **qué agente responde en qué canal** y a qué remitentes.

```json5
{
  channels: {
    telegram: {
      allowFrom: ["+15555550123"],       // solo este remitente
      agents: { "*": "soporte" },         // todo Telegram → agente 'soporte'
    },
    slack: {
      agents: { "*": "editor" },          // todo Slack → agente 'editor'
    },
  },
}
```

> 💡 **Analogía:** es la *recepción de la oficina*. Las cartas de Telegram van al empleado de soporte; las de Slack, al de edición.

**Menciones en grupos:** para que el agente solo responda cuando lo mencionan en grupos:

```json5
{
  messages: {
    groupChat: { mentionPatterns: ["@soporte", "@openclaw"] },
  },
}
```

---

## 3.5 Coordinación entre agentes: casos reales

**Caso 1 — Pipeline de contenido:**
1. Agente **investigador** busca fuentes sobre un tema (subagente aislado).
2. Agente **editor** recibe el resumen y redacta el temario.
3. Agente **revisor** hace control de calidad.

**Caso 2 — Soporte escalado:**
- Agente **soporte** en Telegram (consultas de clientes).
- Agente **dev** en Slack (preguntas técnicas del equipo).
- Aislamiento total de workspaces y memoria.

**Caso 3 — Reportero automático:**
- Un job de cron aislado recolecta métricas.
- Envía el resumen al agente editor para formatearlo.
- Se publica en el canal.

> 💡 La clave de la coordinación: **tareas claras y entregables explícitos** en cada `sessions_spawn`/`sessions_send`. Sin un objetivo definido, los agentes se pisan.

---

## Errores comunes

1. **No definir `workspace` por agente:** todos comparten el default → colisión de contexto.
2. **Delegar todo a subagentes:** sobrecarga. Solo tareas grandes/paralelas.
3. **No esperar resultados:** olvidar `sessions_yield` y continuar sin el resultado del hijo.
4. **Enrutamiento ambiguo:** configurar `agents` en un canal sin allowlist de remitentes → cualquiera habla con tu agente.
5. **Contexto contaminado:** usar sesión main para trabajos masivos que deberían ser aislados.

---

## Ejercicios

- [ ] Crea un segundo agente con su propio workspace (`agents.list[]`).
- [ ] Lanza un subagente con `sessions_spawn` para resumir una URL larga y recolecta el resultado.
- [ ] Enruta un canal concreto (ej. Telegram) a tu segundo agente.
- [ ] Configura `mentionPatterns` para un grupo de chat.

---

## Resumen

- **Multi-agente** = varios empleados, cada uno con su escritorio (workspace) y memoria aislada.
- **Sesiones:** main (tú), aisladas (tarea desechable), persistentes (proyecto en curso).
- **Subagentes** (`sessions_spawn`) delegan trabajo limpio; `sessions_send` comunica entre sesiones.
- **Enrutamiento** por canal/remitente decide qué agente responde dónde.
- Coordina con **objetivos claros y entregables explícitos**.

---

*Siguiente: [Módulo 4 — Automatización avanzada con cron](04-cron-avanzado.md)*


<!-- ================================================ -->
<!-- ARCHIVO: 04-cron-avanzado.md -->
<!-- ================================================ -->

# Módulo 4: Automatización avanzada con cron

> **Duración:** 2.0 h · **Objetivo:** programar jobs recurrentes y puntuales con entrega a canales o webhooks.

## Objetivos de aprendizaje

Al terminar este módulo podrás:
- Crear jobs con los 4 tipos de schedule.
- Elegir el payload correcto (system event, agent message, command).
- Enrutar jobs a la sesión adecuada (main, isolated, current, session:<id>).
- Entregar resultados por `announce`, `webhook` o `none`.
- Gestionar jobs y entender reintentos/fallos.

---

## 4.1 El scheduler: el encargado de las alarmas

**Cron** es el programador de tareas del gateway. Recuerda la metáfora: es el **empleado que pone alarmas y hace tareas a horas fijas**, incluso cuando tú no estás.

> ⚠️ **Importante:** cron corre **dentro del proceso del Gateway**. Si el Gateway está apagado, los jobs no disparan. Los jobs persisten en la base SQLite del estado, así que no se pierden al reiniciar.

### Tipos de schedule

| Tipo | Flag | Ejemplo | Uso |
|---|---|---|---|
| Puntual | `--at` | `--at "20m"` o `2027-02-01T16:00:00Z` | Recordatorio de una sola vez |
| Intervalo | `--every` | `--every 1d` | Cada X tiempo fijo |
| Expresión cron | `--cron` | `--cron "0 9 * * 1"` | Reglas complejas (5-6 campos) |
| Al salir | `--on-exit` | — | Cuando un comando termina |

> ⚠️ **Zonas horarias:** sin `--tz`, la expresión cron usa la zona del **host** del Gateway. Un `--at` sin zona se trata como **UTC**. Usa `--tz America/New_York` (IANA) para fijar zona.

**Ejemplo de expresión cron (5 campos):** `minuto hora día-mes mes día-semana`
- `0 9 * * 1` → todos los lunes a las 9:00.
- `*/15 * * * *` → cada 15 minutos.

> 💡 **Gotcha clásico:** en cron, si pones a la vez día-de-mes y día-de-semana, se interpreta con lógica **OR** (dispara si cualquiera coincide), no AND. Para exigir ambos, usa el modificador `+1` de croner (ej. `0 9 15 * +1` = día 15 Y lunes).

---

## 4.2 Tipos de payload: qué hace el job

| Payload | Flag | Qué hace | Cuándo |
|---|---|---|---|
| **System event** | `--system-event <texto>` | Inyecta texto en la sesión principal, **sin llamar al modelo** | Recordatorios simples |
| **Agent message** | `--message <texto>` | Ejecuta un turno de agente **con modelo** | Revisiones, análisis, tareas de IA |
| **Command** | `--command <shell>` | Ejecuta un script en el host, **sin modelo** | Tareas deterministas, probes |

> 💡 **Analogía:** el system event es una *nota pegada en el escritorio*; el agent message es *pedirle al empleado que haga algo*; el command es *activar una máquina automática*.

**Ejemplo: recordatorio simple (system event, sin modelo):**
```bash
openclaw cron add \
  --name "Revisar temario" \
  --at "2027-02-01T16:00:00Z" \
  --session main \
  --system-event "Recordatorio: revisa `cursos/mi-curso/temario.md`." \
  --wake now \
  --delete-after-run
```

---

## 4.3 Sesiones objetivo: dónde corre el job

| Valor | Corre en | Uso típico |
|---|---|---|
| `main` | Carril de wake de la sesión principal | Recordatorios / system events |
| `isolated` | Sesión aislada `cron:<jobId>` (contexto fresco) | Reportes, tareas que no contaminan |
| `current` | Sesión actual (ligada al crearla) | Trabajo recurrente con contexto |
| `session:<id>` | Sesión persistente con historial | Flujos que acumulan contexto entre runs |

> 💡 **Aislado = contexto fresco.** Un job aislado no hereda tu conversación actual; es ideal para tareas de "caja limpia". Un `session:<id>` persistente sí acumula historial entre ejecuciones (ej. un "standup" diario que recuerda el anterior).

---

## 4.4 Entrega: announce, webhook y none

| Modo | Qué hace |
|---|---|
| `announce` | Entrega el texto final al canal objetivo si el agente no lo envió él mismo |
| `webhook` | Hace POST del evento terminado a una URL |
| `none` | Sin entrega automática (el agente puede enviar con la tool `message`) |

**Ejemplo: revisión semanal aislada que te avisa por Slack:**
```bash
openclaw cron create "0 9 * * 1" \
  "Revisa `cursos/mi-curso/temario.md` y avísame si hay inconsistencias o mejoras." \
  --name "Revisión semanal del temario" \
  --tz "America/New_York" \
  --session isolated \
  --announce \
  --channel slack \
  --to "channel:C1234567890"
```

**Ejemplo: resumen a un webhook (integración con otra app):**
```bash
openclaw cron create "0 18 * * 1-5" \
  "Resume los cambios del día en JSON." \
  --name "Digest diario" \
  --webhook "https://mi-app.com/openclaw/cron"
```

> ⚠️ **Idioma:** los jobs de cron **no infieren idioma** del canal. Si quieres respuesta en español, díselo en el prompt: *"Responde en español; deja URLs, código y nombres de producto igual."*

---

## 4.5 Gestión: listar, ver, ejecutar, borrar

```bash
openclaw cron list                 # listar jobs
openclaw cron get <jobId>          # ver un job como JSON
openclaw cron show <jobId>         # ver job + ruta de entrega resuelta
openclaw cron enable/disable <jobId>
openclaw cron run <jobId>          # forzar ejecución ahora
openclaw cron run <jobId> --wait   # forzar y esperar resultado (útil en scripts)
openclaw cron runs --id <jobId>    # historial de ejecuciones
openclaw cron remove <jobId>       # borrar
```

**Reintentos y fallos:**
- **One-shot:** los errores transitorios (rate limit, red, timeout) reintentan hasta `retry.maxAttempts` (default 3). Un error permanente desactiva el job.
- **Recurrente:** los errores consecutivos aplican backoff (30s, 60s, 5m, 15m, 60m). Se resetea tras un éxito.
- **Alertas de fallo:** configura `--failure-alert-after <n>` para avisarte tras N fallos.

**Solución de problemas:**

```bash
openclaw status
openclaw gateway status
openclaw cron status
openclaw cron list
openclaw cron runs --id <jobId> --limit 20
openclaw logs --follow
openclaw doctor
```

---

## Errores comunes

1. **Zona horaria equivocada:** cron usa el host; `--at` sin zona = UTC. Usa `--tz`.
2. **Gateway apagado:** los jobs no disparan si el gateway no corre.
3. **`--session main` con `--message`:** la sesión main requiere system events. Para tareas con modelo, usa `isolated`/`current`.
4. **Sin idioma en el prompt:** el job responde en el idioma que le digas (o uno raro si no).
5. **Día-mes + día-semana con OR:** revisa la lógica de croner si quieres condiciones AND.
6. **Job aislado sin contexto:** recuerda que un job aislado NO hereda tu conversación.

---

## Ejercicios

- [ ] Crea un recordatorio puntual con `--at "5m"`, `--session main`, `--system-event`, `--delete-after-run`. Espera y comprueba que dispara.
- [ ] Programa una revisión aislada recurrente (`isolated`) que anuncie por tu canal preferido.
- [ ] Envía un resumen a un webhook (puedes usar `https://webhook.site` para verlo).
- [ ] Ejecuta `openclaw cron list` y `openclaw cron runs --id <tu-job>` para inspeccionar.

---

## Resumen

- Cron es el **programador interno del gateway**; los jobs persisten en SQLite.
- **Schedules:** `at`, `every`, `cron`, `on-exit` — con `--tz` para zonas horarias.
- **Payloads:** system event (sin modelo), agent message (con modelo), command (script).
- **Sesiones:** main, isolated, current, session:<id> — elige según necesites contexto.
- **Entrega:** announce, webhook, none.
- Gestiona con `openclaw cron list/get/runs/remove`.

---

*Siguiente: [Módulo 5 — Integración con MCP](05-mcp.md)*


<!-- ================================================ -->
<!-- ARCHIVO: 05-mcp.md -->
<!-- ================================================ -->

# Módulo 5: Integración con Model Context Protocol (MCP)

> **Duración:** 2.0 h · **Objetivo:** conectar servidores MCP y exponer sus herramientas al agente.

## Objetivos de aprendizaje

Al terminar este módulo podrás:
- Explicar qué es MCP y cómo encaja en la arquitectura de agentes.
- Configurar servidores MCP (local/stdio, HTTP, remotos) en `openclaw.json`.
- Exponer tools de MCP al agente y a jobs de cron.
- Aplicar seguridad y permisos a las tools MCP.
- Conectar ejemplos reales: bases de datos, APIs, navegador.

---

## 5.1 ¿Qué es MCP?

**MCP (Model Context Protocol)** es un estándar abierto que permite conectar **herramientas y servicios externos** a un agente de IA de forma uniforme. Es como el **"enchufe universal"** para que el agente use servicios externos.

> 💡 **Analogía:** si las tools nativas son el cajón de herramientas del empleado, MCP es el *contrato de enchufes* que le permite conectar aparatos de cualquier fabricante: una impresora, un teléfono, un sistema de base de datos. Todos usan el mismo tipo de enchufe.

**Arquitectura MCP:**

```
[Agente OpenClaw]  ←→  [Cliente MCP]  ←→  [Servidor MCP]  ←→  [Servicio externo]
                                                              (BD, API, navegador…)
```

- **Cliente MCP:** lo incorpora OpenClaw; habla con los servidores.
- **Servidor MCP:** expone herramientas/recursos de un servicio concreto.
- **Transportes:** `stdio` (proceso local), `HTTP`/SSE (remoto).

**¿Por qué importa?** En vez de integrar cada servicio a mano, MCP estandariza la conexión: una vez que el servidor MCP de una base de datos existe, cualquier agente compatible puede usarlo.

---

## 5.2 Configurar servidores MCP en `openclaw.json`

Los servidores MCP se declaran en la configuración. Pueden ser locales (se lanzan como proceso) o remotos (HTTP).

### Ejemplo: servidor MCP local (stdio)

```json5
{
  mcp: {
    servers: {
      "mi-base-datos": {
        command: "npx",
        args: ["-y", "@modelcontextprotocol/server-sqlite"],
        env: {
          SQLITE_PATH: "/data/app.db",
        },
      },
    },
  },
}
```

- `command`/`args`: cómo se lanza el proceso del servidor.
- `env`: variables de entorno que necesita.
- El transporte `stdio` significa que OpenClaw y el servidor se comunican por entrada/salida estándar.

### Ejemplo: servidor MCP remoto (HTTP)

```json5
{
  mcp: {
    servers: {
      "api-externa": {
        url: "https://api.ejemplo.com/mcp",
        // auth según el servidor
      },
    },
  },
}
```

> 💡 Los servidores remotos requieren autenticación según el proveedor (token, OAuth, etc.). Consulta la doc del servidor MCP concreto.

---

## 5.3 Exponer tools de MCP al agente y a cron

Una vez configurado el servidor, sus **herramientas** quedan disponibles para que el agente las invoque como cualquier otra tool (las ve en su cajón).

**Desde el agente:** simplemente pide una tarea que requiera esa herramienta. Ejemplo: con un MCP de base de datos conectado:

> *"Consulta en la base de datos cuántos usuarios se registraron esta semana."*

El agente detecta la tool MCP de la BD y la usa.

**Desde cron:** un job aislado puede usar las tools MCP para tareas programadas:

```bash
openclaw cron create "0 7 * * *" \
  "Consulta la BD y envía el resumen de actividad diaria." \
  --name "Reporte diario BD" \
  --session isolated \
  --announce \
  --channel telegram \
  --to "-1001234567890"
```

> ⚠️ Recuerda: el job aislado tiene contexto fresco, pero **sí puede usar las tools** configuradas (incluidas las MCP).

---

## 5.4 Seguridad y permisos de las tools MCP

Conectar un MCP = darle al agente acceso a un servicio externo. Hay que controlar el alcance:

- **Allowlists de tools:** restringe qué tools MCP específicas puede usar el agente. No expongas todo el servidor si solo necesitas una función.
- **Permisos por agente:** cada agente puede tener permitidas herramientas distintas (menos privilegios).
- **Auth segura:** usa tokens/credenciales con el menor alcance posible.
- **Revisa el servidor:** solo conecta servidores MCP de fuentes confiables (un MCP malicioso es un vector de ataque).

> 💡 **Analogía de seguridad:** es como darle al empleado una *tarjeta de acceso restringido*: puede entrar a la sala que necesita, no a todo el edificio.

**Configuración de permisos (ejemplo conceptual):**
```json5
{
  agents: {
    defaults: {
      toolsAllow: ["mcp.mi-base-datos.consulta", "mcp.mi-base-datos.inserción"],
    },
  },
}
```

---

## 5.5 Ejemplos prácticos

### Base de datos (SQLite)
Conectas el servidor `@modelcontextprotocol/server-sqlite` y el agente puede:
- Consultar tablas y datos.
- Crear/leer registros según tu política.

### API externa (clima, pagos, CRM)
Con un servidor MCP que envuelva una API:
- *"¿Qué tiempo hará mañana en Madrid?"* → el agente llama a la API de clima vía MCP.

### Navegador
Un MCP de navegador permite al agente automatizar páginas web (rellenar formularios, extraer datos) dentro de sus límites de permisos.

> 💡 **Consejo:** busca servidores MCP existentes en los registros de la comunidad antes de construir uno. La mayoría de servicios populares ya tienen uno.

---

## Errores comunes

1. **Servidor MCP no arranca:** revisa `command`, `args` y `env` (¿existe `npx`? ¿la ruta es correcta?).
2. **Remoto sin auth:** los servidores HTTP suelen requerir token/OAuth; sin auth falla.
3. **Exponer TODO el servidor:** menos privilegios — permite solo las tools necesarias.
4. **MCP de fuente no confiable:** vector de ataque. Verifica el origen.
5. **Confundir MCP con tools nativas:** las tools nativas vienen con OpenClaw; las MCP son externas conectadas por el estándar.

---

## Ejercicios

- [ ] Conecta un servidor MCP local (ej. el de SQLite) y pide al agente una consulta.
- [ ] Conecta un MCP remoto con autenticación (usa un servidor de prueba de la comunidad).
- [ ] Restringe el alcance: permite solo 1-2 tools del servidor vía `toolsAllow`.
- [ ] Programa un job de cron que use una tool MCP y lo anuncie por canal.

---

## Resumen

- **MCP** estandariza cómo el agente usa servicios externos (el "enchufe universal").
- Configura servidores **locales (stdio)** o **remotos (HTTP)** en `openclaw.json`.
- Las tools MCP quedan disponibles para el agente **y para cron**.
- **Seguridad:** allowlists de tools, menos privilegios, auth mínima, fuentes confiables.
- Ejemplos: BD, APIs, navegador.

---

*Siguiente: [Módulo 6 — RAG, embeddings y bases de datos vectoriales](06-rag-vectores.md)*


<!-- ================================================ -->
<!-- ARCHIVO: 06-rag-vectores.md -->
<!-- ================================================ -->

# Módulo 6: RAG, embeddings y bases de datos vectoriales

> **Duración:** 2.5 h · **Objetivo:** montar un pipeline RAG: indexar documentos, generar embeddings y recuperar contexto.

## Objetivos de aprendizaje

Al terminar este módulo podrás:
- Explicar RAG, embeddings, similitud vectorial y chunking.
- Usar la memoria y búsqueda semántica de OpenClaw (`memory_search`, `memory_get`).
- Elegir y configurar una base vectorial (SQLite builtin, QMD, LanceDB, Qdrant, pgvector).
- Configurar proveedores de embeddings y `memorySearch`.
- Integrar RAG en un agente para responder con contexto.

---

## 6.1 Conceptos: el archivador inteligente

**RAG (Retrieval-Augmented Generation)** = **Recuperación aumentada por generación.** La idea: antes de que el modelo responda, se le dan *fragmentos relevantes* de una base de documentos, para que responda con contexto real en vez de solo su conocimiento de entrenamiento.

> 💡 **Analogía:** un empleado con RAG no responde de memoria; tiene un **archivador inteligente** que, ante una pregunta, *busca los papeles más relevantes* y los lee antes de contestar. Así no inventa: cita lo que encontró.

### Piezas clave

- **Embedding:** un **vector de números** que representa el *significado* de un texto. Textos parecidos tienen vectores parecidos (cercanos en el espacio).
- **Similitud vectorial:** cómo de "cerca" están dos vectores. Se mide con coseno, distancia euclidiana, etc.
- **Chunking:** dividir documentos grandes en **fragmentos** (chunks) antes de indexarlos, para que cada vector represente una idea manejable.
- **Base vectorial:** almacén optimizado para buscar por similitud de vectores.

### El flujo RAG

```
1. INDEXADO:
   Documentos → chunking → embeddings → base vectorial

2. CONSULTA:
   Pregunta → embedding de la pregunta
           → buscar chunks más similares (top-k)
           → inyectar chunks en el prompt → el modelo responde con contexto
```

---

## 6.2 Memoria y búsqueda semántica en OpenClaw

OpenClaw trae memoria con **búsqueda semántica** integrada. Las dos tools clave:

- **`memory_search`** — encuentra notas relevantes por *significado* (no solo por palabra). Usa búsqueda híbrida: vectores + coincidencia de keywords.
- **`memory_get`** — lee un archivo de memoria o un rango de líneas concreto.

> 💡 **Por qué es poderoso:** una búsqueda de texto normal encuentra "perro" solo si aparece "perro". Una búsqueda semántica entiende que "mascota canina" también es relevante. Es buscar por *sentido*, no por letras.

**Desde CLI:**
```bash
openclaw memory status                 # estado del índice y proveedor
openclaw memory search "MCP config"    # búsqueda semántica
openclaw memory index --force          # reconstruir el índice
```

**En el agente:** simplemente pregunta y el agente usa `memory_search`/`memory_get` cuando lo necesita. Ejemplo:
> *"¿Qué decidimos la semana pasada sobre el enfoque del curso?"*

---

## 6.3 Bases de datos vectoriales: cuál elegir

| Base | Cuándo usarla |
|---|---|
| **SQLite (builtin)** | Default de OpenClaw; sin dependencias extra. Keyword + vector + híbrido. Perfecta para empezar. |
| **QMD** | Sidecar local con reranking y expansión de queries. Para búsquedas más precisas, todo local. |
| **LanceDB** | Plugin con embeddings OpenAI-compatibles y soporte de Ollama local. |
| **Qdrant** | Base vectorial dedicada, escalable, corre en contenedor. Ideal producción. |
| **pgvector** | Extensión de PostgreSQL. Si ya usas Postgres, añade vectores sin servicio extra. |

> 💡 **Regla práctica:** para aprender y prototipar, usa la **SQLite builtin** (cero setup). Para producción con volumen o búsqueda avanzada, pasa a **Qdrant** o **pgvector**.

---

## 6.4 Proveedores de embeddings y config de `memorySearch`

Los embeddings los genera un **proveedor**. Por defecto OpenClaw usa OpenAI embeddings, pero puedes cambiarlo:

```json5
{
  agents: {
    defaults: {
      memorySearch: {
        provider: "ollama",        // o: openai, gemini, voyage, mistral, bedrock, local GGUF, LM Studio, etc.
        // modelo de embeddings según el proveedor
      },
    },
  },
}
```

**Opciones de proveedor:** OpenAI, Gemini, Voyage, Mistral, Bedrock, DeepInfra, local GGUF, Ollama, LM Studio, GitHub Copilot, o cualquier endpoint compatible con OpenAI.

> 💡 **Tip local/privado:** si no quieres enviar tus documentos a la nube, usa **Ollama** o **LM Studio** con un modelo de embeddings local. Todo queda en tu máquina.

---

## 6.5 Integrar RAG en un agente: caso práctico

Vamos a montar un RAG mínimo: el agente responde sobre la documentación de tu proyecto usando contexto vectorial.

### Paso 1 — Configura el proveedor de embeddings
```json5
{
  agents: {
    defaults: {
      memorySearch: { provider: "openai" },   // o tu proveedor preferido
    },
  },
}
```

### Paso 2 — Indexa tu corpus
Guarda tus documentos en el workspace (o en un directorio indexable) y reconstruye el índice:

```bash
openclaw memory index --force
```

> 💡 Con plugins como QMD puedes indexar **directorios fuera del workspace**. Revisa la doc del plugin que elijas.

### Paso 3 — Pregunta con contexto
Pide al agente algo que requiera recuperar de tu documentación:

> *"Según nuestra documentación, ¿cómo configuramos el servidor MCP?"*

El agente usa `memory_search` para recuperar los fragmentos relevantes y responde *con base en ellos*.

### Paso 4 (producción) — Base vectorial externa
Si necesitas escalar o un RAG más controlado, conecta Qdrant o pgvector y haz que tu agente consulte ahí (a menudo vía MCP, uniendo los Módulos 5 y 6):

```json5
{
  mcp: {
    servers: {
      "vectores": {
        // servidor MCP que envuelve Qdrant/pgvector
      },
    },
  },
}
```

---

## Errores comunes

1. **Chunking mal dimensionado:** chunks demasiado grandes = contexto impreciso; demasiado pequeños = pierdes significado. Ajusta según tu contenido.
2. **Embeddings sin contexto:** olvidar que los embeddings capturan *significado*; si el corpus es ruidoso, la búsqueda lo refleja.
3. **No reindexar:** si cambias los documentos y no reconstruyes el índice, el RAG responde con datos viejos.
4. **Proveedor no configurado:** `memory_search` necesita un proveedor de embeddings; sin él, la búsqueda semántica no funciona (solo keyword).
5. **RAG sin citas:** un buen RAG debe *decirte de dónde sacó* la información, para que puedas verificar.

---

## Ejercicios

- [ ] Configura un proveedor de embeddings y reconstruye el índice (`openclaw memory index --force`).
- [ ] Guarda 3-5 documentos sobre tu proyecto en el workspace y haz búsquedas semánticas variando las palabras (comprueba que entiende el sentido).
- [ ] Levanta Qdrant en Docker y conecta un servidor MCP de vectores.
- [ ] Pide al agente una respuesta que combine contexto RAG con su conocimiento, y evalúa la calidad.

---

## Resumen

- **RAG** = dar contexto relevante al modelo antes de responder (archivador inteligente).
- **Embeddings** = vectores que representan significado; la **similitud vectorial** encuentra lo parecido.
- **Chunking** = partir documentos en fragmentos manejables.
- OpenClaw trae **`memory_search`/`memory_get`** con búsqueda semántica híbrida.
- Bases: **SQLite builtin** (empezar) → **Qdrant/pgvector** (producción).
- Configura el **proveedor de embeddings** (incluso local con Ollama).
- **Reindexa** cuando cambies los documentos.

---

*Siguiente: [Módulo 7 — Despliegue en contenedores Docker](07-docker.md)*


<!-- ================================================ -->
<!-- ARCHIVO: 07-docker.md -->
<!-- ================================================ -->

# Módulo 7: Despliegue en contenedores Docker

> **Duración:** 2.0 h · **Objetivo:** contenerizar el gateway OpenClaw y sus servicios complementarios.

## Objetivos de aprendizaje

Al terminar este módulo podrás:
- Escribir un `Dockerfile` que levante el gateway con el workspace montado.
- Orquestar un stack con Docker Compose (gateway + base vectorial + MCP).
- Persistir estado con volúmenes (workspace, config, SQLite).
- Gestionar redes, puertos y variables de entorno (API keys).
- Aplicar buenas prácticas: sin secretos en la imagen, healthchecks, logs.

---

## 7.1 ¿Por qué Docker? La mudanza perfecta

**Docker** empaqueta tu aplicación (y sus dependencias) en un **contenedor** reproducible. Es como meter toda la oficina en una **caja estándar**: la abres en cualquier máquina y todo funciona igual, sin "en mi máquina sí funcionaba".

> 💡 **Analogía:** Docker es la *caja de mudanza con etiqueta*. Empaquetas el edificio (gateway + config + workspace), lo etiquetas y lo llevas a cualquier host; se monta igual siempre.

**Beneficios para OpenClaw:**
- **Reproducibilidad:** misma imagen → mismo comportamiento en cualquier host.
- **Aislamiento:** el gateway y sus servicios no ensucian el host.
- **Orquestación:** Docker Compose levanta gateway + Qdrant + MCP juntos.
- **Persistencia controlada:** los volúmenes deciden qué sobrevive a un reinicio.

---

## 7.2 El Dockerfile del gateway

Un `Dockerfile` describe cómo construir la imagen. Para OpenClaw:

```dockerfile
# 1. Base: imagen oficial de Node
FROM node:24-slim

# 2. Instala OpenClaw globalmente
RUN npm install -g openclaw@latest

# 3. Directorio del workspace
WORKDIR /workspace

# 4. Copia tu config (sin secrets: usa variables de entorno)
COPY openclaw.json /root/.openclaw/openclaw.json

# 5. Expón el puerto del gateway (Control UI)
EXPOSE 18789

# 6. Comando de arranque
CMD ["openclaw", "gateway", "start"]
```

> ⚠️ **Nunca copies API keys en la imagen.** Se pasan por **variables de entorno** en tiempo de ejecución (ver 7.4).

**Puntos clave:**
- Imagen base `node:24-slim` (ligera).
- `WORKDIR /workspace` = el hogar del agente dentro del contenedor.
- El puerto 18789 es el del Gateway/Control UI.
- El workspace debe venir de un **volumen** (persistencia), no de la imagen.

---

## 7.3 Docker Compose: el stack completo

Compose orquesta varios contenedores. Montamos **gateway + Qdrant** (vectores) para integrar con el Módulo 6:

```yaml
services:
  gateway:
    build: .
    container_name: openclaw-gateway
    ports:
      - "18789:18789"
    environment:
      - OPENAI_API_KEY=${OPENAI_API_KEY}    # desde el .env, no hardcodeado
      - TZ=Europe/Madrid
    volumes:
      - ./workspace:/workspace             # persistencia del workspace
      - openclaw_state:/root/.openclaw     # persistencia config + estado SQLite
    restart: unless-stopped

  qdrant:
    image: qdrant/qdrant
    container_name: openclaw-qdrant
    ports:
      - "6333:6333"
    volumes:
      - qdrant_data:/qdrant/storage
    restart: unless-stopped

volumes:
  openclaw_state:
  qdrant_data:
```

**Qué hace cada bloque:**
- **`gateway`:** tu imagen; expone el puerto; recibe API keys de variables de entorno; monta el workspace y el estado.
- **`qdrant`:** la base vectorial del Módulo 6; guarda sus datos en un volumen.
- **`volumes:`** nombrados para persistir: el workspace, el estado de OpenClaw y los datos de Qdrant sobreviven a `down`/`up`.

> 💡 Los servicios se ven entre sí por **nombre de servicio** en la red de Compose (ej. el gateway puede llamar a `qdrant:6333`).

---

## 7.4 Redes, puertos y variables de entorno

### Variables de entorno (API keys)
Nunca en la imagen ni en el `docker-compose.yml` versionado. Usa un archivo `.env` local (no lo subas a git):

```bash
# .env  (NO versionar)
OPENAI_API_KEY=sk-...
```

Y en Compose: `environment: - OPENAI_API_KEY=${OPENAI_API_KEY}`.

> ⚠️ Añade `.env` a tu `.gitignore`. Los secretos se quedan fuera del repo.

### Puertos
- `18789` → Gateway / Control UI (interfaz web).
- `6333` → Qdrant REST.

Solo expón al host los que necesites. Si no necesitas acceso externo, omite el `ports` y deja que Compose use la red interna.

### Zona horaria
El gateway usa la zona del contenedor. Fija `TZ=Europe/Madrid` (o la tuya) para que cron y fechas sean correctos.

---

## 7.5 Buenas prácticas

1. **Sin secretos en la imagen:** siempre variables de entorno en runtime.
2. **Volúmenes para todo lo que deba persistir:** workspace, config/estado, datos vectoriales.
3. **Healthcheck:** para que orquestadores sepan si el gateway está sano:
   ```yaml
   healthcheck:
     test: ["CMD", "openclaw", "status"]
     interval: 30s
     timeout: 10s
     retries: 3
   ```
4. **Logs:** el gateway escribe a stdout; Compose los captura (`docker compose logs -f gateway`).
5. **`restart: unless-stopped`:** el contenedor se recupera solo si el host se reinicia.
6. **Versión fija de la imagen:** ancla la versión de OpenClaw (`openclaw@X.Y.Z`) para reproducibilidad, y actualiza a propósito.
7. **`.gitignore`:** excluye `.env`, workspaces con secretos, y datos de volumen.

---

## Errores comunes

1. **API key dentro de la imagen:** se filtra a cualquiera que obtenga la imagen. Usa env vars.
2. **Sin volumen en el workspace:** al recrear el contenedor pierdes todo el trabajo.
3. **Confundir `down` con reinicio:** `docker compose down` elimina contenedores; los volúmenes nombrados persisten (salvo `-v`).
4. **Zona horaria por defecto (UTC):** cron/fechas "raro" si no fijas `TZ`.
5. **Exponer puertos innecesarios:** menos superficie de ataque. Solo los que uses.
6. **Sin healthcheck:** no sabes si el gateway está realmente operativo.

---

## Ejercicios

- [ ] Escribe un `Dockerfile` que instale OpenClaw y arranque el gateway con el workspace montado.
- [ ] Crea un `docker-compose.yml` con gateway + Qdrant y un `.env` para la API key.
- [ ] Levanta el stack (`docker compose up -d`) y verifica que el gateway responde en `18789`.
- [ ] Detén y recrea los contenedores (`down` + `up`) y comprueba que workspace y datos persisten.
- [ ] Añade un healthcheck y revisa los logs con `docker compose logs -f`.

---

## Resumen

- **Docker** = empaquetado reproducible (la caja de mudanza).
- **Dockerfile:** imagen base Node, instala OpenClaw, expone 18789.
- **Compose:** orquesta gateway + Qdrant (u otros servicios) en una red.
- **Persistencia:** volúmenes para workspace, estado y datos vectoriales.
- **Seguridad:** API keys por env vars (`.env` no versionado), healthchecks, `restart: unless-stopped`.

---

*Siguiente: [Módulo 8 — Proyecto final integrador](08-proyecto-final.md)*


<!-- ================================================ -->
<!-- ARCHIVO: 08-proyecto-final.md -->
<!-- ================================================ -->

# Módulo 8: Proyecto final integrador

> **Evaluación final ·** El cierre del curso. Integra TODO lo aprendido en un sistema real.

## Objetivo

Construir un **agente OpenClaw de producción** que combine las 7 habilidades del curso en un solo stack funcional de extremo a extremo.

---

## El proyecto, en una frase

> Un agente OpenClaw con **tools propias**, **multi-agente**, **automatización por cron**, **MCP**, **RAG sobre vectores** y desplegado en **Docker** — respondiendo a preguntas sobre tu propia base de conocimiento.

---

## Requisitos funcionales (qué debe cumplir)

Tu sistema debe:

| # | Requisito | Módulo que aplica |
|---|---|---|
| 1 | Expone al menos **2 tools personalizadas** (skills/scripts) | Módulo 2 |
| 2 | Usa **múltiples agentes o subagentes** con rutas aisladas | Módulo 3 |
| 3 | Ejecuta al menos **1 job de cron** que reporte por canal/webhook | Módulo 4 |
| 4 | Se conecta a **1 servidor MCP** y usa sus tools | Módulo 5 |
| 5 | Responde con **RAG** sobre una base vectorial | Módulo 6 |
| 6 | Corre completo en **Docker Compose** con persistencia | Módulo 7 |

---

## Guía de construcción (paso a paso)

### Paso 1 — Define tu base de conocimiento
Elige un tema sobre el que el agente deba "saber": documentación de tu proyecto, manual de producto, FAQs, etc. Reúne 5-10 documentos.

### Paso 2 — Configura el stack base
- Instala y configura OpenClaw con un proveedor de embeddings (Módulo 6).
- Índica tu base de conocimiento (reindexa).
- Crea el Dockerfile y docker-compose.yml (Módulo 7).

### Paso 3 — Añade tus tools (Módulo 2)
Crea 2 skills que resuelvan tareas reales de tu flujo (ej. `resumir-doc`, `generar-informe`). Prueba con `openclaw agent --message`.

### Paso 4 — Multi-agente (Módulo 3)
Define un segundo agente o delega tareas a subagentes (ej. un agente "investigador" que alimenta al principal).

### Paso 5 — Conecta MCP (Módulo 5)
Configura un servidor MCP (puede ser el de tu base vectorial, o una API externa) y expón sus tools con permisos mínimos.

### Paso 6 — Automatiza (Módulo 4)
Crea un job de cron aislado que haga algo útil periódicamente (ej. "cada mañana, resumen de actividad + responde consultas pendientes") y anúncialo por tu canal.

### Paso 7 — Empaqueta (Módulo 7)
Levanta todo con `docker compose up -d` y verifica que persiste entre reinicios.

---

## Entregables

1. **Repositorio** con: `openclaw.json`, skills (`skills/`), scripts y documentación breve.
2. **`docker-compose.yml`** del stack completo (gateway + servicios).
3. **Documentación breve** (un `README.md`): qué hace el sistema, cómo se despliega, cómo se usa.

---

## Criterios de evaluación

| Criterio | Peso aprox. |
|---|---|
| Configuración y aislamiento correcto de agentes | 20% |
| Tools funcionales, seguras y bien documentadas | 20% |
| Jobs de cron operativos con entrega real | 15% |
| RAG respondiendo con contexto relevante | 20% |
| Stack Docker reproducible en otra máquina | 25% |

**Puntos extra:**
- Seguridad sólida (allowlists, menos privilegios, sin secrets en git).
- Healthchecks y buenas prácticas de Docker.
- Documentación clara y ejemplos de uso.

---

## Rúbrica de autoevaluación (antés de entregar)

- [ ] ¿Puedo desplegar el stack en una máquina *limpia* siguiendo mi README, sin pasos mágicos?
- [ ] ¿El agente responde consultas usando mi base de conocimiento (RAG) y lo demuestra?
- [ ] ¿Las tools hacen lo que prometen y no exponen comandos peligrosos?
- [ ] ¿El cron entrega resultados reales a un canal/webhook?
- [ ] ¿No hay API keys ni secretos en el repo?
- [ ] ¿El workspace y los datos persisten tras `docker compose down` + `up`?

> Si respondes **sí** a todas, estás listo. Este es, en esencia, el perfil de un **power user de OpenClaw**. 🏆

---

## Evaluación final (composición de nota)

- **40%** Proyecto integrador (este módulo).
- **30%** Ejercicios prácticos por módulo (las casillas `[ ]` de cada archivo).
- **30%** Examen teórico-práctico sobre arquitectura, cron, MCP y Docker.

---

## Recursos de apoyo

- Documentación oficial: https://docs.openclaw.ai
- Código fuente: https://github.com/openclaw/openclaw
- ClawHub (skills): https://clawhub.ai
- MCP: https://modelcontextprotocol.io
- Docker: https://docs.docker.com

---

## 🎉 ¡Felicidades!

Completaste el curso **OpenClaw Avanzado — De Usuario a Power User**. Ya eres capaz de construir agentes de producción: con tools propias, multi-agente, automatización, MCP, RAG con vectores y despliegue reproducible en Docker. La oficina es tuya. 🏢🔥

