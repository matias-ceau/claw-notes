---
type: note
title: Welcome to Claw Notes
created: 2026-02-05T00:00:00Z
tags: [meta, getting-started]
---

# Welcome to Claw Notes

This is your voice-to-markdown notes system.

## Quick Start

```bash
# Add claw to your PATH
export PATH="$PATH:$(pwd)/.claw/bin"

# Check status
claw status

# Record a voice note (full pipeline)
claw full my-first-note

# Or step by step:
claw record idea           # Record audio
claw transcribe idea*.m4a  # Transcribe with Whisper
claw process idea*.md      # Clean up with LLM

# Add to journal
claw journal "Had a great idea about X"

# Create a quick note
claw note "Project Ideas" "List of things to build"

# Sync changes
claw sync
```

## Directory Structure

- `pages/` - Topic-based notes (like this one)
- `journals/` - Daily notes (YYYY-MM-DD.md)
- `transcripts/raw/` - Direct Whisper output
- `transcripts/cleaned/` - LLM-processed transcripts
- `summaries/` - AI-generated summaries
- `assets/` - Audio files, images
- `templates/` - Note templates

## Links

- [[workflow]] - How the system works
- [[setup]] - Installation guide

## Tags

#meta #getting-started
