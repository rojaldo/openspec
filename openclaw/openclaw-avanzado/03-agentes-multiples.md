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
