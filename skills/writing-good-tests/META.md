# ORIGIN

source: https://github.com/obra/superpowers/blob/main/skills/test-driven-development/writing-good-tests.md
upstream-category: test-driven-development (reference file)
license: MIT (Copyright (c) 2025 Jesse Vincent)
sync-status: adapted (reference promoted to standalone self-contained skill)
last-synced: 2026-08-29
upstream-commit: b36e082 (2026-08-12)

## Provenance

Port of Jesse Vincent's `writing-good-tests.md` from obra/superpowers (MIT). Upstream ships it as a reference file loaded by their `test-driven-development` skill; here it is a standalone, self-contained skill that triggers on any test-writing or test-review request, with or without a test-driven development loop. Two principles (name the break, exercise the real thing), gate functions, the mutation check, and the warning-signs list are upstream's.

## What changed locally

- **Reference -> standalone self-contained skill.** Frontmatter added; the "load this reference when" trigger line moved into the description.
- **Inlined boundary mocking rules.** External dependencies on external skill files removed; boundary rules (mock external services, time/randomness; do not mock internal modules) are defined directly in the skill.
- **Upstream-specific pointers generalized.** Cross-references to external frameworks dropped; human partner devices reworded as standing challenge questions.
- **Refactoring separation.** Upstream loop definition drops "refactor" because refactoring belongs to the review stage, not the green implementation step. Mirroring rule scoped to the boundary type's fields. Added suite-coupling warning sign (pass in isolation, fail in full suite). Added guidance for tests added outside a loop (reviews, backfilled coverage).
