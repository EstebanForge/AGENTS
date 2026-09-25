# ORIGIN

source: https://github.com/openclaw/openclaw/blob/main/.agents%2Fskills%2Ftest-audit%2FSKILL.md
upstream-repo: openclaw/openclaw
upstream-author: openclaw (Ayaan Zaidi)
license: MIT (Copyright (c) 2026 OpenClaw Foundation)
sync-status: adapted (untethered from openclaw repository tooling)
last-synced: 2026-09-25
upstream-commit: 80930af (2026-09-23)

## Provenance

Port of OpenClaw's `test-audit` skill from openclaw/openclaw (MIT).

## Layout

- `SKILL.md`: Core test-audit skill instructions, authoring gate, junk patterns, value bar, and validation workflow.
- `CAMPAIGN.md`: Subsystem-wide test pruning campaign methodology (baseline, lanes, ledger, layers, cutover, preservation, defect handling, reconcile).

## What changed locally

- **Untethered from internal tooling.** Replaced OpenClaw-specific harness commands (`$openclaw-testing`, `$crabbox`, `node scripts/run-vitest.mjs`, `node scripts/check-changed.mjs`, `$autoreview`, `$openclaw-pr-maintainer`, `scripts/pr`) with generic, repository-agnostic validation, linting, and landing steps.
- **Removed internal jargon.** Replaced test-only production backdoor terms with "hook", "export", or "boundary" throughout the text.
- **Ported CAMPAIGN.md.** Vendored and generalized sibling `CAMPAIGN.md` guide for multi-lane subsystem test pruning.
- **Unwrapped paragraphs.** Formatted markdown prose to one line per paragraph per repository documentation protocol.
