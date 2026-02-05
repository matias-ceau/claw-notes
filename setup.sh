#!/data/data/com.termux/files/usr/bin/bash
#
# Claw Notes - Setup Script
#
# Usage: bash setup.sh

set -e

echo "==========================================="
echo "  Claw Notes Setup"
echo "==========================================="
echo ""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

step() { echo -e "${GREEN}[$1/$2]${NC} $3"; }
ok() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

TOTAL_STEPS=8

# Detect environment
if [ -d "/data/data/com.termux" ]; then
    ENV="termux"
else
    ENV="linux"
    warn "Not running in Termux. Some features may not work."
fi

# Step 1: Update packages
step 1 $TOTAL_STEPS "Updating packages..."
if [ "$ENV" = "termux" ]; then
    pkg update -y && pkg upgrade -y
else
    echo "Skipping (not Termux)"
fi

# Step 2: Install core dependencies
step 2 $TOTAL_STEPS "Installing core dependencies..."
if [ "$ENV" = "termux" ]; then
    pkg install -y nodejs-lts git termux-api jq
else
    echo "Please ensure nodejs, git, and jq are installed"
fi

# Step 3: Install Python + Whisper dependencies
step 3 $TOTAL_STEPS "Installing Python and FFmpeg..."
if [ "$ENV" = "termux" ]; then
    pkg install -y python ffmpeg
else
    echo "Please ensure python and ffmpeg are installed"
fi

# Step 4: Install Whisper
step 4 $TOTAL_STEPS "Installing Whisper..."
pip install --quiet openai-whisper || warn "Whisper install failed (may need manual setup)"

# Step 5: Install OpenClaw
step 5 $TOTAL_STEPS "Installing OpenClaw..."
npm install -g openclaw 2>/dev/null || warn "OpenClaw install failed"

# Step 6: Configure OpenClaw
step 6 $TOTAL_STEPS "Configuring OpenClaw..."
if command -v openclaw &> /dev/null; then
    openclaw config set gateway.host 127.0.0.1 2>/dev/null || true
    openclaw config set gateway.port 3000 2>/dev/null || true
    ok "OpenClaw configured"
else
    warn "OpenClaw not found, skipping config"
fi

# Step 7: Setup storage (Termux only)
step 7 $TOTAL_STEPS "Setting up storage access..."
if [ "$ENV" = "termux" ]; then
    if [ ! -d "$HOME/storage" ]; then
        termux-setup-storage
        echo "Please grant storage permission, then press Enter..."
        read -r
    else
        ok "Storage already configured"
    fi
else
    echo "Skipping (not Termux)"
fi

# Step 8: Make scripts executable
step 8 $TOTAL_STEPS "Setting up CLI..."
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
chmod +x "$SCRIPT_DIR/.claw/bin/"* 2>/dev/null || true
chmod +x "$SCRIPT_DIR/.claw/boot/"* 2>/dev/null || true
chmod +x "$SCRIPT_DIR/.claw/lib/"*.sh 2>/dev/null || true

echo ""
echo "==========================================="
echo -e "${GREEN}  Setup Complete!${NC}"
echo "==========================================="
echo ""
echo "Add to your PATH:"
echo "  export PATH=\"\$PATH:$SCRIPT_DIR/.claw/bin\""
echo ""
echo "Or add to ~/.bashrc for permanent access:"
echo "  echo 'export PATH=\"\$PATH:$SCRIPT_DIR/.claw/bin\"' >> ~/.bashrc"
echo ""
echo "Then try:"
echo "  claw status      # Check system status"
echo "  claw start       # Start OpenClaw gateway"
echo "  claw full test   # Record → Transcribe → Process"
echo ""
echo "For auto-start on boot (Termux:Boot required):"
echo "  cp $SCRIPT_DIR/.claw/boot/start-claw.sh ~/.termux/boot/"
echo ""
