# Módulo 3 — Conceptos Clave

> **Objetivo:** dominar el modelo mental de OpenSpec. Todo lo demás es detalle.

---

OpenSpec se construye sobre **cinco conceptos**. Aprende estos y el resto es fácil.

## 3.1 Concepto 1: Specs son la verdad

Una **spec** describe cómo se comporta tu sistema **ahora mismo**. Vive en `openspec/specs/`,
organizada por dominio (`auth/`, `payments/`, `ui/`).

Las specs están hechas de:
- **Requisitos** (requirements): *"El sistema SHALL expirar las sesiones después de 30 minutos."*
- **Escenarios** (scenarios): ejemplos concretos *given/when/then*.

> Piensa en las specs como la respuesta única y acordada a *"¿qué hace este software?"*

## 3.2 Concepto 2: Un cambio (change) es una unidad de trabajo

Cuando quieres **añadir, modificar o eliminar** comportamiento, creas un **cambio**: una
carpeta en `openspec/changes/` que contiene todo sobre ese trabajo en un solo lugar.

```
openspec/changes/add-dark-mode/
├── proposal.md   # por qué y qué cambia
├── specs/        # qué significa "hecho", como requisitos comprobables
├── design.md     # decisiones técnicas (solo cuando el cambio lo necesita)
└── tasks.md      # la checklist de implementación
```

> Un cambio, una carpeta, una feature.

## 3.3 Concepto 3: Delta specs describen lo que cambia, no el mundo entero

Dentro de un cambio **no reescribes toda la spec**. Escribes un **delta** pequeño:

- **ADDED** este requisito
- **MODIFIED** aquel otro
- **REMOVED** este de más allá

Este es el truco que hace que OpenSpec sea bueno editando sistemas existentes (brownfield),
no solo proyectos nuevos. **Describes el diff, no el destino.**

## 3.4 Concepto 4: Los artefactos se construyen unos sobre otros

Un cambio contiene varios documentos, creados en orden natural, cada uno alimentando al siguiente:

```
proposal ──► specs ──► design ──► tasks ──► implement
  why        what      how       steps      do it
```

Puedes revisar cualquiera de ellos en cualquier momento. **Son habilitadores, no puertas.**
El orden muestra qué es posible después, no a qué estás obligado.

> Descubres durante la implementación que el diseño estaba mal → edita `design.md` y sigue.
> El scope debe encogerse → actualiza el `proposal`. Nada te bloquea.

## 3.5 Concepto 5: Archivar (archive) devuelve el cambio a la verdad

Cuando el trabajo está hecho, **archivas** el cambio. Sus delta specs se fusionan en tus specs
principales, y la carpeta del cambio se mueve a `changes/archive/` con una marca de fecha.

```
┌─────────────────────────────────────────────────────────────┐
│ openspec/                                                    │
│                                                              │
│  ┌──────────────┐          ┌──────────────────────────┐       │
│  │ specs/       │          │ changes/                │       │
│  │              │ ◄──────  │  una carpeta por cambio │       │
│  │ fuente de    │  merge   │  proposal · design ·    │       │
│  │ verdad       │  al      │  tasks · delta specs    │       │
│  │ cómo funciona│  archivar│                         │       │
│  └──────────────┘          └──────────────────────────┘       │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

**Dos carpetas.** `specs/` es lo que es verdad. `changes/` es lo que propones. Archivar mueve
una propuesta a la verdad. El ciclo se cierra y estás listo para el siguiente cambio.

## 3.6 El flujo del día a día

En la configuración por defecto, tu día se ve así:

```
/opsx:explore  →  (opcional) piénsalo con la IA primero
/opsx:propose add-dark-mode  →  la IA redacta proposal, specs, design, tasks
                              (tú lees y ajustas el plan)
/opsx:apply    →  la IA construye, marcando tareas
/opsx:archive  →  specs actualizadas, cambio archivado
```

> **¿Dudas? Empieza explorando.** `/opsx:explore` es un compañero de pensamiento sin riesgo:
> lee tu código, plantea opciones y convierte una idea difusa en un plan concreto antes de que
> exista cualquier artefacto. Es el mejor antídoto contra una IA que construirá algo a partir
> de un prompt vago.

## 3.7 ¿Dónde corren los comandos?

- **Setup** (`openspec init`) corre en tu **terminal**.
- **El flujo** (`/opsx:propose`, etc.) corre en el **chat de tu agente de IA**.

Esta división es la fuente de confusión más común. Los slash commands se teclean en el chat
de tu asistente; el CLI se usa en la terminal.

## 3.8 ¿Qué ganas y qué pagas?

**Ganas:**
- Corriges malentendidos **antes** de que cuesten caro (arreglar un párrafo es gratis;
  arreglar 400 líneas de código, no).
- El plan y el código viven en el mismo repo; seis meses después la spec te dice *por qué*
  el sistema funciona como funciona.
- Los cambios son revisables: lee el proposal, hojea los deltas, revisa las tareas.
- Encaja en codebases existentes gracias a los deltas.

**Pagas:**
- Añades un paso (escribes un plan corto antes de construir).
- Para un fix trivial de una línea, la ceremonia puede no pagar. Y está bien.

---

## ✅ Checkpoint del módulo 3

1. ¿Qué es una spec y dónde vive?
2. ¿Qué es un cambio (change) y qué contiene?
3. ¿Qué es un *delta spec* y por qué es importante para brownfield?
4. Nombra los 5 artefactos de un cambio en orden.
5. ¿Qué hace archivar un cambio?
6. ¿Dónde corre `openspec init` y dónde corre `/opsx:propose`?

**Siguiente:** [Módulo 4 — El Workflow](04-workflow.md)
