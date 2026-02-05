#!/data/data/com.termux/files/usr/bin/bash
# Claw Notes - Shared Configuration

# Detect environment
if [ -d "/data/data/com.termux" ]; then
    CLAW_ENV="termux"
    CLAW_ROOT="${CLAW_ROOT:-$HOME/storage/shared/Documents/claw-notes}"
else
    CLAW_ENV="linux"
    CLAW_ROOT="${CLAW_ROOT:-$HOME/claw-notes}"
fi

# Paths
CLAW_DIR="$CLAW_ROOT/.claw"
CLAW_BIN="$CLAW_DIR/bin"
CLAW_LIB="$CLAW_DIR/lib"
CLAW_CONFIG="$CLAW_DIR/config"
CLAW_CACHE="$CLAW_DIR/cache"
CLAW_LOG="$CLAW_DIR/logs"

# Vault paths
VAULT_PAGES="$CLAW_ROOT/pages"
VAULT_JOURNALS="$CLAW_ROOT/journals"
VAULT_TRANSCRIPTS_RAW="$CLAW_ROOT/transcripts/raw"
VAULT_TRANSCRIPTS_CLEAN="$CLAW_ROOT/transcripts/cleaned"
VAULT_SUMMARIES="$CLAW_ROOT/summaries"
VAULT_ASSETS="$CLAW_ROOT/assets"

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
    mkdir -p "$VAULT_PAGES" "$VAULT_JOURNALS" "$VAULT_TRANSCRIPTS_RAW" \
             "$VAULT_TRANSCRIPTS_CLEAN" "$VAULT_SUMMARIES" "$VAULT_ASSETS" \
             "$CLAW_CACHE" "$CLAW_LOG"
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
