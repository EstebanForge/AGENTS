---
name: review-my-go
description: Review Go changes against the 100 Go Mistakes checklist. Use when the user says "review my Go", or when a requested code review, diff, commit, or PR audit turns out to contain .go files. Findings cite mistake numbers and end with a verdict.
---

# Review My Go

Review Go changes in a git repo against the 100 Go Mistakes checklist in [go-mistakes.md](go-mistakes.md) (source: 100go.co). High signal: only defects present in the diff; no drive-bys on untouched code.

## Workflow

1. **Resolve the diff.** Default target: unstaged changes. A named commit, range, staged state, or PR branch overrides the default. Use native git tools when present (pi: `git_diff` / `git_status`), else `git diff` / `git show` / `git diff --cached`, filtered to `*.go`. Run inside the target repo. Done when: the full Go diff is in hand.

2. **Load the rubric.** Read [go-mistakes.md](go-mistakes.md) from this folder. Done when: the checklist is in context.

3. **Apply.** Measure every changed file against every applicable mistake. Read surrounding source when a hunk cannot prove or clear a rule on its own. Done when: each changed file has been checked against the rubric.

4. **Report.** Most impactful first. Per finding: category (Bug/Critical, Suggestion, Nit), mistake number (e.g. `#39`), file:line or code fragment, and the fix. Note Good patterns too. Done when: every finding carries category, citation, location, and fix.

5. **Verdict.** Approve, Request Changes, or Needs Discussion, with a one-line rationale. Done when: the verdict is stated.

## Notes

- Wide diffs: review per directory (`git diff -- <dir>`) so each pass keeps full attention on the rubric.
- PR mechanics (gh, posting, review events): pair with the review-pull-request skill. This skill supplies the Go rubric only.
