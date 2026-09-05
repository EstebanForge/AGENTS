---
name: review-my-php
description: Review PHP code against modern PHP 8.2+ standards and anti-patterns. Use when specifically reviewing PHP source code changes.
---

# Review My PHP

Review PHP changes in a git repo against the PHP 8.2+ anti-patterns rubric in [php-anti-patterns.md](php-anti-patterns.md). The rubric carries its own floor, citation rules, and fix format; follow the protocol at the top of the file. High signal: only entries present in the diff; no drive-bys on untouched code.

## Workflow

1. **Resolve the diff.** Default target: unstaged changes. A named commit, range, staged state, or PR branch overrides the default. Use native git tools when present (pi: `git_diff` / `git_status`), else `git diff` / `git show` / `git diff --cached`, filtered to `*.php`. Run inside the target repo. Done when: the full PHP diff is in hand.

2. **Load the rubric.** Read [php-anti-patterns.md](php-anti-patterns.md) from this folder. Done when: the rubric and its protocol are in context.

3. **Apply.** Measure every changed file against every applicable entry. Read surrounding source when a hunk cannot prove or clear a rule on its own. Done when: each changed file has been checked against the rubric.

4. **Report.** Per the rubric protocol: entry number, file:line, category, corrected snippet from the Do-This examples. Cite See-also references (PHPStan error id, php.net page, clean-code-php section, phptherightway page) when they apply. Note Good patterns too. Done when: every finding carries category, citation, location, and fix.

5. **Verdict.** Approve, Request Changes, or Needs Discussion, with a one-line rationale. Done when: the verdict is stated.

## Notes

- Wide diffs: review per directory (`git diff -- <dir>`) so each pass keeps full attention on the rubric.
- PR mechanics (gh, posting, review events): pair with the review-pull-request skill. This skill supplies the PHP rubric only.
