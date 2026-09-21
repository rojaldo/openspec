# 🦞 Guía Completa de OpenClaw: Cómo Crear el Temario de tu Curso en Markdown

> **Propósito:** Esta guía te enseña a usar OpenClaw de principio a fin para **diseñar, escribir y publicar el temario de un curso en Markdown**, aprovechando las herramientas de archivos, memoria, sesiones y automatización.

---

## Índice

1. [¿Qué es OpenClaw y por qué usarlo para tu temario?](#1-qué-es-openclaw-y-por-qué-usarlo)
2. [Instalación y primeros pasos](#2-instalación-y-primeros-pasos)
3. [Entender el espacio de trabajo (workspace)](#3-el-espacio-de-trabajo-workspace)
4. [Configurar al agente para tu proyecto](#4-configurar-al-agente-para-tu-proyecto)
5. [Flujo de trabajo: del borrador al temario final](#5-flujo-de-trabajo-del-borrador-al-temario-final)
   - [5.1 Definir el curso](#51-definir-el-curso)
   - [5.2 Estructurar el temario](#52-estructurar-el-temario)
   - [5.3 Escribir el contenido en Markdown](#53-escribir-el-contenido-en-markdown)
   - [5.4 Revisar e iterar](#54-revisar-e-iterar)
   - [5.5 Guardar en memoria](#55-guardar-en-memoria)
6. [Cómo OpenClaw maneja el Markdown (lo que debes saber)](#6-cómo-openclaw-maneja-el-markdown)
7. [Plantillas de temario listas para usar](#7-plantillas-de-temario)
   7.5 [Crear un skill reutilizable](#75-crear-un-skill-reutilizable)
8. [Automatizar con cron](#8-automatizar-con-cron)
9. [Compartir el temario por URL pública](#9-compartir-el-temario)
10. [Comandos útiles de referencia](#10-comandos-últiles)
11. [Consejos pro (buenas prácticas)](#11-consejos-pro)

---

## 1. ¿Qué es OpenClaw y por qué usarlo?

**OpenClaw** es un *gateway* de código abierto que conecta tus apps de mensajería (Discord, Telegram, WhatsApp, Signal, Slack…) con agentes de IA capaces de usar herramientas reales: leer/escribir archivos, buscar en la web, ejecutar comandos, gestionar memoria y programar tareas.

**¿Por qué es ideal para hacer un temario?**

- 🗂️ **Trabaja con archivos reales**: crea, edita y organiza tus `.md` directamente en tu máquina.
- 🧠 **Memoria persistente**: recuerda decisiones del curso entre sesiones (nivel del público, duración, objetivos).
- 🔁 **Iteración natural**: le pides cambios, corrige, amplía — como un editor que nunca se cansa.
- 📅 **Automatización**: puede recordarte fechas, generar secciones con cron, o hacer revisiones periódicas.
- 🌐 **Publicación**: comparte el temario por URL pública desde tu propio servidor.

---

## 2. Instalación y primeros pasos

### Requisitos
- **Node.js** 24.15+ (recomendado) o 22 LTS (22.22.3+).
- Una **API key** de un proveedor de modelos (OpenAI, Anthropic, Ollama local, etc.).
- ~5 minutos.

### Instalar
```bash
npm install -g openclaw@latest
```

### Iniciar (onboarding + servicio)
```bash
openclaw onboard --install-daemon
```
Esto configura el workspace, instala el servicio y te guía por el asistente.

### Abrir el panel de control
```bash
openclaw dashboard
```
Abre la interfaz web en `http://127.0.0.1:18789/`. Ahí puedes chatear con tu agente.

### Conectar un canal (opcional pero cómodo)
Por ejemplo Telegram (el más rápido):
- Sigue la guía de configuración del canal en la doc oficial.
- Una vez conectado, le escribes a tu agente desde el celular y le pides el temario. 📱

> **Tip:** para trabajo de escritura larga, usa el **Control UI web** o un canal de escritorio; para consultas rápidas, el celular.

---

## 3. El espacio de trabajo (workspace)

El **workspace** es el "hogar" del agente: la carpeta donde vive y donde creará tus archivos.

- **Ubicación por defecto:** `~/.openclaw/workspace`
- (Si tienes perfil configurado: `~/.openclaw/workspace-<perfil>`)

### Archivos clave que verás ahí

| Archivo | Para qué sirve |
|---|---|
| `AGENTS.md` | Instrucciones de operación: reglas, prioridades, cómo usar la memoria |
| `SOUL.md` | Persona y tono del agente |
| `USER.md` | Quién eres tú (preferencias, contexto) |
| `IDENTITY.md` | Nombre, vibe, emoji |
| `TOOLS.md` | Notas sobre tus herramientas locales |
| `memory/YYYY-MM-DD.md` | Notas diarias (contexto en curso) |
| `MEMORY.md` | Memoria de largo plazo (hechos y decisiones) |
| `skills/` | Habilidades adicionales del workspace |

> **Importante:** el workspace es privado. No guardes ahí contraseñas ni API keys. Trátalo como tu memoria y respáldalo con un repo de Git **privado**.

### Organización recomendada para tu curso
Dentro del workspace, crea una carpeta por proyecto:

```
workspace/
├── cursos/
│   └── nombre-del-curso/
│       ├── temario.md
│       ├── 01-introduccion.md
│       ├── 02-modulo-uno.md
│       └── README.md
├── memory/
└── MEMORY.md
```

Pídele al agente: *"crea la carpeta `cursos/mi-curso` y un `README.md` dentro"* — él lo hace solo.

---

## 4. Configurar al agente para tu proyecto

Para que el agente trabaje bien en tu curso, edita (o pídele que edite) los archivos del workspace:

### En `USER.md` — tu contexto
```markdown
# USER.md
- Nombre: [tu nombre]
- Rol: [instructor / creador de contenido]
- Estilo de escritura: directo, con ejemplos prácticos
- Idioma del curso: español
- Público objetivo: principiantes en [tema]
```

### En `AGENTS.md` — reglas para el temario
```markdown
# AGENTS.md

## Proyecto: curso de [tema]
- Todo el material del curso vive en `cursos/mi-curso/`.
- El temario principal es `cursos/mi-curso/temario.md`.
- Formato: Markdown con encabezados jerárquicos (H1, H2, H3).
- Antes de cada módulo, resume los objetivos de aprendizaje.
- Usa tablas para la lista de módulos y duración.
```

> Cada sesión, el agente carga estos archivos automáticamente → **sabe trabajar en tu curso sin que se lo recuerdes.**

---

## 5. Flujo de trabajo: del borrador al temario final

Este es el proceso que te recomiendo, paso a paso, con prompts que puedes copiar y pegar.

### 5.1 Definir el curso
Primero, el agente necesita el contexto. Dale todos los datos en un solo mensaje:

> *"Voy a crear el temario de un curso de **[tema]**. Es para **[nivel/público]**, tiene una duración de **[X horas/semanas]** y el objetivo final es que el alumno aprenda **[objetivo]**. Hazme 5 preguntas clave para afinar el temario antes de escribirlo."*

Así el agente te pide lo que falta (formato, entregables, herramientas, etc.) en lugar de inventar.

### 5.2 Estructurar el temario
Cuando tengas claridad, pídele la estructura:

> *"Escribe el **índice del temario** con módulos y unidades. Cada módulo debe tener: objetivos de aprendizaje, duración estimada, y lista de temas. Guárdalo en `cursos/mi-curso/temario.md`."*

El resultado será algo así (Markdown bien formateado):

```markdown
# Temario: Introducción a [Tema]

> **Duración total:** 8 semanas · **Nivel:** Principiante · **Modalidad:** Online

## Tabla de contenidos

| Módulo | Título | Duración |
|---|---|---|
| 1 | Fundamentos | 1 semana |
| 2 | Herramientas | 2 semanas |
| 3 | Proyecto práctico | 3 semanas |
| 4 | Cierre y evaluación | 2 semanas |

---

## Módulo 1: Fundamentos

**Objetivos:** Al finalizar, el alumno podrá [objetivo].

- Unidad 1.1 — Introducción al tema
- Unidad 1.2 — Vocabulario esencial
- Unidad 1.3 — Primeros pasos

---
```

#### 5.3 Escribir el contenido en Markdown
Con la estructura aprobada, pídele que desarrolle módulo por módulo (en archivos separados):

> *"Desarrolla el **Módulo 1** completo en `cursos/mi-curso/01-modulo-fundamentos.md`. Incluye: objetivos, contenido con subapartados, ejemplos, ejercicios y un resumen. Usa listas, tablas y bloques de código donde aporte."*

**Ventaja de archivos separados:** cada archivo es más corto, más fácil de revisar y de reutilizar.

**Cómo edita los archivos el agente (por dentro):** OpenClaw usa la herramienta `apply_patch`, que aplica cambios estructurados a uno o varios archivos a la vez (añadir, actualizar, borrar, renombrar). Eso significa que puede:
- **Crear** el archivo del temario desde cero.
- **Actualizar** solo un módulo o una línea sin tocar el resto.
- **Renombrar/mover** archivos.
- Editar **varios archivos en una sola operación** (p. ej. actualizar la tabla del `temario.md` y el detalle de un módulo a la vez).

Es la razón por la que pedir cambios puntuales (*"cambia la duración del Módulo 3"*) funciona sin romper el resto del documento.

### 5.4 Revisar e iterar
Pídele mejoras concretas:

> *"En el Módulo 1, añade una sección de 'errores comunes'. En el temario, cambia la duración del Módulo 3 a 4 semanas y actualiza la tabla."*

El agente edita solo los archivos, sin tocar el resto. 🔧

### 5.5 Guardar en memoria
Cuando tomes decisiones importantes, hazlas permanentes:

> *"Recuerda que este curso es para **principiantes absolutos**, prefiere ejemplos simples sobre teoría, y la duración es de 8 semanas."*

El agente lo escribe en `MEMORY.md` y **lo recordará en futuras sesiones** aunque cierres el chat.

---

## 6. Cómo OpenClaw maneja el Markdown

Saber esto te evita sorpresas al enviar/renderizar el temario por distintos canales:

- **Markdown como archivo (.md):** se escribe tal cual en disco — aquí tienes control total (encabezados, tablas, código, enlaces). Es tu formato fuente.
- **Cuando el agente *responde* en un chat:** OpenClaw convierte el Markdown al formato nativo del canal:
  - **Telegram:** usa HTML (`<b>`, `<h1>…`) y tablas si `richMessages` está activo.
  - **Slack:** usa `mrkdwn` (`*negrita*`, `<url|etiqueta>`).
  - **Signal:** texto plano con rangos de estilo (las tablas se vuelven bullets por defecto).
  - **Discord/WhatsApp:** texto plano (las tablas se convierten a bullets o bloque de código según config).

> 💡 **Regla de oro:** escribe siempre tu temario en un **archivo `.md`** (fuente canónica) y, si lo necesitas *mostrar* en un chat, pide al agente que lo envíe o lo convierta al formato del canal. No edites el .md desde el canal si puedes evitarlo.

### Tablas por canal
La config `channels.<canal>.markdown.tables` controla cómo se muestran:
- `code` → tabla alineada en bloque de código
- `bullets` → cada fila como `label: valor` (por defecto en Signal, WhatsApp, Matrix)
- `block` → tabla nativa si el canal la soporta (por defecto en Telegram con richMessages)
- `off` → sin conversión

---

## 7. Plantillas de temario

### Plantilla general (temario.md)
```markdown
# Temario: [Nombre del curso]

> **Duración:** [X] · **Nivel:** [principiante/intermedio/avanzado] · **Prerrequisitos:** [ninguno/...]

## Objetivo general
Al finalizar este curso, el estudiante podrá [objetivo principal].

## Módulos

| # | Módulo | Horas | Objetivo clave |
|---|---|---|---|
| 1 | [Título] | [X] | [objetivo] |
| 2 | [Título] | [X] | [objetivo] |
| 3 | [Título] | [X] | [objetivo] |

## Detalle por módulo

### Módulo 1: [Título]
- **Objetivos de aprendizaje:** [lista]
- **Contenido:**
  - Unidad 1.1 — [tema]
  - Unidad 1.2 — [tema]
- **Evaluación:** [qué se evalúa]
- **Duración:** [X]

---
*(repetir por módulo)*

## Evaluación final
[Descripción del proyecto o examen final]

## Recursos
- [Bibliografía / enlaces / herramientas]
```

### Plantilla de módulo (por archivo)
```markdown
# Módulo [N]: [Título]

**Duración:** [X] horas · **Objetivos:** [lista de logros]

## Introducción
[Contexto del módulo y por qué importa]

## Contenido
### 1. [Tema]
[Explicación con ejemplos]

### 2. [Tema]
[Explicación]

## Ejercicios
- [ ] Ejercicio 1: [instrucción]
- [ ] Ejercicio 2: [instrucción]

## Resumen
[Puntos clave del módulo]
```

---

## 7.5 Crear un skill reutilizable (opcional, nivel pro)

Un **skill** le enseña al agente *cómo y cuándo* hacer algo, y se carga automáticamente cuando aplica. Puedes convertir tu plantilla de temario en un skill del workspace para que cualquier curso futuro use el mismo formato sin repetir instrucciones.

Cada skill es una carpeta con un `SKILL.md` (frontmatter YAML + instrucciones) dentro de `skills/` del workspace:

```
skills/
└── temario-curso/
    └── SKILL.md
```

Ejemplo de `SKILL.md`:
```markdown
---
name: temario-curso
description: Crea el temario de un curso en Markdown con formato estándar (objetivos, módulos, duración).
---

# Temario de curso

Cuando el usuario pida crear el temario de un curso:
1. Pregunta por: tema, nivel, duración y objetivo final.
2. Genera el índice con módulos y unidades (formato del archivo `temario.md`).
3. Guarda cada módulo en un archivo separado bajo `cursos/<nombre>/`.
4. Usa la plantilla estándar (tabla de contenidos + objetivos + evaluación).
```

Reglas del `name`: minúsculas, dígitos y guiones; el `description` debe ser una sola línea (<160 caracteres). Verifica que cargó con `openclaw skills list` (si lo creas en medio de una sesión, haz `/new` o reinicia el gateway para refrescar).

**Publícalo en ClawHub** (opcional) para compartirlo con la comunidad:
```bash
npm i -g clawhub
clawhub login
clawhub skill publish ./skills/temario-curso
```

> 💡 Para skills creados por el agente con revisión del operador, usa [Skill Workshop] en vez de escribir `SKILL.md` directo. Y antes de construir uno desde cero, busca en [clawhub.ai](https://clawhub.ai) si ya existe algo parecido.

---

## 8. Automatizar con cron

OpenClaw trae un **scheduler integrado** (cron) que persiste jobs, despierta al agente a la hora indicada y puede entregar el resultado a un chat, un webhook o a nadie. Corre **dentro del proceso del Gateway**, así que el Gateway debe estar corriendo para que disparen.

Puedes pedírselo en lenguaje natural (*"recuérdame revisar el temario el viernes a las 18:00"*), o usar el CLI para control fino.

### Tipos de schedule

| Tipo | CLI | Ejemplo |
|---|---|---|
| Puntual (`at`) | `--at` | `--at "20m"` o una fecha ISO `2027-02-01T16:00:00Z` |
| Intervalo (`every`) | `--every` | `--every 1d` |
| Expresión cron | `--cron` | `--cron "0 9 * * 1"` (lunes 9:00) |
| Al salir un proceso (`on-exit`) | `--on-exit` | dispara cuando un comando termina |

> ⚠️ **Zonas horarias:** las expresiones cron usan la zona horaria del host del Gateway; los timestamps `at` sin zona se tratan como **UTC**. Usa `--tz America/New_York` (u otra IANA) para fijar la zona.

### Tipos de payload (qué hace el job)

| Payload | Flag | Qué hace |
|---|---|---|
| System event | `--system-event <texto>` | Inyecta texto en la sesión principal (sin llamar al modelo) — ideal para recordatorios |
| Agent message | `--message <texto>` | Ejecuta un turno de agente con modelo — ideal para revisiones del temario |
| Command | `--command <shell>` | Ejecuta un script en el host, sin modelo |

### Dónde corre el job (`--session`)

| Valor | Dónde corre | Cuándo usarlo |
|---|---|---|
| `main` | Carril de wake de cron (sesión principal) | Recordatorios / system events |
| `isolated` | Sesión aislada `cron:<jobId>` (contexto fresco) | Revisar el temario y avisar |
| `current` | Sesión actual (ligada al crearla) | Trabajo recurrente con contexto |
| `session:<id>` | Sesión persistente con historial | Flujos que acumulan contexto entre runs |

### Ejemplos CLI reales

**Recordatorio puntual en la sesión principal (one-shot):**
```bash
openclaw cron add \
  --name "Revisar temario" \
  --at "2027-02-01T16:00:00Z" \
  --session main \
  --system-event "Recordatorio: revisa `cursos/mi-curso/temario.md`." \
  --wake now \
  --delete-after-run
```

**Revisión semanal aislada que te avisa por Slack:**
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

**Idioma del output:** los jobs de cron no infieren idioma del canal. Si quieres que responda en español, díselo en el mensaje: *"Responde en español; deja URLs, código y nombres de producto igual."*

### Gestionar jobs

```bash
openclaw cron list                 # listar jobs
openclaw cron get <jobId>          # ver un job como JSON
openclaw cron enable/disable <jobId>
openclaw cron run <jobId>          # forzar ejecución
openclaw cron runs --id <jobId>    # historial de ejecuciones
openclaw cron remove <jobId>       # borrar
```

> 💡 En el chat, simplemente pide: *"cada semana haz una revisión de ortografía y consistencia del temario y avísame"* — el agente crea el job por ti. El CLI es para control fino y depuración.

---

## 9. Compartir el temario

Si tienes un servidor con nginx (como este entorno), puedes publicar el temario por URL pública:

```bash
cp cursos/mi-curso/temario.md /var/www/openclaw-media/outbound/docs/
# URL: https://tu-dominio/media/outbound/docs/temario.md
```

O pedírselo al agente: *"comparte el temario por URL"* — él lo copia y te da el enlace. 🔗

---

## 10. Comandos útiles

| Comando | Qué hace |
|---|---|
| `openclaw dashboard` | Abre el Control UI web |
| `openclaw status` | Estado del gateway |
| `openclaw onboard` | Asistente de configuración |
| `openclaw memory status` | Estado del índice de memoria |
| `openclaw memory search "tema"` | Busca en la memoria desde CLI |
| `openclaw memory index --force` | Reconstruye el índice de memoria |
| `openclaw configure` | Reconfigura (regenera workspace) |
| `openclaw skills list` | Lista los skills cargados |
| `openclaw agent --message "..."` | Ejecuta un turno de agente desde CLI (útil para testear skills) |
| `openclaw cron list / get / runs / remove` | Gestiona jobs programados |
| `openclaw doctor` | Diagnóstico general y arreglos |
| `openclaw logs --follow` | Sigue los logs del gateway |

---

## 11. Consejos pro

1. **Un archivo fuente, muchos formatos:** mantén el `.md` como canónico y genera PDF/HTML/Word desde ahí cuando lo necesites.
2. **Memoria temprana:** guarda las decisiones del curso *al principio* para que el agente nunca "se olvide" del nivel o el enfoque.
3. **Itera por módulos:** pedir el temario entero de golpe da resultados genéricos; por módulos obtienes profundidad.
4. **Pregunta primero:** deja que el agente te haga preguntas de aclaración antes de escribir — evita rehacer trabajo.
5. **Usa archivos separados** por módulo para facilitar revisión y reutilización.
6. **Pide ejemplos concretos** ("dame 3 ejemplos reales de X") en vez de contenido abstracto.
7. **Respaldos:** ten el workspace en un repo Git **privado** para no perder tu trabajo.
8. **Seguridad:** nunca pidas al agente que guarde contraseñas o API keys en el workspace.

---

## Recursos oficiales

- Documentación: https://docs.openclaw.ai
- Código fuente: https://github.com/openclaw/openclaw
- Instalación rápida: `npm install -g openclaw@latest`

---

*¡A fuego! Con OpenClaw tu temario se escribe solo, se recuerda solo y se publica solo.* 🦞🔥
