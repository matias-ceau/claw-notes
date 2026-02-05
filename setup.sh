#!/data/data/com.termux/files/usr/bin/bash
# Claw Notes Setup Script
# Usage: bash setup.sh [quick|production|power]

set -e

MODE="${1:-quick}"

echo "=========================================="
echo "  Claw Notes Setup - Mode: $MODE"
echo "=========================================="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

progress() {
    echo -e "${GREEN}[$1/$2]${NC} $3"
}

warn() {
    echo -e "${YELLOW}WARNING:${NC} $1"
}

error() {
    echo -e "${RED}ERROR:${NC} $1"
    exit 1
}

# Check if running in Termux
if [ ! -d "/data/data/com.termux" ]; then
    error "This script must be run in Termux on Android"
fi

# ============================================
# QUICK SETUP (Approach 3)
# ============================================
setup_quick() {
    STEPS=7

    progress 1 $STEPS "Updating packages..."
    pkg update -y && pkg upgrade -y

    progress 2 $STEPS "Installing dependencies..."
    pkg install -y nodejs-lts git termux-api

    progress 3 $STEPS "Setting up storage access..."
    if [ ! -d "$HOME/storage" ]; then
        termux-setup-storage
        echo "Please grant storage permission in the popup, then press Enter..."
        read -r
    fi

    progress 4 $STEPS "Installing OpenClaw..."
    npm install -g openclaw

    progress 5 $STEPS "Creating Android compatibility shim..."
    mkdir -p ~/.openclaw
    cat > ~/.openclaw/hijack.js << 'EOF'
// Android compatibility shim
// Bypasses System Error 13 (blocked os.networkInterfaces)
const os = require('os');
os.networkInterfaces = () => ({});
EOF

    progress 6 $STEPS "Configuring OpenClaw..."
    openclaw config set gateway.host 127.0.0.1
    openclaw config set gateway.port 3000

    progress 7 $STEPS "Creating notes directory..."
    mkdir -p ~/storage/shared/Documents/claw-notes
    cd ~/storage/shared/Documents/claw-notes
    if [ ! -d ".git" ]; then
        git init
        git config user.email "claw-notes@local"
        git config user.name "Claw Notes"
    fi

    echo ""
    echo -e "${GREEN}Quick setup complete!${NC}"
    echo ""
    echo "To start OpenClaw:"
    echo "  node -r ~/.openclaw/hijack.js \$(which openclaw) gateway"
    echo ""
}

# ============================================
# PRODUCTION SETUP (Approach 1)
# ============================================
setup_production() {
    # First do quick setup
    setup_quick

    STEPS=3
    echo ""
    echo "Adding production features..."
    echo ""

    progress 1 $STEPS "Installing Termux services..."
    pkg install -y termux-services

    progress 2 $STEPS "Creating boot script..."
    mkdir -p ~/.termux/boot
    cat > ~/.termux/boot/start-openclaw.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# OpenClaw auto-start with watchdog

# Acquire wake lock
termux-wake-lock

# Start OpenClaw
node -r ~/.openclaw/hijack.js $(which openclaw) gateway &

# Watchdog - restart on crash
while true; do
    sleep 300
    if ! pgrep -f "openclaw" > /dev/null; then
        echo "[$(date)] OpenClaw crashed, restarting..."
        node -r ~/.openclaw/hijack.js $(which openclaw) gateway &
    fi
done &
EOF
    chmod +x ~/.termux/boot/start-openclaw.sh

    progress 3 $STEPS "Creating manual start script..."
    cat > ~/start-claw.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
~/.termux/boot/start-openclaw.sh
EOF
    chmod +x ~/start-claw.sh

    echo ""
    echo -e "${GREEN}Production setup complete!${NC}"
    echo ""
    echo "OpenClaw will auto-start on boot (requires Termux:Boot app)"
    echo ""
    echo "Manual start: ~/start-claw.sh"
    echo ""
    warn "Install Termux:Boot from F-Droid for auto-start on boot"
}

# ============================================
# POWER USER SETUP (Approach 2)
# ============================================
setup_power() {
    # First do production setup
    setup_production

    STEPS=3
    echo ""
    echo "Adding power user features (Whisper)..."
    echo ""

    progress 1 $STEPS "Installing Python and FFmpeg..."
    pkg install -y python ffmpeg

    progress 2 $STEPS "Installing Whisper..."
    pip install openai-whisper

    progress 3 $STEPS "Creating vault structure..."
    VAULT=~/storage/shared/Documents/claw-notes
    mkdir -p "$VAULT"/{pages,journals,transcripts/{raw,cleaned},assets,summaries}

    # Create vault README
    cat > "$VAULT/README.md" << 'EOF'
# Claw Notes Vault

## Structure

- `pages/` - Topic-based notes
- `journals/` - Daily notes (YYYY-MM-DD.md)
- `transcripts/raw/` - Unprocessed Whisper output
- `transcripts/cleaned/` - LLM-processed transcripts
- `assets/` - Audio files, images
- `summaries/` - AI-generated summaries

## Workflow

1. Record voice note
2. Whisper transcribes to `transcripts/raw/`
3. OpenClaw cleans up to `transcripts/cleaned/`
4. Summary generated in `summaries/`
EOF

    echo ""
    echo -e "${GREEN}Power user setup complete!${NC}"
    echo ""
    echo "Vault structure created at:"
    echo "  ~/storage/shared/Documents/claw-notes"
    echo ""
    echo "Transcription workflow:"
    echo "  1. Record: termux-microphone-record -f audio.m4a"
    echo "  2. Transcribe: whisper audio.m4a --output_format txt"
    echo "  3. Clean with OpenClaw LLM"
    echo ""
}

# ============================================
# MAIN
# ============================================
case "$MODE" in
    quick)
        setup_quick
        ;;
    production)
        setup_production
        ;;
    power)
        setup_power
        ;;
    *)
        echo "Usage: bash setup.sh [quick|production|power]"
        echo ""
        echo "Modes:"
        echo "  quick      - Basic setup, minimal dependencies (default)"
        echo "  production - Adds boot persistence and watchdog"
        echo "  power      - Adds Whisper transcription and vault structure"
        exit 1
        ;;
esac

echo "=========================================="
echo "  Setup Complete!"
echo "=========================================="
