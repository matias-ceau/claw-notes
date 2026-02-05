# CLAUDE.md

> **See [AGENT.md](AGENT.md) for complete AI assistant context.**
> This file exists for Claude Code compatibility. The canonical source is AGENT.md.

## Quick Reference

Claw Notes is an **always-on AI assistant platform** for Android Termux. OpenClaw runs 24/7, integrates with WhatsApp, and uses this vault as its memory.

**Key principle**: Users never touch the terminal. Interfaces are widgets, notifications, and chat.

## Critical Files

| File | Purpose |
|------|---------|
| `AGENT.md` | Full AI context (read this first) |
| `.shortcuts/*` | Termux:Widget home screen actions |
| `.claw/boot/watchdog.sh` | Keeps OpenClaw alive |
| `.claw/lib/config.sh` | Shared configuration |
| `.claw/lib/hijack.js` | Android Node.js compatibility |

## Android Constraints (quick ref)

- **System Error 13**: Use `hijack.js` shim for Node.js
- **Network**: `127.0.0.1` only, never `0.0.0.0`
- **Background**: Watchdog + wake locks
- **Storage**: SAF via `termux-setup-storage`

## Adding Features

1. **New widget**: Create in `.shortcuts/`, use `termux-dialog`/`termux-notification`
2. **New hook**: Create in `.claw/hooks/`, wire to OpenClaw
3. **New command**: Create in `.claw/bin/`, wire to widget

See AGENT.md for detailed instructions.
