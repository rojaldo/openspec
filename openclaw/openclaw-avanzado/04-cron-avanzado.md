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
