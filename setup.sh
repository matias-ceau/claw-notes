#!/data/data/com.termux/files/usr/bin/bash
#
# Claw Notes - Setup Script
#
# Installs dependencies, sets up widgets, starts the assistant.
# After setup, you interact via widgets and notifications - no CLI needed.

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
fail() { echo -e "${RED}  ✗${NC} $1"; }

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
    warn "Not running in Termux. Widget features won't work."
    echo ""
fi

TOTAL=9

# Step 1: Update packages
step 1 $TOTAL "Updating packages..."
if [ "$ENV" = "termux" ]; then
    pkg update -y > /dev/null 2>&1 && pkg upgrade -y > /dev/null 2>&1
    ok "Packages updated"
else
    ok "Skipped (not Termux)"
fi

# Step 2: Install core dependencies
step 2 $TOTAL "Installing Node.js, Git, Termux:API..."
if [ "$ENV" = "termux" ]; then
    pkg install -y nodejs-lts git termux-api jq > /dev/null 2>&1
    ok "Core dependencies installed"
else
    ok "Please ensure nodejs, git, jq are installed"
fi

# Step 3: Install Python + FFmpeg
step 3 $TOTAL "Installing Python and FFmpeg..."
if [ "$ENV" = "termux" ]; then
    pkg install -y python ffmpeg > /dev/null 2>&1
    ok "Python and FFmpeg installed"
else
    ok "Please ensure python and ffmpeg are installed"
fi

# Step 4: Install Whisper
step 4 $TOTAL "Installing Whisper (speech-to-text)..."
if pip install --quiet openai-whisper 2>/dev/null; then
    ok "Whisper installed"
else
    warn "Whisper failed - transcription may not work"
fi

# Step 5: Install OpenClaw
step 5 $TOTAL "Installing OpenClaw..."
if npm install -g openclaw > /dev/null 2>&1; then
    ok "OpenClaw installed"
else
    warn "OpenClaw failed - assistant features limited"
fi

# Step 6: Configure OpenClaw for Android
step 6 $TOTAL "Configuring for Android..."
if command -v openclaw &> /dev/null; then
    openclaw config set gateway.host 127.0.0.1 2>/dev/null || true
    openclaw config set gateway.port 3000 2>/dev/null || true
    ok "OpenClaw configured (127.0.0.1:3000)"
else
    warn "OpenClaw not found"
fi

# Step 7: Setup storage
step 7 $TOTAL "Setting up storage access..."
if [ "$ENV" = "termux" ]; then
    if [ ! -d "$HOME/storage" ]; then
        echo "    Grant storage permission when prompted..."
        termux-setup-storage
        sleep 2
    fi
    ok "Storage access ready"
else
    ok "Skipped (not Termux)"
fi

# Step 8: Setup widgets
step 8 $TOTAL "Setting up home screen widgets..."
chmod +x "$SCRIPT_DIR/.shortcuts/"* 2>/dev/null || true
chmod +x "$SCRIPT_DIR/.shortcuts/tasks/"* 2>/dev/null || true
chmod +x "$SCRIPT_DIR/.claw/bin/"* 2>/dev/null || true
chmod +x "$SCRIPT_DIR/.claw/boot/"* 2>/dev/null || true

if [ "$ENV" = "termux" ]; then
    # Link widgets to Termux:Widget location
    mkdir -p "$HOME/.shortcuts/tasks"

    # Link each widget
    for widget in "$SCRIPT_DIR/.shortcuts/"*; do
        [ -d "$widget" ] && continue  # Skip directories
        name=$(basename "$widget")
        ln -sf "$widget" "$HOME/.shortcuts/$name" 2>/dev/null || true
    done

    # Link background tasks
    for task in "$SCRIPT_DIR/.shortcuts/tasks/"*; do
        name=$(basename "$task")
        ln -sf "$task" "$HOME/.shortcuts/tasks/$name" 2>/dev/null || true
    done

    ok "Widgets linked to ~/.shortcuts/"
    echo "    Add Termux:Widget to your home screen"
else
    ok "Scripts ready (widgets require Termux)"
fi

# Step 9: Start assistant
step 9 $TOTAL "Starting assistant..."
if command -v openclaw &> /dev/null && [ "$ENV" = "termux" ]; then
    "$SCRIPT_DIR/.claw/boot/watchdog.sh" --daemon 2>/dev/null
    sleep 2
    if pgrep -f "openclaw" > /dev/null 2>&1; then
        ok "Assistant running"
    else
        warn "Assistant didn't start - run manually later"
    fi
else
    warn "Skipped - start manually with: claw start"
fi

echo ""
echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║       Setup Complete!                ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
echo ""

if [ "$ENV" = "termux" ]; then
    echo "Next steps:"
    echo ""
    echo "  1. Add Termux:Widget to your home screen"
    echo "     (long press → widgets → Termux:Widget)"
    echo ""
    echo "  2. Tap widgets to:"
    echo "     • Record Voice - capture voice notes"
    echo "     • Quick Note   - text notes"
    echo "     • Journal      - daily entries"
    echo "     • Ask Assistant - quick questions"
    echo ""
    echo "  3. For auto-start on boot:"
    echo "     cp .claw/boot/start-claw.sh ~/.termux/boot/"
    echo ""
    echo "You should see a persistent notification with"
    echo "quick actions. No terminal needed from here!"
    echo ""

    # Show notification
    if command -v termux-notification &> /dev/null; then
        termux-notification \
            --title "Claw Notes Ready" \
            --content "Add Termux:Widget to home screen" \
            --button1 "OK" \
            --button1-action "termux-notification-remove claw-setup"
    fi
else
    echo "CLI usage (for non-Android):"
    echo "  export PATH=\"\$PATH:$SCRIPT_DIR/.claw/bin\""
    echo "  claw start"
    echo "  claw full my-note"
    echo ""
fi
