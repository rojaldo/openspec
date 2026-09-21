# Módulo 1 — Introducción a OpenSpec

> **Objetivo:** entender qué es OpenSpec, qué problema resuelve y por qué es relevante en la
> era de los agentes de IA.

---

## 1.1 El problema: la IA construye lo que le pides vagamente

Los asistentes de IA para programar (Claude Code, Cursor, Codex, etc.) son increíblemente
poderosos pero **impredecibles cuando los requisitos viven solo en el historial del chat**.

Si le dices a un agente *"añade modo oscuro"*, puede:
- Implementarlo de una forma que no esperabas.
- Olvidar el caso del usuario sin autenticar.
- Inventar requisitos que nunca pediste (los agentes **alucinan requisitos** cuando la spec
  es vaga).
- Cambiar convenciones de estilo del proyecto (cada agente inventa las suyas → *style drift*).

El resultado: código que "funciona" pero no es lo que querías, y que nadie puede explicar
por qué se hizo así seis meses después.

## 1.2 La solución: una capa de especificación ligera

**OpenSpec** añade una capa de especificación entre tú y tu IA. La idea en cinco palabras:

> **Agree first, then build confidently.**
> (Primero acuerda, luego construye con confianza.)

En lugar de que el agente construya desde un prompt vago, tú y el agente **acuerdan un plan
por escrito** (la spec) antes de que exista una sola línea de código. Ese plan:

- Se versiona junto al código (vive en el mismo repo).
- Es revisable (un paquete ordenado, no arqueología de chat).
- Sirve de fuente de verdad para ti, tu equipo y cualquier agente futuro.

## 1.3 ¿Qué es exactamente OpenSpec?

> **OpenSpec** es un framework ligero y configurable para crear y gestionar especificaciones
> de software. Te ayuda a **construir la cosa correcta** (validación) y a **construirla
> correctamente** (verificación).

- Es un **CLI de Node.js** (`@fission-ai/openspec`).
- El flujo de trabajo corre **dentro de tu agente de IA** mediante *skills* y *slash commands*
  (`/opsx:propose`, etc.).
- Funciona con **30+ herramientas de IA** (Claude Code, Cursor, Codex, Gemini CLI, OpenCode,
  GitHub Copilot, Amazon Q...).
- Es **open source** (MIT) y está en GitHub: <https://github.com/Fission-AI/OpenSpec> (~67k stars).

## 1.4 Filosofía

OpenSpec se define por cinco principios:

| Principio | Significado |
|-----------|-------------|
| **Fluid not rigid** | Los artefactos se pueden revisar en cualquier momento; no hay fases rígidas. |
| **Iterative not waterfall** | El orden de los artefactos muestra *qué es posible después*, no *qué estás obligado a hacer*. |
| **Easy not complex** | Ligero; las specs son Markdown plano, sin sintaxis especial que aprender. |
| **Built for brownfield** | Los *delta specs* permiten especificar cambios en apps de 50k líneas sin documentar todo primero. |
| **Scalable** | Desde proyectos personales hasta empresas (con *Stores* multi-repo). |

## 1.5 OpenSpec vs. alternativas

| Herramienta | OpenSpec | Spec Kit (GitHub) | Kiro (AWS) |
|-------------|----------|-------------------|------------|
| Peso | Ligero | Pesado (fases rígidas, mucho Markdown, setup Python) | Potente pero cerrado |
| Flexibilidad | Iteración libre | Fases rígidas | Limitado |
| Herramientas | 30+ agentes | — | Solo su IDE + modelos Claude |
| Curva | Baja | Alta | Media |

**vs. nada:** programar con IA sin specs = prompts vagos y resultados impredecibles. OpenSpec
trae predictibilidad sin ceremonia.

## 1.6 ¿Cuándo usar OpenSpec?

**Úsalo cuando el acuerdo importe** — que es casi siempre que trabajas con una IA que va a
construir con confianza lo que le pidas vagamente:

- Nuevas features.
- Refactors significativos.
- Cambios arquitectónicos.
- Trabajo en equipo donde varios agentes/desarrolladores tocan el mismo código.

**No lo uses** para un fix de una línea o una corrección de typo: la ceremonia no paga.
OpenSpec es ligero, pero no es gratis.

---

## ✅ Checkpoint del módulo 1

1. ¿Cuál es el problema central que resuelve OpenSpec?
2. ¿Qué significa "agree first, then build confidently"?
3. Nombra los 5 principios de la filosofía de OpenSpec.
4. ¿En qué se diferencia OpenSpec de Spec Kit y de Kiro?
5. ¿Cuándo NO conviene usar OpenSpec?

**Siguiente:** [Módulo 2 — Instalación](02-instalacion.md)
