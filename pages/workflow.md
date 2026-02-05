---
type: note
title: Workflow
created: 2026-02-05T00:00:00Z
tags: [meta, workflow]
---

# Workflow

## Full Pipeline

```
Voice Recording → Whisper → Raw Transcript → LLM → Cleaned + Summary
```

### 1. Record

Record audio using Termux:API microphone:
```bash
claw record meeting
# Creates: assets/meeting_2026-02-05_10-30-00.m4a
```

### 2. Transcribe

Convert audio to text with OpenAI Whisper:
```bash
claw transcribe assets/meeting*.m4a
# Creates: transcripts/raw/meeting_transcript.md
```

### 3. Process

Clean up rambling transcripts with LLM:
```bash
claw process transcripts/raw/meeting_transcript.md
# Creates:
#   transcripts/cleaned/meeting_cleaned.md
#   summaries/meeting_summary.md
```

### One Command

Do all three steps at once:
```bash
claw full meeting
```

## Output Versions

| Version | Location | Purpose |
|---------|----------|---------|
| Raw | `transcripts/raw/` | Exact Whisper output |
| Cleaned | `transcripts/cleaned/` | Coherent, readable |
| Summary | `summaries/` | Key points, action items |

## Why Three Versions?

- **Raw**: Preserve original for reference
- **Cleaned**: Read and share without embarrassment
- **Summary**: Quick review, action tracking

## Links

- [[welcome]] - Getting started
- [[setup]] - Installation

#workflow #meta
