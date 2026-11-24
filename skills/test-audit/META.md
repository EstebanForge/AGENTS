# ORIGIN

source: https://github.com/openclaw/openclaw/blob/main/.agents%2Fskills%2Ftest-audit%2FSKILL.md
upstream-repo: openclaw/openclaw
upstream-author: openclaw (Ayaan Zaidi)
license: MIT (Copyright (c) 2026 OpenClaw Foundation)
sync-status: adapted (untethered from openclaw repository tooling)
last-synced: 2026-11-24
upstream-commit: 57dd84bd1 (2026-11-24)

## Provenance

Port of OpenClaw's `test-audit` skill from openclaw/openclaw (MIT).

## Layout

- `SKILL.md`: Core test-audit skill instructions, authoring gate, junk patterns, value bar, and validation workflow.
- `CAMPAIGN.md`: Subsystem-wide test pruning campaign methodology (baseline, lanes, ledger, layers, cutover, preservation, defect handling, reconcile).
- `references/audit.md`: Candidate-evidence workflow (added upstream after the first sync; untethered here the same way).

## What changed locally

- **Untethered from internal tooling.** Replaced OpenClaw-specific harness commands (`$openclaw-testing`, `$crabbox`, `node scripts/run-vitest.mjs`, `node scripts/check-changed.mjs`, `$autoreview`, `$openclaw-pr-maintainer`, `scripts/pr`) with generic, repository-agnostic validation, linting, and landing steps.
- **Removed internal jargon.** Replaced test-only production backdoor terms with "hook", "export", or "boundary" throughout the text.
- **Ported CAMPAIGN.md.** Vendored and generalized sibling `CAMPAIGN.md` guide for multi-lane subsystem test pruning.
- **Unwrapped paragraphs.** Formatted markdown prose to one line per paragraph per repository documentation protocol.

## 2026-11-24 merge (upstream 57dd84bd1)

- Adopted all upstream content evolution in SKILL.md + CAMPAIGN.md and the
  new references/audit.md (upstream added it after the first sync).
- Re-applied untethering on refresh: SKILL.md keeps the local generic
  "Landing and continuation" + "Handoff" sections (upstream's audit bullet
  block wires `$openclaw-testing`, changed-checks script, autoreview);
  references/audit.md "Validation and handoff" bullets generalized the
  same way (proof-policy path, check-changed.mjs, deadcode scripts,
  autoreview). CAMPAIGN.md needed no untethering.
