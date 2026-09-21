# 🐰 Guía Completa de OpenClaw

> *"Tu asistente personal de IA, siempre conectado, siempre disponible."*

---

## 📖 Índice

1. [¿Qué es OpenClaw?](#-qué-es-openclaw)
2. [Instalación y Primeros Pasos](#-instalación-y-primeros-pasos)
3. [Arquitectura: Cómo Funciona](#-arquitectura-cómo-funciona)
4. [Configuración](#-configuración)
5. [Workspace: La Casa del Agente](#-workspace-la-casa-del-agente)
6. [Canales de Mensajería](#-canales-de-mensajería)
7. [Memoria y Personalidad](#-memoria-y-personalidad)
8. [Sesiones](#-sesiones)
9. [Automatización: Cron y Heartbeat](#-automatización-cron-y-heartbeat)
10. [Skills (Habilidades)](#-skills-habilidades)
11. [CLI: Comandos Esenciales](#-cli-comandos-esenciales)
12. [Webhooks y APIs](#-webhooks-y-apis)
13. [Seguridad](#-seguridad)
14. [Troubleshooting](#-troubleshooting)
15. [Consejos y Buenas Prácticas](#-consejos-y-buenas-prácticas)

---

## 🎯 ¿Qué es OpenClaw?

OpenClaw es un **gateway self-hosted** que conecta plataformas de mensajería (WhatsApp, Telegram, Discord, Signal, Slack, iMessage, y muchas más) a agentes de IA. Funciona como un asistente personal siempre disponible que:

- **Habla por tus canales favoritos** — Un solo agente responde en WhatsApp, Telegram, Discord, etc.
- **Tiene memoria persistente** — Recuerda entre sesiones usando archivos Markdown en su workspace
- **Ejecuta tareas programadas** — Cron jobs, heartbeats, webhooks
- **Corre en tu máquina** — Self-hosted, tú controlas los datos
- **Se extiende con Skills** — Habilidades descargables y personalizables

---

## 🚀 Instalación y Primeros Pasos

### Requisitos previos

- Node.js 18+ (recomendado 20+)
- npm o gestor de paquetes compatible
- Una máquina siempre encendida (VPS, Mac, servidor casero)

### Instalación

```bash
# Instalar OpenClaw globalmente
npm install -g openclaw

# Ejecutar el asistente de configuración interactivo
openclaw onboard

# O configurar lo mínimo sin wizard
openclaw setup --baseline
```

### Primer inicio rápido (setup en 5 minutos)

1. **Iniciar el Gateway:**
   ```bash
   openclaw gateway --port 18789
   ```

2. **Conectar un canal (ej: Telegram):**
   ```bash
   openclaw channels add
   ```
   Sigue las instrucciones para configurar tu bot token.

3. **Crear configuración mínima** en `~/.openclaw/openclaw.json`:
   ```json5
   {
     agents: { defaults: { workspace: "~/.openclaw/workspace" } },
     channels: { telegram: { allowFrom: ["tu_user_id"] } }
   }
   ```

4. **Abrir el dashboard:**
   ```bash
   openclaw dashboard
   ```

¡Ya puedes chatear con tu agente!

---

## 🏗️ Arquitectura: Cómo Funciona

```
┌─────────────────────────────────────────────────┐
│                   GATEWAY                        │
│              (openclaw gateway)                   │
│                                                  │
│  ┌─────────┐  ┌──────────┐  ┌────────────┐     │
│  │WhatsApp │  │ Telegram │  │   Discord   │     │
│  │ (Baileys)│  │(grammY) │  │   (Bot API) │     │
│  └────┬────┘  └────┬─────┘  └─────┬──────┘     │
│       │            │              │              │
│       └────────────┼──────────────┘              │
│                    │                              │
│              ┌─────┴─────┐                        │
│              │  Agent    │                        │
│              │  Loop     │                        │
│              └─────┬─────┘                        │
│                    │                              │
│     ┌──────────────┼──────────────────┐          │
│     │              │                  │          │
│  ┌──┴───┐    ┌────┴────┐      ┌──────┴───┐      │
│  │Memoria│   │Cron/Sched│    │  Skills   │      │
│  │  .md  │   │  Jobs    │    │  Tools    │      │
│  └──────┘    └─────────┘    └──────────┘      │
│                                                  │
│              WebSocket API                       │
│              (puerto 18789)                       │
└─────────────────────────────────────────────────┘
         │              │              │
    ┌────┴───┐    ┌─────┴────┐   ┌────┴────┐
    │  CLI   │    │  macOS   │   │WebChat   │
    │        │    │   App    │   │   UI     │
    └────────┘    └──────────┘   └─────────┘
```

**Componentes clave:**

| Componente | Qué hace |
|---|---|
| **Gateway** | Daemon central. Conecta canales, maneja sesiones, ejecuta el agente |
| **Workspace** | Directorio de trabajo del agente (`~/.openclaw/workspace`) |
| **Sesiones** | Conversaciones aisladas por canal/grupo/usuario |
| **Cron** | Planificador integrado para tareas programadas |
| **Skills** | Instrucciones Markdown que enseñan al agente a usar herramientas |

---

## ⚙️ Configuración

### Archivo de configuración

El archivo principal es `~/.openclaw/openclaw.json` (formato JSON5 — soporta comentarios y trailing commas).

### Métodos para editar la configuración

```bash
# Asistente interactivo completo
openclaw configure

# Leer un valor
openclaw config get agents.defaults.model.primary

# Establecer un valor
openclaw config set agents.defaults.heartbeat.every "30m"

# Eliminar un valor
openclaw config unset plugins.entries.brave.config.apiKey

# Ver toda la config
openclaw config file
```

### Configuración típica de asistente personal

```json5
{
  // Logging
  logging: { level: "info" },

  // Agente por defecto
  agents: {
    defaults: {
      model: { primary: "anthropic/claude-sonnet-4-20250514" },
      workspace: "~/.openclaw/workspace",
      thinkingDefault: "medium",
      timeoutSeconds: 1800,
      // Heartbeat deshabilitado al inicio, activar después
      heartbeat: { every: "0m" },
    },
    list: [
      {
        id: "main",
        default: true,
        groupChat: {
          mentionPatterns: ["@asistente", "asistente"],
        },
      },
    ],
  },

  // Canales
  channels: {
    telegram: { allowFrom: ["123456789"] },
    whatsapp: { allowFrom: ["+15555550123"] },
  },

  // Sesiones
  session: {
    scope: "per-sender",
    resetTriggers: ["/new", "/reset"],
    reset: {
      mode: "daily",
      atHour: 4,
      idleMinutes: 10080, // 1 semana sin actividad
    },
  },
}
```

### Proveedores de modelos soportados

OpenClaw soporta decenas de proveedores. Los más comunes:

| Proveedor | Ejemplo de config |
|---|---|
| OpenAI | `openai/gpt-4.1` |
| Anthropic | `anthropic/claude-sonnet-4-20250514` |
| Google | `google/gemini-2.5-pro` |
| Ollama (local) | `ollama/llama3` |
| OpenRouter | `openrouter/anthropic/claude-sonnet-4-20250514` |
| Groq | `groq/llama-3.3-70b-versatile` |

Configurar autenticación de modelos:
```bash
# Login interactivo
openclaw models auth login

# Pegar API key
openclaw models auth paste-api-key

# Ver modelos disponibles
openclaw models list
```

---

## 🏠 Workspace: La Casa del Agente

El workspace (`~/.openclaw/workspace` por defecto) es donde el agente vive, recuerda y trabaja. **Es su memoria y su hogar.**

### Estructura de archivos

```
~/.openclaw/workspace/
├── AGENTS.md        # Instrucciones operativas del agente
├── SOUL.md          # Personalidad, tono y voz
├── IDENTITY.md      # Nombre, emoji, vibra
├── USER.md          # Info sobre el usuario humano
├── TOOLS.md         # Notas locales sobre herramientas
├── HEARTBEAT.md     # Checklist para heartbeats (opcional)
├── BOOT.md          # Checklist de inicio (opcional)
├── BOOTSTRAP.md     # Ritual de primera ejecución (se elimina después)
├── MEMORY.md        # Memoria curada a largo plazo (opcional)
├── memory/
│   ├── 2025-08-04.md   # Notas diarias
│   └── 2025-08-05.md
├── skills/          # Skills personalizadas del workspace
└── canvas/          # Archivos UI para nodos (opcional)
```

### Qué va en cada archivo

| Archivo | Propósito | Se carga en... |
|---|---|---|
| `AGENTS.md` | Reglas, prioridades, "cómo comportarse" | Cada sesión |
| `SOUL.md` | Voz, tono, personalidad, límites | Cada sesión |
| `USER.md` | Quién es el usuario, preferencias | Cada sesión |
| `IDENTITY.md` | Nombre del agente, emoji, vibra | Cada sesión |
| `TOOLS.md` | Notas sobre herramientas locales | Cada sesión |
| `HEARTBEAT.md` | Tareas periódicas para heartbeat | Runs de heartbeat |
| `MEMORY.md` | Memoria duradera, decisiones, preferencias | Sesión principal |
| `memory/YYYY-MM-DD.md` | Notas diarias, logs crudos | Bajo demanda (memory_search) |

### Respaldar el workspace con Git

```bash
cd ~/.openclaw/workspace
git init
git add AGENTS.md SOUL.md TOOLS.md IDENTITY.md USER.md HEARTBEAT.md memory/
git commit -m "Initial workspace backup"

# Agregar remote privado (GitHub, GitLab, etc.)
git remote add origin <url-del-repo-privado>
git push -u origin main
```

⚠️ **NO incluyas** en el repo: `~/.openclaw/openclaw.json`, credenciales, sesiones, ni secrets.

---

## 💬 Canales de Mensajería

### Canales soportados

| Canal | Tipo | Notas |
|---|---|---|
| **Telegram** | Core | El más fácil de configurar (solo bot token) |
| **WhatsApp** | Plugin oficial | Requiere escanear QR (Baileys) |
| **Discord** | Plugin oficial | Bot API, servidores + DMs |
| **Signal** | Plugin oficial | Privacidad, signal-cli |
| **Slack** | Plugin oficial | Bolt SDK, workspace apps |
| **iMessage** | Core (macOS) | Via `imsg` bridge |
| **Matrix** | Plugin oficial | Protocolo abierto |
| **Microsoft Teams** | Plugin oficial | Bot Framework |
| **IRC** | Plugin oficial | Servidores clásicos |
| **LINE** | Plugin oficial | LINE Messaging API |
| **WeChat** | Plugin externo | Login QR, solo chats privados |
| **Zalo** | Plugin oficial | Bot API de Vietnam |
| **WebChat** | Core | UI web via WebSocket |
| Y más... | Ver docs | Feishu, Nostr, Twitch, SMS, etc. |

### Configurar un canal

```bash
# Agregar canal interactivamente
openclaw channels add

# Ver estado de canales
openclaw channels status

# Login a WhatsApp (escanear QR)
openclaw channels login

# Ver capacidades de un canal
openclaw channels capabilities
```

### Ejemplo: Configurar Telegram

1. Crear bot con [@BotFather](https://t.me/BotFather) → obtener token
2. Configurar en `openclaw.json`:
   ```json5
   {
     channels: {
       telegram: {
         allowFrom: ["tu_telegram_id"],
         token: "TU_BOT_TOKEN"
       }
     }
   }
   ```
3. Reiniciar el Gateway

### Seguridad en canales

- **Siempre** configura `allowFrom` — nunca dejes tu bot abierto al mundo
- WhatsApp requiere un número dedicado (no tu número personal)
- Usa DM scope `per-channel-peer` para multi-usuario:
  ```json5
  { session: { dmScope: "per-channel-peer" } }
  ```

---

## 🧠 Memoria y Personalidad

### Sistema de memoria

OpenClaw recuerda **solo lo que se escribe en disco**. No hay estado oculto.

```
MEMORY.md (memoria a largo plazo)
    ↕ agente consolida periódicamente
memory/YYYY-MM-DD.md (notas diarias)
    ↕ memory_search busca en ambos
```

- **`MEMORY.md`** — Hechos duraderos, preferencias, decisiones. Se carga al inicio de la sesión principal. **No pongas todo aquí** — mantenlo conciso.
- **`memory/YYYY-MM-DD.md`** — Logs diarios, contexto en progreso. Se indexan para búsqueda semántica.

### Herramientas de memoria

| Herramienta | Qué hace |
|---|---|
| `memory_search` | Búsqueda semántica (vectorial + keywords) en todos los archivos de memoria |
| `memory_get` | Lee un archivo específico o rango de líneas |

### Flujo de memoria recomendado

1. El agente escribe notas en `memory/YYYY-MM-DD.md` durante el día
2. Periódicamente (heartbeat o manual), consolida lo valioso en `MEMORY.md`
3. Elimina entradas obsoletas de `MEMORY.md`
4. `memory_search` encuentra lo relevante en cualquier momento

### SOUL.md: Dale personalidad

`SOUL.md` es donde vive la voz del agente. Se inyecta en cada sesión.

**Reglas para un buen SOUL.md:**
- ✅ Tono, opiniones, nivel de detalle, humor
- ✅ Límites de estilo ("sin jerga corporativa", "sé directo")
- ❌ No pongas políticas de seguridad (van en AGENTS.md)
- ❌ No pongas changelogs o listas de tareas

### Flush automático de memoria

Antes de cada compaction (resumen de contexto), OpenClaw ejecuta un flush silencioso que recuerda al agente guardar información importante. Se puede deshabilitar con:

```json5
{
  agents: { defaults: { compaction: { memoryFlush: { enabled: false } } } }
}
```

---

## 💡 Sesiones

### Qué son las sesiones

Cada conversación se enruta a una **sesión** aislada. El gateway es dueño del estado.

| Origen | Comportamiento |
|---|---|
| Mensajes directos (DM) | Sesión compartida por defecto |
| Grupos | Sesión aislada por grupo |
| Cron jobs | Sesión fresca por ejecución |
| Webhooks | Sesión aislada por hook |

### Ciclo de vida

- **Reset diario** (default): Nueva sesión cada día a las 4am
- **Reset por inactividad**: Nueva sesión tras X minutos sin actividad
- **Reset manual**: `/new` o `/reset` en chat

### Configurar sesiones

```json5
{
  session: {
    scope: "per-sender",           // Aislamiento por remitente
    resetTriggers: ["/new", "/reset"],
    reset: {
      mode: "daily",                // daily | idle
      atHour: 4,                    // Hora del reset diario (0-23)
      idleMinutes: 10080,           // Tiempo de inactividad (1 semana)
    },
  },
}
```

### Comandos de chat en sesión

| Comando | Qué hace |
|---|---|
| `/new` | Inicia sesión nueva |
| `/new modelo` | Nueva sesión con modelo específico |
| `/reset` | Reset de sesión |
| `/compact` | Compacta contexto, muestra presupuesto restante |
| `/status` | Diagnóstico rápido |
| `/model nombre` | Cambia modelo en la sesión actual |

---

## ⏰ Automatización: Cron y Heartbeat

### Heartbeat (modo proactivo)

El heartbeat es un check periódico donde el agente decide si hay algo que hacer.

```json5
{
  agents: {
    defaults: {
      heartbeat: { every: "30m" }  // Cada 30 minutos
    }
  }
}
```

- Si `HEARTBEAT.md` existe y tiene tareas, el agente las ejecuta
- Si está vacío o solo tiene comentarios, se salta el run (ahorra tokens)
- Si el agente responde `HEARTBEAT_OK`, no se envía nada al chat

### Cron Jobs (tareas programadas)

```bash
# Recordatorio único (en 20 minutos)
openclaw cron add \
  --name "Recordatorio" \
  --at "20m" \
  --session main \
  --system-event "Revisar el documento pendiente" \
  --wake now \
  --delete-after-run

# Tarea recurrente (todos los días a las 7am, hora de Madrid)
openclaw cron create "0 7 * * *" \
  "Resumir correos del día." \
  --name "Resumen matutino" \
  --tz "Europe/Madrid" \
  --session isolated \
  --announce

# Listar jobs
openclaw cron list

# Ver historial de ejecuciones
openclaw cron runs --id <jobId>
```

### Tipos de schedule

| Tipo | Flag | Descripción |
|---|---|---|
| `at` | `--at` | Una vez, timestamp o relativo ("20m", "2025-12-01T10:00:00") |
| `every` | `--every` | Intervalo fijo ("10m", "1h", "1d") |
| `cron` | `--cron` | Expresión cron (5 o 6 campos) con `--tz` |

### Estilos de ejecución

| Estilo | `--session` | Se ejecuta en | Ideal para |
|---|---|---|---|
| Main | `main` | Lane dedicada del cron | Recordatorios, system events |
| Isolated | `isolated` | Sesión fresca dedicada | Reportes, tareas de fondo |
| Current | `current` | Sesión actual atada al momento de creación | Workflows con contexto |
| Custom | `session:xxx` | Sesión persistente nombrada | Workflows que acumulan contexto |

### Heartbeat vs Cron: cuándo usar cuál

| | Heartbeat | Cron |
|---|---|---|
| **Timing** | Aproximado (cada X minutos) | Exacto (hora específica) |
| **Contexto** | Sesión principal completa | Sesión aislada o dedicada |
| **Modelo** | Mismo que la sesión | Puede usar modelo diferente |
| **Costo** | Comparte contexto, más eficiente por run | Sesión nueva cada vez |
| **Mejor para** | Check periódico, revisar email/calendario | Reportes, recordatorios exactos |

---

## 🛠️ Skills (Habilidades)

Las Skills son archivos Markdown (`SKILL.md`) que enseñan al agente **cómo y cuándo usar herramientas**. Se cargan automáticamente.

### Orden de precedencia (mayor = gana)

| Prioridad | Fuente | Path |
|---|---|---|
| 1 (más alta) | Workspace skills | `<workspace>/skills/` |
| 2 | Project agent skills | `<workspace>/.agents/skills/` |
| 3 | Personal agent skills | `~/.agents/skills/` |
| 4 | Managed/local skills | `~/.openclaw/skills/` |
| 5 | Bundled skills | Viene con la instalación |
| 6 (más baja) | Extra dirs | `skills.load.extraDirs` |

### Instalar skills

```bash
# Buscar skills disponibles
openclaw skills search

# Instalar un skill
openclaw skills install <skill-name>

# Ver skills instalados
openclaw skills list

# Verificar skills
openclaw skills check
```

### Crear skills personalizadas

Usa el **Skill Workshop** — el agente puede proponer, revisar y aprobar skills:

```
El agente usa la herramienta skill_workshop para:
- create: Crear una nueva skill propuesta
- update: Actualizar una skill existente
- list: Ver propuestas pendientes
- apply: Aprobar y aplicar una propuesta
- reject: Rechazar una propuesta
```

O manualmente, crea un directorio con `SKILL.md`:

```markdown
---
name: mi-skill
description: Descripción corta de la skill
version: "1.0"
---

# Mi Skill

Instrucciones para el agente sobre cómo y cuándo usar esta skill...
```

---

## 🖥️ CLI: Comandos Esenciales

### Setup y Configuración

```bash
openclaw onboard          # Asistente de primer setup
openclaw setup --baseline  # Setup mínimo sin wizard
openclaw configure         # Wizard de configuración
openclaw config get <path> # Leer config
openclaw config set <path> <value>  # Establecer config
openclaw config file       # Ver archivo de config completo
openclaw config schema     # Ver schema JSON completo
```

### Gateway y Diagnóstico

```bash
openclaw gateway            # Iniciar gateway (foreground)
openclaw gateway status     # Estado del gateway
openclaw gateway restart    # Reiniciar gateway
openclaw gateway stop       # Detener gateway
openclaw status             # Estado local
openclaw status --all       # Diagnóstico completo
openclaw status --deep      # Probar canales activos
openclaw health --json      # Snapshot de salud via WS
openclaw doctor             # Diagnosticar problemas
openclaw doctor --fix       # Diagnosticar y reparar
openclaw logs               # Ver logs
openclaw logs --follow      # Seguir logs en vivo
```

### Mensajería

```bash
openclaw message send --channel telegram --to "123456" "Hola mundo"
openclaw channels list      # Listar canales configurados
openclaw channels status    # Estado de canales
openclaw channels add       # Agregar canal
openclaw channels login     # Login a canal (QR para WhatsApp)
```

### Modelos

```bash
openclaw models list        # Listar modelos disponibles
openclaw models status      # Estado de modelos
openclaw models set <model> # Establecer modelo por defecto
openclaw models auth login   # Login interactivo a proveedores
```

### Sesiones y Memoria

```bash
openclaw sessions           # Listar sesiones
openclaw memory status      # Estado del índice de memoria
openclaw memory search "consulta"  # Buscar en memoria
openclaw memory index --force      # Reconstruir índice
openclaw transcripts list   # Listar transcripciones
openclaw transcripts show <id>    # Ver transcripción
```

### Cron y Automatización

```bash
openclaw cron list          # Listar jobs
openclaw cron add           # Agregar job
openclaw cron get <id>      # Ver detalle de job
openclaw cron runs --id <id> # Historial de ejecuciones
openclaw cron enable <id>   # Habilitar job
openclaw cron disable <id>  # Deshabilitar job
openclaw cron remove <id>   # Eliminar job
```

### Seguridad

```bash
openclaw security audit     # Auditoría de seguridad
openclaw secrets audit      # Auditoría de secrets
openclaw approvals get      # Ver política de aprobaciones
```

---

## 🪝 Webhooks y APIs

### Habilitar webhooks

```json5
{
  hooks: {
    enabled: true,
    token: "tu-secreto-compartido",
    path: "/hooks",
  },
}
```

### Endpoints disponibles

| Endpoint | Descripción |
|---|---|
| `POST /hooks/wake` | Encolar un system event en la sesión principal |
| `POST /hooks/agent` | Ejecutar un turn de agente aislado |
| `POST /hooks/<name>` | Custom hook con mappings |

### Ejemplo: Wake via curl

```bash
curl -X POST http://127.0.0.1:18789/hooks/wake \
  -H 'Authorization: Bearer TU_SECRETO' \
  -H 'Content-Type: application/json' \
  -d '{"text":"Nuevo email recibido","mode":"now"}'
```

### Ejemplo: Ejecutar agente via webhook

```bash
curl -X POST http://127.0.0.1:18789/hooks/agent \
  -H 'Authorization: Bearer TU_SECRETO' \
  -H 'Content-Type: application/json' \
  -d '{"message":"Resumir la bandeja de entrada","name":"Email"}'
```

⚠️ **Mantén los webhooks detrás de loopback, tailnet o proxy de confianza.**

---

## 🔒 Seguridad

### Reglas fundamentales

1. **Siempre configura `allowFrom`** — Nunca dejes un canal abierto al mundo
2. **Usa números dedicados** — No uses tu WhatsApp personal
3. **Heartbeat deshabilitado al inicio** — Actívalo solo cuando confíes en el setup: `heartbeat.every: "0m"`
4. **El workspace es privado** — No lo compartas, no incluyas secrets
5. **Configura DM scope** — Para multi-usuario, usa `per-channel-peer`

### Auditoría

```bash
openclaw security audit     # Revisión completa
openclaw doctor --fix        # Reparar problemas comunes
```

### Sandbox

Para ejecutar el agente en un entorno aislado:

```json5
{
  agents: {
    defaults: {
      sandbox: { enabled: true }
    }
  }
}
```

### Políticas de ejecución

```bash
# Ver política actual
openclaw approvals get

# Configurar modo (allowlist, confirm, etc.)
openclaw exec-policy set
```

---

## 🔧 Troubleshooting

### Comandos de diagnóstico

```bash
# Estado general
openclaw status

# Estado completo con diagnóstico de canales
openclaw status --all --deep

# Salud del gateway
openclaw health --json

# Diagnóstico y reparación
openclaw doctor
openclaw doctor --fix

# Ver logs en vivo
openclaw logs --follow

# Estado del cron
openclaw cron status
```

### Problemas comunes

| Problema | Solución |
|---|---|
| Gateway no arranca | `openclaw doctor` para ver errores de config |
| Canal desconectado | `openclaw channels status` y revisar credenciales |
| Cron no ejecuta | Verificar `cron.enabled: true` y que el Gateway esté corriendo |
| Agente no recuerda | Verificar que `MEMORY.md` y `memory/` existan en el workspace |
| Config inválida | `openclaw doctor --fix` para reparar |
| Permisos de exec | Revisar `openclaw approvals get` y policy |
| WhatsApp se desconecta | Re-escanear QR: `openclaw channels login` |

### Logs

Los logs se guardan en `/tmp/openclaw/` (default: `openclaw-YYYY-MM-DD.log`).

---

## 📚 Consejos y Buenas Prácticas

### 🎯 Configuración inicial

1. **Empieza conservador** — Deshabilita heartbeat al inicio (`"0m"`), configura `allowFrom`
2. **Usa un número dedicado** — Especialmente para WhatsApp
3. **Prueba con WebChat primero** — Antes de conectar canales externos
4. **Versiona tu workspace** — Git repo privado con backup de `AGENTS.md`, `SOUL.md`, etc.

### 🧠 Memoria

1. **`MEMORY.md` es curado, no es un dump** — Hechos duraderos, preferencias clave, resúmenes
2. **`memory/YYYY-MM-DD.md` es el diario** — Detalles, observaciones, contexto en progreso
3. **Pídele al agente que recuerde** — "Recuerda que prefiero TypeScript"
4. **Consolida periódicamente** — Usa heartbeats para revisar diarios y mover lo valioso a `MEMORY.md`

### 💬 Canales

1. **Telegram es el más fácil** — Un bot token y listo
2. **WhatsApp requiere paciencia** — QR pairing, estado en disco, reconexiones
3. **Configura `allowFrom` siempre** — Es tu primera línea de defensa
4. **Grupos: configura `mentionPatterns`** — Para que el bot solo responda cuando lo mencionen

### ⏰ Automatización

1. **Heartbeat para lo suave** — Checks periódicos, revisar email, verificar calendario
2. **Cron para lo exacto** — Reportes a las 7am, recordatorios a hora específica
3. **Usa `isolated` para tareas de fondo** — No contamina la sesión principal
4. **Modelo más barato para cron** — `--model ollama/qwen3:8b` para reportes simples

### 🔐 Seguridad

1. **Revisa `openclaw security audit` regularmente**
2. **Mantén los webhooks en loopback o behind auth**
3. **No pongas secrets en el workspace** — Usa variables de entorno o `~/.openclaw/`
4. **Sandbox para agentes no confiables**

---

## 🔗 Enlaces Útiles

| Recurso | URL |
|---|---|
| Documentación oficial | https://docs.openclaw.ai |
| Repositorio GitHub | https://github.com/openclaw/openclaw |
| Configuración completa | [Configuration Reference](/gateway/configuration-reference) |
| Canales soportados | [Channels](/channels) |
| Proveedores de modelos | [Model Providers](/providers/models) |
| Skills | [Skills Guide](/tools/skills) |
| CLI Reference | [CLI](/cli) |

---

*Guía creada por 🐰 Bot-Bunnny — A fuego, sin filtro, con ritmo.*
*Basada en la documentación oficial de OpenClaw v2026.6+*