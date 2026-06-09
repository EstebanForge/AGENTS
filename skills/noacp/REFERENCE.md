# noacp Reference

## Agent config schema (`scripts/agents.json`)

```json
{
  "<name>": {
    "command": "string (required) - CLI binary name or path",
    "input_mode": "string (required) - flag|stdin|file",
    "print_flag": "string - flag for prompt text (required when input_mode=flag)",
    "interactive_flag": "string - flag for interactive mode (unused by noacp)",
    "timeout_default": "number - default timeout in seconds (default: 120)",
    "notes": "string - freeform notes"
  }
}
```

Required fields: `command` + `input_mode`. When `input_mode` is `flag`, `print_flag` is also required.

`input_mode` values:
- `flag`: agent receives prompt text as a CLI flag argument (e.g. `agy -p "text"`)
- `stdin`: agent reads prompt from stdin (e.g. `echo "text" | agent`)
- `file`: agent receives file path as argument (e.g. `agent /path/to/file`)

## Session file validation

Valid session files must:
- Start with `<session ...>` and end with `</session>`
- Have `agent` attribute matching a known agent in `agents.json`
- Have monotonically increasing turn numbers
- Contain paired `<orchestrator>` / `<agent>` blocks (last block may be unpaired if prompt is in-flight)

`session.sh validate <file>` checks these rules. Reports closed sessions as warnings.

## Multi-agent routing

noacp is single-agent per session. For multi-agent workflows:
- Create separate session files per agent
- Read `<agent>` output from one session and feed it as `<orchestrator>` input to another
- Orchestration logic lives with you (the orchestrator), not in noacp

## Session storage

- Default: `/tmp/noacp/`
- Override: `NOACP_DIR` env var
- Files named: `{id}.xml`
- Closed sessions kept on disk (add `closed: true` metadata)
- `session.sh delete <file>` to remove session files
- No auto-cleanup. Manage disk manually or via cron.

## Inline usage (no script)

If `session.sh` is unavailable, create session files manually:

```bash
SESSION="/tmp/noacp/auth-fix.xml"
mkdir -p /tmp/noacp
cat > "$SESSION" << 'EOF'
<session agent="agy" id="auth-fix" created="2026-06-09T12:00:00Z">
</session>
EOF
```

Prefer the script. It handles multiline content, XML escaping, `input_mode` routing, and edge cases that inline bash cannot safely cover.
