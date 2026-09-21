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
