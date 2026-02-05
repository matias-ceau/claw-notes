#!/data/data/com.termux/files/usr/bin/bash
#
# Claw Notes - Termux:Boot Startup Script
#
# Copy this to ~/.termux/boot/ for auto-start on device boot:
#   cp /path/to/claw-notes/.claw/boot/start-claw.sh ~/.termux/boot/
#   chmod +x ~/.termux/boot/start-claw.sh

# Find claw-notes location
CLAW_LOCATIONS=(
    "$HOME/storage/shared/Documents/claw-notes"
    "$HOME/claw-notes"
    "/sdcard/Documents/claw-notes"
)

CLAW_ROOT=""
for loc in "${CLAW_LOCATIONS[@]}"; do
    if [ -d "$loc/.claw" ]; then
        CLAW_ROOT="$loc"
        break
    fi
done

if [ -z "$CLAW_ROOT" ]; then
    echo "ERROR: claw-notes not found"
    exit 1
fi

# Start watchdog in daemon mode
"$CLAW_ROOT/.claw/boot/watchdog.sh" --daemon

echo "Claw Notes started from: $CLAW_ROOT"
