# Claw Notes

Always-on AI assistant for Android. Voice notes, quick capture, WhatsApp integration.

## How It Works

Your phone becomes a smart notes device:
- **Tap widget** → Record voice → AI transcribes and cleans it up
- **Message WhatsApp** → Assistant responds, saves to vault
- **Notification actions** → Quick note, sync, ask questions

No terminal needed. Everything via widgets and notifications.

## Setup

```bash
# In Termux (from F-Droid, NOT Play Store)
termux-setup-storage
cd ~/storage/shared/Documents
git clone <this-repo> claw-notes
cd claw-notes
bash setup.sh
```

Setup installs dependencies, creates home screen widgets, and starts the assistant.

## Home Screen Widgets

After setup, add Termux:Widget to your home screen:

| Widget | Action |
|--------|--------|
| **Record Voice** | One-tap recording → sends to OpenClaw for transcription |
| **Quick Note** | Dialog for quick text capture |
| **Journal** | Add to today's journal |
| **Ask Assistant** | Quick question → AI response via notification |
| **Cloud Sync** | Sync vault to/from cloud (Google Drive, Dropbox, etc.) |
| **Sync** | Git commit and push (for code repo) |
| **Status** | Show system status |

## WhatsApp Integration

OpenClaw connects to WhatsApp. Message your assistant to:
- Ask questions
- Send voice notes for transcription
- Get reminders
- Search your notes

Configure in OpenClaw settings after setup.

## What Gets Created

**Architecture: Code and Data Separation**

```
Code (this repo):                   Data (your vault):
~/claw-notes/                       ~/storage/shared/Documents/ClawNotes-Vault/
├── .claw/                          ├── pages/              # Your notes
│   ├── bin/                        ├── journals/           # Daily journal
│   ├── lib/                        ├── transcripts/
│   └── boot/                       │   ├── raw/            # Speech-to-text
├── .shortcuts/                     │   └── cleaned/        # AI-processed
└── setup.sh                        ├── summaries/          # AI summaries
                                    ├── assets/             # Audio files
                                    └── templates/          # Note templates
```

This separation enables:
- **Public code repo** without exposing personal notes
- **Cloud sync** of vault only (Google Drive, Dropbox, etc.)
- **Multiple devices** sharing the same vault

## Cloud Sync

### Built-in rclone (Recommended)

```bash
pkg install rclone
claw-sync setup    # Interactive cloud setup
claw-sync sync     # Bidirectional sync
```

Or use the **Cloud Sync** widget for one-tap sync.

Supports 40+ providers: Google Drive, Dropbox, Mega, OneDrive, pCloud, Box, etc.

### Alternative: Third-party apps

- **Syncthing** (F-Droid) - P2P, no cloud account needed
- **FolderSync** - Schedule sync for 20+ cloud providers
- **Google Drive app** - Auto-backup folders

## Requirements

From F-Droid (not Play Store):
- **Termux** - Linux environment
- **Termux:API** - Android integration
- **Termux:Widget** - Home screen shortcuts
- **Termux:Boot** - Auto-start (optional)

## Auto-Start on Boot

Install Termux:Boot, then:
```bash
cp .claw/boot/start-claw.sh ~/.termux/boot/
```

The assistant starts automatically when your phone boots.

## Persistent Notification

When running, a notification stays in your tray with quick actions:
- Tap **Record** to start voice capture
- Tap **Note** for quick text entry

This also keeps Android from killing the background process.

## API Keys Required

Transcription uses cloud APIs (local Whisper doesn't work on Termux):
- **OpenAI API key** (recommended) - for Whisper transcription
- **OpenRouter API key** (optional) - alternative provider

Setup will prompt for these keys.

## Cloud Sync

Sync your vault to cloud storage (Google Drive, Dropbox, Mega, OneDrive, etc.):

```bash
# Configure cloud sync (first time)
claw-sync --setup

# Then use the Cloud Sync widget, or run:
claw cloud-sync
```

The Cloud Sync widget provides bidirectional sync, push-only, pull-only, and status options.

Alternatively, use third-party sync apps like Syncthing, FolderSync, or the Google Drive app.

## Offline Limitations

- Voice recording: Works offline (saves to assets/)
- Transcription: Requires internet (uses OpenAI Whisper API)
- AI responses: Requires internet
- Sync: Requires internet

## For Developers

See [AGENT.md](AGENT.md) for technical details and how to extend.

## License

MIT
