# 🧠 Hermes Agent — Guía Completa del Framework

> **El agente de IA auto-mejorable de Nous Research.**
> *"The self-improving AI agent built by Nous Research"* — *"The agent that grows with you"*

**Fuente:** Documentación oficial — https://hermes-agent.nousresearch.com/docs/ · Repo: https://github.com/nousresearch/hermes-agent

---

## 📌 ¿Qué es Hermes Agent?

Hermes Agent es un **framework de agentes de IA de código abierto** construido por **Nous Research** (la misma gente detrás de los modelos Hermes). No es un simple chatbot: es un **agente operativo** que vive en tu terminal, se conecta a tus plataformas de mensajería, ejecuta tareas programadas, tiene memoria persistente, aprende skills y se ejecuta de forma segura con un modelo de defensa en profundidad.

**Filosofía central:** *"The agent that grows with you"* — el agente que crece contigo. Se auto-mejora: aprende skills, acumula memoria curada, y se adapta a tu flujo de trabajo.

**Dónde vive:**
- **Docs:** https://hermes-agent.nousresearch.com/docs/
- **Web:** https://hermes-agent.nousresearch.com/
- **Repo:** https://github.com/nousresearch/hermes-agent
- **Discord:** https://discord.gg/NousResearch
- **Empresa:** https://nousresearch.com
- **READMEs traducidos:** README.zh-CN.md, README.ur-pk.md, README.es.md

---

## 🏗️ Arquitectura

Hermes tiene **múltiples puntos de entrada (entry points)** que comparten el mismo núcleo de agente:

| Entry Point | Descripción |
|---|---|
| **CLI** (`cli.py`) | Interfaz de terminal (TUI) interactiva |
| **Gateway** (`gateway/run.py`) | Proceso en segundo plano que conecta plataformas de mensajería |
| **ACP** (`acp_adapter/`) | Adaptador del protocolo ACP (Agent Client Protocol) |
| **Batch Runner** | Ejecución de tareas por lotes |
| **API Server** | Servidor HTTP para integraciones |
| **Python Library** | Usar Hermes como librería dentro de tus propios scripts |

**El Gateway** es el corazón de la operación remota: un solo proceso en segundo plano que:
- Se conecta a todas tus plataformas configuradas (Telegram, Discord, Slack, WhatsApp, etc.)
- Maneja las sesiones por chat
- Ejecuta el **scheduler de cron** (tick cada 60 segundos)
- Entrega mensajes de voz

---

## 🚀 Quickstart (Primeros pasos)

### Instalación
```bash
# Instalación estándar
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash

# Instalación sin skills pre-cargados (perfil limpio)
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash -s -- --no-skills
```

### Setup con un solo comando
```bash
hermes setup --portal
```
Un solo OAuth te da un proveedor de modelo **y** las 4 herramientas del Tool Gateway (TTS, web, etc.) sin editar YAML a mano. Los suscriptores de Portal tienen 10% de descuento en proveedores por tokens.

### Verificar que funciona
```bash
hermes chat          # Sesión interactiva
hermes chat -q "Hola"  # Modo single-query (no interactivo)
```

---

## ⚙️ Configuración

### Estructura de directorios (`~/.hermes/`)
```
~/.hermes/
├── config.yaml      # Settings (modelo, terminal, TTS, compresión, etc.)
├── .env             # API keys y secretos
├── auth.json        # Credenciales OAuth (Nous Portal, etc.)
├── SOUL.md          # Identidad primaria del agente (slot #1 del system prompt)
├── memories/        # Memoria persistente (MEMORY.md, USER.md)
├── skills/          # Skills creadas por el agente
├── cron/            # Trabajos programados
├── sessions/        # Sesiones del gateway
└── logs/            # Logs (errors.log, gateway.log — secretos auto-redactados)
```

