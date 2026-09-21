# Temario: OpenClaw Avanzado — De Usuario a Power User

> **Duración total:** 15 horas · **Nivel:** Intermedio–Avanzado · **Modalidad:** Online · **Prerrequisitos:** Node.js 22.24+/24.15+, OpenClaw instalado y funcionando, conocimientos básicos de CLI y Markdown.

## Objetivo general

Al finalizar este curso, el estudiante será capaz de **construir agentes OpenClaw avanzados de producción**: diseñar funciones (tools) propias, orquestar múltiples agentes, automatizar tareas con cron, conectar servidores MCP, integrar RAG con bases de datos vectoriales y desplegar todo el stack en contenedores Docker.

---

## Tabla de contenidos

| Módulo | Título | Horas |
|---|---|---|
| 1 | Fundamentos avanzados del gateway y la arquitectura | 1.5 |
| 2 | Creación de funciones (tools) personalizadas | 2.5 |
| 3 | Agentes múltiples y rutas de sesión | 2.0 |
| 4 | Automatización avanzada con cron | 2.0 |
| 5 | Integración con Model Context Protocol (MCP) | 2.0 |
| 6 | RAG, embeddings y bases de datos vectoriales | 2.5 |
| 7 | Despliegue en contenedores Docker | 2.0 |
| 8 | Proyecto final integrador | 0.5 *(evaluación)* |

**Total: 15 horas**

---

## Módulo 1: Fundamentos avanzados del gateway y la arquitectura (1.5 h)

**Objetivos:** Al finalizar, el estudiante podrá explicar la arquitectura de OpenClaw y diagnosticar el gateway como operador.

**Contenido:**
- 1.1 — Arquitectura: Gateway, agent runtime, workspace, sesiones y canales
- 1.2 — Configuración profunda (`~/.openclaw/openclaw.json`): agentes, herramientas, sandboxing, memoria
- 1.3 — Modelos y fallbacks: proveedores, override por sesión, cadenas de respaldo
- 1.4 — Diagnóstico: `openclaw status`, `openclaw doctor`, `openclaw logs --follow`
- 1.5 — Seguridad básica: tokens, allowlists, permisos y policy de herramientas

**Ejercicios:**
- [ ] Inspeccionar la config del gateway y mapear el workspace actual
- [ ] Configurar una cadena de fallbacks de modelos
- [ ] Ejecutar un diagnóstico completo y resolver un warning

**Resumen:** Arquitectura, configuración y operación del gateway como base para todo lo demás.

---

## Módulo 2: Creación de funciones (tools) personalizadas (2.5 h)

**Objetivos:** Al finalizar, el estudiante podrá diseñar, implementar y probar tools propias que el agente pueda invocar.

**Contenido:**
- 2.1 — Qué es una tool y cómo el agente la descubre e invoca
- 2.2 — Skills del workspace: estructura `SKILL.md` (frontmatter, `description`, gating)
- 2.3 — Crear tools con `exec`, `apply_patch`, `web_fetch` y scripts propios
- 2.4 — Buenas prácticas: prompts concisos, control de comandos, evitar inyección
- 2.5 — Probando: `openclaw agent --message "..."` y `/skill <nombre>`
- 2.6 — Publicar skills en ClawHub

**Ejercicios:**
- [ ] Crear un skill personalizado que resuelva una tarea real del flujo de trabajo
- [ ] Escribir un script reutilizable y exponerlo como tool
- [ ] Publicar una skill en ClawHub

**Resumen:** Las tools/skills son el corazón de la extensibilidad; el estudiante aprende a crearlas con seguridad y calidad.

---

## Módulo 3: Agentes múltiples y rutas de sesión (2.0 h)

**Objetivos:** Al finalizar, el estudiante podrá configurar varios agentes con workspaces y sesiones aisladas, y enrutar tráfico entre ellos.

**Contenido:**
- 3.1 — Multi-agente: `agents.list[]`, workspaces y aislamiento por agente
- 3.2 — Sesiones: main, aisladas, persistentes y rutas por canal
- 3.3 — Subagentes y delegación de tareas (`sessions_spawn`, `sessions_send`)
- 3.4 — Enrutamiento por canal y por remitente
- 3.5 — Coordinación entre agentes: casos de uso reales

**Ejercicios:**
- [ ] Crear un segundo agente con su propio workspace
- [ ] Delegar una tarea a un subagente y recolectar el resultado
- [ ] Enrutar un canal específico a un agente distinto

**Resumen:** Arquitectura multi-agente para escalar flujos sin colisión de contexto.

---

## Módulo 4: Automatización avanzada con cron (2.0 h)

**Objetivos:** Al finalizar, el estudiante podrá programar jobs recurrentes y puntuales con entrega a canales o webhooks.

**Contenido:**
- 4.1 — Scheduler de cron: schedules `at`, `every`, `cron`, `on-exit`
- 4.2 — Tipos de payload: system event, agent message, command
- 4.3 — Sesiones objetivo: `main`, `isolated`, `current`, `session:<id>`
- 4.4 — Entrega: `announce`, `webhook`, `none`; zonas horarias (`--tz`)
- 4.5 — Gestión: `openclaw cron list/get/runs/remove`, fallos y reintentos

