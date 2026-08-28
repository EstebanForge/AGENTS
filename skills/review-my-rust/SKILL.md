---
name: review-my-rust
description: Review Rust changes against the Rust Code Smells guide. Use when the user says "review my Rust", or when a requested code review, diff, commit, or PR audit turns out to contain .rs files. Findings name anti-patterns and end with a verdict.
---

# Review My Rust

Review Rust changes in a git repo against the Rust Code Smells guide in [rust-smells.md](rust-smells.md). High signal: only anti-patterns present in the diff; no drive-bys on untouched code.

## Workflow

1. **Resolve the diff.** Default target: unstaged changes. A named commit, range, staged state, or PR branch overrides the default. Use native git tools when present (pi: `git_diff` / `git_status`), else `git diff` / `git show` / `git diff --cached`, filtered to `*.rs`. Run inside the target repo. Done when: the full Rust diff is in hand.

2. **Load the rubric.** Read [rust-smells.md](rust-smells.md) from this folder. Done when: the guide is in context.

3. **Apply.** Measure every changed file against every applicable anti-pattern. Read surrounding source when a hunk cannot prove or clear a rule on its own. Done when: each changed file has been checked against the guide.

4. **Report.** Most impactful first. Per finding: category (Bug/Critical, Suggestion, Nit), section + anti-pattern name (e.g. `Error Handling Traps > Excessive .unwrap()`), file:line or code fragment, and the idiomatic fix as a corrected snippet modeled on the guide's Do-This examples. Note Good patterns too. Done when: every finding carries category, citation, location, and fix.

5. **Verdict.** Approve, Request Changes, or Needs Discussion, with a one-line rationale. Done when: the verdict is stated.

## Notes

- Wide diffs: review per directory (`git diff -- <dir>`) so each pass keeps full attention on the guide.
- PR mechanics (gh, posting, review events): pair with the review-pull-request skill. This skill supplies the Rust rubric only.