### Comandos de configuración
```bash
hermes config              # Ver configuración actual
hermes config edit         # Abrir config.yaml en tu editor
hermes config get KEY       # Imprimir un valor resuelto
hermes config set KEY VAL   # Establecer un valor
hermes config unset KEY      # Quitar un valor
hermes config check          # Verificar opciones faltantes
hermes config migrate        # Añadir opciones faltantes interactivamente

# Ejemplos
hermes config get model
hermes config set model anthropic/claude-opus-4
hermes config set terminal.backend docker
hermes config set OPENROUTER_API_KEY sk-or-...   # Se guarda en .env
```

> 💡 `hermes config set` enruta automáticamente los valores al archivo correcto: **API keys → .env**, todo lo demás → config.yaml.

### Precedencia de configuración (mayor a menor)
1. **Argumentos CLI** — ej. `hermes chat --model anthropic/claude-sonnet-4`
2. **`~/.hermes/config.yaml`** — config principal para settings no-secretos
3. **`~/.hermes/.env`** — fallback para env vars; requerido para secretos
4. **Defaults integrados** — valores seguros por defecto

> **Regla de oro:** Secretos (API keys, tokens, passwords) van en `.env`. Todo lo demás va en `config.yaml`. Cuando ambos están, `config.yaml` gana para settings no-secretos.

### Sustitución de variables de entorno
```yaml
auxiliary:
  vision:
    api_key: ${GOOGLE_API_KEY}
    base_url: ${CUSTOM_VISION_URL}
```
Sintaxis Cursor-style también aceptada: `${env:VAR_NAME}`.

---

## 🛠️ Tools & Toolsets

Las herramientas de Hermes están organizadas en **toolsets** por plataforma. Puedes activar/desactivar toolsets según lo que necesites.

```bash
hermes chat --toolsets "web,terminal,skills"
```

### Toolsets principales
- **Web search** — búsqueda en la web
- **Browser automation** — automatización de navegador
- **Terminal** — ejecución de comandos shell
- **File editing** — lectura/escritura/edición de archivos
- **Memory** — memoria persistente
- **Delegation** — delegar tareas a sub-agentes
- **Scheduled tasks** — tareas programadas (cron)
- **Home Assistant** — integración con domótica

> **Nota:** La memoria cross-session de **Honcho** es un *plugin* (`plugins/memory/honcho/`), no un toolset built-in.

---

## 🧠 Skills System

Las **skills** son documentos de conocimiento on-demand que el agente carga cuando las necesita. Siguen el patrón de **progressive disclosure** (divulgación progresiva) para minimizar el uso de tokens, y son compatibles con el estándar abierto **agentskills.io**.

**Dónde viven:** `~/.hermes/skills/` — directorio primario y fuente de verdad.

### Progressive Disclosure (patrón eficiente de tokens)
```
Nivel 0: skills_list() → [{name, description, category}, ...]  (~3k tokens)
Nivel 1: skill_view(name) → Contenido completo + metadata
Nivel 2: skill_view(name, path) → Archivo de referencia específico
```
El agente **solo carga el contenido completo de la skill cuando realmente lo necesita**.

### Usar skills
```bash
# Cada skill instalada es automáticamente un slash command
/gif-search funny cats
/axolotl help me fine-tune Llama 3 on my dataset
/github-pr-workflow create a PR for the auth refactor

# Solo el nombre de la skill la carga y deja que el agente pregunte
/excalidraw

# Apilar múltiples skills en un solo comando (hasta 5)
/github-pr-workflow /test-driven-development fix issue #123 and open a PR
```

### Formato SKILL.md
```yaml
---
name: my-skill
description: Brief description of what this skill does
version: 1.0.0
platforms: [macos, linux]  # Opcional
metadata:
  hermes:
    tags: [python, automation]
    category: devops
    requires_toolsets: [terminal]  # Activación condicional
---
```

