# 📚 Temario Completo — **Hermes Agent** (Nous Research)

> **El agente de IA auto-mejorable de Nous Research.**
> *"The self-improving AI agent built by Nous Research"* — *"The agent that grows with you"*
> Repo: [github.com/nousresearch/hermes-agent](https://github.com/nousresearch/hermes-agent) · Docs: [hermes-agent.nousresearch.com/docs](https://hermes-agent.nousresearch.com/docs)

---

## MÓDULO 0 — Fundamentos y Filosofía

### 0.1 ¿Qué es Hermes Agent?
- **Framework open-source** de **Nous Research** para construir y operar **agentes de IA autónomos**.
- No es un simple chatbot: es un **agente operativo** que vive en tu terminal, se conecta a tus plataformas de mensajería, ejecuta tareas programadas, tiene memoria persistente, aprende skills y se ejecuta de forma segura con un modelo de defensa en profundidad.
- **Filosofía central:** *"The agent that grows with you"* — el agente que crece contigo. Se auto-mejora: aprende skills, acumula memoria curada, y se adapta a tu flujo de trabajo.
- Es el equivalente de "un agente que crece contigo": empieza simple y se vuelve más capaz a medida que le enseñas skills y acumula memoria sobre tu flujo de trabajo.

### 0.2 ¿Por qué "self-improving"?
- **Skills**: el agente puede aprender procedimientos reutilizables (skills) y cargarlos on-demand cuando los necesita.
- **Memoria curada**: no guarda todo, guarda lo que importa (MEMORY.md + USER.md), manteniendo el contexto limpio y el costo de tokens bajo.
- **Auto-mejora operativa**: aprende de tus aprobaciones (minería de historial), se adapta a tu flujo, y crece en capacidad con el tiempo.

### 0.3 Dónde vive Hermes
- **Docs:** https://hermes-agent.nousresearch.com/docs/
- **Web:** https://hermes-agent.nousresearch.com/
- **Repo:** https://github.com/nousresearch/hermes-agent
- **Discord:** https://discord.gg/NousResearch
- **Empresa:** https://nousresearch.com
- **READMEs traducidos:** README.zh-CN.md, README.ur-pk.md, README.es.md

### 0.4 Requisitos
- **Python 3.10+** (el framework está escrito en Python).
- Un **proveedor de modelo** (OpenRouter, Anthropic, Nous Portal, OpenAI, etc.).
- Para el gateway de mensajería: credenciales de las plataformas que quieras conectar.
- Para el backend Docker: Docker Desktop o Docker Engine instalado y corriendo.

### 0.5 Estado y consideraciones
- Framework **activo y en evolución** — las APIs y el comportamiento pueden cambiar entre versiones.
- Elegir modelo, proveedor y canal según requisitos de **procesamiento de datos y compliance**.
- La seguridad es **defense-in-depth** (8 capas) — no es un sandbox contra un agente hostil, sino una red de guardarraíles contra un agente honesto-pero-equivocado.

### 0.6 Hermes vs otros frameworks de agentes
| Aspecto | Hermes Agent | Eve (Vercel) | OpenClaw |
|---|---|---|---|
| **Filosofía** | Agente auto-mejorable que crece contigo | Filesystem-first, backend durables | Asistente personal operativo |
| **Lenguaje** | Python | TypeScript/Node | Node.js |
| **Interfaz principal** | CLI/TUI + Gateway de mensajería | Backend service | CLI + canales |
| **Memoria** | MEMORY.md + USER.md curadas | defineState por-sesión | MEMORY.md + daily notes |
| **Skills** | Progressive disclosure, agentskills.io | Skills on-demand | Skills |
| **Seguridad** | 8 capas defense-in-depth | Trust boundaries app/sandbox | Approval system |
| **Cron** | Tool cronjob unificado | Schedules | Cron jobs |
| **MCP** | Sí (catálogo aprobado por Nous) | Connections | MCP |

### 0.7 Modelo mental: "el agente que crece contigo"
La filosofía central de Hermes se traduce en tres mecanismos concretos:

1. **Aprende skills** — con `/learn` convierte procedimientos que ya conoces en skills reutilizables.
2. **Acumula memoria curada** — MEMORY.md y USER.md guardan lo esencial sin inflar el contexto.
3. **Se adapta a tu flujo** — aprende de tus aprobaciones (minería de historial), respeta tus allowlists, y crece en capacidad con el tiempo.

Este es el diferenciador clave: **no es un agente estático que solo ejecuta**, es un agente que **mejora con el uso**.

---

## MÓDULO 1 — Getting Started (Arranque)

### 1.1 Instalación
```bash
# Instalación estándar
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash

# Instalación sin skills pre-cargados (perfil limpio)
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash -s -- --no-skills
```

### 1.2 Setup con un solo comando
```bash
hermes setup --portal
```
Un solo OAuth te da un proveedor de modelo **y** las 4 herramientas del Tool Gateway (TTS, web, etc.) sin editar YAML a mano. Los suscriptores de Portal tienen 10% de descuento en proveedores por tokens.

### 1.3 Verificar que funciona
```bash
hermes chat          # Sesión interactiva
hermes chat -q "Hola"  # Modo single-query (no interactivo)
```

### 1.4 Estructura de directorios (`~/.hermes/`)
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

### 1.5 Configurar el modelo
```bash
hermes config set model anthropic/claude-opus-4
hermes config set model openai/gpt-5-mini
hermes chat --model "anthropic/claude-sonnet-4"   # Override por invocación
hermes chat --provider nous                        # Usar Nous Portal
hermes chat --provider openrouter                  # Forzar OpenRouter
```

### 1.6 Troubleshooting básico
- **No hay modelo configurado** → corre `hermes setup --portal` o `hermes config set model <provider>/<model>`.
- **API key no encontrada** → las keys van en `~/.hermes/.env` (no en config.yaml).
- **Docker no arranca** → verifica que Docker Desktop/Engine esté corriendo; Hermes sondea `$PATH` y rutas comunes de macOS.
- **Gateway no conecta** → corre `hermes gateway setup` para configurar plataformas interactivamente.

### 1.7 Perfiles (profiles)
Hermes soporta **múltiples perfiles** — cada uno con su propio `HERMES_HOME`, config, memoria, skills y sesiones.

```bash
hermes profile create research --no-skills   # Crear perfil sin skills bundled
hermes profile list                           # Listar perfiles
hermes profile use research                   # Cambiar de perfil
```

Cada perfil es un directorio aislado bajo `~/.hermes/` (o el `HERMES_HOME` que definas). Esto permite tener, por ejemplo:
- Un perfil **personal** con tu asistente de confianza.
- Un perfil **work** con toolsets y skills específicos del trabajo.
- Un perfil **research** limpio, sin skills bundled.

### 1.8 Ejercicio práctico
**Objetivo:** Instalar Hermes, configurar un modelo y verificar que responde.

```bash
# 1. Instalar
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash

# 2. Configurar modelo (o usar hermes setup --portal)
hermes config set model anthropic/claude-sonnet-4

# 3. Verificar
hermes chat -q "Hello, what can you do?"

# 4. (Opcional) Crear un perfil limpio
hermes profile create research --no-skills
hermes profile use research
```

---

## MÓDULO 2 — Arquitectura y Modelo Mental

### 2.1 Entry Points (puntos de entrada)
Hermes tiene **múltiples puntos de entrada** que comparten el mismo núcleo de agente:

| Entry Point | Descripción |
|---|---|
| **CLI** (`cli.py`) | Interfaz de terminal (TUI) interactiva |
| **Gateway** (`gateway/run.py`) | Proceso en segundo plano que conecta plataformas de mensajería |
| **ACP** (`acp_adapter/`) | Adaptador del protocolo ACP (Agent Client Protocol) |
| **Batch Runner** | Ejecución de tareas por lotes |
| **API Server** | Servidor HTTP para integraciones |
| **Python Library** | Usar Hermes como librería dentro de tus propios scripts |

### 2.2 El Gateway (corazón de la operación remota)
El **Gateway** es un solo proceso en segundo plano que:
- Se conecta a todas tus plataformas configuradas (Telegram, Discord, Slack, WhatsApp, etc.)
- Maneja las sesiones por chat
- Ejecuta el **scheduler de cron** (tick cada 60 segundos)
- Entrega mensajes de voz

**Arquitectura del gateway:**
```
Plataforma (Telegram, Discord, ...)
        │
        ▼
  [Adapter de plataforma]  ← recibe mensajes
        │
        ▼
  [Per-chat session store]  ← maneja sesiones
        │
        ▼
  [AIAgent]  ← procesa y responde
        │
        ▼
  [Cron scheduler]  ← tick cada 60s, ejecuta jobs debidos
```

### 2.3 Modelo de sesiones
- Las sesiones **persisten** entre mensajes hasta que se resetean.
- El agente recuerda el contexto de la conversación.
- Por defecto las sesiones **nunca se auto-resetean** — el contexto vive hasta que haces `/reset` manualmente o la compresión de contexto entra en acción.

### 2.4 Modelo de seguridad (defense-in-depth)
Hermes está diseñado con un **modelo de seguridad de 8 capas**:
1. **Autorización de usuario** — quién puede hablar con el agente (allowlists, DM pairing)
2. **Aprobación de comandos peligrosos** — human-in-the-loop para operaciones destructivas
3. **Seguridad de escritura de archivos** — denylist y sandbox opcional para write_file/patch
4. **Aislamiento de contenedores** — Docker/Singularity/Modal con hardening
5. **Filtrado de credenciales MCP** — aislamiento de variables de entorno para subprocesos MCP
6. **Escaneo de archivos de contexto** — detección de prompt injection en archivos de proyecto
7. **Aislamiento cross-session** — las sesiones no acceden a datos/estado de otras; rutas de cron endurecidas contra path traversal
8. **Sanitización de input** — parámetros de working directory validados contra allowlist para prevenir shell injection

### 2.5 Modelo de memoria
- **Memoria acotada y curada** — no guarda todo, guarda lo que importa.
- Vive en `~/.hermes/memories/`.
- Dos archivos clave: **MEMORY.md** (~2,200 chars / ~800 tokens) y **USER.md** (~1,375 chars / ~500 tokens).
- Este diseño mantiene el contexto limpio y el costo de tokens bajo, mientras conserva lo esencial a largo plazo.

### 2.6 El system prompt y SOUL.md
`SOUL.md` es la **identidad primaria del agente** — ocupa el slot #1 del system prompt. Es donde defines quién es el agente, su tono, sus valores y sus líneas rojas.

```markdown
# SOUL.md — Identidad del agente

## Persona
Eres un asistente personal confiable y directo.

## Tono
- Claro y conciso
- Sin jerga innecesaria
- Respetuoso

## Líneas rojas
- Lo privado se queda privado
- Si no sabes algo, dilo
- Antes de hacer algo externo, pregunta
```

> 💡 **Analogía con OpenClaw:** SOUL.md en Hermes es equivalente a SOUL.md en OpenClaw — define la personalidad y los límites del agente.

### 2.7 Flujo de un turno
1. El usuario envía un mensaje (CLI, gateway, etc.).
2. El adapter de plataforma lo recibe y lo enruta al session store.
3. El AIAgent construye el contexto (system prompt + SOUL.md + memoria + skills cargadas + historial).
4. El modelo genera una respuesta, posiblemente llamando tools.
5. Las tools se ejecutan (con aprobación si son peligrosas).
6. La respuesta final se entrega al usuario (o se suprime con token de silencio).

### 2.8 Ejercicio práctico
**Objetivo:** Entender la arquitectura y personalizar la identidad del agente.

```bash
# 1. Ver el SOUL.md actual
cat ~/.hermes/SOUL.md

# 2. Editar la identidad
hermes config edit   # o edita ~/.hermes/SOUL.md directamente

# 3. Verificar que el agente usa la nueva identidad
hermes chat -q "Who are you?"
```

---

## MÓDULO 3 — Configuración Avanzada

### 3.1 Comandos de configuración
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

### 3.2 Precedencia de configuración (mayor a menor)
1. **Argumentos CLI** — ej. `hermes chat --model anthropic/claude-sonnet-4`
2. **`~/.hermes/config.yaml`** — config principal para settings no-secretos
3. **`~/.hermes/.env`** — fallback para env vars; requerido para secretos
4. **Defaults integrados** — valores seguros por defecto

> **Regla de oro:** Secretos (API keys, tokens, passwords) van en `.env`. Todo lo demás va en `config.yaml`. Cuando ambos están, `config.yaml` gana para settings no-secretos.

### 3.3 Sustitución de variables de entorno
```yaml
auxiliary:
  vision:
    api_key: ${GOOGLE_API_KEY}
    base_url: ${CUSTOM_VISION_URL}
delegation:
  api_key: ${DELEGATION_KEY}
```
- Múltiples referencias en un solo valor funcionan: `url: "${HOST}:${PORT}"`.
- Si una variable no está seteada, el placeholder se mantiene verbatim y se loguea un warning.
- Sintaxis Cursor-style también aceptada: `${env:VAR_NAME}` (el prefijo `env:` se quita).
- Otros SecretRefs (`${file:...}`, `${vault:...}`, `${bitwarden:...}`) no se resuelven inline — los backends de secretos externos inyectan sus valores en el entorno al arranque vía el bloque `secrets:`.

### 3.4 Timeouts de proveedor
```yaml
providers:
  <id>:
    request_timeout_seconds: 1800
    stale_timeout_seconds: 90
    models:
      <model>:
        timeout_seconds: 120
        stale_timeout_seconds: 60
```
- `request_timeout_seconds` — timeout por request a nivel proveedor.
- `stale_timeout_seconds` — detector de llamadas estancadas (non-streaming).
- Defaults legacy: `HERMES_API_TIMEOUT=1800s`, `HERMES_API_CALL_STALE_TIMEOUT=90s`, Anthropic nativo 900s.

### 3.5 Comportamiento de actualización
```yaml
updates:
  pre_update_backup: quick   # quick (default) | full | off
  backup_keep: 5             # Cuántos zips de backup completos mantener
  non_interactive_local_changes: stash  # stash | discard
```
- `pre_update_backup: quick` — snapshot de archivos de estado críticos (pairing, cron, config, auth) en `state-snapshots/`.
- `full` — además zipea todo `HERMES_HOME` en `backups/`.
- `off` — desactiva ambos.

### 3.6 Runtime limits
```yaml
runtime:
  nofile_soft_limit: 4096
```
Aplica el límite soft de `RLIMIT_NOFILE` durante el arranque de superficies de servidor long-running (gateway, `hermes serve --isolated`). Default: 4096. `0`, `false` o `null` desactiva el ajuste.

### 3.7 Ejercicio práctico
**Objetivo:** Configurar un perfil de Hermes con modelo, backend Docker y una API key.

```bash
# 1. Setear el modelo
hermes config set model anthropic/claude-sonnet-4

# 2. Cambiar el backend a Docker
hermes config set terminal.backend docker

# 3. Añadir una API key (se guarda en .env automáticamente)
hermes config set OPENROUTER_API_KEY sk-or-...

# 4. Verificar
hermes config get model
hermes config get terminal.backend
```

### 3.8 Managed Scope (deployments de organización)
Un administrador puede fijar valores específicos de config y secretos que un usuario estándar **no puede sobrescribir**, vía un directorio gestionado a nivel de sistema. Ver [Managed Scope](/docs/user-guide/managed-scope).

Esto es útil en entornos corporativos donde quieres:
- Fijar el proveedor de modelo obligatorio.
- Bloquear el cambio de backend a `local`.
- Impedir que usuarios desactiven la seguridad.

### 3.9 Ejemplo de config.yaml completo
```yaml
# ~/.hermes/config.yaml
model: anthropic/claude-sonnet-4
provider: anthropic

terminal:
  backend: docker
  timeout: 180
  docker_image: "nikolaik/python-nodejs:python3.11-nodejs20"
  docker_network: true

approvals:
  mode: smart
  timeout: 300
  cron_mode: deny
  single_query_mode: deny

updates:
  pre_update_backup: quick
  backup_keep: 5

cron:
  model: anthropic/claude-sonnet-4
  model_drift_guard: true
  preflight: true

runtime:
  nofile_soft_limit: 4096

personalities:
  helpful: "You are a helpful, friendly AI assistant."
  pirate: "Arrr! Ye be talkin' to Captain Hermes..."

quick_commands:
  status:
    type: exec
    command: systemctl status hermes-agent
```

---

## MÓDULO 4 — Tools & Toolsets

### 4.1 ¿Qué es un toolset?
Las herramientas de Hermes están organizadas en **toolsets** por plataforma. Puedes activar/desactivar toolsets según lo que necesites.

```bash
hermes chat --toolsets "web,terminal,skills"
```

### 4.2 Toolsets principales
| Toolset | Descripción |
|---|---|
| **Web search** | Búsqueda en la web |
| **Browser automation** | Automatización de navegador |
| **Terminal** | Ejecución de comandos shell |
| **File editing** | Lectura/escritura/edición de archivos |
| **Memory** | Memoria persistente |
| **Delegation** | Delegar tareas a sub-agentes |
| **Scheduled tasks** | Tareas programadas (cron) |
| **Home Assistant** | Integración con domótica |

> **Nota:** La memoria cross-session de **Honcho** es un *plugin* (`plugins/memory/honcho/`), no un toolset built-in.

### 4.3 Ver tools disponibles
```bash
# En el CLI
/tools

# Desde la línea de comandos
hermes chat --toolsets skills -q "What skills do you have?"
hermes chat --toolsets skills -q "Show me the axolotl skill"
```

### 4.4 Ejercicio práctico
**Objetivo:** Explorar los toolsets disponibles y activar solo los que necesitas.

```bash
# 1. Ver qué toolsets hay
hermes chat --toolsets "web,terminal" -q "What tools do you have?"

# 2. Activar un set específico
hermes chat --toolsets "web,terminal,skills,memory"

# 3. Ver tools en sesión interactiva
hermes chat
> /tools
```

### 4.5 Modelo mental: toolsets como "permisos"
Piensa en los toolsets como **permisos granulares** que decides otorgar al agente:

- **Menos toolsets = más seguro.** Si el agente no necesita el terminal, no se lo des. Reduce la superficie de ataque.
- **Más toolsets = más capaz.** Un agente con web + terminal + skills puede hacer mucho más.
- **Balance:** empieza mínimo y añade según necesites. Es más fácil añadir que quitar.

### 4.6 Toolsets y seguridad
La elección de toolsets es tu **primera línea de defensa**. Antes de llegar a la aprobación de comandos peligrosos, puedes simplemente **no darle** el toolset que no quieres que use.

> ⚠️ El agente tiene el mismo acceso al filesystem que tu cuenta de usuario. Usa `hermes tools` para desactivar tools que no quieras, o cambia a Docker para sandboxing.

---

## MÓDULO 5 — Skills System

### 5.1 ¿Qué es una skill?
Las **skills** son documentos de conocimiento on-demand que el agente carga cuando las necesita. Siguen el patrón de **progressive disclosure** (divulgación progresiva) para minimizar el uso de tokens, y son compatibles con el estándar abierto **agentskills.io**.

**Dónde viven:** `~/.hermes/skills/` — directorio primario y fuente de verdad.

### 5.2 Progressive Disclosure (patrón eficiente de tokens)
```
Nivel 0: skills_list() → [{name, description, category}, ...]  (~3k tokens)
Nivel 1: skill_view(name) → Contenido completo + metadata
Nivel 2: skill_view(name, path) → Archivo de referencia específico
```
El agente **solo carga el contenido completo de la skill cuando realmente lo necesita**.

### 5.3 Usar skills
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

### 5.4 Formato SKILL.md
```yaml
---
name: my-skill
description: Brief description of what this skill does
version: 1.0.0
platforms: [macos, linux]  # Opcional — restringir a OS específicos
metadata:
  hermes:
    tags: [python, automation]
    category: devops
    fallback_for_toolsets: [web]  # Opcional — activación condicional
    requires_toolsets: [terminal]  # Opcional — activación condicional
    config:  # Opcional — settings de config.yaml
      - key: my.setting
        description: "What this controls"
        default: "value"
        prompt: "Prompt for setup"
---
```

### 5.5 Aprender skills desde fuentes (`/learn`)
```bash
# Un SDK o directorio de docs local
/learn the REST client in ~/projects/acme-sdk, focus on auth + pagination

# Una página de docs online
/learn https://docs.example.com/api/quickstart

# El workflow que acabas de hacer en esta conversación
/learn how I just deployed the staging server

# Notas pegadas / un procedimiento descrito
/learn filing an expense: open the portal, New > Expense, attach the receipt, submit

# Un libro entero → se convierte en knowledge-base skill
/learn ~/books/designing-data-intensive-applications.pdf
```

### 5.6 Large sources → knowledge-base skills
Cuando la fuente es un libro, un stack de papers, una spec o una carpeta grande de docs, el agente **no** la mete en un solo archivo ni la reduce a un resumen con pérdida. En su lugar, crea una **knowledge-base skill** expansiva:
- Un **SKILL.md** lean con los modelos mentales centrales + un índice.
- Un archivo destilado por capítulo/tema bajo `references/`.
- Un glosario o cheatsheet cuando la fuente lo merece.

Los archivos de referencia **no cuestan nada** hasta que una pregunta los necesita — el agente los carga on-demand con `skill_view`, así el costo de query es proporcional a la respuesta, no a la fuente.

### 5.7 Gestión de skills
```bash
hermes skills opt-out          # Dejar de sembrar skills bundled (no borra nada)
hermes skills opt-out --remove # También borra skills bundled NO modificadas
hermes skills opt-in --sync     # Revertir y re-sembrar
```

### 5.8 Pre-cargar skills al arranque
```bash
hermes -s hermes-agent-dev,github-auth
hermes chat -s github-pr-workflow -s github-auth
hermes chat -s github-pr-workflow -q "open a draft PR"
```
Hermes carga cada skill nombrada en el prompt de la sesión antes del primer turno.

### 5.9 Ejercicio práctico
**Objetivo:** Crear una skill reutilizable desde un procedimiento que ya conoces.

```bash
# 1. Aprender un procedimiento como skill
/learn how I just deployed the staging server

# 2. Verificar que se creó
hermes chat --toolsets skills -q "What skills do you have?"

# 3. Usarla como slash command
/deploy-staging

# 4. (Opcional) Escribir una skill a mano en ~/.hermes/skills/
# Crea un archivo ~/.hermes/skills/mi-skill/SKILL.md con el formato de 5.4
```

### 5.10 Skill bundles
Para combinaciones de skills que usas repetidamente, puedes crear un **skill bundle** — el mismo efecto que apilar skills, pero bajo un solo comando corto.

### 5.11 El skill `plan`
El skill bundled `plan` es un buen ejemplo. Correr `/plan [request]`:
1. Carga las instrucciones del skill.
2. Le dice a Hermes que inspeccione el contexto si es necesario.
3. Escribe un **plan de implementación en markdown** en vez de ejecutar la tarea.
4. Guarda el resultado bajo `.hermes/plans/` relativo al working directory activo.

### 5.12 Skills y progressive disclosure en la práctica
El patrón de progressive disclosure es lo que hace a Hermes **eficiente en tokens**:

- **Nivel 0** — el agente solo ve la lista de skills (nombres + descripciones). Costo fijo bajo (~3k tokens).
- **Nivel 1** — cuando una skill es relevante, carga su contenido completo.
- **Nivel 2** — si la skill tiene archivos de referencia, carga solo el que necesita.

Esto significa que puedes tener **cientos de skills** instaladas sin inflar el contexto de cada turno. El agente solo paga el costo de las que realmente usa.

### 5.13 Ejercicio avanzado: knowledge-base skill
**Objetivo:** Convertir un libro o docs grande en una knowledge-base skill.

```bash
# 1. Aprender un libro como knowledge-base skill
/learn ~/books/designing-data-intensive-applications.pdf

# 2. Ver la estructura creada
ls -la ~/.hermes/skills/designing-data-intensive-applications/
# Deberías ver SKILL.md + references/ con un archivo por capítulo

# 3. Hacer preguntas que requieran cargar referencias
hermes chat -q "Explain the CAP theorem from my book"
```

---

## MÓDULO 6 — Memoria Persistente

### 6.1 ¿Qué es la memoria de Hermes?
Hermes usa **memoria acotada y curada** — no guarda todo, guarda lo que importa. Vive en `~/.hermes/memories/`.

### 6.2 Los dos archivos clave
| Archivo | Tamaño típico | Contenido |
|---|---|---|
| **MEMORY.md** | ~2,200 chars (~800 tokens) | Notas personales del agente, decisiones, lecciones |
| **USER.md** | ~1,375 chars (~500 tokens) | Perfil del usuario, preferencias, contexto |

Este diseño mantiene el contexto limpio y el costo de tokens bajo, mientras conserva lo esencial a largo plazo.

### 6.3 Cómo funciona en la práctica
- El agente lee MEMORY.md y USER.md al inicio de cada sesión.
- A medida que aprende cosas nuevas, actualiza estos archivos.
- La memoria es **curada** — el agente decide qué vale la pena conservar.

### 6.4 Honcho (memoria cross-session)
**Honcho** es un plugin de memoria cross-session en `plugins/memory/honcho/`. No es un toolset built-in, sino un plugin opcional que permite memoria persistente entre sesiones y agentes.

### 6.5 Ejercicio práctico
**Objetivo:** Ver y entender la memoria del agente.

```bash
# 1. Ver el contenido de la memoria
cat ~/.hermes/memories/MEMORY.md
cat ~/.hermes/memories/USER.md

# 2. Preguntar al agente sobre su memoria
hermes chat -q "What do you remember about me?"

# 3. (Opcional) Editar USER.md para añadir preferencias
# Añade tus preferencias de tono, horario, etc.
```

### 6.6 Modelo mental: memoria curada vs memoria cruda
| Aspecto | Memoria curada (Hermes) | Memoria cruda (logs) |
|---|---|---|
| **Qué guarda** | Lo esencial, destilado | Todo, sin filtrar |
| **Tamaño** | Acotado (~800 tokens MEMORY.md) | Crece sin límite |
| **Costo de tokens** | Bajo y predecible | Alto y creciente |
| **Calidad** | Alta (curada por el agente) | Variable (ruido incluido) |
| **Uso** | Contexto de cada turno | Análisis offline |

La memoria curada es la elección correcta para el **contexto de cada turno** — mantiene el costo bajo y la calidad alta. La memoria cruda (logs, state.db) es útil para **análisis offline** y auditoría.

### 6.7 Cómo el agente decide qué recordar
El agente actualiza MEMORY.md y USER.md a medida que aprende cosas nuevas. Las decisiones típicas:
- **Recordar:** preferencias del usuario, decisiones importantes, lecciones aprendidas, contexto de proyectos.
- **No recordar:** detalles efímeros, conversaciones triviales, datos que se pueden re-derivar.

> 💡 Puedes guiar esto explícitamente: "Recuerda que prefiero respuestas en español" o "Guarda esto en tu memoria".

### 6.8 Ejercicio avanzado: enseñar memoria
**Objetivo:** Hacer que el agente recuerde preferencias a largo plazo.

```bash
# 1. Decirle al agente que recuerde algo
hermes chat -q "Remember that I prefer concise answers in Spanish"

# 2. Verificar que lo guardó
cat ~/.hermes/memories/USER.md

# 3. Probar en una sesión nueva
hermes chat -q "How should you answer me?"
# Debería reflejar la preferencia guardada
```

---

## MÓDULO 7 — Scheduled Tasks (Cron)

### 7.1 ¿Qué es cron en Hermes?
Hermes expone la gestión de cron a través de **un solo tool `cronjob`** con operaciones estilo action (en vez de tools separados de schedule/list/remove).

### 7.2 Qué puede hacer cron
- Programar tareas **one-shot** o **recurrentes**
- **Pausar, reanudar, editar, disparar y eliminar** jobs
- Adjuntar **cero, una o múltiples skills** a un job
- Entregar resultados al chat de origen, archivos locales o plataformas configuradas
- Correr en sesiones de agente frescas
- Correr en **modo no-agente** (script en un schedule, stdout entregado verbatim, cero LLM)

### 7.3 Crear tareas
```bash
# En chat con /cron
/cron add 30m "Remind me to check the build"
/cron add "every 2h" "Check server status"
/cron add "every 1h" "Summarize new feed items" --skill blogwatcher

# Desde el CLI standalone
hermes cron create "every 2h" "Check server status"
hermes cron create "every 1h" "Summarize new feed items" --skill blogwatcher
hermes cron create "every 1h" "Use both skills and combine the result" \
  --skill blogwatcher \
  --skill maps \
  --name "Skill combo"

# Por conversación natural
# "Every morning at 9am, check Hacker News for AI news and send me a summary on Telegram."
```

### 7.4 Ciclo de vida
```bash
hermes cron list
hermes cron pause <job_id>
hermes cron resume <job_id>
hermes cron run <job_id>
hermes cron remove <job_id>
hermes cron edit <job_id> --schedule "every 4h"
hermes cron edit <job_id> --prompt "Use the revised task"
hermes cron edit <job_id> --skill blogwatcher --skill maps
hermes cron edit <job_id> --add-skill maps
hermes cron edit <job_id> --remove-skill blogwatcher
hermes cron edit <job_id> --clear-skills
hermes cron status
hermes cron tick
```

### 7.5 Skills adjuntas a jobs cron
```python
# Un solo skill
cronjob(
    action="create",
    skill="blogwatcher",
    prompt="Check the configured feeds and summarize anything new.",
    schedule="0 9 * * *",
    name="Morning feeds",
)

# Múltiples skills (se cargan en orden)
cronjob(
    action="create",
    skills=["blogwatcher", "maps"],
    prompt="Look for new local events and interesting nearby places, then combine them into one short brief.",
    schedule="every 6h",
    name="Local brief",
)
```

### 7.6 Correr un job dentro de un directorio de proyecto
```bash
hermes cron create "every 1d at 09:00" \
  "Audit open PRs, summarize CI health, and post to #eng" \
  --workdir /home/me/projects/acme
```
Cuando `workdir` está seteado:
- `AGENTS.md`, `CLAUDE.md` y `.cursorrules` de ese directorio se inyectan en el system prompt.
- `terminal`, `read_file`, `write_file`, `patch`, `search_files` y `execute_code` usan ese directorio como working directory.
- La ruta debe ser un directorio absoluto que exista.

> ⚠️ **Serialización:** Los jobs con workdir corren secuencialmente en el tick del scheduler, no en el pool paralelo. Esto es deliberado: el worker aplica el workdir a través de estado global del terminal, así que dos jobs con workdir corriendo a la vez se corromperían el cwd.

### 7.7 ¿Qué modelo usa un job cron?
Resolución al momento de disparo: **per-job pin → cron.model en config.yaml → default global de `hermes model`**.

```yaml
cron:
  model: anthropic/claude-sonnet-4   # Default para toda la flota de cron
  model_provider: anthropic
```

> ⚠️ **Drift guard:** Si el default global cambia y un job no tiene pin, el job **falla cerrado** (skip, no hace llamada de inferencia, alerta una vez). Esto evita que un job desatendido herede silenciosamente un cambio a un proveedor/modelo de pago. Desactívalo con `cron.model_drift_guard: false` si quieres que sigan el default global.

### 7.8 Validación pre-dispatch
Antes de construir cualquier maquinaria de agente para un run programado, el scheduler valida que la configuración del job pueda producir un run exitoso:
- La API key del proveedor se resuelve (se salta si hay cadena de `fallback_providers`).
- Las skills adjuntas están listas (sin env vars requeridas faltantes, comandos o archivos de credenciales).
- Los targets de plataforma de entrega son conocidos y tienen credenciales de gateway configuradas.

Cuando la validación falla, el `last_status` del job se vuelve `blocked_config`, se entrega UNA alerta (no se repite cada tick), y **no se hace ninguna llamada LLM** — un job mal configurado nunca gasta tokens.

Desactivable con:
```yaml
cron:
  preflight: false
```

### 7.9 Modo no-agente (script-only)
Un job cron puede correr en **modo no-agente**: un script en un schedule, su stdout entregado verbatim, **cero involucramiento de LLM**.

### 7.10 Restricciones de seguridad
> ⚠️ **Los jobs cron NO pueden crear recursivamente más jobs cron** — Hermes desactiva las tools de gestión de cron dentro de ejecuciones cron para prevenir loops de scheduling descontrolados.

### 7.11 Ejercicio práctico
**Objetivo:** Crear un job cron recurrente que te envíe un resumen diario.

```bash
# 1. Crear un job diario a las 9am
hermes cron create "0 9 * * *" "Check Hacker News for AI news and send me a summary on Telegram."

# 2. Ver el job
hermes cron list

# 3. Dispararlo manualmente para probar
hermes cron run <job_id>

# 4. Pausarlo si no lo necesitas
hermes cron pause <job_id>

# 5. Reanudarlo
hermes cron resume <job_id>
```

### 7.12 Modelo mental: cron como "agente desatendido"
Piensa en los jobs cron como **agentes desatendidos** que corren en tu nombre:

- **Sin supervisión humana** — corren solos en el schedule.
- **Con guardarraíles** — el drift guard evita que hereden cambios de modelo/proveedor; el preflight evita que gasten tokens si están mal configurados.
- **Con skills** — pueden cargar skills para heredar workflows reutilizables.
- **Con entrega** — pueden enviar resultados a tu chat, archivos locales o plataformas.

### 7.13 Cron y seguridad
- **`cron_mode: deny`** (default) — cuando un job cron golpea un comando peligroso, lo bloquea (el agente debe encontrar otro camino).
- **`cron_mode: approve`** — auto-aprueba todo en contexto cron (peligroso para jobs desatendidos).
- **Los jobs cron NO pueden crear más jobs cron** — previene loops de scheduling descontrolados.
- **Preflight validation** — un job mal configurado nunca gasta tokens.

### 7.14 Ejercicio avanzado: cron con skills y workdir
**Objetivo:** Crear un job que corra dentro de un proyecto con skills adjuntas.

```bash
# 1. Crear un job con skill y workdir
hermes cron create "every 1d at 09:00" \
  "Audit open PRs, summarize CI health, and post to #eng" \
  --skill github-pr-workflow \
  --workdir /home/me/projects/acme

# 2. Verificar que carga AGENTS.md del proyecto
hermes cron list

# 3. Editar el job
hermes cron edit <job_id> --schedule "every 2d at 09:00"
```

---

## MÓDULO 8 — MCP (Model Context Protocol)

### 8.1 ¿Qué es MCP en Hermes?
MCP permite a Hermes conectarse a **servidores de tools externos** — GitHub, bases de datos, file systems, browser stacks, APIs internas, y más.

> **¿Vienes de Claude Code?** El bloque `mcpServers` de tu `~/.claude.json` mapea a `mcp_servers` en el config.yaml de Hermes. `hermes import-agent claude-code` lo migra automáticamente (junto con skills e instructions).

### 8.2 Qué te da MCP
- Acceso a ecosistemas de tools externas sin escribir un tool nativo de Hermes primero.
- Servidores stdio locales y servidores HTTP MCP remotos en el mismo config.
- Descubrimiento y registro automático de tools al arranque.
- Wrappers de utilidad para recursos y prompts MCP cuando el servidor los soporta.
- Filtrado por servidor para exponer solo las tools MCP que quieres que Hermes vea.

### 8.3 Quick start
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
Hermes descubrirá las tools del servidor MCP y las usará como cualquier otra tool.

### 8.4 Catálogo de MCPs aprobados por Nous
```bash
hermes mcp              # Picker interactivo (default)
hermes mcp catalog       # Lista en texto plano, scriptable
hermes mcp install n8n   # Instalar una entrada del catálogo por nombre
hermes mcp configure linear  # Re-abrir el checklist de selección de tools
```

El picker muestra cada entrada con su estado actual:
```
n8n      available   Manage and inspect n8n workflows from Hermes
linear   enabled     Linear issue/project management (remote OAuth)
github   installed (disabled)  GitHub repo + PR tools
```

- Los catálogos están **deshabilitados por defecto** — instala solo lo que quieras.
- Cada entrada requiere **API key, OAuth (remote MCP)** o **OAuth de terceros** (Google/GitHub).
- **Selección de tools al instalar:** Hermes sondea el servidor, lista todas sus tools y te presenta un checklist (SPACE toggle, ENTER confirm).
- **Modelo de confianza:** los manifests pasan por revisión de PR en el repo de hermes-agent. Lee el manifest antes de instalar, especialmente el campo `source:`.

### 8.5 Sustitución de variables en runtime
Dentro de `transport.command`, `transport.args`, `transport.url` y `headers`, los placeholders `${VAR}` se resuelven al conectar desde variables de entorno (incluye todo lo de `~/.hermes/.env`).

También se sustituyen variables estilo Cursor (case-sensitive):
- `${userHome}` — directorio home
- `${workspaceFolder}` — raíz del workspace de la sesión
- `${workspaceFolderBasename}` — nombre base del workspace
- `${pathSeparator}` / `${/}` — separador de path del OS

### 8.6 Ejercicio práctico
**Objetivo:** Conectar un servidor MCP de filesystem y usarlo.

```yaml
# 1. Añadir el servidor MCP a config.yaml
mcp_servers:
  filesystem:
    command: "npx"
    args: ["-y", "@modelcontextprotocol/server-filesystem", "/home/user/projects"]
```
```bash
# 2. Arrancar Hermes
hermes chat

# 3. Pedirle que use el MCP
# "List the files in /home/user/projects and summarize the repo structure."

# 4. (Opcional) Instalar un MCP del catálogo
hermes mcp install n8n
```

### 8.7 Modelo mental: MCP como "puente a tools externas"
MCP es el estándar para conectar agentes a **ecosistemas de tools que ya existen**. En vez de escribir un tool nativo de Hermes para cada integración, MCP te deja reutilizar servidores de tools ya construidos:

- **GitHub** — repos, PRs, issues.
- **Bases de datos** — consultas SQL.
- **File systems** — acceso a directorios.
- **Browser stacks** — automatización de navegador.
- **APIs internas** — servicios de tu empresa.

### 8.8 MCP y seguridad
- **Filtrado de credenciales MCP** — las variables de entorno de los subprocesos MCP se aíslan (capa 5 de seguridad).
- **Selección de tools al instalar** — solo expones las tools MCP que quieres que Hermes vea.
- **Modelo de confianza del catálogo** — los manifests pasan por revisión de PR en el repo de hermes-agent. Lee el manifest antes de instalar, especialmente el campo `source:`.

### 8.9 Ejercicio avanzado: MCP con filtrado de tools
**Objetivo:** Instalar un MCP del catálogo y seleccionar solo las tools que necesitas.

```bash
# 1. Instalar un MCP del catálogo
hermes mcp install linear

# 2. En el checklist, selecciona solo las tools que necesitas
# [x] find_issues
# [x] get_issue
# [x] create_issue
# [ ] delete_workspace   ← deselecciona las peligrosas

# 3. Re-configurar la selección después
hermes mcp configure linear
```

---

## MÓDULO 9 — Seguridad (Defense-in-Depth)

### 9.1 Las 8 capas de seguridad
1. **Autorización de usuario** — quién puede hablar con el agente (allowlists, DM pairing)
2. **Aprobación de comandos peligrosos** — human-in-the-loop para operaciones destructivas
3. **Seguridad de escritura de archivos** — denylist y sandbox opcional para write_file/patch
4. **Aislamiento de contenedores** — Docker/Singularity/Modal con hardening
5. **Filtrado de credenciales MCP** — aislamiento de variables de entorno para subprocesos MCP
6. **Escaneo de archivos de contexto** — detección de prompt injection en archivos de proyecto
7. **Aislamiento cross-session** — las sesiones no acceden a datos/estado de otras; rutas de cron endurecidas contra path traversal
8. **Sanitización de input** — parámetros de working directory validados contra allowlist para prevenir shell injection

### 9.2 Aprobación de comandos peligrosos

**Modos de aprobación** (`approvals.mode` en config.yaml):
```yaml
approvals:
  mode: smart        # smart | manual | off
  timeout: 300       # segundos para esperar respuesta (default: 300)
  cron_mode: deny    # deny | approve — qué hacen los jobs cron con comandos peligrosos
  single_query_mode: deny  # deny | approve — qué hacen las sesiones -q
  mcp_reload_confirm: true  # /reload-mcp pregunta antes de invalidar el cache de tools MCP
  destructive_slash_confirm: true  # /clear, /new, /reset, /undo preguntan antes de descartar estado
```

| Modo | Comportamiento |
|---|---|
| **smart** (default) | Usa un LLM auxiliar para evaluar riesgo. Comandos de bajo riesgo se auto-aprueban; peligrosos se auto-denegan; inciertos escalan a prompt manual |
| **manual** | Siempre pregunta al usuario por comandos peligrosos |
| **off** | Desactiva todos los checks (equivale a `--yolo`) |

### 9.3 YOLO Mode
```bash
hermes --yolo          # CLI flag
/yolo                  # Slash command (toggle)
HERMES_YOLO_MODE=1      # Env var
```
> ⚠️ YOLO desactiva todos los checks de seguridad de comandos peligrosos **excepto el hardline blocklist**.

Cuando YOLO está activo, Hermes muestra dos recordatorios visuales persistentes:
- Un **banner rojo** al inicio de la sesión: `⚠ YOLO mode — all approval prompts bypassed`.
- Un fragmento `⚠ YOLO` en la status bar, actualizado en vivo.

### 9.4 Hardline Blocklist (piso siempre-activo)
Comandos tan catastróficos que Hermes **se niega a ejecutarlos sin importar nada** (ni `--yolo`, ni `approvals.mode: off`, ni cron headless, ni "allow always"):

| Patrón | Por qué es hardline |
|---|---|
| `rm -rf /` y variantes obvias | Borra la raíz del filesystem |
| `rm -rf --no-preserve-root /` | El "sí, me refiero a root" explícito |
| `:(){ :|:& };:` (fork bomb) | Congela el host hasta reboot |
| `mkfs.*` en un dispositivo root montado | Formatea el sistema vivo |
| `dd if=/dev/zero of=/dev/sd*` | Zeroea un disco físico |
| Piping de URLs no confiables a `sh` en el rootfs | Vector de RCE demasiado amplio |

Si tocas el blocklist, el tool call devuelve un error explicativo al agente y **nada se ejecuta**.

### 9.5 Reglas de denegación definidas por el usuario (`approvals.deny`)
```yaml
approvals:
  deny:
    - "git push --force*"
    - "*curl*|*sh*"
    - "dd if=* of=/dev/*"
```
- Patrones glob (fnmatch) que bloquean comandos incondicionalmente — antes de `--yolo`, `/yolo` y `approvals.mode: off`.
- Útil para "yolo con excepciones": "deja que el agente haga todo, excepto estas cosas específicas, nunca".
- Matching corre sobre las mismas variantes normalizadas/deofuscadas que usa el detector de patrones peligrosos, así que trucos de quoting simple (`git pu""sh --force`) no se cuelan.
- **YAML quoting:** siempre cita los patrones. Un `*` inicial desnudo es un alias YAML y falla al parsear.

### 9.6 Flujo de aprobación (CLI)
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

### 9.7 Flujo de aprobación (Gateway/Messaging)
En plataformas de mensajería, el agente envía los detalles del comando peligroso al chat y espera la respuesta del usuario:
- Responde `yes`, `y`, `approve`, `ok` o `go` para aprobar.
- Responde `no`, `n`, `deny` o `cancel` para denegar.

La variable de entorno `HERMES_EXEC_ASK=1` se setea automáticamente al correr el gateway.

### 9.8 Allowlist permanente
```yaml
# config.yaml
command_allowlist:
  - rm
  - systemctl
```
Los patrones se cargan al arranque y se aprueban silenciosamente en todas las sesiones futuras.

> 💡 Usa `hermes config edit` para revisar o quitar patrones de tu allowlist permanente.

### 9.9 Minería de historial de aprobaciones
```bash
hermes approvals suggest              # Dry run — imprime propuesta numerada
hermes approvals suggest --apply 1,3  # Fusionar picks en command_allowlist
hermes approvals suggest --json        # Salida machine-readable
```
Escanea `~/.hermes/state.db` buscando comandos peligrosos que realmente ejecutaste (aprobaste), los agrega en patrones y los rankea por frecuencia.

**Reglas de seguridad:**
- Nada se aplica automáticamente — el run default es read-only; solo `--apply N[,M...]` escribe en config.yaml.
- Las clases destructivas nunca se proponen, sin importar cuántas veces se aprobaron: deletes recursivos, sudo, escrituras a disco/dispositivos, ediciones de credenciales y config del sistema, pipe-to-shell, SQL DROP/TRUNCATE, kills de procesos, y toda clase hardline.
- Las propuestas ya cubiertas por tu `command_allowlist` existente se saltan.

Flags útiles: `--days N` (ventana de historial, default 90), `--min-count N` (mínimo de aprobaciones para calificar, default 2), `--limit N`, `--db PATH`.

### 9.10 Seguridad de escritura de archivos
Antes de que `write_file` o `patch` toquen disco, Hermes chequea la ruta contra un denylist y un sandbox opcional. Los writes bloqueados devuelven un error al agente inmediatamente — no hay prompt de aprobación ni forma de override desde la UI del chat.

**Rutas protegidas (siempre bloqueadas):**
| Categoría | Ejemplos |
|---|---|
| Almacenes de credenciales del SO | `~/.ssh/`, `~/.aws/`, `~/.kube/`, `/etc/sudoers`, `~/.netrc` |
| Almacenes de credenciales de Hermes | `auth.json`, `.env`, `.anthropic_oauth.json`, `mcp-tokens/`, `pairing/` |
| Archivos secretos de proyecto | `.env`, `.env.local`, `.env.production`, `.envrc` |

**Sandbox opcional (`HERMES_WRITE_SAFE_ROOT`):**
```bash
export HERMES_WRITE_SAFE_ROOT=/path/to/project:/home/you/.hermes
```
Cuando está seteado, `write_file` y `patch` solo pueden apuntar a rutas dentro de los prefijos listados. Se setea automáticamente en la imagen Docker oficial (`/opt/data`).

> ⚠️ **Defense-in-depth, no un límite duro:** Los guards de escritura aplican solo a `write_file` y `patch`. El tool terminal corre como el mismo usuario del OS y puede `cat` o sobrescribir rutas denegadas vía comandos shell. El denylist reduce daño accidental y da a los modelos una señal clara de stop; no sandboxea un agente hostil o comprometido.

### 9.11 Autorización de usuarios (Gateway)
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
WHATSAPP_ALLOWED_USERS=15551234567
SLACK_ALLOWED_USERS=U01ABC123
GATEWAY_ALLOWED_USERS=123456789
```
> ⚠️ Si no hay allowlists configuradas y `GATEWAY_ALLOW_ALL_USERS` no está seteado, **todos los usuarios son denegados**.

### 9.12 DM Pairing (alternativa a allowlists)
```bash
# El usuario ve: "Pairing code: XKGH5N7P"
hermes pairing approve telegram XKGH5N7P
hermes pairing list
hermes pairing revoke telegram 123456789
```
Los códigos expiran después de 1 hora, tienen rate-limit y usan aleatoriedad criptográfica.

### 9.13 Admins vs Usuarios regulares
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

### 9.14 Ejercicio práctico
**Objetivo:** Configurar un gateway seguro con allowlists y probar el flujo de aprobación.

```bash
# 1. Configurar allowlist de Telegram
# Añade a ~/.hermes/.env:
# TELEGRAM_ALLOWED_USERS=123456789

# 2. Probar el flujo de aprobación en CLI
hermes chat
# Pide un comando peligroso y observa el prompt de aprobación

# 3. Probar YOLO mode (con cuidado)
hermes --yolo
> /yolo   # toggle off

# 4. Ver tu acceso
/whoami
```

### 9.15 Modelo mental: las 8 capas como "cebolla"
La seguridad de Hermes es **defense-in-depth** — piensa en ella como una cebolla con 8 capas. Si una capa falla, las demás siguen protegiendo:

1. **Autorización de usuario** — ¿quién puede hablar con el agente?
2. **Aprobación de comandos** — ¿puede ejecutar comandos destructivos sin permiso?
3. **Seguridad de escritura** — ¿puede sobrescribir archivos sensibles?
4. **Aislamiento de contenedores** — ¿está sandboxeado?
5. **Filtrado de credenciales MCP** — ¿los subprocesos MCP ven tus secretos?
6. **Escaneo de contexto** — ¿hay prompt injection en archivos de proyecto?
7. **Aislamiento cross-session** — ¿una sesión puede ver los datos de otra?
8. **Sanitización de input** — ¿los parámetros de working directory están validados?

### 9.16 Threat model: honesto-pero-equivocado vs hostil
Es crucial entender el **threat model** de Hermes:

- **Guardarraíles** (approval, deny rules, blocklist) protegen contra un agente **honesto-pero-equivocado** — que intenta hacer lo correcto pero puede equivocarse.
- **No son un sandbox** contra un agente **deliberadamente adversarial** — para eso necesitas un backend aislado (Docker, Modal) o un entorno con restricción de egress.

> ⚠️ **Defense-in-depth, no un límite duro:** Los guards de escritura aplican solo a `write_file` y `patch`. El tool terminal corre como el mismo usuario del OS y puede `cat` o sobrescribir rutas denegadas vía comandos shell.

### 9.17 Ejercicio avanzado: deny rules con excepciones
**Objetivo:** Configurar "yolo con excepciones" — deja que el agente haga casi todo, pero bloquea operaciones específicas para siempre.

```yaml
# ~/.hermes/config.yaml
approvals:
  mode: smart
  deny:
    - "git push --force*"
    - "*curl*|*sh*"
    - "dd if=* of=/dev/*"
```

```bash
# Probar que el deny rule bloquea
hermes chat
# Pide: git push --force origin main
# Debería devolver un error BLOCKED
```

---

## MÓDULO 10 — Messaging Gateway

### 10.1 ¿Qué es el gateway de mensajería?
Hermes se conecta a **muchísimas plataformas**: Telegram, Discord, Slack, WhatsApp, Signal, SMS, Email, Home Assistant, Mattermost, Matrix, DingTalk, Feishu/Lark, WeCom, Weixin, BlueBubbles (iMessage), QQ, Yuanbao, Microsoft Teams, LINE, ntfy, y tu navegador.

### 10.2 Setup
```bash
hermes gateway setup   # Setup interactivo para todas las plataformas
hermes gateway         # Correr en foreground
hermes gateway install # Instalar como servicio de usuario
hermes gateway start    # Iniciar el servicio
hermes gateway status   # Ver estado
```

### 10.3 Comparativa de plataformas (capacidades)
| Plataforma | Voz | Imágenes | Archivos | Threads | Reacciones | Typing | Streaming |
|---|---|---|---|---|---|---|---|
| Telegram | ✅ | ✅ | ✅ | ✅ | — | ✅ | ✅ |
| Discord | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Slack | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Google Chat | — | ✅ | ✅ | ✅ | — | ✅ | — |
| WhatsApp | — | ✅ | ✅ | — | — | ✅ | ✅ |
| WhatsApp Cloud API | ✅ | ✅ | ✅ | — | — | ✅ | — |
| Signal | — | ✅ | ✅ | — | — | ✅ | — |
| SMS | — | — | — | — | — | — | — |
| Email | — | ✅ | ✅ | ✅ | — | — | — |
| Home Assistant | — | — | — | — | — | — | — |
| Mattermost | ✅ | ✅ | ✅ | ✅ | — | ✅ | ✅ |
| Matrix | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| DingTalk | — | ✅ | ✅ | — | ✅ | — | ✅ |
| Feishu/Lark | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| WeCom | ✅ | ✅ | ✅ | — | — | — | — |
| Weixin | ✅ | ✅ | ✅ | — | — | ✅ | — |
| BlueBubbles | — | ✅ | ✅ | — | ✅ | ✅ | — |
| Photon (iMessage) | ✅ | ✅ | ✅ | — | ✅ | ✅ | — |
| QQ | ✅ | ✅ | ✅ | — | — | ✅ | — |
| Yuanbao | ✅ | ✅ | ✅ | — | — | ✅ | ✅ |
| Microsoft Teams | — | ✅ | — | ✅ | — | ✅ | — |
| LINE | — | ✅ | ✅ | — | — | ✅ | — |
| ntfy | — | — | — | — | — | — | — |
| SimpleX | ✅ | ✅ | ✅ | — | — | ✅ | — |

**Leyenda:** Voz = respuestas de audio TTS y/o transcripción de mensajes de voz. Imágenes = enviar/recibir imágenes. Archivos = adjuntos. Threads = conversaciones en hilos. Reacciones = reacciones emoji. Typing = indicador de escritura. Streaming = actualizaciones progresivas de mensajes vía edición.

### 10.4 Slash commands dentro de mensajería
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
/sethome             → Setear este chat como canal home
/compress            → Comprimir contexto manualmente
/title [name]        → Setear/ver título de sesión
/resume [name]       → Reanudar sesión nombrada
/sessions [all] [search <query>] → Listar sesiones previas
/usage               → Uso de tokens
/insights [days]     → Insights y analytics de uso
/reasoning [level|show|hide] → Cambiar esfuerzo de razonamiento
/voice [on|off|tts|join|leave|status] → Controlar voz
/rollback [number]   → Restaurar checkpoints del filesystem
/background <prompt> → Correr prompt en sesión separada
/reload-mcp          → Recargar servidores MCP
/update              → Actualizar Hermes
/help                → Mostrar comandos
/<skill-name>        → Invocar cualquier skill instalada
```

### 10.5 Tokens de silencio intencional
Para group chats, hooks y flujos de automatización, Hermes soporta tokens de silencio explícitos. Si la respuesta final del agente es exactamente un token soportado, el gateway **suprime la entrega** y no envía nada al chat.

Tokens soportados: `[SILENT]`, `SILENT`, `NO_REPLY`, `NO REPLY`

> El silencio es solo una decisión de entrega. Hermes mantiene el turno de silencio en el transcript de la sesión, así la conversación alterna normalmente.

### 10.6 Fiabilidad de entrega (delivery ledger)
Las respuestas finales se registran en un ledger durable (`state.db`). Si el gateway crashea entre producir una respuesta y confirmar el envío, el próximo boot **re-entrega** la respuesta almacenada en vez de perderla o re-ejecutar todo el turno.
- Semántica honesta **at-least-once**.
- Una respuesta que nunca empezó a enviarse se re-entrega tal cual.
- Una respuesta a medio enviar se re-entrega con prefijo visible `♻️ Recovered reply — … may be a duplicate`.
- Re-entrega acotada: 3 intentos, 24h de frescura, luego se abandona. Rows entregadas se podan tras 7 días.
- Desactivable con `gateway.delivery_ledger: false`.

### 10.7 Reset policies
```yaml
session_reset:
  mode: idle   # "idle", "daily", "both", o "none" (default)
  idle_minutes: 1440
  at_hour: 4
```
| Modo | Descripción |
|---|---|
| none | Nunca auto-reset (default) |
| daily | Reset a una hora específica cada día |
| idle | Reset tras N minutos de inactividad |
| both | Lo que dispare primero |

### 10.8 Overrides por canal
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
      "987654321098765432":
        model: openai/gpt-5-mini
```
- Las tres keys son opcionales — setea solo `model`, solo `system_prompt`, o cualquier combinación.
- Orden de lookup: ID exacto de channel/thread primero, luego ID del parent channel/forum.
- Prioridad de resolución del modelo: override de sesión `/model` → `channel_overrides` → config global.

### 10.9 Redirigir al agente (busy-input mode)
```yaml
display:
  busy_input_mode: steer   # o queue, o interrupt (default)
  busy_ack_enabled: true
```
- **interrupt** (default) — tu mensaje redirige el turno activo
- **queue** — los mensajes esperan y corren como siguiente turno
- **steer** — se inyectan en el run actual vía `/steer`

### 10.10 Clarify questions (multi-select)
Cuando el agente usa el tool `clarify` para preguntarte algo, el gateway renderiza las opciones como un prompt numerado (o botones nativos en plataformas que los soporten). Clarify soporta preguntas multi-select:
- **Plataformas de mensajería** — el prompt dice "Multiple selections allowed"; responde con números separados por comas o espacios (ej. `1, 3`), el texto de la opción, o tu propia respuesta libre.
- **CLI/TUI clásico** — multi-select renderiza como checkboxes: Space alterna, Enter envía.

### 10.11 Tool progress notifications
```yaml
display:
  tool_progress: all   # off | new | all | verbose | log
  tool_progress_command: false
  tool_progress_grouping: accumulate  # accumulate | separate
```
- **log mode** — no envía burbujas de progreso al chat; cada tool call se añade como línea a `~/.hermes/logs/tool_calls.log` (archivo de auditoría rotativo, 5 MB × 3 backups, con redacción de secretos).

### 10.12 Ejercicio práctico
**Objetivo:** Conectar Hermes a Telegram y configurar un bot seguro.

```bash
# 1. Setup interactivo
hermes gateway setup

# 2. Configurar allowlist
# Añade a ~/.hermes/.env:
# TELEGRAM_ALLOWED_USERS=123456789

# 3. Arrancar el gateway
hermes gateway

# 4. Probar desde Telegram
# Envía un mensaje al bot y observa la respuesta

# 5. Ver tu acceso
/whoami
```

### 10.13 Modelo mental: el gateway como "hub central"
El gateway es un **hub central** que conecta todas tus plataformas a un solo agente:

- **Un solo proceso** — se conecta a todas las plataformas configuradas.
- **Sesiones por chat** — cada chat tiene su propia sesión y contexto.
- **Cron integrado** — el gateway también corre el scheduler de cron.
- **Voz** — entrega mensajes de voz.

### 10.14 Hermes Relay (experimental)
**Hermes Relay** no es una plataforma de chat en sí — es un **sistema de conectores** que fronta plataformas como Discord, Telegram, Slack y WhatsApp a través de un conector externo que posee las credenciales de la plataforma. Las capacidades (media, prompts nativos de aprobación/clarify, reacciones, threads, typing, streaming) se negocian por conector al handshake.

### 10.15 Admins vs usuarios en la práctica
El split admin/user responde dos preguntas:
- **Allowlists** — ¿puede esta persona llegar al bot en absoluto?
- **Admin/user** — ya que está dentro, ¿qué se le permite hacer?

Cada usuario permitido cae en uno de dos tiers por scope (DM vs grupo/canal):
- **Admin** — acceso completo, puede correr todos los slash commands.
- **Regular user** — puede chatear, pero solo los slash commands que habilites explícitamente (piso: `/help` y `/whoami`).

> 💡 El DM admin status no implica group/channel admin status — cada scope tiene su propia lista de admins.

### 10.16 Ejercicio avanzado: overrides por canal
**Objetivo:** Configurar diferentes modelos/personas por canal en Discord.

```yaml
# ~/.hermes/gateway-config.yaml
platforms:
  discord:
    enabled: true
    channel_overrides:
      "123456789012345678":
        model: anthropic/claude-sonnet-4.6
        provider: anthropic
        system_prompt: "You are the #dev channel code-review specialist."
      "987654321098765432":
        model: openai/gpt-5-mini
```

```bash
# Verificar que el override funciona
hermes gateway restart
# Envía un mensaje en cada canal y observa el modelo/persona
```

---

## MÓDULO 11 — CLI Interface

### 11.1 ¿Qué es el CLI de Hermes?
El CLI de Hermes es una **interfaz de terminal completa (TUI)** — no una web UI. Incluye edición multilínea, autocompletado de slash commands, historial de conversación, interrupt-and-redirect, y streaming de output de tools. Construido para gente que vive en la terminal.

### 11.2 Comandos principales
```bash
hermes                          # Sesión interactiva (default)
hermes chat -q "Hello"          # Single query mode
hermes chat --model "anthropic/claude-sonnet-4"
hermes chat --provider nous     # Usar Nous Portal
hermes chat --toolsets "web,terminal,skills"
hermes -s hermes-agent-dev,github-auth   # Pre-cargar skills
hermes --continue               # Reanudar sesión más reciente (-c)
hermes --resume <session_id>    # Reanudar sesión específica (-r)
hermes --resume latest          # Reanudar la más reciente
hermes -w                       # Git worktree aislado (agentes paralelos)
hermes -w -z "Fix issue #123"   # Single query en worktree
hermes chat --verbose           # Modo verbose (debug)
```

### 11.3 Status bar
```
 ⚕ claude-sonnet-4-20250514 │ 12.4K/200K │ [██████░░░░] 6% │ $0.06 │ 15m
```
| Elemento | Descripción |
|---|---|
| Model name | Modelo actual (truncado si >26 chars) |
| Token count | Tokens de contexto usados / máx |
| Context bar | Indicador visual con umbrales de color |
| Cost | Costo estimado de sesión |
| 🗜️ N | Conteo de compresiones de contexto |
| ▶ N | Tareas background activas |
| Duration | Tiempo transcurrido de sesión |
| Session title | Badge dorado en el borde derecho |
| ⚠ YOLO | Warning de modo YOLO |

**Código de colores del contexto:**
- 🟢 Verde (<50%) — hay espacio de sobra
- 🟡 Amarillo (50-80%) — llenándose
- 🟠 Naranja (80-95%) — acercándose al límite
- 🔴 Rojo (≥95%) — casi overflow, considera `/compress`

### 11.4 Keybindings
| Tecla | Acción |
|---|---|
| `Enter` | Enviar mensaje |
| `Alt+Enter` / `Ctrl+J` / `Shift+Enter` | Nueva línea (multi-line input) |
| `Alt+V` | Pegar imagen del clipboard |
| `Ctrl+V` | Pegar texto + adjuntar imágenes |
| `Ctrl+B` | Iniciar/detener grabación de voz |
| `Ctrl+G` | Abrir buffer en `$EDITOR` |
| `Ctrl+X Ctrl+E` | Binding alternativo estilo Emacs para editor externo |
| `Ctrl+S` | Stash del prompt (guardar borrador) |
| `Ctrl+C` | Interrumpir agente (doble-press = force exit) |
| `Ctrl+D` | Salir |
| `Ctrl+Z` | Suspender a background (Unix) |
| `Tab` | Aceptar autosugerencia / autocompletar |
| `!<command>` | Shell mode — correr comando sin gastar turno de modelo |

### 11.5 Shell mode (`!`)
```bash
> !git status
> !ls -la
> !pytest -x tests/cli
```
- **Cero costo** — el modelo nunca se invoca (no API call, no tokens, no latencia).
- Nada entra en la conversación — el comando y su output no se añaden al historial.
- Corre donde corre el tool terminal del agente — usa el working directory de la sesión.
- **Las aprobaciones siguen aplicando** — un comando peligroso pasa por el mismo prompt de aprobación.
- Non-zero exits se muestran: `! exited <code>`.
- Shell mode es solo CLI — las plataformas del gateway y cron lo ignoran.

### 11.6 Personalidades
```bash
/personality pirate
/personality kawaii
/personality concise
```
Built-in: helpful, concise, technical, creative, teacher, kawaii, catgirl, pirate, shakespeare, surfer, noir, uwu, philosopher, hype.

Para volver al default (sin overlay): `/personality none` (default y neutral también funcionan).

Personalidades custom en config.yaml:
```yaml
personalities:
  helpful: "You are a helpful, friendly AI assistant."
  kawaii: "You are a kawaii assistant! Use cute expressions..."
  pirate: "Arrr! Ye be talkin' to Captain Hermes..."
```

### 11.7 Quick Commands (comandos personalizados)
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
Luego `/status`, `/gpu`, `/restart` en cualquier chat (CLI y plataformas de mensajería).

### 11.8 Gestión de sesiones
```bash
hermes --continue                    # Reanudar la más reciente
hermes --resume 20260225_143052_a1b2c3  # Reanudar por ID
hermes --resume "refactoring auth"   # Reanudar por título
hermes --resume latest --in ./my-project  # Última sesión del workspace
hermes sessions list                 # Listar sesiones pasadas
hermes sessions rename <id> <title>  # Renombrar sesión
```
Las sesiones se guardan en SQLite (`~/.hermes/state.db`): metadata, historial de mensajes, lineage, e índices de búsqueda full-text.

### 11.9 Multi-line input
Dos formas de entrar mensajes multi-línea:
- `Alt+Enter`, `Ctrl+J` o `Shift+Enter` — inserta nueva línea.
- **Backslash continuation** — termina una línea con `\` para continuar:
```
❯ Write a function that:\
 1. Takes a list of numbers\
 2. Returns the sum
```

### 11.10 Ejercicio práctico
**Objetivo:** Dominar el CLI de Hermes.

```bash
# 1. Arrancar una sesión interactiva
hermes

# 2. Probar shell mode
> !pwd
> !git status

# 3. Probar personalidades
/personality pirate
/personality none

# 4. Probar quick commands (si los configuraste)
/status

# 5. Salir y reanudar
Ctrl+D
hermes --continue
```

### 11.11 Modelo mental: el CLI como "centro de comando"
El CLI de Hermes es tu **centro de comando** — donde configuras, operas y supervisas todo:

- **Status bar** — monitorea modelo, tokens, costo, compresiones, tareas background.
- **Shell mode (`!`)** — corre comandos sin gastar turnos de modelo.
- **Slash commands** — control total de la sesión.
- **Quick commands** — tus atajos personalizados.
- **Sesiones** — reanuda, renombra, busca.

### 11.12 El TUI moderno
Hermes también incluye un **TUI moderno** con overlays modales, selección con mouse y input no bloqueante. Lánzalo con `hermes --tui`.

### 11.13 Ejercicio avanzado: quick commands personalizados
**Objetivo:** Crear atajos de terminal que corren sin invocar el LLM.

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

```bash
# Usarlos en cualquier chat
/status
/gpu
/restart
```

---

## MÓDULO 12 — Terminal Backends

### 12.1 ¿Qué es un backend de terminal?
Cada backend determina **dónde se ejecutan los comandos shell del agente** — tu máquina local, un contenedor Docker, un servidor remoto vía SSH, un sandbox cloud de Modal, un workspace de Daytona, un Vercel Sandbox, o un contenedor Singularity/Apptainer.

### 12.2 Los 7 backends
| Backend | Dónde corren los comandos | Aislamiento | Mejor para |
|---|---|---|---|
| **local** | Tu máquina directamente | Ninguno | Desarrollo, uso personal |
| **docker** | Contenedor Docker persistente | Full (namespaces, cap-drop) | Sandboxing seguro, CI/CD |
| **ssh** | Servidor remoto vía SSH | Network boundary | Dev remoto, hardware potente |
| **modal** | Sandbox cloud de Modal | Full (cloud VM) | Compute cloud efímero, evals |
| **daytona** | Workspace de Daytona | Full (cloud container) | Entornos cloud gestionados |
| **vercel_sandbox** | Vercel Sandbox | Full (cloud microVM) | Ejecución cloud con persistencia snapshot |
| **singularity** | Contenedor Singularity/Apptainer | Namespaces (--containall) | Clusters HPC, máquinas compartidas |

### 12.3 Configuración
```yaml
terminal:
  backend: local   # local | docker | ssh | modal | daytona | vercel_sandbox | singularity
  cwd: "."
  font_family: ""   # Fuente del terminal desktop
  timeout: 180      # Timeout por comando en segundos
  home_mode: auto   # auto | real | profile
  env_passthrough: []  # Env vars a reenviar a ejecución sandboxed
  singularity_image: "docker://nikolaik/python-nodejs:python3.11-nodejs20"
  modal_image: "nikolaik/python-nodejs:python3.11-nodejs20"
  daytona_image: "nikolaik/python-nodejs:python3.11-nodejs20"
```

### 12.4 Local backend
El default. Los comandos corren directamente en tu máquina sin aislamiento. No requiere setup especial.

```yaml
terminal:
  backend: local
```

**`terminal.home_mode`:**
| Modo | Host installs | Contenedores | Tradeoff |
|---|---|---|---|
| auto | Mantiene el HOME real del OS-user | Usa `{HERMES_HOME}/home` | Recomendado. CLIs del host siguen funcionando; estado del contenedor persiste |
| real | Fuerza el HOME real del OS-user | Fuerza el HOME real si es visible | Útil si un proceso padre arrancó con HOME apuntando a un home de perfil |
| profile | Usa `{HERMES_HOME}/home` cuando existe | Usa `{HERMES_HOME}/home` cuando existe | Aislamiento estricto de config CLI por perfil, pero `~/.ssh`, `~/.gitconfig`, etc. no serán visibles |

> ⚠️ El agente tiene el mismo acceso al filesystem que tu cuenta de usuario. Usa `hermes tools` para desactivar tools que no quieras, o cambia a Docker para sandboxing.

### 12.5 Docker backend
Corre comandos dentro de un contenedor Docker con hardening de seguridad (todos los capabilities caídos, sin escalada de privilegios, límites de PID).

```yaml
terminal:
  backend: docker
  docker_image: "nikolaik/python-nodejs:python3.11-nodejs20"
  docker_mount_cwd_to_workspace: false
  docker_run_as_host_user: false
  docker_forward_env:
    - "GITHUB_TOKEN"
  docker_env:
    DEBUG: "1"
    PYTHONUNBUFFERED: "1"
  docker_volumes:
    - "/home/user/projects:/workspace/projects"
    - "/home/user/data:/data:ro"
  docker_extra_args:
    - "--gpus=all"
    - "--network=host"
  docker_network: true   # false = air-gap (--network=none)
  container_cpu: 1
  container_memory: 5120
  container_disk: 51200
  container_persistent: true
  docker_persist_across_processes: true
  docker_orphan_reaper: true
  timeout: 180
  lifetime_seconds: 300
```

**Puntos clave:**
- **Un solo contenedor persistente** compartido entre sesiones, `/new`, y sub-agentes.
- Hermes arranca UN contenedor long-lived en el primer uso y enruta todo a través de `docker exec` en ese mismo contenedor.
- Los cambios de working directory, paquetes instalados, archivos en `/workspace` y procesos background **sobreviven** entre tool calls y entre procesos de Hermes.
- `docker_env` vs `docker_forward_env`: el primero inyecta pares KEY=VAL literales que especificas; el segundo reenvía valores de tu shell o `~/.hermes/.env` (el secreto nunca aparece en el config file). Usa `docker_forward_env` para tokens y `docker_env` para knobs estáticos.
- Podman soportado: `HERMES_DOCKER_BINARY=podman`.

**Container lifecycle:**
Cada contenedor gestionado por Hermes se etiqueta con tres labels:
- `hermes-agent=1` — lo marca como gestionado por Hermes
- `hermes-task-id=<sanitized task_id>` — key del probe de reuso por tarea
- `hermes-profile=<sanitized profile name>` — scope del reuso y reaping al perfil activo

El contenedor solo se destruye (stop + `docker rm -f`) en estos casos:
| Trigger | Cuándo dispara |
|---|---|
| `docker_persist_across_processes: false` | Aislamiento explícito por proceso |
| Idle reaper (`lifetime_seconds`, default 300s) | Solo cuando `persist_across_processes=false` |
| Orphan reap | Barrido de contenedores Exited abandonados |

### 12.6 Ejercicio práctico
**Objetivo:** Configurar y probar el backend Docker.

```bash
# 1. Cambiar al backend Docker
hermes config set terminal.backend docker

# 2. Verificar
hermes config get terminal.backend

# 3. Arrancar una sesión y probar
hermes chat
# Pide un comando y observa que corre en el contenedor

# 4. (Opcional) Air-gap el contenedor
hermes config set terminal.docker_network false
```

---

## MÓDULO 13 — Plugins

### 13.1 ¿Qué son los plugins?
Los plugins extienden las capacidades de Hermes. Se gestionan a través del comando `hermes plugins`.

### 13.2 Comandos de plugins
```bash
hermes plugins install owner/repository --no-enable
hermes plugins list
hermes plugins enable <plugin-name>
hermes plugins disable <plugin-name>
hermes plugins update <plugin-name>
hermes plugins remove <plugin-name>
```

### 13.3 Portabilidad
Los paquetes portables permanecen deshabilitados hasta que se habilitan explícitamente. Hermes carga actualmente **Agent Skills portables** y **entradas stdio MCP**.

---

## MÓDULO 14 — Integraciones y Recursos

### 14.1 Nous Portal
`hermes setup --portal` es la opción de menor fricción para runs desatendidos, ya que el refresh de OAuth es automático. Los suscriptores de Portal obtienen:
- Un proveedor de modelo vía un solo OAuth.
- Las 4 herramientas del Tool Gateway (TTS, web, etc.).
- 10% de descuento en proveedores por tokens.

### 14.2 Importar desde otros agentes
```bash
hermes import-agent claude-code
```
Migra automáticamente `mcpServers`, skills e instructions desde Claude Code.

### 14.3 Recursos de aprendizaje
- **Video Masterclass** de "Onchain AI Garage"
- **Playlist de YouTube:** "Hermes Agent Tutorials & Use Cases" — https://www.youtube.com/playlist?list=PLmpUb_PWAkDxewld5ZYyKifuHxgIbiq2d
- **Discord:** https://discord.gg/NousResearch

---

## MÓDULO 15 — TUI (Terminal User Interface)

### 15.1 ¿Qué es el TUI?
Hermes incluye un **TUI moderno** además del CLI clásico. Ofrece overlays modales, selección con mouse y input no bloqueante. Lánzalo con `hermes --tui`.

### 15.2 Diferencias CLI clásico vs TUI
| Aspecto | CLI clásico | TUI moderno |
|---|---|---|
| **Overlays modales** | No | Sí |
| **Selección con mouse** | No | Sí |
| **Input no bloqueante** | No | Sí |
| **Session picker** | Básico | Interactivo (filtro, flechas, Enter) |
| **Context breakdown** | `/context` | Visual |

### 15.3 Comandos del TUI
```bash
hermes --tui          # Lanzar el TUI
hermes --tui --resume <id>   # Reanudar sesión en TUI
```

### 15.4 Ejercicio práctico
**Objetivo:** Explorar el TUI moderno.

```bash
# 1. Lanzar el TUI
hermes --tui

# 2. Probar el session picker
/sessions
# Filtra con texto, navega con flechas, Enter para reanudar

# 3. Probar el context breakdown
/context
# Muestra el desglose visual de tokens por categoría

# 4. Probar la selección con mouse
# Selecciona texto con el mouse
```

---

## MÓDULO 16 — Voice Mode

### 16.1 ¿Qué es el Voice Mode?
Hermes soporta **voz** en varias superficies:
- **CLI microphone mode** — graba con Ctrl+B.
- **Spoken replies en messaging** — respuestas de audio TTS.
- **Discord voice-channel conversations** — conversaciones en canales de voz de Discord.

### 16.2 Configuración de voz
```bash
# En el CLI
/voice on          # Habilitar modo voz
/voice tts         # Alternar playback hablado de respuestas

# En messaging
/voice [on|off|tts|join|leave|status]
```

### 16.3 Requisitos
- Un **proveedor de TTS** (text-to-speech).
- Un **proveedor de modelo** para transcripción.
- Un **Nous Portal** subscription bundlea ambos.

### 16.4 Ejercicio práctico
**Objetivo:** Probar el modo voz en el CLI.

```bash
# 1. Habilitar voz
/voice on

# 2. Grabar un mensaje
# Presiona Ctrl+B para empezar a grabar, Ctrl+B de nuevo para parar

# 3. Escuchar la respuesta hablada
/voice tts
```

---

## MÓDULO 17 — Operación y Producción

### 17.1 El gateway como servicio
```bash
hermes gateway install   # Instalar como servicio de usuario (Linux) / launchd (macOS)
sudo hermes gateway install --system   # Linux: servicio de sistema al boot
hermes gateway start
hermes gateway stop
hermes gateway status
```

### 17.2 Watchdog de event-loop (Linux/systemd)
Un gateway gestionado por systemd puede optar por recuperación de proceso cuando el event-loop de asyncio de Python deja de recibir tiempo de scheduling:

```yaml
# ~/.hermes/config.yaml
gateway:
  systemd_watchdog_seconds: 120
```

```bash
hermes gateway install --force   # Regenerar la unit después de cambiar esto
```

Un valor positivo hace que la unit generada use `Type=notify`, `NotifyAccess=main` y el `WatchdogSec` correspondiente. Hermes envía heartbeats solo mientras su event-loop progresa a tiempo; systemd reinicia el proceso cuando se detienen. El default `0` mantiene el comportamiento `Type=simple`.

### 17.3 Logs y observabilidad
```bash
# Logs principales
~/.hermes/logs/errors.log
~/.hermes/logs/gateway.log

# Tool calls audit (si display.tool_progress: log)
~/.hermes/logs/tool_calls.log
```

Los logs **redactan secretos automáticamente** — las credenciales nunca llegan a disco.

### 17.4 Actualización
```bash
hermes update          # Actualizar a la última versión
/update                # Desde el chat
```

Con `updates.pre_update_backup: quick` (default), Hermes hace snapshot de archivos de estado críticos antes de actualizar.

### 17.5 Ejercicio práctico
**Objetivo:** Instalar el gateway como servicio y verificar su estado.

```bash
# 1. Instalar como servicio
hermes gateway install

# 2. Iniciar
hermes gateway start

# 3. Verificar estado
hermes gateway status

# 4. Ver logs
cat ~/.hermes/logs/gateway.log
```

---

## MÓDULO 18 — Proyecto Final: Asistente Personal Operativo

### 18.1 Objetivo
Construir un **asistente personal operativo** completo con Hermes Agent que:
- Se conecta a Telegram.
- Tiene memoria persistente de tus preferencias.
- Ejecuta tareas programadas (cron).
- Usa skills para workflows reutilizables.
- Está protegido con allowlists y aprobación de comandos.

### 18.2 Paso 1: Setup base
```bash
# 1. Instalar
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash

# 2. Configurar modelo
hermes setup --portal   # o hermes config set model <provider>/<model>

# 3. Verificar
hermes chat -q "Hello"
```

### 18.3 Paso 2: Personalizar identidad
```markdown
# ~/.hermes/SOUL.md
## Persona
Eres mi asistente personal operativo. Directo, eficiente, confiable.

## Tono
- Conciso
- Proactivo
- Respetuoso

## Líneas rojas
- No ejecutes comandos destructivos sin aprobación
- No compartas información privada
- Pregunta antes de acciones externas
```

### 18.4 Paso 3: Configurar memoria
```bash
# Añadir preferencias a USER.md
cat >> ~/.hermes/memories/USER.md << 'EOF'
- Prefiere respuestas en español
- Horario de trabajo: 9am-6pm
- Proyecto principal: acme-app
EOF
```

### 18.5 Paso 4: Crear una skill
```bash
# Aprender un workflow como skill
/learn how I deploy the acme-app staging server
```

### 18.6 Paso 5: Configurar cron
```bash
# Resumen diario de noticias de IA
hermes cron create "0 9 * * *" "Check Hacker News for AI news and send me a summary on Telegram."

# Recordatorio semanal
hermes cron create "0 17 * * 5" "Remind me to review the week's progress"
```

### 18.7 Paso 6: Conectar Telegram de forma segura
```bash
# 1. Setup del gateway
hermes gateway setup

# 2. Configurar allowlist
# Añade a ~/.hermes/.env:
# TELEGRAM_ALLOWED_USERS=123456789

# 3. Arrancar
hermes gateway
```

### 18.8 Paso 7: Probar y verificar
```bash
# 1. Probar desde Telegram
# Envía: "What do you remember about me?"
# Debería reflejar tus preferencias de USER.md

# 2. Probar la skill
/deploy-staging

# 3. Probar el cron
hermes cron run <job_id>

# 4. Verificar seguridad
/whoami
```

### 18.9 Criterios de éxito
- ✅ El agente responde desde Telegram.
- ✅ Recuerda tus preferencias entre sesiones.
- ✅ Ejecuta tareas programadas.
- ✅ Usa skills para workflows.
- ✅ Solo usuarios autorizados pueden hablar con él.
- ✅ Los comandos peligrosos requieren aprobación.

---

## MÓDULO 19 — Mejores Prácticas

### 19.1 Seguridad primero
1. **Empieza con el mínimo de toolsets** — añade según necesites.
2. **Usa allowlists** — nunca `GATEWAY_ALLOW_ALL_USERS=true` en producción.
3. **Mantén `approvals.mode: smart`** — no lo pongas en `off` salvo entornos de confianza.
4. **Usa un backend aislado** (Docker, Modal) para tareas que tocan el sistema.
5. **Revisa tu `command_allowlist`** periódicamente con `hermes approvals suggest`.

### 19.2 Eficiencia de tokens
1. **Usa skills con progressive disclosure** — no metas todo en el system prompt.
2. **Mantén la memoria curada** — MEMORY.md y USER.md acotados.
3. **Usa `/compress`** cuando el contexto se acerque al límite.
4. **Usa shell mode (`!`)** para comandos que no necesitan el LLM.
5. **Elige el modelo adecuado** — un modelo barato para tareas simples, uno frontier para tareas complejas.

### 19.3 Operación
1. **Usa cron con preflight** — un job mal configurado nunca gasta tokens.
2. **Pinea el modelo de los jobs cron** — evita el drift guard.
3. **Monitorea los logs** — `~/.hermes/logs/` redacta secretos automáticamente.
4. **Haz backups** — `updates.pre_update_backup: quick` o `full`.
5. **Usa perfiles** — separa personal/work/research.

### 19.4 Escalabilidad
1. **Skills para workflows reutilizables** — no repitas procedimientos.
2. **MCP para tools externas** — no escribas tools nativas si ya existe un servidor MCP.
3. **Overrides por canal** — un gateway, múltiples modelos/personas.
4. **Delegation** — delega tareas a sub-agentes para paralelizar.

### 19.5 Anti-patrones (qué NO hacer)
| Anti-patrón | Por qué evitarlo | Alternativa |
|---|---|---|
| `approvals.mode: off` en producción | Desactiva toda la seguridad | `smart` con deny rules |
| `GATEWAY_ALLOW_ALL_USERS=true` | Cualquiera puede hablar con el bot | Allowlists o DM pairing |
| Skills gigantes en el system prompt | Infla el contexto de cada turno | Progressive disclosure |
| Memoria sin límite | Costo de tokens alto y creciente | Memoria curada (MEMORY.md/USER.md) |
| Jobs cron sin pin de modelo | Riesgo de drift a proveedor de pago | `cron.model` o per-job pin |
| Escribir tools nativas para todo | Duplica lo que MCP ya resuelve | Servidores MCP |

---

## 📚 Apéndice A — Referencia rápida de comandos

### Configuración
```bash
hermes config              # Ver configuración
hermes config edit         # Editar config.yaml
hermes config get KEY       # Obtener valor
hermes config set KEY VAL   # Setear valor
hermes config unset KEY      # Quitar valor
hermes config check          # Verificar opciones
hermes config migrate        # Añadir opciones faltantes
```

### CLI
```bash
hermes                          # Sesión interactiva
hermes chat -q "Hello"          # Single query
hermes --continue               # Reanudar más reciente
hermes --resume <id>            # Reanudar por ID
hermes -s <skills>              # Pre-cargar skills
hermes -w                       # Git worktree
```

### Gateway
```bash
hermes gateway setup
hermes gateway
hermes gateway install
hermes gateway start
hermes gateway stop
hermes gateway status
```

### Cron
```bash
hermes cron create "every 2h" "Check server status"
hermes cron list
hermes cron pause <job_id>
hermes cron resume <job_id>
hermes cron run <job_id>
hermes cron remove <job_id>
hermes cron edit <job_id> --schedule "every 4h"
hermes cron status
hermes cron tick
```

### MCP
```bash
hermes mcp
hermes mcp catalog
hermes mcp install <name>
hermes mcp configure <name>
```

### Plugins
```bash
hermes plugins install owner/repo
hermes plugins list
hermes plugins enable <name>
hermes plugins disable <name>
hermes plugins update <name>
hermes plugins remove <name>
```

### Seguridad
```bash
hermes approvals suggest
hermes approvals suggest --apply 1,3
hermes pairing approve telegram <code>
hermes pairing list
hermes pairing revoke telegram <id>
```

---

## 📚 Apéndice B — Glosario

| Término | Definición |
|---|---|
| **ACP** | Agent Client Protocol — protocolo para conectar agentes a clientes |
| **Allowlist** | Lista de usuarios permitidos para hablar con el agente |
| **Backend** | Dónde se ejecutan los comandos shell del agente (local, docker, ssh, etc.) |
| **Cron** | Tareas programadas que se ejecutan automáticamente |
| **DM Pairing** | Sistema de códigos de emparejamiento para autorizar usuarios |
| **Drift guard** | Protección contra jobs cron que heredan cambios de modelo/proveedor |
| **Gateway** | Proceso en segundo plano que conecta plataformas de mensajería |
| **Hardline blocklist** | Comandos que Hermes nunca ejecuta, sin importar nada |
| **MCP** | Model Context Protocol — protocolo para conectar tools externas |
| **Progressive disclosure** | Patrón de cargar contenido on-demand para minimizar tokens |
| **Skill** | Documento de conocimiento on-demand que el agente carga cuando lo necesita |
| **Toolset** | Grupo de herramientas organizado por plataforma |
| **YOLO mode** | Modo que desactiva los prompts de aprobación de comandos peligrosos |

---

## 📚 Apéndice C — Troubleshooting

### C.1 No arranca
| Síntoma | Causa probable | Solución |
|---|---|---|
| `hermes` no se encuentra | No instalado o PATH | Reinstalar con el install.sh |
| Error de modelo | No hay modelo configurado | `hermes setup --portal` o `hermes config set model` |
| API key no encontrada | Key en el archivo equivocado | Mover a `~/.hermes/.env` |

### C.2 Gateway
| Síntoma | Causa probable | Solución |
|---|---|---|
| No conecta a Telegram | Token mal configurado | `hermes gateway setup` |
| Todos los usuarios denegados | Sin allowlists | Configurar `TELEGRAM_ALLOWED_USERS` |
| Gateway crashea | Event-loop stall | `gateway.systemd_watchdog_seconds` |

### C.3 Docker
| Síntoma | Causa probable | Solución |
|---|---|---|
| Docker no arranca | Docker no corriendo | Iniciar Docker Desktop/Engine |
| Contenedor no encontrado | Imagen no descargada | Verificar `docker_image` |
| Sin red en contenedor | `docker_network: false` | Setear a `true` |

### C.4 Cron
| Síntoma | Causa probable | Solución |
|---|---|---|
| Job no corre | `blocked_config` | Verificar preflight (API key, skills, delivery) |
| Job skip sin alerta | Drift guard | Pinear modelo o desactivar guard |
| Job no crea más jobs | Restricción de seguridad | Diseñar sin recursión |

### C.5 MCP
| Síntoma | Causa probable | Solución |
|---|---|---|
| Tools MCP no aparecen | Servidor no alcanzable | Verificar `command`/`args` |
| Tools filtradas | Selección al instalar | `hermes mcp configure <name>` |
| OAuth falla | No autenticado | `hermes auth <provider>` |

---

## 📚 Apéndice D — Ejercicios resueltos

### D.1 Configurar modelo y backend
```bash
hermes config set model anthropic/claude-sonnet-4
hermes config set terminal.backend docker
hermes config get model        # → anthropic/claude-sonnet-4
hermes config get terminal.backend  # → docker
```

### D.2 Crear y probar un job cron
```bash
hermes cron create "0 9 * * *" "Check Hacker News for AI news and send me a summary on Telegram."
hermes cron list
hermes cron run <job_id>
hermes cron pause <job_id>
hermes cron resume <job_id>
```

### D.3 Conectar un MCP de filesystem
```yaml
mcp_servers:
  filesystem:
    command: "npx"
    args: ["-y", "@modelcontextprotocol/server-filesystem", "/home/user/projects"]
```
```bash
hermes chat
# "List the files in /home/user/projects and summarize the repo structure."
```

### D.4 Configurar un gateway seguro
```bash
# ~/.hermes/.env
TELEGRAM_ALLOWED_USERS=123456789

hermes gateway setup
hermes gateway
```

### D.5 Crear una skill con /learn
```bash
/learn how I deploy the acme-app staging server
hermes chat --toolsets skills -q "What skills do you have?"
/deploy-staging
```

---

*Temario elaborado a partir de la documentación oficial de Hermes Agent (Nous Research). Fechas de consulta: 2026-08-17.*
