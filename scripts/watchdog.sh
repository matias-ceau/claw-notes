#!/data/data/com.termux/files/usr/bin/bash
#
# OpenClaw Watchdog Script
# Monitors OpenClaw process and restarts if crashed
#
# Usage:
#   ./watchdog.sh [--daemon]
#
# Options:
#   --daemon    Run in background mode
#

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HIJACK_JS="${HOME}/.openclaw/hijack.js"
CHECK_INTERVAL=300  # 5 minutes
LOG_FILE="${HOME}/.openclaw/watchdog.log"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

start_openclaw() {
    log "Starting OpenClaw..."
    node -r "$HIJACK_JS" "$(which openclaw)" gateway &
    local pid=$!
    log "OpenClaw started with PID: $pid"
}

check_openclaw() {
    if pgrep -f "openclaw" > /dev/null; then
        return 0  # Running
    else
        return 1  # Not running
    fi
}

run_watchdog() {
    log "Watchdog started"

    # Acquire wake lock
    if command -v termux-wake-lock &> /dev/null; then
        termux-wake-lock
        log "Wake lock acquired"
    fi

    # Initial start if not running
    if ! check_openclaw; then
        start_openclaw
    fi

    # Monitor loop
    while true; do
        sleep "$CHECK_INTERVAL"

        if ! check_openclaw; then
            log "OpenClaw not running, restarting..."
            start_openclaw
        fi
    done
}

# Main
case "${1:-}" in
    --daemon)
        log "Starting watchdog in daemon mode"
        run_watchdog &
        disown
        log "Watchdog daemonized with PID: $!"
        ;;
    --status)
        if check_openclaw; then
            echo "OpenClaw is running"
            pgrep -af "openclaw"
            exit 0
        else
            echo "OpenClaw is NOT running"
            exit 1
        fi
        ;;
    --stop)
        log "Stopping OpenClaw and watchdog..."
        pkill -f "watchdog.sh" 2>/dev/null
        pkill -f "openclaw" 2>/dev/null
        log "Stopped"
        ;;
    --help)
        echo "OpenClaw Watchdog"
        echo ""
        echo "Usage: $0 [option]"
        echo ""
        echo "Options:"
        echo "  (none)     Run watchdog in foreground"
        echo "  --daemon   Run watchdog in background"
        echo "  --status   Check if OpenClaw is running"
        echo "  --stop     Stop OpenClaw and watchdog"
        echo "  --help     Show this help"
        ;;
    *)
        run_watchdog
        ;;
esac