### Aprender skills desde fuentes (`/learn`)
```bash
# Un SDK o directorio de docs local
/learn the REST client in ~/projects/acme-sdk, focus on auth + pagination

# Una página de docs online
/learn https://docs.example.com/api/quickstart

# El workflow que acabas de hacer en esta conversación
/learn how I just deployed the staging server

# Un libro entero → se convierte en knowledge-base skill
/learn ~/books/designing-data-intensive-applications.pdf
```

### Gestión de skills
```bash
hermes skills opt-out          # Dejar de sembrar skills bundled (no borra nada)
hermes skills opt-out --remove # También borra skills bundled NO modificadas
hermes skills opt-in --sync     # Revertir y re-sembrar
```

---

## 💾 Memoria Persistente

Hermes usa **memoria acotada y curada** — no guarda todo, guarda lo que importa. Vive en `~/.hermes/memories/`.

### Dos archivos clave
| Archivo | Tamaño típico | Contenido |
|---|---|---|
| **MEMORY.md** | ~2,200 chars (~800 tokens) | Notas personales del agente, decisiones, lecciones |
| **USER.md** | ~1,375 chars (~500 tokens) | Perfil del usuario, preferencias, contexto |

Este diseño mantiene el contexto limpio y el costo de tokens bajo, mientras conserva lo esencial a largo plazo.

---

## ⏰ Scheduled Tasks (Cron)

Hermes expone la gestión de cron a través de **un solo tool `cronjob`** con operaciones estilo action (en vez de tools separados de schedule/list/remove).

### Qué puede hacer cron
- Programar tareas **one-shot** o **recurrentes**
- **Pausar, reanudar, editar, disparar y eliminar** jobs
- Adjuntar **cero, una o múltiples skills** a un job
- Entregar resultados al chat de origen, archivos locales o plataformas configuradas
- Correr en sesiones de agente frescas
- Correr en **modo no-agente** (script en un schedule, stdout entregado verbatim, cero LLM)

### Crear tareas
```bash
# En chat con /cron
/cron add 30m "Remind me to check the build"
/cron add "every 2h" "Check server status"
/cron add "every 1h" "Summarize new feed items" --skill blogwatcher

# Desde el CLI standalone
hermes cron create "every 2h" "Check server status"
hermes cron create "every 1h" "Summarize new feed items" --skill blogwatcher

# Por conversación natural
# "Every morning at 9am, check Hacker News for AI news and send me a summary on Telegram."
```

### Ciclo de vida
```bash
hermes cron list
hermes cron pause <job_id>
hermes cron resume <job_id>
hermes cron run <job_id>
hermes cron remove <job_id>
hermes cron edit <job_id> --schedule "every 4h"
hermes cron status
hermes cron tick
```

### ¿Qué modelo usa un job cron?
Resolución al momento de disparo: **per-job pin → cron.model en config.yaml → default global de `hermes model`**.

> ⚠️ **Drift guard:** Si el default global cambia y un job no tiene pin, el job **falla cerrado** (skip, no hace llamada de inferencia, alerta una vez). Esto evita que un job desatendido herede silenciosamente un cambio a un proveedor/modelo de pago. Desactívalo con `cron.model_drift_guard: false` si quieres que sigan el default global.

> ⚠️ **Los jobs cron NO pueden crear recursivamente más jobs cron** — Hermes desactiva las tools de gestión de cron dentro de ejecuciones cron para prevenir loops de scheduling descontrolados.

---

## 🔌 MCP (Model Context Protocol)

MCP permite a Hermes conectarse a **servidores de tools externos** — GitHub, bases de datos, file systems, browser stacks, APIs internas, y más.

> **¿Vienes de Claude Code?** El bloque `mcpServers` de tu `~/.claude.json` mapea a `mcp_servers` en el config.yaml de Hermes. `hermes import-agent claude-code` lo migra automáticamente (junto con skills e instructions).

### Quick start
```yaml
# ~/.hermes/config.yaml
mcp_servers:
  filesystem:
    command: "npx"
    args: ["-y", "@modelcontextprotocol/server-filesystem", "/home/user/projects"]
```
```bash
hermes chat
# "List the files in /home/user/projects and summarize the repo structure."
```

