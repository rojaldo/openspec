# Módulo 6: RAG, embeddings y bases de datos vectoriales

> **Duración:** 2.5 h · **Objetivo:** montar un pipeline RAG: indexar documentos, generar embeddings y recuperar contexto.

## Objetivos de aprendizaje

Al terminar este módulo podrás:
- Explicar RAG, embeddings, similitud vectorial y chunking.
- Usar la memoria y búsqueda semántica de OpenClaw (`memory_search`, `memory_get`).
- Elegir y configurar una base vectorial (SQLite builtin, QMD, LanceDB, Qdrant, pgvector).
- Configurar proveedores de embeddings y `memorySearch`.
- Integrar RAG en un agente para responder con contexto.

---

## 6.1 Conceptos: el archivador inteligente

**RAG (Retrieval-Augmented Generation)** = **Recuperación aumentada por generación.** La idea: antes de que el modelo responda, se le dan *fragmentos relevantes* de una base de documentos, para que responda con contexto real en vez de solo su conocimiento de entrenamiento.

> 💡 **Analogía:** un empleado con RAG no responde de memoria; tiene un **archivador inteligente** que, ante una pregunta, *busca los papeles más relevantes* y los lee antes de contestar. Así no inventa: cita lo que encontró.

### Piezas clave

- **Embedding:** un **vector de números** que representa el *significado* de un texto. Textos parecidos tienen vectores parecidos (cercanos en el espacio).
- **Similitud vectorial:** cómo de "cerca" están dos vectores. Se mide con coseno, distancia euclidiana, etc.
- **Chunking:** dividir documentos grandes en **fragmentos** (chunks) antes de indexarlos, para que cada vector represente una idea manejable.
- **Base vectorial:** almacén optimizado para buscar por similitud de vectores.

### El flujo RAG

```
1. INDEXADO:
   Documentos → chunking → embeddings → base vectorial

2. CONSULTA:
   Pregunta → embedding de la pregunta
           → buscar chunks más similares (top-k)
           → inyectar chunks en el prompt → el modelo responde con contexto
```

---

## 6.2 Memoria y búsqueda semántica en OpenClaw

OpenClaw trae memoria con **búsqueda semántica** integrada. Las dos tools clave:

- **`memory_search`** — encuentra notas relevantes por *significado* (no solo por palabra). Usa búsqueda híbrida: vectores + coincidencia de keywords.
- **`memory_get`** — lee un archivo de memoria o un rango de líneas concreto.

> 💡 **Por qué es poderoso:** una búsqueda de texto normal encuentra "perro" solo si aparece "perro". Una búsqueda semántica entiende que "mascota canina" también es relevante. Es buscar por *sentido*, no por letras.

**Desde CLI:**
```bash
openclaw memory status                 # estado del índice y proveedor
openclaw memory search "MCP config"    # búsqueda semántica
openclaw memory index --force          # reconstruir el índice
```

**En el agente:** simplemente pregunta y el agente usa `memory_search`/`memory_get` cuando lo necesita. Ejemplo:
> *"¿Qué decidimos la semana pasada sobre el enfoque del curso?"*

---

## 6.3 Bases de datos vectoriales: cuál elegir

| Base | Cuándo usarla |
|---|---|
| **SQLite (builtin)** | Default de OpenClaw; sin dependencias extra. Keyword + vector + híbrido. Perfecta para empezar. |
| **QMD** | Sidecar local con reranking y expansión de queries. Para búsquedas más precisas, todo local. |
| **LanceDB** | Plugin con embeddings OpenAI-compatibles y soporte de Ollama local. |
| **Qdrant** | Base vectorial dedicada, escalable, corre en contenedor. Ideal producción. |
| **pgvector** | Extensión de PostgreSQL. Si ya usas Postgres, añade vectores sin servicio extra. |

> 💡 **Regla práctica:** para aprender y prototipar, usa la **SQLite builtin** (cero setup). Para producción con volumen o búsqueda avanzada, pasa a **Qdrant** o **pgvector**.

---

## 6.4 Proveedores de embeddings y config de `memorySearch`

