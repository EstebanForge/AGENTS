# review-pull-request

A skill that reviews a GitHub pull request's diff for issues that require fixes: bugs, regressions, security holes, breaking changes, performance, edge cases, and missing tests. It produces a high-signal, severity-ordered verdict and submits it through `gh`. No style nits, no drive-bys on untouched code.

## Installation

### Manual install (only the skill file)

```bash
mkdir -p ~/.claude/skills/review-pull-request
cp SKILL.md ~/.claude/skills/review-pull-request/
```

## Usage

In your agent, invoke the skill:

```
/review-pull-request
```

Or ask the agent directly:

```
Review PR #142.
```

It accepts a PR number, a URL, or infers the PR from the current branch.

## Workflow

1. Resolve the PR. Number or URL, else infer from the branch. Detect self-authored PRs (GitHub allows `--comment` only on your own PRs).
2. Fetch the diff and file list with `gh pr diff` and `gh pr view --json files`.
3. Filter noise. Skip generated, vendored, and lock files; note they changed, do not review them.
4. Review focus. Per changed file, check correctness, security, breaking changes, performance, edge cases, tests, and error handling. Review the diff only, never pre-existing untouched code.
5. De-duplicate. Merge issues with one root cause into a single comment.
6. Verdict. Issues found -> `REQUEST_CHANGES`, severity-ordered with `file:line` and a concrete fix. No issues -> `APPROVE`. Never approve on an empty or failed diff.
7. Gate (hard). Render the full review body and any inline comments, then STOP. Do not submit until approved.
8. Submit with `gh pr review <N> --<event> --body-file <file>`. Location-specific fixes go through `gh api .../pulls/<N>/comments`.

## Hard rules

- **Gate the review (hard).** Render the full body and inline comments, then STOP. Silence is a cancel.
- **Only flag issues that require fixes.** No style nits, no opinions on untouched code.
- **Never approve to clear a queue.** Approve only when the diff genuinely needs no changes.
- **No AI attribution.** No `Co-Authored-By`, no `Generated with ...`, no agent names anywhere.
- **Use `--body-file`** for the review body.

## Version History

- **1.0.0** - Initial release.

## Source

Source: [EstebanForge](https://github.com/EstebanForge).

## License

MIT
