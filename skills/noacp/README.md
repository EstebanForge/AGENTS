# noacp

A file-based session protocol for CLI agents that lack ACP adapters (agy and similar). The orchestrator owns a session file; the agent is stateless. The file IS the session. Each turn appends XML-tagged blocks, and the full history is re-sent on every call so the agent keeps its context.

Use it when `acpx` is unavailable, the target agent has no ACP support, or the user mentions `noacp`, an `agy session`, or a file-based agent conversation.

## Installation

### Manual install (the skill plus scripts)

```bash
mkdir -p ~/.claude/skills/noacp
cp SKILL.md ~/.claude/skills/noacp/
cp -r scripts ~/.claude/skills/noacp/
```

## Usage

```bash
# Create a session (prints the file path)
bash skills/noacp/scripts/session.sh new agy

# Send the first prompt
bash skills/noacp/scripts/session.sh prompt /tmp/noacp/<id>.xml "Analyze auth middleware"

# Continue the same session (same file = same context)
bash skills/noacp/scripts/session.sh prompt /tmp/noacp/<id>.xml "Fix the timing vuln you found"

# Read history
bash skills/noacp/scripts/session.sh history /tmp/noacp/<id>.xml
```

## Commands

| Command | What it does |
|---------|--------------|
| `new <agent> [id]` | Create a session file, print its path. |
| `prompt <file> ["text"]` | Append your turn, call the agent, append its reply, print it. |
| `history <file>` | Print all turn pairs in readable form. |
| `list` | List all sessions in `NOACP_DIR`. |
| `close <file>` | Mark a session closed, keep the file. |
| `delete <file>` | Delete a session file. |
| `validate <file>` | Check session file integrity. |

Prompt options: `--timeout N` (per-call override), `--file path` (read prompt from file; preferred for multi-line).

## agy model aliases

The registry pre-binds agy model tiers to aliases: `agy-flash`, `agy-flash-high`, `agy-flash-low`, `agy-pro`, `agy-pro-low`, `agy-claude` (Sonnet), `agy-opus`. Picking an alias injects the right `--model` for you. Verify exact strings with `agy models` before relying on a name.

## Notes

- No streaming, no mid-turn cancel, no parallel turns on the same session.
- Token cost grows linearly: full history is re-sent each turn.
- For large prompts, use `--file` and prefer `stdin` or `file` `input_mode` in `agents.json`.
- Full schema, validation rules, and multi-agent routing in [REFERENCE.md](REFERENCE.md).

## Version History

- **1.0.0** - Initial release.

## Source

Source: [EstebanForge](https://github.com/EstebanForge).

## License

MIT
