# Módulo 5 — Specs v1.1: el formato de especificación

> **Objetivo:** escribir specs en formato v1.1 que cualquier motor compatible con OpenSpec
> pueda parsear, validar y ejecutar.

---

## 5.1 El formato

Un archivo OpenSpec puede ser **JSON, YAML o TOON**. En v1.1 el documento es **una sola
especificación** — no hay wrapper de proyecto ni array de specifications.

La raíz lleva `schemaVersion: "1.1"` más un puñado de campos obligatorios:
`id`, `projectId`, `title`, `status`, `goals`, `requirements`, `architecture`, `scope`,
`techStack`, `folderStructures`, `acceptanceCriteria`, `nonFunctionalRequirements`,
`guardrails`, `epics` y `blueprints`.

### El spec válido más pequeño (Todo API)

```json
{
  "schemaVersion": "1.1",
  "id": "spec-todo-api",
  "projectId": "proj-todo",
  "title": "Todo API",
  "status": "planning",
  "goals": [
    {
      "id": "goal-capture",
      "title": "Capture todos quickly",
      "description": "Let users create and list todos with minimal friction.",
      "type": "user",
      "successCriteria": ["A todo can be created and listed in under one second"]
    },
    {
      "id": "goal-durable",
      "title": "Keep todos durable",
      "description": "Persist todos so they survive restarts.",
      "type": "technical",
      "successCriteria": ["No todo is lost across a service restart"]
    },
    {
      "id": "goal-contract",
      "title": "Expose a stable contract",
      "description": "Offer a predictable REST surface clients can rely on.",
      "type": "business",
      "successCriteria": ["The public endpoints follow a documented contract"]
    }
  ],
  "requirements": [
    {
      "id": "req-create",
      "title": "Create a todo",
      "description": "Clients can create a todo with a title.",
      "type": "functional",
      "acceptanceCriteria": [
        {
          "id": "ac-create",
          "given": "a valid todo payload",
          "when": "the client POSTs to /todos",
          "then": "the todo is stored and returned with a generated id",
          "order": 1
        }
      ]
    },
    {
      "id": "req-list",
      "title": "List todos",
      "description": "Clients can retrieve all todos.",
      "type": "functional",
      "acceptanceCriteria": [
        {
          "id": "ac-list",
          "given": "stored todos exist",
          "when": "the client GETs /todos",
          "then": "all todos are returned in creation order",
          "order": 1
        }
      ]
    },
    {
      "id": "req-validate",
      "title": "Reject invalid input",
      "description": "Malformed payloads are rejected clearly.",
      "type": "business-rule",
      "acceptanceCriteria": [
        {
          "id": "ac-validate",
          "given": "a payload without a title",
          "when": "the client POSTs to /todos",
          "then": "the request is rejected with a 400",
          "order": 1
        }
      ]
    }
  ],
  "architecture": "A stateless HTTP service backed by a relational database, exposing a small REST API for todos.",
  "scope": {
    "inScope": ["Creating todos", "Listing todos", "Input validation"],
    "outOfScope": ["Authentication and multi-user accounts"]
  },
  "techStack": [],
  "folderStructures": [
    {
      "id": "fs-service",
      "scope": "service",
      "content": "src/\n routes/todos.ts\n db/index.ts\n server.ts"
    }
  ],
  "acceptanceCriteria": [],
  "nonFunctionalRequirements": [],
  "guardrails": [],
  "epics": [],
  "blueprints": []
}
```

Guárdalo como `todo-api.oschema.json`. Ese es un spec OpenSpec válido. Todo lo demás se
construye sobre este esqueleto.

---

## 5.2 Goals y requirements son estructurados

En v1.1, los goals y requirements ya no son strings planos — cada uno es un **objeto tipado**.

- Un **goal** declara un `type` y `successCriteria`.
- Un **requirement** lleva `acceptanceCriteria` escritos como **Given / When / Then**, para que
  un agente tenga una checklist concreta de aprobado/fallo que verificar.

```json
{
  "goals": [
    {
      "id": "goal-capture",
      "title": "Capture todos quickly",
      "description": "Let users create and list todos with minimal friction.",
      "type": "user",
      "successCriteria": ["A todo can be created and listed in under one second"]
    }
  ],
  "requirements": [
    {
      "id": "req-create",
      "title": "Create a todo",
      "description": "Clients can create a todo with a title.",
      "type": "functional",
      "acceptanceCriteria": [
        {
          "id": "ac-create",
          "given": "a valid todo payload",
          "when": "the client POSTs to /todos",
          "then": "the todo is stored and returned with a generated id",
          "order": 1
        }
      ]
    }
  ]
}
```

> **Por qué importa:** los agentes alucinan requisitos cuando la spec es vaga. Los criterios de
> aceptación estructurados les dan una checklist explícita de aprobado/fallo en vez de un
> párrafo que interpretar.

---

## 5.3 Shared patterns — convenciones compartidas

Capturan convenciones que aplican a través de tickets. Evitan el *style drift* dándole a los
agentes una única fuente de verdad para estándares de código, imports comunes y tipos de retorno.

