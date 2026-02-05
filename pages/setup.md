---
type: note
title: Setup Guide
created: 2026-02-05T00:00:00Z
tags: [meta, setup, termux]
---

# Setup Guide

## Requirements

- Android 7.0+
- From **F-Droid** (not Play Store):
  - Termux
  - Termux:API
  - Termux:Boot (optional, for auto-start)

## Installation

### 1. Install Dependencies

```bash
pkg update && pkg upgrade -y
pkg install -y nodejs-lts git termux-api python ffmpeg jq
pip install openai-whisper
npm install -g openclaw
```

### 2. Setup Storage

```bash
termux-setup-storage
# Grant permission in popup
```

### 3. Clone/Move Vault

```bash
cd ~/storage/shared/Documents
git clone <your-repo-url> claw-notes
# OR move existing:
# mv /path/to/claw-notes ~/storage/shared/Documents/
```

### 4. Add to PATH

```bash
echo 'export PATH="$PATH:$HOME/storage/shared/Documents/claw-notes/.claw/bin"' >> ~/.bashrc
source ~/.bashrc
```

### 5. Configure OpenClaw

```bash
openclaw config set gateway.host 127.0.0.1
openclaw config set gateway.port 3000
```

### 6. Test

```bash
claw status
claw start
```

## Auto-Start (Optional)

For automatic startup on boot:

```bash
mkdir -p ~/.termux/boot
cp ~/storage/shared/Documents/claw-notes/.claw/boot/start-claw.sh ~/.termux/boot/
chmod +x ~/.termux/boot/start-claw.sh
```

Then open Termux:Boot once to register.

## Troubleshooting

### System Error 13

Android blocks `os.networkInterfaces()`. The hijack.js shim handles this automatically.

### Process Killed

Android battery optimization kills background processes. Solutions:
1. Use `termux-wake-lock`
2. Disable battery optimization for Termux
3. Use Termux:Boot for auto-restart

### Storage Permission Denied

Run `termux-setup-storage` and grant permission.

## Links

- [[welcome]] - Getting started
- [[workflow]] - How it works

#setup #termux #meta