### Catálogo de MCPs aprobados por Nous
```bash
hermes mcp              # Picker interactivo (default)
hermes mcp catalog       # Lista en texto plano, scriptable
hermes mcp install n8n   # Instalar una entrada del catálogo por nombre
hermes mcp configure linear  # Re-abrir el checklist de selección de tools
```

- Los catálogos están **deshabilitados por defecto** — instala solo lo que quieras.
- Cada entrada requiere **API key, OAuth (remote MCP)** o **OAuth de terceros** (Google/GitHub).
- **Selección de tools al instalar:** Hermes sondea el servidor, lista todas sus tools y te presenta un checklist (SPACE toggle, ENTER confirm).
- **Modelo de confianza:** los manifests pasan por revisión de PR en el repo de hermes-agent. Lee el manifest antes de instalar, especialmente el campo `source:`.

### Sustitución de variables en runtime
Dentro de `transport.command`, `transport.args`, `transport.url` y `headers`, los placeholders `${VAR}` se resuelven al conectar desde variables de entorno (incluye todo lo de `~/.hermes/.env`). También se sustituyen variables estilo Cursor: `${userHome}`, `${workspaceFolder}`, `${pathSeparator}`.

---

## 🔐 Seguridad (Defense-in-Depth)

Hermes está diseñado con un **modelo de seguridad de 8 capas**:

1. **Autorización de usuario** — quién puede hablar con el agente (allowlists, DM pairing)
2. **Aprobación de comandos peligrosos** — human-in-the-loop para operaciones destructivas
3. **Seguridad de escritura de archivos** — denylist y sandbox opcional para write_file/patch
4. **Aislamiento de contenedores** — Docker/Singularity/Modal con hardening
5. **Filtrado de credenciales MCP** — aislamiento de variables de entorno para subprocesos MCP
6. **Escaneo de archivos de contexto** — detección de prompt injection en archivos de proyecto
7. **Aislamiento cross-session** — las sesiones no acceden a datos/estado de otras; rutas de cron endurecidas contra path traversal
8. **Sanitización de input** — parámetros de working directory validados contra allowlist para prevenir shell injection

### Aprobación de comandos peligrosos

**Modos de aprobación** (`approvals.mode` en config.yaml):
```yaml
approvals:
  mode: smart        # smart | manual | off
  timeout: 300       # segundos para esperar respuesta (default: 300)
  cron_mode: deny    # deny | approve — qué hacen los jobs cron con comandos peligrosos
  single_query_mode: deny  # deny | approve — qué hacen las sesiones -q
```

| Modo | Comportamiento |
|---|---|
| **smart** (default) | Usa un LLM auxiliar para evaluar riesgo. Comandos de bajo riesgo se auto-aprueban; peligrosos se auto-denegan; inciertos escalan a prompt manual |
| **manual** | Siempre pregunta al usuario por comandos peligrosos |
| **off** | Desactiva todos los checks (equivale a `--yolo`) |

### YOLO Mode
```bash
hermes --yolo          # CLI flag
/yolo                  # Slash command (toggle)
HERMES_YOLO_MODE=1      # Env var
```
> ⚠️ YOLO desactiva todos los checks de seguridad de comandos peligrosos **excepto el hardline blocklist**.

### Hardline Blocklist (piso siempre-activo)
Comandos tan catastróficos que Hermes **se niega a ejecutarlos sin importar nada** (ni `--yolo`, ni `approvals.mode: off`, ni cron headless, ni "allow always"):
- `rm -rf /` y variantes obvias
- `rm -rf --no-preserve-root /`
- Fork bombs (`:(){ :|:& };:`)
- `mkfs.*` en un dispositivo root montado
- `dd if=/dev/zero of=/dev/sd*`
- Piping de URLs no confiables a `sh` en el rootfs

