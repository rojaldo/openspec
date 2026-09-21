#!/usr/bin/env bash
# ============================================================
#  provision.sh — instala el stack de herramientas en la VM Ubuntu
#  Se ejecuta automáticamente con:  vagrant up
#  Es idempotente: puedes re-ejecutarlo sin romper nada.
#
#  Stack instalado (repos oficiales verificados):
#   - OpenCode      -> anomalyco/opencode            (CLI agente IA)
#   - OpenChamber   -> openchamber/openchamber       (workspace visual de OpenCode, requiere Node 22+)
#   - Spec Kit      -> github/spec-kit               (Spec-Driven Development, requiere Python 3.11+ y uv)
#   - OpenSpec      -> Fission-AI/OpenSpec           (npm @fission-ai/openspec)
#   - ECC           -> affaan-m/ecc            (agent harness OS; npm ecc-universal)
#   - BMad          -> bmad-code-org/BMAD-METHOD     (framework dev con IA, npx skills add)
#  Complementos (mismo dominio):
#   - Superpowers      -> obra/superpowers           (kit de skills nº1, 250k+ ⭐)
#   - agent-skills     -> addyosmani/agent-skills    (skills production-grade)
#   - Aider            -> Aider-AI/aider             (agente de coding por terminal)
#   - Recursos índice  -> VoltAgent/awesome-agent-skills, hesreallyhim/awesome-claude-code
# ============================================================
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
export USER_HOME=/home/vagrant

echo "==> [1/8] Actualizando sistema..."
apt-get update -y
apt-get upgrade -y

echo "==> [2/8] Paquetes base..."
apt-get install -y \
  git curl wget unzip build-essential ca-certificates \
  python3 python3-pip python3-venv \
  jq htop net-tools vim

# ---------- Node.js 22+ (necesario para OpenChamber CLI y OpenSpec) ----------
echo "==> [3/8] Instalando Node.js 22 LTS..."
if ! command -v node >/dev/null 2>&1 || [ "$(node -v | cut -d. -f1 | tr -d v)" -lt 22 ]; then
  curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
  apt-get install -y nodejs
fi
npm install -g npm@latest

# ---------- Python 3.11+ y uv (necesario para Spec Kit) ----------
echo "==> [4/8] Instalando Python 3.11+ y uv..."
apt-get install -y python3.11 python3.11-venv 2>/dev/null || true
if ! command -v uv >/dev/null 2>&1; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
fi
# uv para el usuario vagrant
sudo -u vagrant bash -c 'curl -LsSf https://astral.sh/uv/install.sh | sh' || true

# ============================================================
#  HERRAMIENTAS
# ============================================================

# --- [5/8] OpenCode (anomalyco/opencode) ---
echo "==> [5/8] Instalando OpenCode..."
if ! command -v opencode >/dev/null 2>&1; then
  curl -fsSL https://opencode.ai/install | bash
  # el instalador lo deja en ~/.opencode/bin; lo enlazamos
  ln -sf "$USER_HOME/.opencode/bin/opencode" /usr/local/bin/opencode 2>/dev/null || true
fi

# --- [6/8] OpenChamber (openchamber/openchamber) + OpenSpec (Fission-AI) ---
echo "==> [6/8] Instalando OpenChamber (CLI) y OpenSpec..."
# OpenChamber CLI (requiere Node 22+; usa tu OpenCode ya instalado)
if ! command -v openchamber >/dev/null 2>&1; then
  curl -fsSL https://raw.githubusercontent.com/openchamber/openchamber/main/scripts/install.sh | bash
fi

# OpenSpec (npm global)
if ! command -v openspec >/dev/null 2>&1; then
  npm install -g @fission-ai/openspec@latest
fi

# --- [7/8] Spec Kit (github/spec-kit) ---
echo "==> [7/8] Instalando Spec Kit (specify-cli)..."
if ! command -v specify >/dev/null 2>&1; then
  sudo -u vagrant bash -c 'export PATH="$HOME/.local/bin:$PATH"; uv tool install specify-cli' \
    || uv tool install specify-cli
fi

# --- [8/8] ECC (Everything Claude Code) y BMad ---
echo "==> [8/8] Instalando ECC (affaan-m/ecc) y BMad..."
# ECC: agent harness OS desde su repo canónico affaan-m/ecc.
# Se instala vía npm (ecc-universal). El guided setup es interactivo,
# así que aquí lo dejamos preparado + documentado para ejecutarlo a mano:
sudo -u vagrant bash -lc 'command -v ecc || npm install -g ecc-universal || true'
# Nota: para el setup guiado real (elegir harness OpenCode/Claude/Codex) ejecuta:
#   npx ecc-universal@2.2.1 setup
# ECC soporta OpenCode como harness nativo, así que encaja con tu stack.

