# Claw Notes

Voice-to-markdown notes system for Android using OpenClaw, Termux, and AI-powered transcription.

## Overview

Claw Notes captures voice notes on Android, transcribes them using AI, and saves them as markdown files compatible with [Logseq](https://logseq.com/) and [Obsidian](https://obsidian.md/). Notes are synced via Git for version control and backup.

## Approach Comparison

Three implementation approaches were explored during development:

| Feature | Approach 1: Boot Persistence | Approach 2: Whisper + AI | Approach 3: Compact SAF |
|---------|------------------------------|--------------------------|-------------------------|
| **Complexity** | Moderate | High | Low |
| **Auto-restart** | Yes (watchdog) | Yes | No |
| **Transcription** | Basic | Whisper + LLM cleanup | Basic |
| **Output** | Single markdown | Raw + Cleaned + Summary | Single markdown |
| **Setup time** | ~15 min | ~30 min | ~10 min |
| **Dependencies** | Node.js, Termux:API, Termux:Boot | + Python, FFmpeg, Whisper | Node.js, Termux:API |

### Recommendation: Tiered Approach

**Start with Approach 3** (Compact SAF) for quick deployment, then optionally upgrade:

1. **Quick Start** - Approach 3: Minimal setup, get started immediately
2. **Production** - Approach 1: Add boot persistence when you need reliability
3. **Power User** - Approach 2: Add Whisper when you need transcript cleanup from ramblings

## Quick Start (Approach 3 - Recommended)

### Prerequisites

- Android device with [Termux](https://f-droid.org/packages/com.termux/) from F-Droid
- [Termux:API](https://f-droid.org/packages/com.termux.api/) from F-Droid

### Installation

```bash
# [1/7] Update packages
pkg update && pkg upgrade -y

# [2/7] Install dependencies
pkg install -y nodejs-lts git termux-api

# [3/7] Configure storage access
termux-setup-storage

# [4/7] Install OpenClaw
npm install -g openclaw

# [5/7] Create Android compatibility shim
mkdir -p ~/.openclaw
cat > ~/.openclaw/hijack.js << 'EOF'
const os = require('os');
os.networkInterfaces = () => ({});
EOF

# [6/7] Configure OpenClaw
openclaw config set gateway.host 127.0.0.1
openclaw config set gateway.port 3000

# [7/7] Start OpenClaw
node -r ~/.openclaw/hijack.js $(which openclaw) gateway
```

### Setting Up Notes Directory

```bash
# Create notes directory with SAF access
mkdir -p ~/storage/shared/Documents/claw-notes

# Initialize git repo
cd ~/storage/shared/Documents/claw-notes
git init
```

## Production Setup (Approach 1)

Add boot persistence to automatically restart on crashes:

```bash
# Install Termux:Boot from F-Droid
pkg install termux-services

# Create boot script
mkdir -p ~/.termux/boot
cat > ~/.termux/boot/start-openclaw.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
termux-wake-lock

# Start OpenClaw
node -r ~/.openclaw/hijack.js $(which openclaw) gateway &

# Watchdog - restart if crashed
while true; do
  sleep 300
  if ! pgrep -f "openclaw"; then
    node -r ~/.openclaw/hijack.js $(which openclaw) gateway &
  fi
done &
EOF

chmod +x ~/.termux/boot/start-openclaw.sh
```

## Power User Setup (Approach 2)

Add Whisper for intelligent transcript processing:

```bash
# Install additional dependencies
pkg install -y python ffmpeg

# Install Whisper
pip install openai-whisper

# Create vault structure
mkdir -p ~/storage/shared/Documents/claw-notes/{pages,journals,transcripts/{raw,cleaned},assets}
```

### Vault Structure

```
claw-notes/
├── pages/           # Topic-based notes
├── journals/        # Daily notes
├── transcripts/
│   ├── raw/         # Unprocessed Whisper output
│   └── cleaned/     # LLM-processed transcripts
├── assets/          # Audio files, images
└── summaries/       # AI-generated summaries
```

## Technical Notes

### Android Compatibility

The `hijack.js` shim is required because Android blocks `os.networkInterfaces()` on non-rooted devices (System Error 13). The shim mocks this function.

### Network Binding

Use `127.0.0.1` (loopback) instead of `0.0.0.0` to avoid crashes on non-rooted Android.

### Wake Lock

Use `termux-wake-lock` to prevent Android from killing the process during audio processing.

## Workflow

1. **Capture**: Record voice note using Termux:API microphone
2. **Transcribe**: Process audio with Whisper (Approach 2) or basic recognition
3. **Clean**: Optionally process with OpenClaw LLM for coherent output
4. **Save**: Write markdown to notes directory
5. **Sync**: Git commit and push

## Compatibility

- **Note Apps**: Logseq, Obsidian, any markdown-based PKM
- **Android**: 7.0+ (Termux requirement)
- **Storage**: Uses Android SAF (Scoped Access Framework) for Documents folder access

## License

MIT

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.