### Reglas de denegación definidas por el usuario (`approvals.deny`)
```yaml
approvals:
  deny:
    - "git push --force*"
    - "*curl*|*sh*"
    - "dd if=* of=/dev/*"
```
Patrones glob (fnmatch) que bloquean comandos incondicionalmente — antes de `--yolo`, `/yolo` y `approvals.mode: off`. Útil para "yolo con excepciones".

### Flujo de aprobación (CLI)
```
 ⚠️ DANGEROUS COMMAND: recursive delete
 rm -rf /tmp/old-project
 [o]nce | [s]ession | [a]lways | [d]eny
 Choice [o/s/a/D]:
```
- **once** — permitir esta única ejecución
- **session** — permitir este patrón por el resto de la sesión
- **always** — añadir a allowlist permanente (guardado en config.yaml)
- **deny** (default) — bloquear

### Allowlist permanente
```yaml
# config.yaml
command_allowlist:
  - rm
  - systemctl
```

### Minería de historial de aprobaciones
```bash
hermes approvals suggest              # Dry run — imprime propuesta numerada
hermes approvals suggest --apply 1,3  # Fusionar picks en command_allowlist
hermes approvals suggest --json        # Salida machine-readable
```
Escanea `~/.hermes/state.db` buscando comandos peligrosos que realmente ejecutaste (aprobaste), los agrega en patrones y los rankea por frecuencia. **Nada se aplica automáticamente** — solo con `--apply`. Las clases destructivas nunca se proponen.

### Seguridad de escritura de archivos
Antes de que `write_file` o `patch` toquen disco, Hermes chequea la ruta contra un denylist y un sandbox opcional.

**Rutas protegidas (siempre bloqueadas):**
- Almacenes de credenciales del SO: `~/.ssh/`, `~/.aws/`, `~/.kube/`, `/etc/sudoers`, `~/.netrc`
- Almacenes de credenciales de Hermes: `auth.json`, `.env`, `mcp-tokens/`, `pairing/`
- Archivos secretos de proyecto: `.env`, `.env.local`, `.env.production`, `.envrc`

**Sandbox opcional (`HERMES_WRITE_SAFE_ROOT`):**
```bash
export HERMES_WRITE_SAFE_ROOT=/path/to/project:/home/you/.hermes
```
Cuando está seteado, `write_file` y `patch` solo pueden apuntar a rutas dentro de los prefijos listados. Se setea automáticamente en la imagen Docker oficial (`/opt/data`).

### Autorización de usuarios (Gateway)
Orden de chequeo de `_is_user_authorized()`:
1. Per-platform allow-all flag (ej. `DISCORD_ALLOW_ALL_USERS=true`)
2. DM pairing approved list
3. Platform-specific allowlists (ej. `TELEGRAM_ALLOWED_USERS=12345,67890`)
4. Global allowlist (`GATEWAY_ALLOWED_USERS=12345,67890`)
5. Global allow-all (`GATEWAY_ALLOW_ALL_USERS=true`)
6. **Default: deny**

```bash
# ~/.hermes/.env
TELEGRAM_ALLOWED_USERS=123456789,987654321
DISCORD_ALLOWED_USERS=111222333444555666
GATEWAY_ALLOWED_USERS=123456789
```
> ⚠️ Si no hay allowlists configuradas y `GATEWAY_ALLOW_ALL_USERS` no está seteado, **todos los usuarios son denegados**.

### DM Pairing (alternativa a allowlists)
```bash
# El usuario ve: "Pairing code: XKGH5N7P"
hermes pairing approve telegram XKGH5N7P
hermes pairing list
hermes pairing revoke telegram 123456789
```
Los códigos expiran después de 1 hora, tienen rate-limit y usan aleatoriedad criptográfica.

### Admins vs Usuarios regulares
- **Admin** — acceso completo, puede correr todos los slash commands
- **Regular user** — puede chatear, pero solo los slash commands que habilites explícitamente (piso: `/help` y `/whoami`)

```yaml
gateway:
  platforms:
    discord:
      extra:
        allow_from: ["111", "222", "333"]
        allow_admin_from: ["111"]
        user_allowed_commands: [status, model]
```