# BMad: via npx skills add
if command -v npx >/dev/null 2>&1; then
  sudo -u vagrant bash -lc 'cd ~ && npx -y skills add bmad-code-org/BMAD-METHOD' 2>/dev/null || \
    echo "  [!] BMad: fallo al ejecutar 'npx skills add' (revisar manualmente)";
else
  echo "  [!] npx no disponible; BMad se instala a mano con: npx skills add bmad-code-org/BMAD-METHOD"
fi

# ---------- Fix permisos ----------
echo "==> Ajustando permisos npm global para vagrant..."
chown -R vagrant:vagrant /usr/lib/node_modules /usr/local/lib/node_modules 2>/dev/null || true

# ============================================================
#  HERRAMIENTAS COMPLEMENTARIAS (mismo dominio, verificado)
# ============================================================

# --- Superpowers (obra/superpowers) — kit de skills nº1 (250k+ estrellas) ---
echo "==> [EXTRA] Superpowers (obra/superpowers) para OpenCode..."
# Se instala desde DENTRO de OpenCode con:
#   "Fetch and follow instructions from https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/.opencode/INSTALL.md"
# Aquí dejamos la doc descargada para referencia:
if [ ! -d "$USER_HOME/superpowers" ]; then
  sudo -u vagrant git clone --depth 1 https://github.com/obra/superpowers.git "$USER_HOME/superpowers" || true
fi

# --- Addy Osmani agent-skills (production-grade engineering skills) ---
echo "==> [EXTRA] addyosmani/agent-skills..."
cd "$USER_HOME" && sudo -u vagrant bash -lc 'cd ~ && npx -y skills add addyosmani/agent-skills' 2>/dev/null || \
  echo "  [!] agent-skills: fallo al ejecutar; instala a mano con: npx skills add addyosmani/agent-skills"

# --- Aider (Aider-AI/aider) — agente de coding por terminal ---
echo "==> [EXTRA] Aider (Aider-AI/aider)..."
if ! command -v aider >/dev/null 2>&1; then
  pip install -q aider-install 2>/dev/null && aider-install || \
    pip install -q aider-chat 2>/dev/null || \
    echo "  [!] Aider: instalación por pip falló; revisar manualmente"
fi

# ============================================================
#  INTERFAZ GRÁFICA: XFCE ligero + servidor VNC (x11vnc)
# ============================================================
echo "==> [GUI] Instalando escritorio XFCE y VNC..."
export DEBIAN_FRONTEND=noninteractive
apt-get install -y --no-install-recommends \
  xfce4 xfce4-terminal \
  x11vnc xvfb dbus-x11 \
  lightdm \
  firefox \
  ttf-ubuntu-font-family 2>/dev/null || true

# Arranque de VNC automático para el usuario vagrant
# Conecta con: vncviewer 192.168.56.10:1   (o puerto 5901)
cat > /etc/systemd/system/vnc.service <<'EOF'
[Unit]
Description=Autostart XFCE + x11vnc
After=multi-user.target

[Service]
User=vagrant
Environment=DISPLAY=:1
Environment=HOME=/home/vagrant
ExecStartPre=/usr/bin/Xvfb :1 -screen 0 1280x800x24 &
ExecStart=/usr/bin/x11vnc -display :1 -forever -shared -bg -o /home/vagrant/.vnc.log -rfbport 5901 -nopw
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable vnc.service 2>/dev/null || true
systemctl start vnc.service 2>/dev/null || true
# Asegurar sesión xfce
sudo -u vagrant bash -c 'echo "exec startxfce4" > ~/.xsession; chmod +x ~/.xsession' 2>/dev/null || true

echo "==> [GUI] XFCE + VNC listos. Conecta con: vncviewer 192.168.56.10:5901"

# ---------- Reporte final ----------
echo ""
echo "========== VERSIONES INSTALADAS =========="
for c in node npm python3 opencode openchamber openspec specify uv ecc aider; do
  if command -v "$c" >/dev/null 2>&1; then
    printf "  %-14s -> %s\n" "$c" "$(command -v $c)  [$( $c --version 2>/dev/null | head -1 )]"
  else
    printf "  %-14s -> (no en PATH; ver nota)\n" "$c"
  fi
done
echo "=========================================="
echo ""
echo "Nota ECC: dentro de la VM ejecuta el setup guiado (elige tu harness):"
echo "  npx ecc-universal@2.2.1 setup"
echo "Repo oficial: https://github.com/affaan-m/ecc"
echo ""
echo "INTERFAZ GRÁFICA (XFCE): conecta desde tu máquina con un cliente VNC:"
echo "  vncviewer 192.168.56.10:5901"
echo "  (o en VirtualBox: la ventana de la VM muestra el escritorio directamente)"
echo ""
echo "Recursos extra (índices curados, no instalados):"
echo "  - VoltAgent/awesome-agent-skills  (1497+ skills para agentes)"
echo "  - hesreallyhim/awesome-claude-code (recursos Claude Code)"
echo ""
echo "Provisioning completado."
