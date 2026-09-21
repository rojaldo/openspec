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
