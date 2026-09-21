# Módulo 6 — El CLI de OpenSpec

> **Objetivo:** dominar los comandos de terminal de OpenSpec.

---

El CLI (`openspec`) se divide en grupos. Tu agente ejecuta la mayoría de los comandos de
workflow; tú usas el CLI para setup, inspección y validación.

## 6.1 Comandos de setup

| Comando | Qué hace |
|---------|----------|
| `openspec init` | Inicializa OpenSpec en un proyecto. |
| `openspec update` | Actualiza los archivos de instrucciones instalados. |
| `openspec config` | Ve y cambia la configuración global. |

### `openspec init`

```bash
openspec init                          # directorio actual, selector interactivo de tools
openspec init --tools claude,cursor    # configurar tools concretas, sin prompts
openspec init --tools none             # solo estructura openspec/, sin archivos de tool
```

- `--tools <tools>`: ids separados por coma, `all` o `none`. Salta el selector.
- `--force`: elimina archivos de layouts antiguos sin preguntar.
- `--profile <profile>`: `core` (conjunto estándar) o `custom`.
- `--no-animation`: pantalla de bienvenida estática.

### `openspec update`

```bash
openspec update          # refresca tools cuyos archivos son más viejos que el CLI
openspec update --force  # reescribe archivos aunque estén al día
```

- Si hay una versión más nueva del CLI, primero ofrece actualizarlo.
- `OPENSPEC_NO_UPDATE_CHECK=1` salta la comprobación de versión.
- Fuera de un proyecto con OpenSpec: `✖ Error: No OpenSpec directory found. Run 'openspec init' first.`

### `openspec config`

```bash
openspec config list                 # ver ajustes actuales
openspec config get delivery         # leer un valor (scriptable)
openspec config set delivery skills  # cambiar un valor
openspec config unset delivery       # quitar una clave (vuelve al default)
openspec config reset --all -y      # resetear todo
openspec config edit                 # abrir el config en $EDITOR
openspec config profile              # selector interactivo de workflows
```

- La config es **global a tu máquina**: `~/.config/openspec/config.json` (o `%APPDATA%` en Windows).
- `set` coacciona tipos (`true` → booleano, `"3"` → número). Usa `--string` para forzar string.
- Claves desconocidas fallan con exit 1 salvo que pases `--allow-unknown`.

---

## 6.2 Comandos de changes y specs

| Comando | Qué hace |
|---------|----------|
| `openspec list` | Lista changes, o specs con `--specs`. |
| `openspec show` | Imprime un change o spec, como markdown o JSON. |
| `openspec view` | Dashboard de una pantalla de specs y changes. |
| `openspec validate` | Comprueba changes y specs por problemas estructurales. |
| `openspec archive` | Mueve un change completado al archivo y actualiza las specs. |

### `openspec list`

```bash
openspec list            # changes, más recientes primero
openspec list --specs    # specs con conteo de requisitos
openspec list --json     # salida JSON, incluye la raíz resuelta
```

- `--sort recent|name` (default: recent; specs siempre por nombre).
- `--store <id>`: usa un store registrado como raíz.

Salida:
```
Changes:
 add-rate-limit   No tasks just now

Specs:
 api   requirements 1
```

### `openspec show`

```bash
openspec show add-rate-limit        # change: imprime proposal.md
openspec show add-rate-limit --diff # change: añade diffs de requisitos
openspec show api                   # spec: imprime spec.md
openspec show api --json            # spec JSON
```

- `--json`: salida estructurada.
- `--type <change|spec>`: desambigua cuando un change y una spec comparten nombre.
- `--diff`: para changes, añade diffs por requisito.
- `-r, --requirement <id>`: para specs JSON, un requisito por posición 1-based.

### `openspec view`

```bash
openspec view
```

Dashboard de una pantalla. Los changes se agrupan por progreso de tareas:
- **Draft** (sin tareas aún)
- **Active** (tareas en curso, con barra de progreso y %)
- **Completed** (cada tarea marcada)

Las specs se listan con conteo de requisitos, las más grandes primero.

### `openspec validate`

```bash
openspec validate add-rate-limit   # un change o spec, por nombre
openspec validate --all            # cada change y spec
openspec validate --changes        # cada change
openspec validate --specs          # cada spec
openspec validate --strict         # tratar warnings como fallos
openspec validate --json           # reporte estructurado
```

- `--archived`: comprueba completitud de tareas en changes archivados.
- `--concurrency <n>`: paralelismo en runs bulk (default: `OPENSPEC_CONCURRENCY`, si no 6).
- `--no-interactive`: un nombre ausente/ambiguo se vuelve error.

Salida bulk:
```
✓ change/add-rate-limit
✓ spec/api
Totals: 2 passed, 0 failed (2 items)
```

> **Archive merge findings:** para changes, `validate` ejecuta el merge builder de archive contra
> las specs actuales sin escribir archivos. Reporta conflictos de merge (p. ej. un MODIFIED cuyo
> target falta) como `INFO`. Los INFO nunca cambian el exit code, ni siquiera con `--strict`.

### `openspec archive`

Mueve un change completado al archivo y actualiza las specs principales con sus deltas.

---

## 6.3 Comandos de workflows y schemas

| Comando | Qué hace |
|---------|----------|
| `openspec new` | Crea un directorio de change nuevo. |
| `openspec status` | Estado de completitud de artefactos de uno o todos los changes activos. |
| `openspec instructions` | Instrucciones para crear un artefacto, aplicar o archivar. |
| `openspec templates` | Rutas de template resueltas para los artefactos de un schema. |
| `openspec schemas` | Lista los schemas de workflow disponibles. |
| `openspec schema` | Inspecciona, bifurca o crea un schema (experimental). |

---

## 6.4 Comandos multi-repo (beta)

| Comando | Qué hace |
|---------|----------|
| `openspec store` | Crea y gestiona stores: repos OpenSpec independientes registrados en tu máquina. |
| `openspec doctor` | Reporta la salud de relaciones para la raíz OpenSpec resuelta. |
| `openspec context` | Imprime el contexto de trabajo para la raíz OpenSpec resuelta. |
| `openspec workset` | Compone, mantiene y abre vistas de trabajo personales. |

---

## 6.5 Utilidades

| Comando | Qué hace |
|---------|----------|
| `openspec feedback` | Envía feedback sobre OpenSpec. |
| `openspec completion` | Instala o genera completions de shell. |

**Deprecados:** `openspec change` y `openspec spec` (formas nominales de show/list/validate).
El CLI avisa y apunta a los comandos verb-first.

---

## 6.6 Flags globales

- `-h, --help` en cada comando.
- `-V, --version`: imprime la versión del CLI.
- `--no-color`: desactiva salida de color.

---

## ✅ Checkpoint del módulo 6

1. ¿Qué hace `openspec init --tools none`?
2. ¿Cuál es la diferencia entre `openspec list` y `openspec view`?
3. ¿Qué hace `openspec validate --all` y qué son los "archive merge findings"?
4. ¿Cómo desambiguas un nombre que es a la vez change y spec en `show`?
5. ¿Dónde vive la config global de OpenSpec?
6. Nombra dos comandos del grupo multi-repo (beta).

**Ejercicio:** [Ejercicio 4 — Validación](ejercicios/04-ejercicio-validacion.md)

**Siguiente:** [Módulo 7 — Avanzado](07-avanzado.md)