```json
{
  "sharedPatterns": [
    {
      "id": "sp-rest",
      "name": "REST conventions",
      "description": "All endpoints return JSON and use plural resource URLs.",
      "codeStandards": {
        "naming": "camelCase for fields, plural nouns for routes",
        "errorHandling": "Return a typed Result at module boundaries"
      },
      "commonImports": ["import { Result, ok, err } from '../shared/result'"],
      "returnTypes": { "handler": "Promise<Result<Response, AppError>>" }
    }
  ]
}
```

> **Por qué importa:** sin shared patterns, cada agente (o desarrollador) inventa sus propias
> convenciones y la spec se vuelve inconsistente con el tiempo.

---

## 5.4 Blueprints — artefactos de diseño

Los blueprints son artefactos de diseño — diagramas, esquemas, ADRs — referenciados por los
tickets. Cada uno tiene una `category`, un `format` y un cuerpo `content`. Mantienen las
decisiones de diseño descubribles en vez de perdidas en logs de chat o carpetas de documentos.

```json
{
  "blueprints": [
    {
      "id": "bp-db-schema",
      "title": "Database schema",
      "category": "erd",
      "format": "mermaid",
      "content": "erDiagram\n TODO {\n  uuid id PK\n  string title\n  bool completed\n }"
    },
    {
      "id": "bp-api-contract",
      "title": "API contract",
      "category": "api",
      "format": "markdown",
      "content": "GET /todos -> 200 [Todo]\nPOST /todos -> 201 Todo"
    }
  ]
}
```

> **Por qué importa:** los artefactos de diseño que viven fuera de la spec se pierden o quedan
> obsoletos. Los blueprints los mantienen versionados y enlazados a los tickets que los
> implementan.

---

## 5.5 Tickets — la unidad atómica del trabajo del agente

Los tickets viven dentro de un **epic** y son la pieza de trabajo más pequeña de una spec.
Cada uno declara un `ticketType`, una `complexity`, un presupuesto `estimatedMinutes`, criterios
de aceptación Given/When/Then, `implementationSteps` ordenados y los archivos que tocará — para
que el agente implementador sepa exactamente qué construir y cómo se comprobará.

```json
{
  "id": "ticket-create-todo",
  "epicId": "epic-core",
  "title": "Implement POST /todos",
  "description": "Create a todo. Validate the title is non-empty. Return 201 with the created resource.",
  "ticketType": "implementation",
  "complexity": "small",
  "estimatedMinutes": 90,
  "acceptanceCriteria": [
    {
      "id": "ac-create-201",
      "given": "a payload with a title",
      "when": "POST /todos is called",
      "then": "a 201 is returned with the created todo",
      "order": 1
    },
    {
      "id": "ac-create-400",
      "given": "a payload without a title",
      "when": "POST /todos is called",
      "then": "a 400 is returned with an error envelope",
      "order": 2
    }
  ],
  "implementationSteps": [
    { "id": "step-1", "text": "Add the POST /todos route handler", "order": 1 },
    { "id": "step-2", "text": "Validate the payload and persist the todo", "order": 2 }
  ],
  "filesToBeCreated": ["src/routes/todos.ts"],
  "blueprintReferences": [
    { "blueprintId": "bp-api-contract", "context": "Create path" }
  ],
  "dependencies": []
}
```

---

## 5.6 Dependencies — el grafo de ejecución

Los tickets pueden declarar dependencias de otros tickets usando un `ticketId` objetivo y un
`type`. OpenSpec soporta dos tipos:

- **`requires`** — este ticket necesita que el otro esté completo antes de empezar.
- **`blocks`** — este ticket impide que el otro empiece hasta que esté completo.

```json
[
  { "id": "ticket-create-todo", "title": "POST /todos", "dependencies": [] },
  {
    "id": "ticket-list-todos",
    "title": "GET /todos",
    "dependencies": [{ "ticketId": "ticket-create-todo", "type": "requires" }]
  },
  {
    "id": "ticket-delete-todo",
    "title": "DELETE /todos/:id",
    "dependencies": [{ "ticketId": "ticket-create-todo", "type": "requires" }]
  }
]
```

> **Por qué importa:** sin datos de dependencia explícitos, un motor podría empezar un ticket
> cuyos prerrequisitos aún no están hechos. El validador detecta dependencias circulares y
> referencias colgantes en tiempo de lint.

### Cómo ve un motor esta spec

```
ticket-create-todo
   │
   ├──► ticket-list-todos
   └──► ticket-delete-todo
```

`ticket-create-todo` no tiene dependencias, así que es accionable de inmediato. Los otros dos
lo requieren, así que esperan.

---

## ✅ Checkpoint del módulo 5

1. ¿Qué formatos soporta un archivo OpenSpec?
2. ¿Qué campos obligatorios lleva la raíz de un spec v1.1?
3. ¿Por qué los goals y requirements son objetos tipados y no strings?
4. ¿Qué son los *shared patterns* y qué problema resuelven?
5. ¿Qué es un *blueprint* y qué campos tiene?
6. ¿Qué campos declara un *ticket*?
7. ¿Cuál es la diferencia entre `requires` y `blocks`?

**Ejercicio:** [Ejercicio 3 — Spec v1.1](ejercicios/03-ejercicio-spec-v11.md)

**Siguiente:** [Módulo 6 — CLI](06-cli.md)
