---
name: review-my-javascript
description: Review JavaScript changes against the JS flaws rubric. Use when the user says "review my JavaScript" or "review my JS", or when a requested code review, diff, commit, or PR audit turns out to contain .js, .mjs, or .cjs files. Findings cite entry numbers and end with a verdict.
---

# Review My JavaScript

Review JavaScript changes in a git repo against the JS flaws rubric in [js-flaws.md](js-flaws.md). The rubric carries its own floor, file targets, citation rules, and fix format; follow the protocol at the top of the file. It targets the semantic and security flaws Biome / ESLint do not catch. High signal: only flaws present in the diff; no drive-bys on untouched code.

## Workflow

1. **Resolve the diff.** Default target: unstaged changes. A named commit, range, staged state, or PR branch overrides the default. Use native git tools when present (pi: `git_diff` / `git_status`), else `git diff` / `git show` / `git diff --cached`, filtered to `.js` / `.mjs` / `.cjs`. Run inside the target repo. Done when: the full JS diff is in hand.

2. **Load the rubric.** Read [js-flaws.md](js-flaws.md) from this folder. Done when: the rubric and its protocol are in context.

3. **Apply.** Measure every changed file against every applicable entry. Read surrounding source when a hunk cannot prove or clear a rule on its own. Done when: each changed file has been checked against the rubric.

4. **Report.** Per the rubric protocol: entry number, file:line, category, corrected snippet from the good example. Note Good patterns too. Done when: every finding carries category, citation, location, and fix.

5. **Verdict.** Approve, Request Changes, or Needs Discussion, with a one-line rationale. Done when: the verdict is stated.

## Notes

- Wide diffs: review per directory (`git diff -- <dir>`) so each pass keeps full attention on the rubric.
- TypeScript territory (`.ts`, `.tsx`, React): use the review-my-typescript skill instead.
- PR mechanics (gh, posting, review events): pair with the review-pull-request skill. This skill supplies the JS rubric only.
