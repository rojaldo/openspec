# Módulo 2 — Instalación y Setup

> **Objetivo:** instalar el CLI de OpenSpec y configurar tu primer proyecto.

---

## 2.1 Requisitos previos

OpenSpec es un CLI de Node.js. Necesitas **Node.js 20.19.0 o superior**.

```bash
node --version
```

Si imprime `v20.19.0` o superior, estás listo. Si no, instala una versión más nueva desde
[nodejs.org](https://nodejs.org) o con tu gestor de versiones (nvm, fnm, asdf, volta).

> ⚠️ **Nota sobre Bun/Deno:** Bun instala OpenSpec pero **no lo ejecuta** — necesitas Node igualmente.
> Deno necesita flags de permisos explícitos. La vía más simple y recomendada es **npm**.

## 2.2 Instalar el CLI globalmente

```bash
npm install -g @fission-ai/openspec@latest
```

### Otras vías (opcionales)

**Bun** (necesitas Node igualmente):
```bash
bun add -g @fission-ai/openspec
```

**Deno** (con flags de permisos):
```bash
deno install --global \
  --allow-read --allow-write --allow-env --allow-sys=cpus,homedir --allow-net=edge.openspec.dev \
  npm:@fission-ai/openspec@latest
```

**Nix**:
```bash
nix profile install github:Fission-AI/OpenSpec
# o ejecución puntual sin instalar:
nix run github:Fission-AI/OpenSpec -- --version
```

## 2.3 Verificar la instalación

```bash
openspec --version
```

Si imprime un número de versión, el CLI está en tu PATH. Se instala **una vez por máquina**.

## 2.4 Inicializar un proyecto

Con el CLI instalado, navega a la raíz de tu proyecto y ejecuta:

```bash
cd <tu-proyecto>
openspec init
```

`init` te pregunta qué herramientas de IA usas, escribe los archivos de workflow para las que
elijas y te reporta el resultado:

```
OpenSpec Setup Complete

Created: Claude Code
6 skills and 6 commands in .claude/
Config: openspec/config.yaml (schema: spec-driven)

Restart your IDE for the new commands to take effect.
```

### Opciones útiles de `init`

```bash
openspec init --tools claude,cursor   # configurar herramientas concretas, sin prompts
openspec init --tools none            # solo la estructura openspec/, sin archivos de tool
openspec init --force                 # limpiar archivos de versiones antiguas sin preguntar
```

> **Re-ejecutar `init` es seguro:** las herramientas ya configuradas imprimen `Refreshed`
> en vez de `Created`, y añadir una herramienta nueva con `--tools` la agrega sin tocar las demás.

## 2.5 ¿Qué crea `init`?

`init` crea **dos cosas** en tu proyecto:

### 1. La carpeta `openspec/` (en la raíz del repo)

```
openspec/
├── config.yaml        # ajustes del proyecto y contexto para la IA
├── specs/             # tus specs (vacía por ahora)
└── changes/           # cambios en movimiento (vacía por ahora)
    └── archive/       # los cambios completados se mueven aquí
```

### 2. Los archivos de workflow (skills y commands)

Se añaden a la carpeta de tu herramienta de IA (`.agents/`, `.claude/`, etc.):

```
.agents/skills/
├── openspec-explore/          # pensar una idea primero
├── openspec-propose/          # proponer un cambio
├── openspec-apply-change/     # implementar las tareas de un cambio
├── openspec-update-change/    # revisar el plan de un cambio
├── openspec-sync-specs/       # sincronizar deltas de un cambio en specs/
├── openspec-archive-change/   # mover un cambio terminado al archivo
├── openspec-verify-change/    # (opcional) verificar que la implementación coincide
└── openspec-bulk-archive-change/  # (opcional) archivar varios cambios a la vez
```

Cada workflow se instala en **dos formas** (por defecto):
- **Skill** (`openspec-apply-change`): instrucciones que tu agente recoge solo.
- **Command** (`/opsx:apply` en Claude Code): un punto de entrada tecleado para el mismo workflow.

Son funcionalmente idénticos. OpenSpec prefiere skills y planea retirar los commands.

> **Commit todo** (la carpeta `openspec/` y los archivos de workflow) como parte de tu código
> fuente. `init` no cambia nada más en tu repo.

## 2.6 Cambiar el perfil de instalación

Puedes cambiar cómo se instalan los workflows (skills, commands, o ambos) y qué conjunto de
workflows se usa:

```bash
openspec config profile
```

Ejemplo — cambiar a solo skills:

```
Current profile settings
 Delivery: both

? What do you want to configure? Delivery only
? Delivery mode (how workflows are installed): Skills only

Config changes:
 delivery: both -> skills
? Apply changes to this project now? (Y/n) y
```

> Los cambios de config no llegan a los proyectos hasta que ejecutas `openspec update`.

## 2.7 Actualizar OpenSpec

```bash
openspec update
```

- Actualiza los archivos de instrucciones instalados en tu proyecto.
- Si hay una versión más nueva del CLI, te ofrece actualizarla primero (una vez por máquina).
- Cada ejecución refresca los skills y commands generados del proyecto (nunca se actualizan solos).

```bash
openspec update --force   # reescribir archivos aunque estén al día
```

## 2.8 Desinstalar

1. Quita las completions de shell (si las configuraste): `openspec completion uninstall`
2. Quita el paquete: `npm uninstall -g @fission-ai/openspec`
3. Borra lo que quede (opcional): archivos generados en `.claude/`/`.agents/`, la carpeta
   `openspec/` (pausa: `specs/` y `changes/archive/` son tu registro del sistema, Markdown
   plano que se lee sin OpenSpec), y el estado por máquina en `~/.config/openspec/`.

---

## ✅ Checkpoint del módulo 2

1. ¿Qué versión de Node.js necesitas?
2. ¿Cuál es el comando para instalar el CLI globalmente?
3. ¿Qué dos cosas crea `openspec init`?
4. ¿Cuál es la diferencia entre un *skill* y un *command* de workflow?
5. ¿Qué hace `openspec update` y por qué es necesario?

**Ejercicio:** [Ejercicio 1 — Setup](ejercicios/01-ejercicio-setup.md)

**Siguiente:** [Módulo 3 — Conceptos](03-conceptos.md)
