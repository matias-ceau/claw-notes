# CLAUDE.md

Context for AI assistants working on this codebase.

## What This Is

Claw Notes is a voice-to-markdown system for Android Termux. The repo IS the vault - notes and tooling live together.

## Architecture

```
claw-notes/
├── pages/journals/transcripts/summaries/assets/  ← Actual notes (vault)
├── templates/                                     ← Note templates
└── .claw/                                         ← CLI tooling
    ├── bin/        claw, claw-record, claw-transcribe, claw-process, etc.
    ├── lib/        config.sh, hijack.js
    ├── boot/       watchdog.sh, start-claw.sh
    └── config/     (future: user config)
```

## Key Files

| File | Purpose |
|------|---------|
| `.claw/bin/claw` | Main entry point, dispatches to subcommands |
| `.claw/bin/claw-full` | Full pipeline: record → transcribe → process |
| `.claw/bin/claw-process` | Calls OpenClaw LLM for transcript cleanup |
| `.claw/lib/config.sh` | Shared configuration, paths, helpers |
| `.claw/lib/hijack.js` | Android compatibility shim for Node.js |
| `.claw/boot/watchdog.sh` | Auto-restart daemon |

## Pipeline

```
claw full meeting
    ↓
claw-record     → assets/meeting_*.m4a
    ↓
claw-transcribe → transcripts/raw/meeting_transcript.md
    ↓
claw-process    → transcripts/cleaned/meeting_cleaned.md
                → summaries/meeting_summary.md
```

## Android Constraints

### System Error 13
Android blocks `os.networkInterfaces()`. Solution: `hijack.js` shim that mocks it.

```javascript
const os = require('os');
os.networkInterfaces = () => ({});
```

### Network Binding
Use `127.0.0.1`, never `0.0.0.0`. Non-rooted Android crashes on wildcard binding.

### Wake Locks
Android kills background processes. Use `termux-wake-lock` for long operations.

### Storage
Uses SAF via `termux-setup-storage`. Vault lives at `~/storage/shared/Documents/claw-notes`.

## LLM Integration

`claw-process` calls OpenClaw's OpenAI-compatible API:

```bash
curl http://127.0.0.1:3000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"default","messages":[...]}'
```

Two prompts:
1. **Cleanup**: Fix filler words, false starts, make coherent
2. **Summary**: Extract key points, action items, suggest tags

## Markdown Format

All notes use YAML frontmatter + wikilinks for Logseq/Obsidian compatibility:

```markdown
---
type: transcript|note|journal|summary
created: ISO-8601
tags: []
---

# Title

Content with [[wikilinks]] and #tags
```

## Common Tasks

### Add a new subcommand
1. Create `.claw/bin/claw-newcmd`
2. Source `../lib/config.sh` for shared config
3. Add dispatch case in `.claw/bin/claw`

### Change Whisper model
Edit `WHISPER_MODEL` in `.claw/lib/config.sh` (tiny/base/small/medium/large)

### Change LLM prompts
Edit the prompt strings in `.claw/bin/claw-process`

## Testing

Test on actual Android hardware. Termux behavior differs from Linux:
- Storage permissions require SAF
- Network binding restrictions
- Process lifecycle management
