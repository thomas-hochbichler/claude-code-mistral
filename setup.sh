#!/usr/bin/env bash
set -euo pipefail

# Claude Code + Mistral.ai EU-Compliant Setup
# Configures claude-code-router to route Claude Code through Mistral's EU API
#
# Exit codes:
#   0 — Success
#   1 — Prerequisite failure
#   2 — User cancelled

REQUIRED_NODE_MAJOR=20
CCR_CONFIG_DIR="$HOME/.claude-code-router"
CCR_CONFIG_FILE="$CCR_CONFIG_DIR/config.json"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_CONFIG="$SCRIPT_DIR/config.json"

# --- Helpers ---

info()  { printf "\033[1;34m[INFO]\033[0m  %s\n" "$1"; }
ok()    { printf "\033[1;32m[OK]\033[0m    %s\n" "$1"; }
warn()  { printf "\033[1;33m[WARN]\033[0m  %s\n" "$1"; }
fail()  { printf "\033[1;31m[FAIL]\033[0m  %s\n" "$1"; exit 1; }

# --- Prerequisite Checks ---

info "Checking prerequisites..."

# 1. Node.js >= 20
if ! command -v node &>/dev/null; then
  fail "Node.js is not installed. Install Node.js $REQUIRED_NODE_MAJOR+ from https://nodejs.org"
fi

NODE_VERSION=$(node -v | sed 's/^v//')
NODE_MAJOR=$(echo "$NODE_VERSION" | cut -d. -f1)

if [ "$NODE_MAJOR" -lt "$REQUIRED_NODE_MAJOR" ]; then
  fail "Node.js $NODE_VERSION found, but >= $REQUIRED_NODE_MAJOR.0.0 is required. Update via nvm or https://nodejs.org"
fi
ok "Node.js $NODE_VERSION"

# 2. Claude Code installed
if ! command -v claude &>/dev/null; then
  fail "Claude Code is not installed. Install it from https://claude.ai/code"
fi
ok "Claude Code $(claude --version 2>/dev/null || echo 'installed')"

# 3. MISTRAL_API_KEY set
if [ -z "${MISTRAL_API_KEY:-}" ]; then
  fail "MISTRAL_API_KEY is not set. Get your API key at https://console.mistral.ai and run: export MISTRAL_API_KEY=\"your-key-here\""
fi
ok "MISTRAL_API_KEY is set"

# 4. Config template exists
if [ ! -f "$TEMPLATE_CONFIG" ]; then
  fail "Template config.json not found at $TEMPLATE_CONFIG. Are you running this from the repository root?"
fi

# --- Existing Config Detection ---

if [ -f "$CCR_CONFIG_FILE" ]; then
  warn "Existing configuration found at $CCR_CONFIG_FILE"
  printf "    Overwrite with Mistral EU configuration? [y/N] "
  read -r response
  case "$response" in
    [yY]|[yY][eE][sS])
      info "Backing up existing config to $CCR_CONFIG_FILE.bak"
      cp "$CCR_CONFIG_FILE" "$CCR_CONFIG_FILE.bak"
      ;;
    *)
      info "Setup cancelled. Your existing configuration is unchanged."
      exit 2
      ;;
  esac
fi

# --- Installation ---

info "Installing claude-code-router..."
if ! npm install -g @musistudio/claude-code-router; then
  fail "Failed to install claude-code-router. Check your npm permissions or try: sudo npm install -g @musistudio/claude-code-router"
fi
ok "claude-code-router installed"

# --- Configuration ---

info "Creating configuration directory..."
mkdir -p "$CCR_CONFIG_DIR"
mkdir -p "$CCR_CONFIG_DIR/plugins"

info "Installing custom transformer plugin..."
cp "$SCRIPT_DIR/plugins/strip-reasoning.js" "$CCR_CONFIG_DIR/plugins/strip-reasoning.js"
ok "Custom transformer installed"

info "Writing Mistral EU configuration..."
# Write config with absolute path to plugin
sed "s|plugins/strip-reasoning.js|$CCR_CONFIG_DIR/plugins/strip-reasoning.js|" "$TEMPLATE_CONFIG" > "$CCR_CONFIG_FILE"
ok "Configuration written to $CCR_CONFIG_FILE"

# --- Success ---

echo ""
echo "=========================================="
echo "  Setup complete!"
echo "=========================================="
echo ""
echo "  Your Claude Code requests will now route"
echo "  through Mistral's EU-hosted API."
echo ""
echo "  Start coding:"
echo "    ccr code"
echo ""
echo "  Verify routing (check logs):"
echo "    cat ~/.claude-code-router/logs/ccr-*.log | grep api.mistral.ai"
echo ""
echo "  For persistent shell integration, add to ~/.zshrc:"
echo "    export MISTRAL_API_KEY=\"your-key-here\""
echo "    eval \"\$(ccr activate)\""
echo ""
echo "=========================================="
