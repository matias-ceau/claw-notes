# AGENT.md

Context for AI agents working on this system.

## Purpose

Claw Notes is an **always-on AI assistant platform** for Android Termux. OpenClaw runs 24/7, handles transcription via cloud APIs, and integrates with WhatsApp. This vault is OpenClaw's workspace and memory.

## Architecture

**Key Design: Code and Data are separate.**

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
        ┌──────────┐   ┌──────────┐   ┌──────────────────┐
        │ Whisper  │   │   LLM    │   │      Vault       │
        │(cloud API)│   │ (brain)  │   │ (separate from   │
        └──────────┘   └──────────┘   │  code, cloud-    │
                                      │  syncable)       │
                                      └──────────────────┘
```

### Separation of Concerns

| Component | Location | Sync Method |
|-----------|----------|-------------|
| **Code** (scripts, widgets) | `~/claw-notes/` (this repo) | Git |
| **Data** (notes, journals) | `~/storage/shared/Documents/ClawNotes-Vault/` | Sync app (Syncthing, etc.) |
| **Config** (API keys) | `~/.config/claw-notes/` + `~/.openclaw/` | Manual backup |

This separation allows:
- Public code repo without exposing personal notes
- Cloud sync of vault via rclone (built-in) or third-party apps
- Easy backup and restore of user data
- Multiple devices sharing the same vault

### Cloud Sync Options

**Option 1: Built-in rclone sync (recommended)**
- CLI: `claw-sync setup` → `claw-sync sync`
- Widget: Tap "Cloud Sync" → choose Push/Pull/Sync
- Supports: Google Drive, Dropbox, Mega, OneDrive, 40+ providers
- Bidirectional sync with conflict handling

**Option 2: Third-party apps**
- Syncthing (F-Droid) - P2P sync
- FolderSync, Dropsync - Scheduled sync
- Google Drive, Dropbox apps - Native sync

## Key Principle

**The user never touches the terminal.** Everything happens through:
- WhatsApp messages (send voice notes directly!)
- Home screen widget taps
- Notification actions

The CLI exists only as infrastructure.

## OpenClaw Does the Heavy Lifting

OpenClaw already handles:
- **Audio transcription** via its media pipeline (OpenAI Whisper API, Groq, Deepgram)
- **WhatsApp integration** via Baileys
- **60+ PKM skills** including Logseq integration
- **44 speech/transcription skills**
- **Model-agnostic LLM** (OpenAI, OpenRouter, local models)

Don't reinvent these. Configure and use them:

```json
// ~/.openclaw/openclaw.json
{
  "tools": {
    "media": {
      "audio": {
        "enabled": true,
        "models": [
          { "provider": "openai", "model": "whisper-1" }
        ]
      }
    }
  }
}
```

See: [OpenClaw Audio Docs](https://docs.openclaw.ai/nodes/audio)

## File Structure

### Code Repository (`~/claw-notes/`)

```
claw-notes/                      ← PUBLIC (git repo)
├── .shortcuts/                  ← Termux:Widget (HOME SCREEN)
│   ├── Record Voice             ← Record → send to OpenClaw
│   ├── Quick Note               ← Dialog → save to vault
│   ├── Journal                  ← Add to today's journal
│   ├── Ask Assistant            ← Query OpenClaw
│   ├── Sync                     ← Git commit/push (code)
│   ├── Vault Info               ← Show vault location for syncing
│   ├── Status                   ← Show system status
│   ├── Update Widgets           ← Refresh widgets after git pull
│   └── tasks/                   ← Background processing
├── .claw/
│   ├── boot/                    ← Auto-start scripts
│   │   ├── watchdog.sh          ← Keeps OpenClaw alive
│   │   └── start-claw.sh        ← Boot script (copied to ~/.termux/boot/)
│   ├── bin/                     ← CLI tools
│   │   └── update-widgets       ← Re-copy widgets to ~/.shortcuts/
│   ├── lib/                     ← Shared config
│   ├── skills/                  ← Workspace skills
│   └── config/                  ← OpenClaw config template
├── templates/                   ← Note templates (copied to vault)
├── setup.sh                     ← First-run setup
└── AGENT.md                     ← This file
```

### Vault (`~/storage/shared/Documents/ClawNotes-Vault/`)

```
ClawNotes-Vault/                 ← PRIVATE (cloud-synced)
├── pages/                       ← Topic notes
├── journals/                    ← Daily journals (YYYY-MM-DD.md)
├── transcripts/
│   ├── raw/                     ← Direct Whisper output
│   └── cleaned/                 ← LLM-processed transcripts
├── summaries/                   ← AI-generated summaries
├── assets/                      ← Audio files (NOT synced to cloud)
└── templates/                   ← Note templates
```

### User Config (`~/.config/claw-notes/`)

```bash
# ~/.config/claw-notes/config
CLAW_ROOT="/path/to/claw-notes"      # Code location
VAULT_ROOT="/path/to/vault"          # Data location
```

## Transcription Flow

**Option 1: WhatsApp (recommended)**
1. Send voice note to your assistant on WhatsApp
2. OpenClaw auto-transcribes via configured provider
3. Assistant responds with transcript and can save to vault

**Option 2: Widget**
1. Tap "Record Voice" widget
2. Recording saved to `assets/`
3. Sent to OpenClaw API for transcription
4. Saved to `transcripts/`

**NOT**: Local Whisper (doesn't work on Termux)

## Android Constraints

### System Error 13
Android blocks `os.networkInterfaces()`. The `hijack.js` shim mocks it:
```javascript
const os = require('os');
os.networkInterfaces = () => ({});
```

### Network
Use `127.0.0.1` only. Never `0.0.0.0` on non-rooted Android.

### Background Processes
Android kills idle processes. Solutions:
- Foreground notification (persistent)
- `termux-wake-lock` during operations
- Watchdog auto-restart in `.claw/boot/`

### Storage
SAF via `termux-setup-storage`. Vault at `~/storage/shared/Documents/ClawNotes-Vault/`.

### Termux:Widget
Widget scripts must be **copied** (not symlinked) to `~/.shortcuts/`:
- Symlinks to external paths don't work (canonical path check)
- Directory permissions must be `700`
- Refresh widget on home screen after changes

Setup copies scripts automatically. After `git pull`, update widgets:
```bash
~/claw-notes/.claw/bin/update-widgets   # Or tap "Update Widgets" widget
```

## Cloud Sync

The vault is a standard folder in Android shared storage. Sync options:

### Option 1: Built-in rclone (Recommended)

**Setup:**
```bash
pkg install rclone
claw-sync setup  # Interactive config for cloud provider
```

**Usage:**
- CLI: `claw-sync sync` (bidirectional), `claw-sync push`, `claw-sync pull`
- Widget: Tap "Cloud Sync" → choose operation
- Supports 40+ providers: Google Drive, Dropbox, Mega, OneDrive, pCloud, etc.

**Features:**
- Bidirectional sync with conflict detection
- Interactive setup via widgets (no terminal needed)
- Progress notifications
- Excludes `.git/`, `*.tmp`, `.DS_Store` automatically

### Option 2: Third-Party Apps

| App | Type | Notes |
|-----|------|-------|
| **Syncthing** | P2P | Open source, no cloud account needed, F-Droid |
| **FolderSync** | Cloud | Supports 20+ providers, Play Store |
| **Dropsync** | Dropbox | Dedicated Dropbox sync |
| **Google Drive** | Cloud | Built-in Android, auto-backup folders |

**Setup (Syncthing example):**
1. Install Syncthing from F-Droid
2. Add vault folder: `~/storage/shared/Documents/ClawNotes-Vault`
3. Connect to your other devices (PC, tablet, etc.)
4. Notes sync automatically in background

### What to Sync
- `pages/` - Notes
- `journals/` - Daily journals
- `transcripts/` - Voice transcripts
- `summaries/` - AI summaries
- `templates/` - Note templates

### Exclude from Sync
- `assets/` - Audio files (large, keep local only)

## Adding Features

### Use OpenClaw Skills First
Before building custom:
1. Check [awesome-openclaw-skills](https://github.com/VoltAgent/awesome-openclaw-skills)
2. Install: `npx clawhub@latest install <skill-slug>`
3. 1700+ community skills available

### New Widget
1. Create script in `.shortcuts/NewWidget`
2. Use `termux-dialog` for input
3. Use `termux-notification` for feedback
4. Call OpenClaw API or save directly to vault

### New Skill (for OpenClaw)
1. Create `.claw/skills/<name>/SKILL.md`
2. Define commands and triggers
3. OpenClaw auto-discovers workspace skills

## Critical Behaviors

1. **OpenClaw must always run** - Watchdog ensures this
2. **No terminal for users** - Everything via widgets/WhatsApp
3. **Use cloud APIs** - Local Whisper doesn't work on Termux
4. **Leverage OpenClaw skills** - Don't reinvent PKM features
5. **Notification feedback** - No terminal output

## Relevant Links

- [OpenClaw Docs](https://docs.openclaw.ai/)
- [Audio Transcription](https://docs.openclaw.ai/nodes/audio)
- [Awesome Skills](https://github.com/VoltAgent/awesome-openclaw-skills)
- [OpenAI Whisper API](https://platform.openai.com/docs/api-reference/audio)
