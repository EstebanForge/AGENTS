---
name: review-my-go
description: Review Go changes against the 100 Go Mistakes checklist and JetBrains' version-resolved modern-Go guidelines. Use when the user says "review my Go", or when a requested code review, diff, commit, or PR audit turns out to contain .go files. Findings cite mistake numbers or guideline IDs and end with a verdict.
---

# Review My Go

Review Go changes in a git repo against the 100 Go Mistakes checklist in [go-mistakes.md](go-mistakes.md) (source: 100go.co), then against modern-Go guidelines via the bundled CLI (source: JetBrains go-modern-guidelines). High signal: only defects present in the diff; no drive-bys on untouched code.

## Workflow

1. **Resolve the diff.** Default target: unstaged changes. A named commit, range, staged state, or PR branch overrides the default. Use native git tools when present (pi: `git_diff` / `git_status`), else `git diff` / `git show` / `git diff --cached`, filtered to `*.go`. Run inside the target repo. Done when: the full Go diff is in hand.

2. **Load the rubric.** Read [go-mistakes.md](go-mistakes.md) from this folder. Done when: the checklist is in context.

3. **Apply.** Measure every changed file against every applicable mistake. Read surrounding source when a hunk cannot prove or clear a rule on its own. Done when: each changed file has been checked against the rubric.

4. **Mechanical pass.** `go version` first: only Go 1.26+ ships the modernize fixers; older toolchains skip this pass and say so. Run `go fix -diff ./<pkg>/...` on the packages that own the changed files; `-diff` exits non-zero when it has output, which means findings, not failure. Review is read-only: never run the unflagged write form. Each resulting hunk touching a changed file is a Modernization finding cited as `go fix`. Caveats: `go fix` applies only what the file's or module's declared Go version permits; generated files are skipped; for build-tagged code re-run per relevant GOOS/GOARCH; the output can leave unused variables, call those out. Done when: `-diff` hunks on changed files are collected, or the pass was skipped with the toolchain version stated.

5. **Guideline pass.** For each changed `.go` file, run `sh "<skill-dir>/scripts/run-tool.sh" list --file-path <file>`. A diff spanning many files in one module: one run per `go.mod` root is enough. Read the complete list output before deciding what applies; never pipe it through `head`, `tail`, `grep`, `sed`, or any truncating/filtering command. Check every diff hunk against every returned guideline. `explain <id>` only for IDs that may apply to the diff and need more detail. Done when: each returned guideline was applied, skipped per the rules below, or clearly does not apply.

6. **Report.** Most impactful first. Per finding: category (Bug/Critical, Suggestion, Nit, Modernization), citation (mistake number `#39`, guideline ID `modern:rangeint`, or `go fix`), file:line or code fragment, and the fix. Note Good patterns too. Done when: every finding carries category, citation, location, and fix.

7. **Verdict.** Approve, Request Changes, or Needs Discussion, with a one-line rationale. Done when: the verdict is stated.

## Notes

- Wide diffs: review per directory (`git diff -- <dir>`) so each pass keeps full attention on the rubric.
- Modernization skips: skip a returned guideline only when it would not compile, would change behavior, or clearly does not match the edited code. Before skipping one that seems relevant, read its `explain` output first. Guideline IDs are version-gated by the repo's `go.mod` / `go.work` / toolchain; never apply a guideline the CLI did not return for that version.
- Mixed diffs: when a diff mixes `go fix` output with hand edits, suggest separating the mechanical diff into its own commit so reviewers can see tool work vs author work.
- Modernization CLI: first run runs `go install` (Go toolchain + network required) and pins `scripts/VERSION` into `~/.cache/go-modern-guidelines`. If it cannot run or install, state that in the report and deliver the rubric-only review; no silent skip.
- PR mechanics (gh, posting, review events): pair with the review-pull-request skill. This skill supplies the Go rubric only.
