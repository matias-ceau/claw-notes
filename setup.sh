#!/data/data/com.termux/files/usr/bin/bash
#
# Claw Notes - Setup Script
#
# Sets up OpenClaw as your always-on AI assistant.
# Transcription uses cloud APIs (OpenAI Whisper API), not local models.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

step() { echo -e "${CYAN}[$1/$2]${NC} $3"; }
ok() { echo -e "${GREEN}  ✓${NC} $1"; }
warn() { echo -e "${YELLOW}  !${NC} $1"; }

echo ""
echo -e "${CYAN}╔══════════════════════════════════════╗${NC}"
echo -e "${CYAN}║       Claw Notes Setup               ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════╝${NC}"
echo ""

# Detect environment
if [ -d "/data/data/com.termux" ]; then
    ENV="termux"
else
    ENV="linux"
    warn "Not running in Termux. Some features won't work."
    echo ""
fi

TOTAL=8

# Step 1: Update packages
step 1 $TOTAL "Updating packages..."
if [ "$ENV" = "termux" ]; then
    pkg update -y > /dev/null 2>&1 && pkg upgrade -y > /dev/null 2>&1
    ok "Packages updated"
else
    ok "Skipped"
fi

# Step 2: Install core dependencies
step 2 $TOTAL "Installing Node.js, Git, Termux:API..."
if [ "$ENV" = "termux" ]; then
    pkg install -y nodejs-lts git termux-api jq curl > /dev/null 2>&1
    ok "Core dependencies installed"
else
    ok "Ensure nodejs, git, jq, curl are installed"
fi

# Step 3: Install OpenClaw
step 3 $TOTAL "Installing OpenClaw..."
if npm install -g openclaw > /dev/null 2>&1; then
    ok "OpenClaw installed"
else
    warn "OpenClaw install failed - try: npm install -g openclaw"
fi

# Step 4: Setup storage
step 4 $TOTAL "Setting up storage access..."
if [ "$ENV" = "termux" ]; then
    if [ ! -d "$HOME/storage" ]; then
        echo "    Grant storage permission when prompted..."
        termux-setup-storage
        sleep 2
    fi
    ok "Storage access ready"
else
    ok "Skipped"
fi

# Step 5: Configure API keys for transcription
step 5 $TOTAL "Configuring API keys..."
echo ""
echo "    OpenClaw uses cloud APIs for voice transcription."
echo "    You need at least one API key (OpenAI recommended)."
echo ""

OPENCLAW_DIR="$HOME/.openclaw"
OPENCLAW_CONFIG="$OPENCLAW_DIR/openclaw.json"
mkdir -p "$OPENCLAW_DIR"

CONFIGURE_KEYS=true
if [ -f "$OPENCLAW_CONFIG" ]; then
    echo "    Found existing config at $OPENCLAW_CONFIG"
    read -p "    Update API keys? [y/N] " -n 1 -r
    echo ""
    [[ ! $REPLY =~ ^[Yy]$ ]] && CONFIGURE_KEYS=false
fi

if [ "$CONFIGURE_KEYS" = true ]; then
    echo ""
    read -p "    OpenAI API key: " OPENAI_KEY
    read -p "    OpenRouter API key (optional): " OPENROUTER_KEY
    echo ""

    # Build providers section
    PROVIDERS=""
    if [ -n "$OPENAI_KEY" ]; then
        PROVIDERS="\"openai\": { \"apiKey\": \"$OPENAI_KEY\" }"
    fi
    if [ -n "$OPENROUTER_KEY" ]; then
        [ -n "$PROVIDERS" ] && PROVIDERS="$PROVIDERS,"
        PROVIDERS="$PROVIDERS \"openrouter\": { \"apiKey\": \"$OPENROUTER_KEY\" }"
    fi

    cat > "$OPENCLAW_CONFIG" << EOF
{
  "gateway": {
    "host": "127.0.0.1",
    "port": 3000
  },
  "workspace": {
    "root": "$SCRIPT_DIR"
  },
  "providers": {
    $PROVIDERS
  },
  "tools": {
    "media": {
      "audio": {
        "enabled": true,
        "models": [
          { "provider": "openai", "model": "whisper-1" }
        ]
      }
    }
  },
  "channels": {
    "whatsapp": { "enabled": true }
  }
}
EOF
    ok "Config saved"
else
    ok "Keeping existing config"
fi

# Step 6: Setup widgets
step 6 $TOTAL "Setting up home screen widgets..."
chmod +x "$SCRIPT_DIR/.shortcuts/"* 2>/dev/null || true
chmod +x "$SCRIPT_DIR/.shortcuts/tasks/"* 2>/dev/null || true
chmod +x "$SCRIPT_DIR/.claw/bin/"* 2>/dev/null || true
chmod +x "$SCRIPT_DIR/.claw/boot/"* 2>/dev/null || true

if [ "$ENV" = "termux" ]; then
    mkdir -p "$HOME/.shortcuts/tasks"

    for widget in "$SCRIPT_DIR/.shortcuts/"*; do
        [ -d "$widget" ] && continue
        name=$(basename "$widget")
        ln -sf "$widget" "$HOME/.shortcuts/$name" 2>/dev/null || true
    done

    for task in "$SCRIPT_DIR/.shortcuts/tasks/"*; do
        name=$(basename "$task")
        ln -sf "$task" "$HOME/.shortcuts/tasks/$name" 2>/dev/null || true
    done

    ok "Widgets linked to ~/.shortcuts/"
else
    ok "Scripts ready"
fi

# Step 7: WhatsApp setup
step 7 $TOTAL "WhatsApp integration..."
if command -v openclaw &> /dev/null; then
    echo ""
    echo "    To connect WhatsApp, run: openclaw onboard"
    echo "    This scans a QR code to link your WhatsApp."
    echo ""
    read -p "    Run WhatsApp setup now? [Y/n] " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        openclaw onboard
    else
        ok "Run 'openclaw onboard' later for WhatsApp"
    fi
else
    warn "Install OpenClaw first, then run 'openclaw onboard'"
fi

# Step 8: Start assistant
step 8 $TOTAL "Starting assistant..."
if command -v openclaw &> /dev/null && [ "$ENV" = "termux" ]; then
    "$SCRIPT_DIR/.claw/boot/watchdog.sh" --daemon 2>/dev/null
    sleep 2
    if pgrep -f "openclaw" > /dev/null 2>&1; then
        ok "Assistant running"
    else
        warn "Start manually: openclaw gateway"
    fi
else
    warn "Start later with: openclaw gateway"
fi

echo ""
echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║       Setup Complete!                ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
echo ""

if [ "$ENV" = "termux" ]; then
    echo "How to use:"
    echo ""
    echo "  1. Add Termux:Widget to your home screen"
    echo ""
    echo "  2. Tap 'Record Voice' → transcribes via OpenAI"
    echo ""
    echo "  3. Or just send voice notes to your assistant"
    echo "     on WhatsApp! It transcribes automatically."
    echo ""
    echo "  4. Auto-start on boot:"
    echo "     cp .claw/boot/start-claw.sh ~/.termux/boot/"
    echo ""

    if command -v termux-notification &> /dev/null; then
        termux-notification \
            --title "Claw Notes Ready" \
            --content "Add Termux:Widget or use WhatsApp"
    fi
else
    echo "Usage:"
    echo "  openclaw gateway   # Start the assistant"
    echo "  openclaw onboard   # Connect WhatsApp"
    echo ""
fi