**Ejercicios:**
- [ ] Crear un recordatorio puntual con `--delete-after-run`
- [ ] Programar una revisión aislada recurrente que avise por canal
- [ ] Enviar un resumen a un webhook

**Resumen:** Automatización fiable de tareas periódicas como operador del gateway.

---

## Módulo 5: Integración con Model Context Protocol (MCP) (2.0 h)

**Objetivos:** Al finalizar, el estudiante podrá conectar servidores MCP y exponer sus herramientas al agente.

**Contenido:**
- 5.1 — Qué es MCP y cómo encaja en la arquitectura de agentes
- 5.2 — Configurar servidores MCP en `openclaw.json` (stdin/stdio, HTTP, remotos)
- 5.3 — Exponer tools de MCP al agente y a cron
- 5.4 — Seguridad y permisos de las tools MCP
- 5.5 — Ejemplos prácticos: bases de datos, APIs externas, navegador

**Ejercicios:**
- [ ] Conectar un servidor MCP local y usar sus tools desde el agente
- [ ] Conectar un MCP remoto con autenticación
- [ ] Restringir el alcance de un MCP con allowlists

**Resumen:** Ampliar el agente con ecosistemas MCP de forma segura.

---

## Módulo 6: RAG, embeddings y bases de datos vectoriales (2.5 h)

**Objetivos:** Al finalizar, el estudiante podrá montar un pipeline RAG: indexar documentos, generar embeddings y recuperar contexto.

**Contenido:**
- 6.1 — Conceptos: RAG, embeddings, similitud vectorial, chunking
- 6.2 — Memoria y búsqueda semántica en OpenClaw (`memory_search`, `memory_get`)
- 6.3 — Bases de datos vectoriales: SQLite (builtin), QMD, LanceDB, Qdrant, pgvector
- 6.4 — Proveedores de embeddings y config de `memorySearch`
- 6.5 — Integrar RAG en un agente: indexar documentación y responder con contexto

**Ejercicios:**
- [ ] Configurar un proveedor de embeddings y reconstruir el índice
- [ ] Indexar un corpus de documentos y hacer búsquedas semánticas
- [ ] Conectar el agente a una base vectorial externa (Qdrant/pgvector)

**Resumen:** El estudiante construye un RAG funcional con memoria y vectores.

---

## Módulo 7: Despliegue en contenedores Docker (2.0 h)

**Objetivos:** Al finalizar, el estudiante podrá contenerizar el gateway OpenClaw y sus servicios complementarios.

**Contenido:**
- 7.1 — Dockerfile del gateway: runtime Node, dependencias, volumen del workspace
- 7.2 — Docker Compose: gateway + base vectorial + servidor MCP
- 7.3 — Persistencia: volúmenes para workspace, config y estado (SQLite)
- 7.4 — Redes, puertos y variables de entorno (API keys)
- 7.5 — Buenas prácticas: no guardar secretos, healthchecks, logs

**Ejercicios:**
- [ ] Crear un Dockerfile que levante el gateway con el workspace montado
- [ ] Levantar un stack Compose con gateway + Qdrant + MCP
- [ ] Persistir estado entre reinicios con volúmenes

**Resumen:** El estudiante despliega un stack completo y reproducible en Docker.

---

## Módulo 8: Proyecto final integrador (evaluación)

**Objetivo:** Integrar todos los módulos en un sistema funcional de extremo a extremo.

**Proyecto:** Construir un agente OpenClaw de producción que:
1. Exponga **tools personalizadas** (Módulo 2)
2. Use **múltiples agentes/subagentes** con rutas aisladas (Módulo 3)
3. Ejecute **jobs de cron** que reporten por canal (Módulo 4)
4. Se conecte a un **servidor MCP** (Módulo 5)
5. Responda con **RAG** sobre una base de datos vectorial (Módulo 6)
6. Corra completo en **Docker Compose** con persistencia (Módulo 7)

**Entregables:**
- Repositorio con la configuración, skills y scripts
- `docker-compose.yml` del stack completo
- Documentación breve del sistema

**Criterios de evaluación:**
- Correcta configuración y aislamiento de agentes
- Tools funcionales y seguras
- Jobs de cron operativos con entrega real
- RAG respondiendo con contexto relevante
- Stack Docker reproducible en otra máquina

---

## Evaluación final

- **40%** Proyecto integrador (Módulo 8)
- **30%** Ejercicios prácticos por módulo
- **30%** Examen teórico-práctico sobre arquitectura, cron, MCP y Docker

---

## Recursos

- Documentación oficial: https://docs.openclaw.ai
- Código fuente: https://github.com/openclaw/openclaw
- ClawHub (skills de la comunidad): https://clawhub.ai
- MCP: https://modelcontextprotocol.io
- Docker: https://docs.docker.com
