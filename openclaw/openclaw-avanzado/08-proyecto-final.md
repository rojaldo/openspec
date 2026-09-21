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
