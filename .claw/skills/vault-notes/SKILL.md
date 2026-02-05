# Vault Notes Skill

Manage the local markdown vault for Claw Notes.

## Commands

### save-note
Save a note to the vault.

```
save-note <title> [content]
```

Saves to `pages/<title>.md` with YAML frontmatter.

### save-journal
Add an entry to today's journal.

```
save-journal <content>
```

Appends to `journals/YYYY-MM-DD.md`.

### save-transcript
Save a transcript from voice processing.

```
save-transcript <name> <transcript_text>
```

Saves to `transcripts/<name>.md` with metadata.

### search-vault
Search the vault for content.

```
search-vault <query>
```

Returns matching files and snippets.

## Configuration

```json
{
  "skills": {
    "vault-notes": {
      "vaultPath": "~/storage/shared/Documents/claw-notes"
    }
  }
}
```

## Triggers

This skill auto-triggers when:
- Audio transcription completes → saves to transcripts/
- User says "note:" or "journal:" → routes to appropriate save
- Daily summary requested → creates journal entry
