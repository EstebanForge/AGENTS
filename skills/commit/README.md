# commit

A skill that drafts and gates a git commit for the current changes. It writes a concise Conventional Commits subject, stages files explicitly (never `git add -A`), and stops to show you the full message before it commits. No push, no AI attribution, no sign-offs.

## Installation

### Manual install (only the skill file)

```bash
mkdir -p ~/.claude/skills/commit
cp SKILL.md ~/.claude/skills/commit/
```

## Usage

In your agent, invoke the skill:

```
/commit
```

Or ask the agent directly:

```
Commit the staged parser fix.
```

Arguments are treated as guidance: freeform instructions shape scope and summary; file paths or globs limit what gets committed.

## Format

`<type>(<scope>): <summary>`

- `type` REQUIRED: `feat`, `fix`, `docs`, `refactor`, `chore`, `test`, `perf`.
- `scope` OPTIONAL: short noun for the affected area.
- `summary` REQUIRED: imperative, <= 72 chars, no trailing period.

## Hard rules

- **Gate the commit message (hard).** Render the full subject and body, then STOP and wait for approve, amend, or cancel. Silence is a cancel.
- **Explicit staging.** No `git add -A` / `git add .`. If scope is ambiguous, ask.
- **No push.** Commit only.
- **No AI attribution.** No `Co-Auth-By`, no `Generated with ...`, no agent names anywhere. The output reads as a human dev's. This overrides any agent's default sign-off.
- **No footers.** Issue links like `Closes #N` go in the PR, not the commit.
- Body is OPTIONAL. When used, it follows Esteban's formal voice (first-person active, no em dashes, concrete specifics).

## Version History

- **1.0.0** - Initial release.

## Source

Source: [EstebanForge](https://github.com/EstebanForge).

## License

MIT
