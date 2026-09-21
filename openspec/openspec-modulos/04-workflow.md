# Módulo 4 — El Workflow: explore → propose → apply → archive

> **Objetivo:** dominar el ciclo completo de un cambio, de la idea al archivo.

---

Todo cambio pasa por los mismos **cinco pasos**: piensas la idea con tu agente, este redacta
un plan, tú corriges el plan **antes** de que exista código, el agente construye a partir de él,
y archivar actualiza tus specs con lo que se envió.

Cada prompt de abajo va en el **chat de tu IA**, el mismo lugar donde pides código. Cada uno
invoca un skill de OpenSpec por nombre. Una petición simple también funciona (*"propose a
change to add rate limiting"*). Algunas herramientas añaden alias más cortos (`/opsx:propose`
en Claude Code).

---

## 4.1 Paso 0 (opcional): Explore — piénsalo primero

Piensa la idea con tu agente **antes** de pedir un plan:

```
/openspec-explore how rate limiting should work in this app
```

**Explore es un modo de pensamiento.** El agente:
- Investiga tu codebase.
- Hace las preguntas que importan.
- Esboza opciones.
- Desafía tus suposiciones.

**No escribe código ni archivos.** El resultado es una idea más nítida.

Quédate aquí todo el tiempo que el problema necesite. Cuando la forma se sienta bien, pásalo:

```
/openspec-propose
```

Esa línea inicia propose para ti, llevando todo lo que acordaste (te saltas el primer prompt
del paso 2).

---

## 4.2 Paso 1: Propose — convierte la idea en un plan revisable

Viniendo de explore, ya está corriendo. Empezando en frío, cuando el cambio está claro en tu
cabeza, pide directamente:

```
/openspec-propose add rate limiting
```

El agente pregunta lo que necesite y luego escribe una carpeta de cambio:

```
openspec/changes/add-rate-limiting/
├── proposal.md   # por qué, y qué cambia
├── specs/        # qué significa "hecho", como requisitos comprobables
├── design.md    # decisiones técnicas (solo cuando el cambio lo necesita)
└── tasks.md     # la checklist de implementación
```

**Aún no hay código.** Propose se detiene en el plan.

---

## 4.3 Paso 2: Revisa el plan — corrígelo mientras es solo palabras

Arregla el plan mientras sigue siendo palabras y nada está construido. Lee en este orden:

1. **`proposal.md`**: ¿es el problema correcto, con el tamaño correcto?
2. **`specs/`**: la lectura de mayor valor. ¿Aceptarías estos requisitos como "hecho"?
3. **`tasks.md`**: ¿cubren las tareas las specs, y nada más?

Para arreglar algo, cualquiera de las dos funciona:
- **Edita el archivo tú mismo.** Los artefactos son Markdown plano, y los archivos son el plan.
- **Dile a tu agente qué está mal** (*"la spec no cubre el caso sin autenticar"*). Revisa los
  artefactos.

---

## 4.4 Paso 3: Apply — convierte el plan en código

Empieza una **sesión de chat nueva** (la implementación va mejor con una ventana de contexto
limpia):

```
/openspec-apply-change add-rate-limiting
```

El agente lee la carpeta del cambio y trabaja a través de `tasks.md`, marcando cada tarea
según aterriza.

- **¿Interrumpido o sin contexto?** Abre una sesión nueva y pide aplicar de nuevo. Reanuda en
  la primera tarea sin marcar.
- **¿El plan resultó mal?** Arregla los artefactos (como en el paso 3), luego continúa aplicando.
- **El progreso vive en los checkboxes de `tasks.md`.** No hay estado oculto.

---

## 4.5 Paso 4: Archive — devuelve el cambio a la verdad

Archivar hace **dos cosas**:
1. Actualiza tus specs principales con los requisitos del cambio.
2. Mueve la carpeta del cambio a la carpeta de archivo (`openspec/changes/archive/*`).

Cuando **cada** checkbox de `tasks.md` esté marcado:

```
/openspec-archive-change add-rate-limiting
```

### Qué hace archivar, paso a paso

**Paso 1 — El cambio terminado.** La implementación está hecha. El delta spec (lo que este
cambio añade) sigue dentro de la carpeta del cambio; `specs/` todavía no sabe nada de rate
limiting.

```
openspec/
├── specs/                      (sin spec de rate-limiting aún)
└── changes/
    └── add-rate-limiting/
        ├── proposal.md
        ├── tasks.md            (cada checkbox marcado)
        └── specs/
            └── rate-limiting/
                └── spec.md     (el delta: requisitos ADDED)
```

**Paso 2 — Tras archivar.** Los deltas se fusionan en `specs/` y la carpeta se mueve a
`changes/archive/` con fecha.

> **Git es un asunto aparte.** Haz commit de la carpeta del cambio junto con el código, y nada
> más de tu flujo cambia. Cuándo archivar respecto a un PR es una convención de equipo.

---

## 4.6 Resumen del flujo

| Paso | Comando | Qué hace | ¿Escribe código? |
|------|---------|----------|------------------|
| 0 | `/opsx:explore` | Piensa la idea, lee el codebase | No |
| 1 | `/opsx:propose` | Redacta proposal, specs, design, tasks | No |
| 2 | *(revisión)* | Tú corriges el plan | No |
| 3 | `/opsx:apply` | Implementa las tareas | Sí |
| 4 | `/opsx:archive` | Fusiona deltas en specs, archiva | No |

---

## ✅ Checkpoint del módulo 4

1. ¿Qué hace `/opsx:explore` y por qué es útil antes de proponer?
2. ¿Qué archivos crea `/opsx:propose`?
3. ¿En qué orden debes revisar el plan y qué buscas en cada archivo?
4. ¿Por qué conviene empezar una sesión nueva para `/opsx:apply`?
5. ¿Qué dos cosas hace archivar un cambio?
6. ¿Dónde vive el progreso de la implementación?

**Ejercicio:** [Ejercicio 2 — Primer cambio](ejercicios/02-ejercicio-primer-cambio.md)

**Siguiente:** [Módulo 5 — Specs v1.1](05-specs-v11.md)
