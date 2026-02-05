# Claw Notes

Voice-to-markdown notes for Android. Record → Transcribe → Clean → Sync.

## What It Does

1. **Record** voice notes on your phone
2. **Transcribe** with Whisper (local, offline)
3. **Clean up** rambling transcripts with LLM
4. **Sync** to git for backup and cross-device access

Works with Logseq, Obsidian, or any markdown-based PKM.

## Quick Start

```bash
# Clone to your Android device (in Termux)
cd ~/storage/shared/Documents
git clone <this-repo> claw-notes
cd claw-notes

# Run setup
bash setup.sh

# Add to PATH
export PATH="$PATH:$(pwd)/.claw/bin"

# Record your first note
claw full my-first-note
```

## Commands

```bash
claw record [name]     # Record voice note
claw full [name]       # Full pipeline: record → transcribe → process
claw transcribe <file> # Transcribe audio with Whisper
claw process <file>    # Clean transcript with LLM
claw journal [text]    # Add to today's journal
claw note <title>      # Create quick text note
claw sync [message]    # Git commit and push
claw start             # Start OpenClaw gateway
claw stop              # Stop gateway
claw status            # Show system status
```

## Structure

```
claw-notes/
├── pages/              # Topic notes
├── journals/           # Daily notes (YYYY-MM-DD.md)
├── transcripts/
│   ├── raw/            # Direct Whisper output
│   └── cleaned/        # LLM-processed versions
├── summaries/          # AI-generated summaries
├── assets/             # Audio files, images
├── templates/          # Note templates
└── .claw/              # CLI tooling (hidden)
```

## Requirements

- Android with Termux (from F-Droid)
- Termux:API (from F-Droid)
- Node.js, Python, FFmpeg, Whisper, OpenClaw

## Output Example

One voice recording produces three files:

| File | Purpose |
|------|---------|
| `transcripts/raw/idea_transcript.md` | Exact Whisper output |
| `transcripts/cleaned/idea_cleaned.md` | Coherent, readable version |
| `summaries/idea_summary.md` | Key points + action items |

## Auto-Start

For automatic startup on boot (requires Termux:Boot):

```bash
cp .claw/boot/start-claw.sh ~/.termux/boot/
chmod +x ~/.termux/boot/start-claw.sh
```

## Documentation

- [[pages/welcome]] - Getting started
- [[pages/workflow]] - How the pipeline works
- [[pages/setup]] - Detailed installation

## License

MIT
