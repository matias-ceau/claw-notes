# CLAUDE.md - AI Assistant Context

This file provides context for AI assistants working on this codebase.

## Project Overview

Claw Notes is a voice-to-markdown notes system for Android Termux using OpenClaw AI. It captures voice notes, transcribes them, and saves as markdown compatible with Logseq and Obsidian.

## Key Technical Constraints

### Android Termux Environment

- **No root access assumed**: All code must work on non-rooted Android
- **System Error 13**: Android blocks `os.networkInterfaces()` - use the hijack.js shim:
  ```javascript
  const os = require('os');
  os.networkInterfaces = () => ({});
  ```
- **Network binding**: Always use `127.0.0.1`, never `0.0.0.0`
- **Wake locks**: Long-running processes need `termux-wake-lock`

### Required Apps (from F-Droid, NOT Google Play)

- Termux
- Termux:API
- Termux:Boot (for persistence)

### Storage Access

- Uses SAF (Scoped Access Framework) via `termux-setup-storage`
- Notes stored at `~/storage/shared/Documents/claw-notes`
- Git sync for version control

## Architecture Decisions

| Decision | Rationale |
|----------|-----------|
| Native Termux (not proot-distro) | Avoids filesystem overhead, PATH complexity, and awkward API escaping |
| Termux:API as foundation | Provides native Android primitives; Tasker is just a bridge |
| 127.0.0.1 loopback only | Non-rooted Android crashes with 0.0.0.0 gateway binding |
| hijack.js shim | Required workaround for Android kernel blocking os.networkInterfaces() |

## Three Implementation Approaches

See `dev/` for conversation history. Summary:

1. **Approach 1** (`threads-export-*14.140Z.json`): Boot persistence + watchdog
2. **Approach 2** (`threads-export-*21.343Z.json`): Whisper + LLM processing (most features)
3. **Approach 3** (`threads-export-*26.601Z.json`): Compact SAF (simplest, recommended start)

**Recommendation**: Start with Approach 3, upgrade to 1 for reliability, then 2 for power features.

## Directory Structure

```
claw-notes/
├── README.md           # User documentation
├── CLAUDE.md           # This file - AI context
├── setup.sh            # Quick setup script
├── dev/                # Development conversations/history
│   └── threads-*.json  # Conversation exports
├── scripts/            # Helper scripts
│   ├── hijack.js       # Android compatibility shim
│   └── watchdog.sh     # Process monitor
└── docs/               # Extended documentation
    └── COMPARISON.md   # Detailed approach comparison
```

## Common Commands

```bash
# Start OpenClaw (with Android shim)
node -r ~/.openclaw/hijack.js $(which openclaw) gateway

# Record audio
termux-microphone-record -f audio.m4a

# Wake lock (prevent Android killing process)
termux-wake-lock

# Check if OpenClaw running
pgrep -f "openclaw"
```

## Development Guidelines

1. **Test on actual Android device** - Termux behavior differs from Linux
2. **Always include hijack.js shim** - Required for Node.js on Android
3. **Use 127.0.0.1** - Never 0.0.0.0 for gateway binding
4. **Handle storage permissions** - SAF requires explicit user grant
5. **Consider battery** - Use wake locks sparingly, implement proper cleanup

## Markdown Format

Output notes should be compatible with both Logseq and Obsidian:

- Use `[[wikilinks]]` for internal links
- Use `#tags` for tagging
- YAML frontmatter for metadata
- Standard markdown for formatting

## Error Handling

Common issues and solutions:

| Error | Cause | Solution |
|-------|-------|----------|
| System Error 13 | os.networkInterfaces blocked | Use hijack.js shim |
| EADDRINUSE | Port already bound | Check for existing process, use different port |
| Storage permission denied | SAF not configured | Run `termux-setup-storage` |
| Process killed | Android battery optimization | Use `termux-wake-lock`, disable battery optimization |