---

## 💬 Messaging Gateway

Hermes se conecta a **muchísimas plataformas**: Telegram, Discord, Slack, WhatsApp, Signal, SMS, Email, Home Assistant, Mattermost, Matrix, DingTalk, Feishu/Lark, WeCom, Weixin, BlueBubbles (iMessage), QQ, Yuanbao, Microsoft Teams, LINE, ntfy, y tu navegador.

### Setup
```bash
hermes gateway setup   # Setup interactivo para todas las plataformas
hermes gateway         # Correr en foreground
hermes gateway install # Instalar como servicio de usuario
hermes gateway start    # Iniciar el servicio
hermes gateway status   # Ver estado
```

### Comparativa de plataformas (capacidades)
| Plataforma | Voz | Imágenes | Archivos | Threads | Reacciones | Typing | Streaming |
|---|---|---|---|---|---|---|---|
| Telegram | ✅ | ✅ | ✅ | ✅ | — | ✅ | ✅ |
| Discord | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Slack | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| WhatsApp | — | ✅ | ✅ | — | — | ✅ | ✅ |
| Signal | — | ✅ | ✅ | — | — | ✅ | — |
| Email | — | ✅ | ✅ | ✅ | — | — | — |
| Matrix | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

### Slash commands dentro de mensajería
```
/new o /reset        → Sesión fresca
/model [provider:model] → Ver/cambiar modelo
/personality [name]  → Setear personalidad
/retry               → Reintentar último mensaje
/undo                → Quitar último intercambio
/status              → Info de sesión
/whoami              → Ver tu acceso (admin/user/unrestricted)
/stop                → Detener el agente
/approve             → Aprobar comando peligroso pendiente
/deny                → Rechazar comando peligroso pendiente
/compress            → Comprimir contexto manualmente
/sessions            → Listar sesiones previas
/usage               → Uso de tokens
/reasoning           → Cambiar esfuerzo de razonamiento
/voice               → Controlar respuestas de voz
/rollback            → Restaurar checkpoints del filesystem
/background <prompt> → Correr prompt en sesión separada
/reload-mcp          → Recargar servidores MCP
/update              → Actualizar Hermes
/<skill-name>        → Invocar cualquier skill instalada
```

### Tokens de silencio intencional
Para group chats, hooks y flujos de automatización, Hermes soporta tokens de silencio explícitos. Si la respuesta final del agente es exactamente un token soportado, el gateway **suprime la entrega** y no envía nada al chat.

Tokens soportados: `[SILENT]`, `SILENT`, `NO_REPLY`, `NO REPLY`

> El silencio es solo una decisión de entrega. Hermes mantiene el turno de silencio en el transcript de la sesión, así la conversación alterna normalmente.

### Fiabilidad de entrega (delivery ledger)
Las respuestas finales se registran en un ledger durable (`state.db`). Si el gateway crashea entre producir una respuesta y confirmar el envío, el próximo boot **re-entrega** la respuesta almacenada en vez de perderla o re-ejecutar todo el turno.
- Semántica honesta **at-least-once**
- Re-entrega acotada: 3 intentos, 24h de frescura
- Desactivable con `gateway.delivery_ledger: false`

### Overrides por canal
Diferentes canales pueden correr diferentes modelos y personas desde un solo gateway:
```yaml
platforms:
  discord:
    enabled: true
    channel_overrides:
      "123456789012345678":
        model: anthropic/claude-sonnet-4.6
        provider: anthropic
        system_prompt: "You are the #dev channel code-review specialist."
```

### Redirigir al agente (busy-input mode)
```yaml
display:
  busy_input_mode: steer   # o queue, o interrupt (default)
```
- **interrupt** (default) — tu mensaje redirige el turno activo
- **queue** — los mensajes esperan y corren como siguiente turno
- **steer** — se inyectan en el run actual vía `/steer`

---

## 🖥️ CLI Interface

