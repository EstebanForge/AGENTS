# ORIGIN

source: https://github.com/obra/superpowers/blob/main/skills/test-driven-development/writing-good-tests.md
upstream-category: test-driven-development (reference file)
license: MIT (Copyright (c) 2025 Jesse Vincent)
sync-status: adapted (reference promoted to standalone skill)
last-synced: 2026-08-28
upstream-commit: b36e082 (2026-08-12)

## Provenance

Port of Jesse Vincent's `writing-good-tests.md` from obra/superpowers
(MIT). Upstream ships it as a reference file loaded by their
`test-driven-development` skill; here it is a standalone skill so it
fires on any test-writing or test-review request, with or without the
red-green loop. Two principles (name the break, exercise the real
thing), gate functions, the mutation check, and the warning-signs list
are upstream's, near-verbatim (upstream punctuation preserved).

## What changed locally

- **Reference → standalone skill.** Frontmatter added; the
  "load this reference when" trigger line moved into the description.
- **Upstream-specific pointers generalized.** The
  `superpowers:writing-skills` cross-reference dropped; the "your human
  partner's correction/question" devices reworded as standing challenge
  questions.
- **Local bindings.** Intro binds process to the local `tdd` skill;
  mock boundary principles point at `tdd/mocking.md`.
- **Aligned with local `tdd` skill (peer review, 2026-08-28).**
  Upstream's "failing test, minimal implementation, refactor" loop
  definition drops "refactor" — local `tdd` keeps refactoring in the
  review stage, not the loop. Mirroring rule scoped to the boundary
  type's fields (upstream's "all documented fields" bloats on large
  real-world payloads). Added a suite-coupling warning sign (pass in
  isolation, fail in the full suite). Added a sentence covering tests
  added outside a loop (reviews, backfilled coverage).
