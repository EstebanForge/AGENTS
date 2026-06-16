---
name: noacp
description: File-based session protocol for agents without ACP support. Wraps any CLI agent (agy, etc.) in persistent multi-turn conversations using shared session files. Use when acpx is unavailable, the target agent lacks ACP, or when user mentions noacp, agy session, file-based agent, or non-ACP agent communication.
---

File-based session protocol. Replaces ACPX for agents that lack ACP adapters.

## Concept

The orchestrator (you) owns a session file. The agent is stateless. The file IS the session. Each turn appends XML-tagged blocks. Full history re-sent each call so the agent sees context.

## Quick start

```bash
# Create session (returns file path)
bash skills/noacp/scripts/session.sh new agy
# /tmp/noacp/a1b2.md

# Send first prompt
bash skills/noacp/scripts/session.sh prompt /tmp/noacp/a1b2.md "Analyze auth middleware"

# Continue (same file = same session)
bash skills/noacp/scripts/session.sh prompt /tmp/noacp/a1b2.md "Fix the timing vuln you found"

# Read history
bash skills/noacp/scripts/session.sh history /tmp/noacp/a1b2.md
```

## Session file format

Sessions live in `/tmp/noacp/` by default. Override with `NOACP_DIR`. Files use `.xml` extension.

```xml
<session agent="agy" id="auth-fix" created="2026-06-09T12:00:00Z">
<orchestrator turn="1" ts="2026-06-09T12:00:01Z">Analyze auth middleware</orchestrator>
<agent turn="1" ts="2026-06-09T12:00:15Z">Found timing vuln in...</agent>
<orchestrator turn="2" ts="2026-06-09T12:01:00Z">Fix it, minimal change</orchestrator>
<agent turn="2" ts="2026-06-09T12:01:30Z">Here is the patch: ...</agent>
</session>
```

Tags: `<orchestrator>` (you), `<agent>` (them). The `agent` attribute on `<session>` identifies which CLI agent is in use.

## Commands

| Command | Usage | What it does |
|---------|-------|--------------|
| `new` | `session.sh new <agent> [id]` | Create session file, print path. Random id if omitted. |
| `prompt` | `session.sh prompt <file> [opts] ["text"]` | Append orchestrator block, call agent, append agent block, print response. |
| `prompt` | `... --timeout N` | Override agent timeout for this call (seconds). |
| `prompt` | `... --file prompt.txt` | Read prompt text from file (avoids shell arg size limits). |
| `history` | `session.sh history <file>` | Print all turn pairs in readable format. |
| `list` | `session.sh list` | List all sessions in `NOACP_DIR`. |
| `close` | `session.sh close <file>` | Mark session closed, keep file on disk. |
| `delete` | `session.sh delete <file>` | Delete session file. |
| `validate` | `session.sh validate <file>` | Check session file integrity. |

## Agent registry

Defined in `scripts/agents.json`. Add new agents with `command` + `input_mode`:

```json
{
  "agy": {
    "command": "agy",
    "print_flag": "-p",
    "input_mode": "flag",
    "timeout_default": 120
  }
}
```

`input_mode` values: `flag` (prompt via CLI flag), `stdin` (prompt via stdin), `file` (prompt via file path arg).

## Limitations

- No streaming. Agent responds once per call.
- Token cost grows linearly (full history re-sent each turn).
- No tool-use callbacks during agent turn.
- No cancel mid-turn. Use OS signals (`timeout` wrapper).
- No parallel turns on same session. Sequential only.

### Large payloads and arg size limits

Agents using `flag` input_mode pass the entire session file as a CLI argument. Linux `ARG_MAX` is typically 2MB. Session history grows each turn. The script rejects payloads over 1MB with a clear error.

For large prompts (docs, code reviews, multi-file context):
1. Use `--file prompt.txt` to read prompt from file
2. Use `stdin` or `file` input_mode in `agents.json` instead of `flag`
3. Start a new session when history grows too large

```bash
# Large prompt via file
bash skills/noacp/scripts/session.sh prompt /tmp/noacp/abc123.xml --file /tmp/large-review.txt

# Override timeout for slow agents
bash skills/noacp/scripts/session.sh prompt /tmp/noacp/abc123.xml --timeout 300 "Analyze this"
```

## Advanced

See [REFERENCE.md](REFERENCE.md) for agent config schema, session validation rules, multi-agent routing, and inline usage fallback.
