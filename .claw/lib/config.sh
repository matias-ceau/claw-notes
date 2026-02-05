#!/data/data/com.termux/files/usr/bin/bash
# Claw Notes - Shared Configuration
#
# Architecture: Code and Data are separate
# - CLAW_ROOT: Code repository (scripts, config templates)
# - VAULT_ROOT: User data (notes, journals, transcripts) - can be cloud-synced

# Detect environment
if [ -d "/data/data/com.termux" ]; then
    CLAW_ENV="termux"
    # Code location (where .claw/ lives)
    CLAW_ROOT="${CLAW_ROOT:-$HOME/claw-notes}"
    # Data location (cloud-syncable, separate from code)
    VAULT_ROOT="${VAULT_ROOT:-$HOME/storage/shared/Documents/ClawNotes-Vault}"
else
    CLAW_ENV="linux"
    CLAW_ROOT="${CLAW_ROOT:-$HOME/claw-notes}"
    VAULT_ROOT="${VAULT_ROOT:-$HOME/ClawNotes-Vault}"
fi

# Load user config if exists (overrides defaults)
CLAW_USER_CONFIG="$HOME/.config/claw-notes/config"
if [ -f "$CLAW_USER_CONFIG" ]; then
    source "$CLAW_USER_CONFIG"
fi

# Code paths (infrastructure - in git repo)
CLAW_DIR="$CLAW_ROOT/.claw"
CLAW_BIN="$CLAW_DIR/bin"
CLAW_LIB="$CLAW_DIR/lib"
CLAW_CONFIG="$CLAW_DIR/config"
CLAW_CACHE="$CLAW_DIR/cache"
CLAW_LOG="$CLAW_DIR/logs"

# Vault paths (user data - cloud-syncable, NOT in code repo)
VAULT_PAGES="$VAULT_ROOT/pages"
VAULT_JOURNALS="$VAULT_ROOT/journals"
VAULT_TRANSCRIPTS_RAW="$VAULT_ROOT/transcripts/raw"
VAULT_TRANSCRIPTS_CLEAN="$VAULT_ROOT/transcripts/cleaned"
VAULT_SUMMARIES="$VAULT_ROOT/summaries"
VAULT_ASSETS="$VAULT_ROOT/assets"
VAULT_TEMPLATES="$VAULT_ROOT/templates"

# OpenClaw settings
OPENCLAW_HOST="${OPENCLAW_HOST:-127.0.0.1}"
OPENCLAW_PORT="${OPENCLAW_PORT:-3000}"

# Whisper settings
WHISPER_MODEL="${WHISPER_MODEL:-base}"
WHISPER_LANGUAGE="${WHISPER_LANGUAGE:-en}"

# Recording settings
RECORD_FORMAT="${RECORD_FORMAT:-m4a}"
RECORD_LIMIT="${RECORD_LIMIT:-300}"  # 5 minutes default

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_ok() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Ensure directories exist
ensure_dirs() {
    # Vault directories (user data)
    mkdir -p "$VAULT_PAGES" "$VAULT_JOURNALS" "$VAULT_TRANSCRIPTS_RAW" \
             "$VAULT_TRANSCRIPTS_CLEAN" "$VAULT_SUMMARIES" "$VAULT_ASSETS" \
             "$VAULT_TEMPLATES"
    # Code directories (infrastructure)
    mkdir -p "$CLAW_CACHE" "$CLAW_LOG"
}

# Ensure vault is initialized with templates
ensure_vault() {
    ensure_dirs
    # Copy templates from code repo if vault templates are empty
    if [ -d "$CLAW_ROOT/templates" ] && [ ! -f "$VAULT_TEMPLATES/note.md" ]; then
        cp -r "$CLAW_ROOT/templates/"* "$VAULT_TEMPLATES/" 2>/dev/null || true
    fi
}

# Generate timestamp
timestamp() {
    date '+%Y-%m-%d_%H-%M-%S'
}

# Generate date for journal
today() {
    date '+%Y-%m-%d'
}

# Check if running in Termux
is_termux() {
    [ "$CLAW_ENV" = "termux" ]
}

# Check if OpenClaw is running
openclaw_running() {
    pgrep -f "openclaw" > /dev/null 2>&1
}

# Notification helpers (no-op on non-Termux)
notify() {
    local title="$1"
    local content="$2"
    local id="${3:-claw}"
    if is_termux && command -v termux-notification &> /dev/null; then
        termux-notification --id "$id" --title "$title" --content "$content"
    fi
}

notify_ongoing() {
    local title="$1"
    local content="$2"
    local id="${3:-claw}"
    if is_termux && command -v termux-notification &> /dev/null; then
        termux-notification --id "$id" --title "$title" --content "$content" --ongoing
    fi
}

notify_clear() {
    local id="${1:-claw}"
    if is_termux && command -v termux-notification-remove &> /dev/null; then
        termux-notification-remove "$id"
    fi
}

toast() {
    if is_termux && command -v termux-toast &> /dev/null; then
        termux-toast "$1"
    else
        echo "$1"
    fi
}
