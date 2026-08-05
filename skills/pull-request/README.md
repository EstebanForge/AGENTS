# pull-request

A skill that opens the current branch's changes for review as a GitHub pull request. It enforces branch safety, delegates the commit to the `commit` skill, detects the real base branch, describes the whole changeset, drafts the body, runs preflight, pushes, and gates the title and body before it creates the PR with `gh`. Clean, attribution-free output.

## Installation

### Manual install (only the skill file)

```bash
mkdir -p ~/.claude/skills/pull-request
cp SKILL.md ~/.claude/skills/pull-request/
```

## Usage

In your agent, invoke the skill:

```
/pull-request
```

Or ask the agent directly:

```
Open a PR for this branch.
```

Arguments are treated as guidance: a branch name, a title, or an issue number for `Closes #N`.

## Workflow

1. Branch safety. Refuse on protected branches (`main`, `master`, `develop`, `release/*`). Personal repos owned by `EstebanForge` or `actitudstudio` may push the default branch directly.
2. Commit. Hand uncommitted changes to the `commit` skill.
3. Detect the base branch. Do not assume `main`.
4. Describe the whole changeset with `git diff <base>...HEAD`.
5. Draft the body from the repo template, or the What / Why / How / Testing fallback.
6. Preflight. Run the repo's lint/test command; ask if unknown.
7. Push. `git push -u origin HEAD`. Never force-push.
8. Gate (hard). Render the full title and body, then STOP. Do not create until approved.
9. Create with `gh pr create --body-file`. Report the PR URL.

## Hard rules

- **Gate the PR (hard).** Render title and body, then STOP. Silence is a cancel.
- **No AI attribution.** No `Co-Authored-By`, no `Generated with ...`, no agent names anywhere.
- **Never push to a protected branch** (except the personal-repo exception above).
- **Explicit staging.** No `git add -A` / `git add .`.
- **Use `--body-file`.** Never pass a multi-line body inline or via heredoc.

## Version History

- **1.0.0** - Initial release.

## Source

Source: [EstebanForge](https://github.com/EstebanForge).

## License

MIT
