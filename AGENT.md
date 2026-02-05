# AGENT.md

Context for AI agents working on this system.

## Purpose

Claw Notes is an **always-on AI assistant platform** for Android, not a CLI tool. The vault stores what the assistant learns and creates. OpenClaw is the brain - it runs 24/7 and integrates with WhatsApp, notifications, and other channels.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        User Interfaces                       │
├──────────────┬──────────────┬──────────────┬────────────────┤
│   WhatsApp   │   Widgets    │ Notifications│   Share Menu   │
│  (primary)   │  (one-tap)   │   (status)   │   (capture)    │
└──────┬───────┴──────┬───────┴──────┬───────┴───────┬────────┘
       │              │              │               │
       └──────────────┴──────────────┴───────────────┘
                              │
                    ┌─────────▼─────────┐
                    │     OpenClaw      │
                    │   (always-on)     │
                    │  127.0.0.1:3000   │
                    └─────────┬─────────┘
                              │
              ┌───────────────┼───────────────┐
              ▼               ▼               ▼
        ┌──────────┐   ┌──────────┐   ┌──────────┐
        │  Whisper │   │   LLM    │   │  Vault   │
        │ (speech) │   │ (brain)  │   │ (memory) │
        └──────────┘   └──────────┘   └──────────┘
```

## Key Principle

**The user never touches the terminal.** Everything happens through:
- WhatsApp messages to the assistant
- Home screen widget taps
- Notification actions
- Share menu (share audio/text to Claw)

The CLI exists only as infrastructure that powers these interfaces.

## File Structure

```
claw-notes/
├── .shortcuts/              ← Termux:Widget (HOME SCREEN)
│   ├── Record Voice         ← One-tap record
│   ├── Ask Assistant        ← Open WhatsApp/chat
│   ├── Quick Note           ← Dialog → save note
│   ├── Sync                 ← Git push
│   └── tasks/               ← Background tasks
├── .claw/                   ← Infrastructure (hidden)
│   ├── bin/                 ← CLI tools
│   ├── lib/                 ← Shared code
│   ├── boot/                ← Auto-start
│   ├── hooks/               ← OpenClaw webhooks
│   └── config/              ← Settings
├── pages/journals/etc.      ← Vault (assistant's memory)
└── AGENT.md                 ← This file
```

## OpenClaw Integration

OpenClaw is the core. It must always be running.

### Channels
- **WhatsApp**: Primary interface via OpenClaw's WhatsApp bridge
- **Telegram**: Alternative if configured
- **API**: `http://127.0.0.1:3000/v1/chat/completions`

### Webhooks
OpenClaw can trigger scripts in `.claw/hooks/`:
- `on-message.sh` - When user sends message
- `on-voice.sh` - When voice note received
- `on-reminder.sh` - Scheduled reminders

## Android Constraints

### System Error 13
Android blocks `os.networkInterfaces()`. The `hijack.js` shim mocks it:
```javascript
const os = require('os');
os.networkInterfaces = () => ({});
```

### Network
Use `127.0.0.1` only. Wildcard `0.0.0.0` crashes on non-rooted Android.

### Background Processes
Android kills idle processes. Solutions:
- `termux-wake-lock` during operations
- Watchdog auto-restart in `.claw/boot/`
- Foreground notification to prevent kill

### Storage
SAF (Scoped Access Framework) via `termux-setup-storage`.
Vault at `~/storage/shared/Documents/claw-notes`.

## Mobile UX Commands

These power the widgets (user never types these):

```bash
# Widget: Record Voice
termux-microphone-record -l 300 -f "$ASSETS/recording.m4a"
termux-notification -t "Recording..." --ongoing
# ... then transcribe + process

# Widget: Quick Note
text=$(termux-dialog text -t "Quick Note" | jq -r '.text')
# ... save to vault

# Widget: Ask Assistant
termux-open-url "https://wa.me/..."  # Or OpenClaw chat URL

# Notification feedback (not terminal)
termux-notification -t "Note saved" -c "Meeting notes processed"
termux-toast "Synced!"
```

## Vault Format

Markdown with YAML frontmatter, compatible with Logseq/Obsidian:

```markdown
---
type: note|journal|transcript|summary
created: 2026-02-05T10:30:00Z
source: voice|whatsapp|widget|manual
tags: []
---

# Title

Content with [[wikilinks]] and #tags
```

## Adding Features

### New Widget
1. Create script in `.shortcuts/NewWidget`
2. Use `termux-dialog` for input
3. Use `termux-notification` for feedback
4. Never require terminal interaction

### New Webhook
1. Create script in `.claw/hooks/on-event.sh`
2. Configure in OpenClaw
3. Process silently, notify on completion

### New Command (infrastructure only)
1. Create `.claw/bin/claw-newcmd`
2. Source `../lib/config.sh`
3. Add to `.claw/bin/claw` dispatch
4. Wire to widget or webhook

## Critical Behaviors

1. **OpenClaw must always run** - Watchdog ensures this
2. **No terminal output for users** - Use notifications/toasts
3. **Fail silently with notification** - Don't break the experience
4. **Auto-sync regularly** - User shouldn't think about git
5. **Process voice async** - Record fast, process in background
