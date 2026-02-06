# Claw Notes

Always-on AI assistant for Android. Voice notes, quick capture, WhatsApp integration.

## How It Works

Your phone becomes a smart notes device:
- **Tap widget** → Record voice → AI transcribes and saves it
- **Message WhatsApp** → Assistant responds, saves to vault
- **Notification actions** → Quick note, sync, ask questions

No terminal needed. Everything via widgets and notifications.

## Setup

```bash
# In Termux (from F-Droid, NOT Play Store)
termux-setup-storage
cd ~
git clone <this-repo> claw-notes
cd claw-notes
bash setup.sh
```

Setup will:
- Install dependencies (Node.js, etc.)
- Ask where to store your notes (default: `~/storage/shared/Documents/ClawNotes-Vault`)
- Configure API keys for transcription
- Copy widgets to home screen
- Install boot script for auto-start

## Architecture

**Code and data are separate:**

| What | Location | Sync |
|------|----------|------|
| Code (this repo) | `~/claw-notes` | Git |
| Your notes | `~/storage/shared/Documents/ClawNotes-Vault` | Your choice (Syncthing, Google Drive, etc.) |

This keeps your private notes out of the code repo.

## Home Screen Widgets

After setup, add Termux:Widget to your home screen:

| Widget | Action |
|--------|--------|
| **Record Voice** | One-tap recording → sends to OpenClaw for transcription |
| **Quick Note** | Dialog for quick text capture |
| **Journal** | Add to today's journal |
| **Ask Assistant** | Quick question → AI response via notification |
| **Sync** | Git commit and push (code repo) |
| **Status** | Show system status |
| **Vault Info** | Show vault location for cloud sync setup |
| **Update Widgets** | Refresh widgets after `git pull` |

## Cloud Sync (Optional)

Your vault is a regular folder. Sync it with any app:
- **Syncthing** (recommended, open source, F-Droid)
- **FolderSync** (supports 20+ cloud providers)
- **Google Drive** / **Dropbox** app

Just point your sync app at: `~/storage/shared/Documents/ClawNotes-Vault`

## WhatsApp Integration

OpenClaw connects to WhatsApp. Message your assistant to:
- Ask questions
- Send voice notes for transcription
- Get reminders
- Search your notes

Run `openclaw onboard` after setup to connect.

## Vault Structure

Your notes are stored separately from code:

```
ClawNotes-Vault/
├── pages/              # Topic notes
├── journals/           # Daily journal (YYYY-MM-DD.md)
├── transcripts/
│   ├── raw/            # Direct speech-to-text
│   └── cleaned/        # AI-processed (coherent)
├── summaries/          # AI summaries
└── assets/             # Audio files (not synced)
```

## Requirements

From F-Droid (not Play Store):
- **Termux** - Linux environment
- **Termux:API** - Android integration
- **Termux:Widget** - Home screen shortcuts
- **Termux:Boot** - Auto-start (optional but recommended)

## Auto-Start

Setup automatically installs the boot script. Just install **Termux:Boot** from F-Droid and the assistant starts when your phone boots.

## API Keys Required

Transcription uses cloud APIs (local Whisper doesn't work on Termux):
- **OpenAI API key** (recommended) - for Whisper transcription
- **OpenRouter API key** (optional) - alternative provider

Setup will prompt for these keys.

## Updating

```bash
cd ~/claw-notes
git pull
~/.shortcuts/Update\ Widgets   # or tap "Update Widgets" widget
```

## For Developers

See [AGENT.md](AGENT.md) for technical details and how to extend.

## License

MIT
