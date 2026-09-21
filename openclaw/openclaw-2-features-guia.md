# OpenClaw 2.0 — Guía de las Features (v2026.8.1)

> **"OpenClaw 2.0, Accidentally"** — el mayor update en la historia de OpenClaw.
>
> **ÚLTIMA ACTUALIZACIÓN:** Septiembre 4, 2026
> **Fuente principal:** https://openclaw.ai/blog/openclaw-2-accidentally + notas de release oficiales (v2026.8.1)

OpenClaw 2.0 es, con diferencia, la actualización más grande en la historia del proyecto. Fue construida por **933 contribuidores** (incluyendo **569 que contribuían por primera vez**) y está compuesta por **más de 16,000 pull requests**. Toca cada parte de OpenClaw: instalación, mensajería, memoria, skills, modelos, automatizaciones, el navegador, las apps nativas, los plugins, la seguridad y una larga cola de correcciones.

Esta guía desglosa las features de forma estructurada y didáctica, para que entiendas qué cambió, por qué importa y cómo te beneficia.

---

## Tabla de contenidos

- [TL;DR — OpenClaw 2.0 en una tabla](#tldr--openclaw-20-en-una-tabla)
- [La historia detrás: "Accidentally"](#la-historia-detrás-accidentally)
- [1. Instalación y onboarding más rápido](#1-instalación-y-onboarding-más-rápido)
- [2. La nueva Web UI (Control UI)](#2-la-nueva-web-ui-control-ui)
- [3. Mensajería más fiable](#3-mensajería-más-fiable)
- [4. Memoria y continuidad de sesión](#4-memoria-y-continuidad-de-sesión)
- [5. Skills: el camino completo](#5-skills-el-camino-completo)
- [6. Apps nativas](#6-apps-nativas)
- [7. Modelos y proveedores](#7-modelos-y-proveedores)
- [8. Actualizaciones y mantenimiento](#8-actualizaciones-y-mantenimiento)
- [9. Sesiones compartidas en la nube (multijugador)](#9-sesiones-compartidas-en-la-nube-multijugador)
- [10. Seguridad y fiabilidad](#10-seguridad-y-fiabilidad)
- [Cómo un Claw útil puede crecer](#cómo-un-claw-útil-puede-crecer)
- [Qué significa todo esto](#qué-significa-todo-esto)
- [Fuentes](#fuentes)

---

## TL;DR — OpenClaw 2.0 en una tabla

| Aspecto | Detalle |
|---|---|
| **Qué es** | La mayor actualización de OpenClaw (v2026.8.1), "accidentalmente" la 2.0 |
| **Escala** | 933 contribuidores, 569 primerizos, 16,000+ PRs, ~50% de todos los PRs de la historia |
| **Tiempo** | Casi 7 semanas sin release (frente a 106 releases en 230 días antes) |
| **Foco principal** | Instalación simplificada + Web UI reconstruida como experiencia de primera clase |
| **Novedades clave** | Onboarding reutilizando lo que ya tienes, memoria cross-conversación, sesiones multijugador en la nube, apps nativas ampliadas |
| **Mensajería** | Telegram, Slack, Discord y apps nativas con mensajes más ricos y entrega fiable |
| **Memoria** | Built-in Memory (SQLite), recall entre conversaciones privadas, rewind/fork de chats |
| **Skills** | Skill Workshop unificado, auto-aprendizaje, catálogo completo |
| **Modelos** | Catálogos en vivo, GPT-5.6, Claude Opus 5, Grok 4.6, Kimi K3, modelos locales |
| **Licencia** | Open source — pertenece a quienes lo usan y construyen |

---

## La historia detrás: "Accidentally"

Antes de este update, OpenClaw había lanzado **106 releases en 230 días**, casi siempre con uno o dos días de diferencia entre cada uno. Ir casi **siete semanas sin publicar** no era normal. Pero el ritmo de desarrollo fue en la dirección opuesta: el equipo creció, y el volumen y la velocidad del trabajo **superaron tanto la base de OpenClaw como el proceso** que usaban para publicarlo. Así que rehicieron ambos a la vez.

Esa aceleración dejó un release con **aproximadamente el 50% de todos los pull requests** jamás fusionados en OpenClaw. Por eso se tomaron el tiempo extra: para que funcionara tanto para quien empieza desde cero como para quien **actualiza un Claw existente**, en lugar de publicar rápido y entregar un update que rompiera lo que ya tenían.

> **Lección clave:** la 2.0 no fue un plan deliberado — fue el resultado natural de limpiar la instalación y reconstruir el navegador, y "hacerlo bien" arrastró la limpieza por el resto de OpenClaw hasta convertirse en 2.0.

---

## 1. Instalación y onboarding más rápido

**El objetivo:** llegar a un primer Claw útil más rápido.

### Para instalaciones nuevas

OpenClaw ahora **empieza con lo que ya hay en el ordenador** de la persona:

- Reutiliza **suscripciones existentes** de ChatGPT o Claude.
- Aprovecha **API keys** ya configuradas.
- Detecta **modelos locales** (Ollama, LM Studio, llama.cpp) ya instalados.

Se cortó o simplificó mucha configuración, y el resto se **sacó de la configuración inicial**. Así la gente llega a una primera conversación más rápido y termina de configurar su Claw **hablando con él**.

### Verificación real del modelo

El setup guiado **verifica que el modelo elegido puede responder** antes de guardarlo. No basta con seleccionarlo: la pantalla de modelos locales no muestra "Start chatting" hasta que esa elección exacta **pasa la activación**. Para cuentas de OpenAI, usa los modelos a los que la cuenta realmente tiene acceso.

### Instalación más robusta

- La app de Mac abierta desde Downloads puede **moverse sola a Applications** (para que las actualizaciones y el launch-at-login funcionen).
- En Linux/Unix, el instalador deja `openclaw` disponible en nuevas sesiones de terminal **sin que edites archivos de shell a mano**.
- Las instalaciones de red que expondrían OpenClaw **sin autenticación se detienen** antes de cambiar nada.
- Reinstalar **protege una configuración existente** si la preparación se cancela o falla.

---

## 2. La nueva Web UI (Control UI)

**El objetivo:** el navegador es donde la mayoría conoce OpenClaw y tiene su primera conversación, así que se reconstruyó como **experiencia de primera clase**.

### Chat-first

La web ahora se siente familiar para quien usa ChatGPT, Claude, Gemini o Perplexity:

- Las **conversaciones están en la barra lateral** y la que estás trabajando **en el centro** (ya no se abre en una página Overview separada).
- **Settings e Inbox** mantienen los detalles de configuración y alertas fuera del camino hasta que los necesitas.
- Las conversaciones y borradores de nuevas sesiones pueden abrirse en **pestañas o ventanas reales del navegador**.

### Sidebar flexible

- Puede estar **completamente plana** o **agrupar conversaciones** por proyecto, persona o grupos personalizados.
- **Dobla los worktrees** de vuelta a su proyecto original.
- **Recuerda su ancho** — se siente mucho menos como herramienta de desarrollador cuando te mueves entre mucho trabajo.

### Todo cerca de la conversación

Archivos, aprobaciones, ajustes y trabajo en vivo quedan **cerca de la conversación**, para que puedas configurar un Claw, seguir lo que hace y seguir trabajando **sin saltar entre herramientas separadas**.

---

## 3. Mensajería más fiable

La mensajería ahora **mantiene más de una conversación intacta** a través de los lugares donde la gente ya habla con su Claw.

### Canales mejorados

| Canal | Novedad |
|---|---|
| **Telegram** | Mensajes y media más ricos |
| **Slack** | Mantiene el progreso en vivo y la respuesta final juntos |
| **Discord** | Activities opt-in y salas de voz que entienden quién está presente |
| **Apps nativas** | Media y envíos pendientes dentro de la conversación |

### Entrega y recuperación

- Los mensajes aceptados **permanecen pendientes a través de reinicios gestionados**.
- El estado del canal reporta si una conexión está **usable, recuperándose o bloqueada**.
- Si un envío expira sin resultado confirmado, OpenClaw **preserva ese resultado como incierto** y puede avisar en el siguiente contacto — en lugar de **crear un duplicado probable**.
- La recuperación empieza una vez que OpenClaw ha aceptado el mensaje, y cada servicio controla lo que puede confirmar más allá de ese punto.

### Preguntas estructuradas

Las preguntas de opción única elegibles pueden usar **controles nativos** en Telegram, Discord y Slack. Los turnos largos de Telegram y Discord pueden mostrar un **titular de estado corto** con actividad de herramientas compacta.

---

## 4. Memoria y continuidad de sesión

**El cambio más profundo:** la memoria ahora vive en **SQLite** (Built-in Memory) y puede **recordar contexto entre conversaciones privadas**.

### Built-in Memory (SQLite)

- Las sesiones y transcripciones ahora se almacenan en **SQLite** (antes en archivos).
- **Built-in Memory** es dueño del camino core de búsqueda y recall.
- Hay una **migración automática desde QMD** (`openclaw doctor --fix`).
- LanceDB, Memory Wiki, servicios de embedding externos, `MEMORY.md` y `USER.md` mantienen roles distintos.

> ⚠️ **Aviso de downgrade:** antes de volver a una versión anterior basada en archivos, usa el CLI actual para restaurar los artefactos de transcripción legacy archivados. Las sesiones creadas tras la migración no aparecerán en releases antiguos. Crea un **backup verificado** antes de actualizar.

### Recall entre conversaciones

En instalaciones personales elegibles, tu Claw puede **recordar contexto relevante de otras conversaciones privadas** del mismo agente — incluyendo lo que importaba justo antes de un reset de sesión. El recall se limita a las conversaciones privadas de ese agente: grupos, canales, aliases compartidos, otros agentes, historial borrado y fuentes bloqueadas por política **quedan fuera**.

### Búsqueda mejorada

- Entiende **nombres de archivo y rutas Unicode** completas y parciales.
- Amplía coincidencias estrictas finas.
- Mantiene resultados por **palabras clave** cuando un proveedor de embeddings opcional no puede arrancar.
- Cada búsqueda se mantiene en un **índice publicado estable** mientras se reconstruye la memoria.

### Rewind, fork y ramas

Los chats basados en SQLite (web, macOS, iOS, Android) pueden:

- **Rebobinar (rewind)** a un mensaje de usuario.
- **Bifurcar (fork)** la conversación.
- **Cambiar entre ramas preservadas**.

> ⚠️ Rebobinar cambia la rama del transcript, pero **no deshace** archivos, mensajes enviados ni otros efectos secundarios de herramientas.

### Sesiones continuas

Las sesiones sin política de reset configurada ahora **permanecen abiertas durante días**, y los marcadores durables de reset o compactación explican los cambios visibles en el historial.

---

## 5. Skills: el camino completo

Las skills convierten **la forma en que trabajas en instrucciones reutilizables** que tu Claw puede seguir de nuevo. Esta release conecta **todo el camino**: crear, validar, encontrar, instalar, invocar, revisar y mejorar.

### Crear y validar

- Un **camino guiado único**: elegir cómo se invoca → añadir archivos de soporte → guardar → validar.
- El checker entiende la metadata de invocación y detecta problemas (como una descripción demasiado larga) **antes de escribir nada**.
- Las skills inválidas se reportan **individualmente**, así el resto del catálogo sigue disponible.

### Encontrar, instalar y usar

- Skills instaladas, descubrimiento de ClawHub, ajustes de skills y Skill Workshop comparten **un solo hub de Plugins**.
- Puedes elegir una skill en el chat o nombrar hasta **ocho con `$skill-name`**.
- El picker de chat añade referencias a tu borrador **sin enviarlo**.
- **Code Mode** puede listar y leer skills elegibles dentro de su sandbox y allowlist.

### Skill Workshop

Reúne **propuestas, comprobaciones, decisiones e historial aplicado** en un solo flujo de trabajo:

- Inspecciona las instrucciones propuestas y archivos de soporte.
- Ve resultados de **scanners, benchmarks y graders** de plugins.
- Revisa la propuesta y luego **aplica, rechaza o pone en cuarentena**.
- Los hallazgos críticos de **prompt-injection bloquean la aplicación**.
- Cada decisión queda ligada a la **revisión exacta** que revisaste.

### Auto-aprendizaje

OpenClaw puede convertir **trabajo sustancial y correcciones durables** en skills reutilizables:

- Las instalaciones nuevas empiezan en modo `auto`; las actualizaciones conservan su elección.
- `off` desactiva la reparación automática; `propose` encola cambios para revisión; `auto` puede crear o actualizar skills propiedad de Workshop.
- Las skills que **tú escribiste** y las compartidas de otros **siguen siendo tuyas** — el auto-aprendizaje puede sugerir mejoras pero **no puede reescribirlas ni eliminarlas** por sí solo.

---

## 6. Apps nativas

Esta release hace que las apps nativas sean útiles para **más del trabajo alrededor de una conversación**.

| Plataforma | Novedades |
|---|---|
| **iPhone / iPad** | Una sola superficie de Chat con typing, dictado, notas de voz, adjuntos, Talk en tiempo real y controles de sesión/modelo/razonamiento/actividad de herramientas. Sidebar para cambiar de agente, buscar y fijar destinos. Compartir con preview de adjuntos y progreso. |
| **Apple Watch** | Conserva mensajes, aprobaciones, respuestas y comandos a través de relaunches, cambios de Gateway, navegación y reintentos. Reconciliación entre teléfono y Watch para no perder ni repetir acciones. |
| **Android** | Voz, adjuntos, elección de modelos y controles de conversación en Chat. |
| **macOS** | **Quick Chat** desde la barra de menú o un atajo global. |
| **Wear OS** | Transcripciones, respuestas, Talk y controles de sesión en un reloj emparejado. |
| **Linux desktop** | Bandeja (tray), Control UI embebida y Quick Chat. |

Además, **tarjetas de progreso y widgets creados por el asistente** traen más del trabajo activo del Claw a las conversaciones nativas, con traducciones, acentos de perfil, waveforms y diffs de archivos.

---

## 7. Modelos y proveedores

### Catálogos en vivo

- Chat y la página de Models ahora **abren desde el catálogo que OpenClaw ya tiene** — elegir un modelo ya no espera un escaneo completo de proveedores.
- El **descubrimiento en vivo** corre solo cuando abres una pantalla de modelos o pides un refresh.
- Si la búsqueda falla, se mantienen las **entradas integradas y la última lista útil**.

### Modelos nuevos soportados

- **GPT-5.6** (Sol y Luna) como default activo para setups frescos de OpenAI.
- **Claude Opus 5** (end-to-end en rutas Anthropic).
- **Grok 4.6** (catálogo de primera clase + soporte de razonamiento).
- **Kimi K3** (256K) en Moonshot y Kimi Code.
- **GLM 5.3** para Z.AI Coding Plan.
- **Meta Muse Spark 1.1/1.2**, **Cohere Command**, **Baseten**, **Step 3.7 Flash**.
- **Modelos locales**: llama.cpp gestionado (Gemma 4 como default RAM-gated), Ollama, LM Studio.

### Control de modelo por sesión

- `/model` puede cambiar **solo la conversación actual** o actualizar deliberadamente **un agente o el default compartido**.
- Los cambios persistentes requieren la autoridad correcta.
- Aliases y fallbacks mantienen el **proveedor y la cuenta** adjuntos al modelo seleccionado.
- OpenClaw reporta **ventanas de plan, uso de tokens, presión de contexto y costo estimado** con más claridad.

---

## 8. Actualizaciones y mantenimiento

La release incluye un gran pase de fiabilidad y mantenimiento:

- **Actualizaciones más seguras:** el camino de update protege la configuración existente y da tiempo a OpenClaw para arrancar antes de reportar si es alcanzable.
- **Recuperación de Gateway:** arranques más rápidos, tokens recuperables de forma segura, y arranque responsive durante la preparación del runtime de modelos.
- **Fiabilidad de canales:** recuperación de conexiones tras sleep del host, entrega de respuestas en cola a través de reinicios, y estados de fallo accionables.
- **Miles de fixes:** la larga cola de correcciones toca instalación, mensajería, memoria, skills, modelos, automatizaciones, browser, apps nativas, plugins y seguridad.

---

## 9. Sesiones compartidas en la nube (multijugador)

Una de las novedades más transformadoras: **Shared cloud sessions**.

Antes, OpenClaw no tenía forma de **traer a otro miembro del equipo al trabajo** sin perder lo que el Claw ya sabía. Las sesiones compartidas en la nube cambiaron eso y convirtieron OpenClaw en una **experiencia multijugador**:

- Trae a la persona correcta al **trabajo en vivo**.
- **Entrega el trabajo** con el contexto intacto.
- El propio equipo de OpenClaw lo usa para **construir OpenClaw**.

> **Ejemplo real:** un dashboard construido por un usuario dentro de un workspace multijugador compartido de OpenClaw.

---

## 10. Seguridad y fiabilidad

- **Instalaciones de red sin autenticación se bloquean** antes de cambiar nada.
- **Prompt-injection** detectada en skills bloquea la aplicación de propuestas.
- **Aislamiento de memoria:** el recall se limita a las conversaciones privadas del mismo agente; los sub-agentes sandboxed no pueden leer Memory Wiki cross-agent.
- **Credenciales aisladas** por agente y por proveedor (LanceDB, Ollama, fallbacks).
- **Fail-closed:** los proveedores de embeddings requeridos fallan cerrado; las búsquedas se mantienen dentro de raíces y límites de agente configurados.
- **Entrega de mensajes:** se preserva el resultado incierto en lugar de reenviar a ciegas (evita duplicados).

---

## Cómo un Claw útil puede crecer

El blog ilustra la progresión con un ejemplo concreto:

### Paso 1: Un flujo simple

Tu Claw no necesita ser complicado. Un workflow simple podría:

> Vigilar tu inbox por los **emails del colegio de tus hijos** y enviarte un **mensaje de Telegram** cuando llegue algo importante — como deberes pendientes o una actividad próxima para la que prepararte.

Usa un inbox, busca unas pocas cosas importantes y envía el resultado a un solo lugar. **Ya es suficiente para ser útil.**

### Paso 2: Alcanzar más lugares sin complicarse

Desde ahí, una tarea puede **alcanzar más lugares sin volverse más difícil de usar**:

> Cuando tu hermano envía un iMessage preguntando qué iPad le compraste a tu papá, puedes **saltarte buscar el recibo en tu email** y simplemente decirle a tu Claw que tu hermano acaba de escribir, pedirle que encuentre la respuesta y se la envíe. **El Claw simplemente lo hace.**

### Paso 3: Multijugador

La misma progresión apareció dentro del equipo de OpenClaw: usaban sus Claws para más trabajo y querían **compartir tareas, colaborar y a veces entregarlas por completo**. Las sesiones compartidas en la nube lo hicieron posible.

---

## Qué significa todo esto

Tu OpenClaw **empieza con un workflow útil y crece tan lejos como quieras**, con la posibilidad de:

- Alcanzar **más de tu vida y trabajo**.
- Volverse **multijugador** con tu familia o equipo, cuando y como quieras.

Esto ha cambiado la relación de la gente con el software: de algo **diseñado en otro lugar que tienes que aceptar**, a algo que **puedes decirle qué hacer, moldear alrededor de tu vida y trabajo, y realmente poseer**.

> **No están vendiendo nada** ni pidiendo que confíes en una sola empresa, modelo o proveedor de IA con ese futuro. OpenClaw es **open source** y pertenece a quienes lo usan y ayudan a construirlo.

---

## Fuentes

- Blog oficial: https://openclaw.ai/blog/openclaw-2-accidentally
- Notas de release (v2026.8.1): https://docs.openclaw.ai/releases/2026.8.1
- Getting started: https://docs.openclaw.ai/start/getting-started
- Repo: https://github.com/openclaw/openclaw
- Discord: https://discord.com/invite/clawd
