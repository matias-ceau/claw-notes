#!/data/data/com.termux/files/usr/bin/bash
#
# Claw Notes - Termux:Boot Startup Script
#
# This script is automatically installed to ~/.termux/boot/ by setup.sh
# It starts the Claw Notes assistant when your device boots.
#
# Requirements: Install Termux:Boot from F-Droid

# Load user config if exists
CLAW_USER_CONFIG="$HOME/.config/claw-notes/config"
if [ -f "$CLAW_USER_CONFIG" ]; then
    source "$CLAW_USER_CONFIG"
fi

# Fallback: search common locations
if [ -z "$CLAW_ROOT" ] || [ ! -d "$CLAW_ROOT/.claw" ]; then
    CLAW_LOCATIONS=(
        "$HOME/claw-notes"
        "$HOME/storage/shared/Documents/claw-notes"
        "/sdcard/Documents/claw-notes"
    )

    CLAW_ROOT=""
    for loc in "${CLAW_LOCATIONS[@]}"; do
        if [ -d "$loc/.claw" ]; then
            CLAW_ROOT="$loc"
            break
        fi
    done
fi

if [ -z "$CLAW_ROOT" ] || [ ! -d "$CLAW_ROOT/.claw" ]; then
    echo "ERROR: claw-notes not found"
    exit 1
fi

# Start watchdog in daemon mode
"$CLAW_ROOT/.claw/boot/watchdog.sh" --daemon

echo "Claw Notes started from: $CLAW_ROOT"