Los embeddings los genera un **proveedor**. Por defecto OpenClaw usa OpenAI embeddings, pero puedes cambiarlo:

```json5
{
  agents: {
    defaults: {
      memorySearch: {
        provider: "ollama",        // o: openai, gemini, voyage, mistral, bedrock, local GGUF, LM Studio, etc.
        // modelo de embeddings según el proveedor
      },
    },
  },
}
```

**Opciones de proveedor:** OpenAI, Gemini, Voyage, Mistral, Bedrock, DeepInfra, local GGUF, Ollama, LM Studio, GitHub Copilot, o cualquier endpoint compatible con OpenAI.

> 💡 **Tip local/privado:** si no quieres enviar tus documentos a la nube, usa **Ollama** o **LM Studio** con un modelo de embeddings local. Todo queda en tu máquina.

---

## 6.5 Integrar RAG en un agente: caso práctico

Vamos a montar un RAG mínimo: el agente responde sobre la documentación de tu proyecto usando contexto vectorial.

### Paso 1 — Configura el proveedor de embeddings
```json5
{
  agents: {
    defaults: {
      memorySearch: { provider: "openai" },   // o tu proveedor preferido
    },
  },
}
```

### Paso 2 — Indexa tu corpus
Guarda tus documentos en el workspace (o en un directorio indexable) y reconstruye el índice:

```bash
openclaw memory index --force
```

> 💡 Con plugins como QMD puedes indexar **directorios fuera del workspace**. Revisa la doc del plugin que elijas.

### Paso 3 — Pregunta con contexto
Pide al agente algo que requiera recuperar de tu documentación:

> *"Según nuestra documentación, ¿cómo configuramos el servidor MCP?"*

El agente usa `memory_search` para recuperar los fragmentos relevantes y responde *con base en ellos*.

### Paso 4 (producción) — Base vectorial externa
Si necesitas escalar o un RAG más controlado, conecta Qdrant o pgvector y haz que tu agente consulte ahí (a menudo vía MCP, uniendo los Módulos 5 y 6):

```json5
{
  mcp: {
    servers: {
      "vectores": {
        // servidor MCP que envuelve Qdrant/pgvector
      },
    },
  },
}
```

---

## Errores comunes

1. **Chunking mal dimensionado:** chunks demasiado grandes = contexto impreciso; demasiado pequeños = pierdes significado. Ajusta según tu contenido.
2. **Embeddings sin contexto:** olvidar que los embeddings capturan *significado*; si el corpus es ruidoso, la búsqueda lo refleja.
3. **No reindexar:** si cambias los documentos y no reconstruyes el índice, el RAG responde con datos viejos.
4. **Proveedor no configurado:** `memory_search` necesita un proveedor de embeddings; sin él, la búsqueda semántica no funciona (solo keyword).
5. **RAG sin citas:** un buen RAG debe *decirte de dónde sacó* la información, para que puedas verificar.

---

## Ejercicios

- [ ] Configura un proveedor de embeddings y reconstruye el índice (`openclaw memory index --force`).
- [ ] Guarda 3-5 documentos sobre tu proyecto en el workspace y haz búsquedas semánticas variando las palabras (comprueba que entiende el sentido).
- [ ] Levanta Qdrant en Docker y conecta un servidor MCP de vectores.
- [ ] Pide al agente una respuesta que combine contexto RAG con su conocimiento, y evalúa la calidad.

---

## Resumen

- **RAG** = dar contexto relevante al modelo antes de responder (archivador inteligente).
- **Embeddings** = vectores que representan significado; la **similitud vectorial** encuentra lo parecido.
- **Chunking** = partir documentos en fragmentos manejables.
- OpenClaw trae **`memory_search`/`memory_get`** con búsqueda semántica híbrida.
- Bases: **SQLite builtin** (empezar) → **Qdrant/pgvector** (producción).
- Configura el **proveedor de embeddings** (incluso local con Ollama).
- **Reindexa** cuando cambies los documentos.

---

*Siguiente: [Módulo 7 — Despliegue en contenedores Docker](07-docker.md)*