El CLI de Hermes es una **interfaz de terminal completa (TUI)** — no una web UI. Incluye edición multilínea, autocompletado de slash commands, historial de conversación, interrupt-and-redirect, y streaming de output de tools.

### Comandos principales
```bash
hermes                          # Sesión interactiva (default)
hermes chat -q "Hello"          # Single query mode
hermes chat --model "anthropic/claude-sonnet-4"
hermes chat --provider nous     # Usar Nous Portal
hermes chat --toolsets "web,terminal,skills"
hermes -s hermes-agent-dev,github-auth   # Pre-cargar skills
hermes --continue               # Reanudar sesión más reciente (-c)
hermes --resume <session_id>    # Reanudar sesión específica (-r)
hermes -w                       # Git worktree aislado (agentes paralelos)
```

### Status bar
```
 ⚕ claude-sonnet-4-20250514 │ 12.4K/200K │ [██████░░░░] 6% │ $0.06 │ 15m
```
Muestra: modelo, tokens usados/máx, barra de contexto (con código de colores), costo estimado, compresiones, tareas background, duración, título de sesión, y badge YOLO.

**Código de colores del contexto:**
- 🟢 Verde (<50%) — hay espacio de sobra
- 🟡 Amarillo (50-80%) — llenándose
- 🟠 Naranja (80-95%) — acercándose al límite
- 🔴 Rojo (≥95%) — casi overflow, considera `/compress`

### Keybindings
| Tecla | Acción |
|---|---|
| `Enter` | Enviar mensaje |
| `Alt+Enter` / `Ctrl+J` / `Shift+Enter` | Nueva línea |
| `Ctrl+V` | Pegar texto + adjuntar imágenes |
| `Ctrl+B` | Iniciar/detener grabación de voz |
| `Ctrl+G` | Abrir buffer en `$EDITOR` |
| `Ctrl+S` | Stash del prompt (guardar borrador) |
| `Ctrl+C` | Interrumpir agente (doble-press = force exit) |
| `Ctrl+D` | Salir |
| `Ctrl+Z` | Suspender a background (Unix) |
| `Tab` | Aceptar autosugerencia / autocompletar |
| `!<command>` | Shell mode — correr comando sin gastar turno de modelo |

### Shell mode (`!`)
```bash
> !git status
> !ls -la
> !pytest -x tests/cli
```
- **Cero costo** — el modelo nunca se invoca
- Nada entra en la conversación
- Corre donde corre el tool terminal del agente
- **Las aprobaciones siguen aplicando** — un comando peligroso pasa por el mismo prompt de aprobación

### Personalidades
```bash
/personality pirate
/personality kawaii
/personality concise
```
Built-in: helpful, concise, technical, creative, teacher, kawaii, catgirl, pirate, shakespeare, surfer, noir, uwu, philosopher, hype.

Personalidades custom en config.yaml:
```yaml
personalities:
  helpful: "You are a helpful, friendly AI assistant."
  pirate: "Arrr! Ye be talkin' to Captain Hermes..."
```

### Quick Commands (comandos personalizados)
```yaml
# ~/.hermes/config.yaml
quick_commands:
  status:
    type: exec
    command: systemctl status hermes-agent
  gpu:
    type: exec
    command: nvidia-smi --query-gpu=utilization.gpu,memory.used --format=csv,noheader
  restart:
    type: alias
    target: /gateway restart
```
Luego `/status`, `/gpu`, `/restart` en cualquier chat.

### Gestión de sesiones
```bash
hermes --continue                    # Reanudar la más reciente
hermes --resume 20260225_143052_a1b2c3  # Reanudar por ID
hermes --resume "refactoring auth"   # Reanudar por título
hermes sessions list                 # Listar sesiones pasadas
hermes sessions rename <id> <title>  # Renombrar sesión
```
Las sesiones se guardan en SQLite (`~/.hermes/state.db`): metadata, historial de mensajes, lineage, e índices de búsqueda full-text.

