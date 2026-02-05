#!/data/data/com.termux/files/usr/bin/bash
#
# Claw Notes - OpenClaw Watchdog
# Monitors OpenClaw and restarts on crash
#
# Usage:
#   ./watchdog.sh [--daemon|--status|--stop|--help]

# Find claw root (parent of .claw)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAW_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CLAW_LIB="$CLAW_ROOT/.claw/lib"
CLAW_LOG="$CLAW_ROOT/.claw/logs"

HIJACK_JS="$CLAW_LIB/hijack.js"
CHECK_INTERVAL=300  # 5 minutes
LOG_FILE="$CLAW_LOG/watchdog.log"

mkdir -p "$CLAW_LOG"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

show_notification() {
    if command -v termux-notification &> /dev/null; then
        termux-notification \
            --id claw-assistant \
            --title "Claw Assistant" \
            --content "Running - tap for options" \
            --ongoing \
            --button1 "Record" \
            --button1-action "$CLAW_ROOT/.shortcuts/Record Voice" \
            --button2 "Note" \
            --button2-action "$CLAW_ROOT/.shortcuts/Quick Note"
    fi
}

clear_notification() {
    if command -v termux-notification-remove &> /dev/null; then
        termux-notification-remove claw-assistant
    fi
}

start_openclaw() {
    log "Starting OpenClaw..."
    if [ -f "$HIJACK_JS" ]; then
        node -r "$HIJACK_JS" "$(which openclaw)" gateway &
    else
        openclaw gateway &
    fi
    local pid=$!
    log "OpenClaw started with PID: $pid"
    show_notification
}

check_openclaw() {
    pgrep -f "openclaw" > /dev/null 2>&1
}

run_watchdog() {
    log "Watchdog started (CLAW_ROOT: $CLAW_ROOT)"

    # Acquire wake lock on Termux
    if command -v termux-wake-lock &> /dev/null; then
        termux-wake-lock
        log "Wake lock acquired"
    fi

    # Initial start
    if ! check_openclaw; then
        start_openclaw
    fi

    # Monitor loop
    while true; do
        sleep "$CHECK_INTERVAL"
        if ! check_openclaw; then
            log "OpenClaw crashed, restarting..."
            start_openclaw
        fi
    done
}

case "${1:-}" in
    --daemon)
        log "Daemonizing watchdog..."
        run_watchdog &
        disown
        log "Watchdog PID: $!"
        ;;
    --status)
        if check_openclaw; then
            echo "OpenClaw: RUNNING"
            pgrep -af "openclaw"
        else
            echo "OpenClaw: STOPPED"
            exit 1
        fi
        ;;
    --stop)
        log "Stopping..."
        pkill -f "watchdog.sh" 2>/dev/null
        pkill -f "openclaw" 2>/dev/null
        clear_notification
        if command -v termux-wake-unlock &> /dev/null; then
            termux-wake-unlock
        fi
        log "Stopped"
        ;;
    --help)
        echo "Claw Notes Watchdog"
        echo ""
        echo "Usage: $0 [option]"
        echo "  (none)    Run in foreground"
        echo "  --daemon  Run in background"
        echo "  --status  Check OpenClaw status"
        echo "  --stop    Stop OpenClaw and watchdog"
        ;;
    *)
        run_watchdog
        ;;
esac
