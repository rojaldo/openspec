# Módulo 2: Creación de funciones (tools) personalizadas

> **Duración:** 2.5 h · **Objetivo:** diseñar, implementar y probar tools propias que el agente pueda invocar.

## Objetivos de aprendizaje

Al terminar este módulo podrás:
- Explicar qué es una tool y cómo el agente la descubre.
- Crear **skills** del workspace (`SKILL.md`) con frontmatter y gating.
- Construir tools combinando `exec`, `apply_patch`, `web_fetch` y scripts propios.
- Seguir buenas prácticas de seguridad y calidad.
- Probar con `openclaw agent --message` y publicar en ClawHub.

---

## 2.1 ¿Qué es una tool y cómo la invoca el agente?

Una **tool** es una *capacidad* que el agente puede usar: leer archivos, ejecutar comandos, buscar en la web, etc. El modelo de IA no ejecuta código directamente: **pide** usar una tool, y OpenClaw la ejecuta y le devuelve el resultado.

> 💡 **Analogía:** el agente es un empleado con un cajón de herramientas. No sabe soldar por sí mismo, pero *sabe cuándo* pedir el soldador y *cómo* usarlo. Las tools son ese cajón.

**El ciclo de una tool:**

1. El modelo ve la lista de tools disponibles (sus descripciones).
2. Decide que necesita una y la invoca con argumentos.
3. OpenClaw ejecuta la tool.
4. El resultado vuelve al modelo, que lo usa para responder.

**Por eso la descripción importa muchísimo:** el modelo "elige" la tool correcta leyendo su descripción. Una descripción vaga = el agente no sabe cuándo usarla.

---

## 2.2 Skills del workspace: el `SKILL.md`

Una **skill** es la forma principal de añadir capacidades/instrucciones al agente. Es una carpeta con un archivo `SKILL.md` (frontmatter YAML + instrucciones en Markdown). Se guardan en `skills/` del workspace.

```
skills/
└── mi-skill/
    └── SKILL.md
```

### Estructura de `SKILL.md`

```markdown
---
name: mi-skill
description: Crea informes semanales en Markdown con métricas.
---

# Mi skill

Cuando el usuario pida un informe semanal:
1. Lee los datos de `data/`.
2. Genera un resumen con métricas.
3. Guárdalo en `informes/YYYY-MM-DD.md`.
```

**Campos del frontmatter:**

| Campo | Obligatorio | Qué hace |
|---|---|---|
| `name` | ✅ | Slug en minúsculas, dígitos y guiones. Debe coincidir con la carpeta. |
| `description` | ✅ | Una línea (<160 caracteres) que el agente usa para saber cuándo aplica. |
| `user-invocable` | No | Si el usuario puede lanzarlo con `/skill`. Por defecto `true`. |
| `disable-model-invocation` | No | Si `true`, el agente NO lo auto-invoca (solo `/skill`). |
| `command-dispatch` | No | Enruta el comando directamente a una tool, sin pasar por el modelo. |

### Gating: que la skill solo cargue si hay requisitos

Puedes hacer que una skill solo se active si hay ciertas condiciones:

```markdown
---
name: gemini-search
description: Busca en la web usando Gemini CLI.
metadata:
  openclaw:
    requires:
      bins: ["gemini"]            # necesita el binario 'gemini' en PATH
      env: ["GEMINI_API_KEY"]     # necesita esa variable de entorno
---
```

> 💡 Si la skill no cumple los requisitos, OpenClaw no la inyecta en el prompt del agente. Ahorra contexto y evita errores.

### Referencias con `{baseDir}`

Para no hardcodear rutas, usa `{baseDir}`, que el agente resuelve contra la carpeta de la skill:

```markdown
Ejecuta el script de ayuda en `{baseDir}/scripts/run.sh`.
```

---

## 2.3 Construir tools: `exec`, `apply_patch`, `web_fetch` y scripts

Una skill "dirige" al agente para que use las tools base. Las tools base más útiles para tu cajón:

### `exec` — ejecutar comandos
```markdown
# Skill: backup
Cuando el usuario pida hacer un backup:
1. Ejecuta: `tar -czf backups/temario-$(date +%F).tar.gz cursos/`
2. Confirma el archivo creado con `ls -la backups/`
```

### `apply_patch` — editar varios archivos de forma estructurada
`apply_patch` aplica cambios a uno o varios archivos en una sola operación (añadir, actualizar, borrar, renombrar). Ideal para editar el temario sin romper el resto:

```text
*** Begin Patch
*** Add File: cursos/mi-curso/02-tools.md
+# Tools personalizadas
+Contenido del módulo 2...
*** Update File: cursos/mi-curso/temario.md
@@
-| 2 | Herramientas | 1 semana |
+| 2 | Herramientas | 2 semanas |
*** End Patch
```

> 💡 `apply_patch` por defecto solo escribe **dentro del workspace** (`workspaceOnly: true`). Es una protección por defecto.

### `web_fetch` — traer contenido de una URL
```markdown
# Skill: resumir-doc
Cuando el usuario pida resumir una URL:
1. Haz `web_fetch` de la URL.
2. Resume los puntos clave en 5 bullets.
```

### Combinando todo en una skill real

Crea `skills/crear-temario/SKILL.md`:

```markdown
---
name: crear-temario
description: Crea el temario de un curso en Markdown con formato estándar.
---

# Crear temario

Cuando el usuario pida crear el temario de un curso:
1. Pregunta por: tema, nivel, duración y objetivo final.
2. Genera el índice con módulos y unidades.
3. Guárdalo en `cursos/<nombre>/temario.md` con `apply_patch`.
4. Usa la plantilla: tabla de contenidos + objetivos + evaluación.
```

> 💡 **Tip:** las skills no deben explicar "cómo ser una IA". Deben decir *qué hacer* con las tools, de forma concisa.

---

## 2.4 Buenas prácticas: seguridad y calidad

1. **Prompts concisos:** la skill instruye *qué* hacer, no diserta.
2. **Control de comandos:** si usas `exec`, no permitas inyección de comandos desde entrada no confiable. Valida/sanitiza argumentos.
3. **Menos privilegios:** la skill solo usa las tools necesarias.
4. **Un archivo por módulo:** temarios en archivos separados = más fácil revisar y reutilizar.
5. **Prueba antes de publicar:** `openclaw agent --message "..."`.

---

## 2.5 Probando tus tools

```bash
# Desde la terminal
openclaw agent --message "crea el temario de un curso de Python"

# O verifica que la skill cargó
openclaw skills list
```

Si creaste una skill en medio de una sesión, el agente puede no verla aún. Haz `/new` (sesión nueva) o reinicia el gateway:

```bash
openclaw gateway restart
```

En el chat, puedes invocar la skill explícitamente con `/skill <nombre>`.

> ⚠️ **Gotcha:** el agente solo "ve" las skills que estaban cargadas al inicio de su sesión. Cambios a mitad de sesión requieren sesión nueva o reinicio.

---

## 2.6 Publicar en ClawHub

ClawHub es el registro público de skills de la comunidad. Publicar la tuya:

```bash
npm i -g clawhub
clawhub login
clawhub skill publish ./skills/mi-skill
```

> 💡 **Antes de construir desde cero, busca en [clawhub.ai](https://clawhub.ai)** — quizá ya existe la skill que necesitas. Reutilizar > reinventar.

---

## Errores comunes

1. **`name` con mayúsculas o espacios:** OpenClaw no la carga. Usa minúsculas + guiones.
2. **`description` muy larga:** debe ser una línea <160 caracteres.
3. **Carpeta y `name` distintos:** deben coincidir.
4. **Skill no visible tras crearla:** falta `/new` o reiniciar el gateway.
5. **Inyección de comandos:** nunca interpoles input no confiable en `exec` sin validar.

---

## Ejercicios

- [ ] Crea una skill `resumir-url` que use `web_fetch` y devuelva un resumen en 5 bullets.
- [ ] Crea una skill `backup-temario` que use `exec` para comprimir tu carpeta de cursos.
- [ ] Prueba ambas con `openclaw agent --message "..."`.
- [ ] (Opcional) Publica una en ClawHub.

---

## Resumen

- Las **tools** son el cajón de herramientas del agente; el modelo decide cuándo usarlas según sus **descripciones**.
- Un **skill** = carpeta + `SKILL.md` (frontmatter + instrucciones).
- El **gating** hace que las skills solo carguen si hay requisitos.
- `exec`, `apply_patch` y `web_fetch` son los ladrillos; los scripts propios los extienden.
- **Prueba siempre** y reinicia/`/new` tras crear skills.
- **ClawHub** para compartir y reutilizar.

---

*Siguiente: [Módulo 3 — Agentes múltiples y rutas de sesión](03-agentes-multiples.md)*