---

## 🧩 Terminal Backends

Hermes soporta **siete backends de terminal** — cada uno determina dónde se ejecutan los comandos shell del agente.

| Backend | Dónde corren los comandos | Aislamiento | Mejor para |
|---|---|---|---|
| **local** | Tu máquina directamente | Ninguno | Desarrollo, uso personal |
| **docker** | Contenedor Docker persistente | Full (namespaces, cap-drop) | Sandboxing seguro, CI/CD |
| **ssh** | Servidor remoto vía SSH | Network boundary | Dev remoto, hardware potente |
| **modal** | Sandbox cloud de Modal | Full (cloud VM) | Compute cloud efímero, evals |
| **daytona** | Workspace de Daytona | Full (cloud container) | Entornos cloud gestionados |
| **vercel_sandbox** | Vercel Sandbox | Full (cloud microVM) | Ejecución cloud con persistencia snapshot |
| **singularity** | Contenedor Singularity/Apptainer | Namespaces (--containall) | Clusters HPC, máquinas compartidas |

```yaml
terminal:
  backend: local   # local | docker | ssh | modal | daytona | vercel_sandbox | singularity
  cwd: "."
  timeout: 180
```

### Docker backend
```yaml
terminal:
  backend: docker
  docker_image: "nikolaik/python-nodejs:python3.11-nodejs20"
  docker_mount_cwd_to_workspace: false
  docker_forward_env:
    - "GITHUB_TOKEN"
  docker_volumes:
    - "/home/user/projects:/workspace/projects"
  docker_network: true   # false = air-gap (--network=none)
  container_cpu: 1
  container_memory: 5120
  container_persistent: true
```
- **Un solo contenedor persistente** compartido entre sesiones, `/new`, y sub-agentes
- Hermes arranca UN contenedor long-lived en el primer uso y enruta todo a través de `docker exec`
- Los cambios de working directory, paquetes instalados y procesos background **sobreviven** entre tool calls
- Podman soportado: `HERMES_DOCKER_BINARY=podman`

---

## 📦 Plugins

```bash
hermes plugins install owner/repository --no-enable
hermes plugins list
hermes plugins enable <plugin-name>
hermes plugins disable <plugin-name>
hermes plugins update <plugin-name>
hermes plugins remove <plugin-name>
```
Los paquetes portables permanecen deshabilitados hasta que se habilitan explícitamente. Hermes carga actualmente **Agent Skills portables** y **entradas stdio MCP**.

---

## 🎓 Recursos de aprendizaje

- **Video Masterclass** de "Onchain AI Garage"
- **Playlist de YouTube:** "Hermes Agent Tutorials & Use Cases" — https://www.youtube.com/playlist?list=PLmpUb_PWAkDxewld5ZYyKifuHxgIbiq2d
- **Discord:** https://discord.gg/NousResearch

---

## ✅ Resumen — ¿Para qué sirve Hermes Agent?

Hermes Agent es un **agente operativo completo** que combina:

1. **CLI/TUI potente** para vivir en la terminal
2. **Gateway de mensajería** para operar desde Telegram, Discord, Slack, WhatsApp, etc.
3. **Memoria persistente curada** (MEMORY.md + USER.md)
4. **Sistema de skills** con progressive disclosure y estándar agentskills.io
5. **Cron/scheduled tasks** con ciclo de vida completo
6. **MCP** para conectar tools externas (GitHub, DBs, browsers, APIs)
7. **Seguridad defense-in-depth** de 8 capas
8. **Múltiples backends de terminal** (local, Docker, SSH, cloud)
9. **Auto-mejora** — aprende skills, acumula memoria, se adapta

Es el equivalente de "un agente que crece contigo": empieza simple y se vuelve más capaz a medida que le enseñas skills y acumula memoria sobre tu flujo de trabajo.

---

*Documento elaborado a partir de la documentación oficial de Hermes Agent (Nous Research). Fechas de consulta: 2026-08-17.*
