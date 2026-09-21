# Módulo 5: Integración con Model Context Protocol (MCP)

> **Duración:** 2.0 h · **Objetivo:** conectar servidores MCP y exponer sus herramientas al agente.

## Objetivos de aprendizaje

Al terminar este módulo podrás:
- Explicar qué es MCP y cómo encaja en la arquitectura de agentes.
- Configurar servidores MCP (local/stdio, HTTP, remotos) en `openclaw.json`.
- Exponer tools de MCP al agente y a jobs de cron.
- Aplicar seguridad y permisos a las tools MCP.
- Conectar ejemplos reales: bases de datos, APIs, navegador.

---

## 5.1 ¿Qué es MCP?

**MCP (Model Context Protocol)** es un estándar abierto que permite conectar **herramientas y servicios externos** a un agente de IA de forma uniforme. Es como el **"enchufe universal"** para que el agente use servicios externos.

> 💡 **Analogía:** si las tools nativas son el cajón de herramientas del empleado, MCP es el *contrato de enchufes* que le permite conectar aparatos de cualquier fabricante: una impresora, un teléfono, un sistema de base de datos. Todos usan el mismo tipo de enchufe.

**Arquitectura MCP:**

```
[Agente OpenClaw]  ←→  [Cliente MCP]  ←→  [Servidor MCP]  ←→  [Servicio externo]
                                                              (BD, API, navegador…)
```

- **Cliente MCP:** lo incorpora OpenClaw; habla con los servidores.
- **Servidor MCP:** expone herramientas/recursos de un servicio concreto.
- **Transportes:** `stdio` (proceso local), `HTTP`/SSE (remoto).

**¿Por qué importa?** En vez de integrar cada servicio a mano, MCP estandariza la conexión: una vez que el servidor MCP de una base de datos existe, cualquier agente compatible puede usarlo.

---

## 5.2 Configurar servidores MCP en `openclaw.json`

Los servidores MCP se declaran en la configuración. Pueden ser locales (se lanzan como proceso) o remotos (HTTP).

### Ejemplo: servidor MCP local (stdio)

```json5
{
  mcp: {
    servers: {
      "mi-base-datos": {
        command: "npx",
        args: ["-y", "@modelcontextprotocol/server-sqlite"],
        env: {
          SQLITE_PATH: "/data/app.db",
        },
      },
    },
  },
}
```

- `command`/`args`: cómo se lanza el proceso del servidor.
- `env`: variables de entorno que necesita.
- El transporte `stdio` significa que OpenClaw y el servidor se comunican por entrada/salida estándar.

### Ejemplo: servidor MCP remoto (HTTP)

```json5
{
  mcp: {
    servers: {
      "api-externa": {
        url: "https://api.ejemplo.com/mcp",
        // auth según el servidor
      },
    },
  },
}
```

> 💡 Los servidores remotos requieren autenticación según el proveedor (token, OAuth, etc.). Consulta la doc del servidor MCP concreto.

---

## 5.3 Exponer tools de MCP al agente y a cron

Una vez configurado el servidor, sus **herramientas** quedan disponibles para que el agente las invoque como cualquier otra tool (las ve en su cajón).

**Desde el agente:** simplemente pide una tarea que requiera esa herramienta. Ejemplo: con un MCP de base de datos conectado:

> *"Consulta en la base de datos cuántos usuarios se registraron esta semana."*

El agente detecta la tool MCP de la BD y la usa.

**Desde cron:** un job aislado puede usar las tools MCP para tareas programadas:

```bash
openclaw cron create "0 7 * * *" \
  "Consulta la BD y envía el resumen de actividad diaria." \
  --name "Reporte diario BD" \
  --session isolated \
  --announce \
  --channel telegram \
  --to "-1001234567890"
```

> ⚠️ Recuerda: el job aislado tiene contexto fresco, pero **sí puede usar las tools** configuradas (incluidas las MCP).

---

## 5.4 Seguridad y permisos de las tools MCP

Conectar un MCP = darle al agente acceso a un servicio externo. Hay que controlar el alcance:

- **Allowlists de tools:** restringe qué tools MCP específicas puede usar el agente. No expongas todo el servidor si solo necesitas una función.
- **Permisos por agente:** cada agente puede tener permitidas herramientas distintas (menos privilegios).
- **Auth segura:** usa tokens/credenciales con el menor alcance posible.
- **Revisa el servidor:** solo conecta servidores MCP de fuentes confiables (un MCP malicioso es un vector de ataque).

> 💡 **Analogía de seguridad:** es como darle al empleado una *tarjeta de acceso restringido*: puede entrar a la sala que necesita, no a todo el edificio.

**Configuración de permisos (ejemplo conceptual):**
```json5
{
  agents: {
    defaults: {
      toolsAllow: ["mcp.mi-base-datos.consulta", "mcp.mi-base-datos.inserción"],
    },
  },
}
```

---

## 5.5 Ejemplos prácticos

### Base de datos (SQLite)
Conectas el servidor `@modelcontextprotocol/server-sqlite` y el agente puede:
- Consultar tablas y datos.
- Crear/leer registros según tu política.

### API externa (clima, pagos, CRM)
Con un servidor MCP que envuelva una API:
- *"¿Qué tiempo hará mañana en Madrid?"* → el agente llama a la API de clima vía MCP.

### Navegador
Un MCP de navegador permite al agente automatizar páginas web (rellenar formularios, extraer datos) dentro de sus límites de permisos.

> 💡 **Consejo:** busca servidores MCP existentes en los registros de la comunidad antes de construir uno. La mayoría de servicios populares ya tienen uno.

---

## Errores comunes

1. **Servidor MCP no arranca:** revisa `command`, `args` y `env` (¿existe `npx`? ¿la ruta es correcta?).
2. **Remoto sin auth:** los servidores HTTP suelen requerir token/OAuth; sin auth falla.
3. **Exponer TODO el servidor:** menos privilegios — permite solo las tools necesarias.
4. **MCP de fuente no confiable:** vector de ataque. Verifica el origen.
5. **Confundir MCP con tools nativas:** las tools nativas vienen con OpenClaw; las MCP son externas conectadas por el estándar.

---

## Ejercicios

- [ ] Conecta un servidor MCP local (ej. el de SQLite) y pide al agente una consulta.
- [ ] Conecta un MCP remoto con autenticación (usa un servidor de prueba de la comunidad).
- [ ] Restringe el alcance: permite solo 1-2 tools del servidor vía `toolsAllow`.
- [ ] Programa un job de cron que use una tool MCP y lo anuncie por canal.

---

## Resumen

- **MCP** estandariza cómo el agente usa servicios externos (el "enchufe universal").
- Configura servidores **locales (stdio)** o **remotos (HTTP)** en `openclaw.json`.
- Las tools MCP quedan disponibles para el agente **y para cron**.
- **Seguridad:** allowlists de tools, menos privilegios, auth mínima, fuentes confiables.
- Ejemplos: BD, APIs, navegador.

---

*Siguiente: [Módulo 6 — RAG, embeddings y bases de datos vectoriales](06-rag-vectores.md)*
