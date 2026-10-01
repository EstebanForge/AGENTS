# META

source: https://github.com/BlockedPath/pi-visualize-code-changes/blob/main/skills/visualize-code-changes/SKILL.md
upstream-repo: BlockedPath/pi-visualize-code-changes
upstream-author: BlockedPath
license: MIT
repo-created: 2026-10-01
last-synced: 2026-10-01
upstream-commit: cef1927 (2026-10-01)
sync-status: synced (one local trim)

## Provenance

Vendored skill-only copy of the upstream package. The package wiring
(`package.json`, `pi.skills` mapping) is intentionally not vendored; the skill
reaches agents through `manage.sh` symlink sync instead.

History: first adopted as the npm package `pi-visualize-code-changes`, removed
in commit d77a1b2, re-adopted the same day as this in-repo skill.

## What changed locally

- Dropped the stale harness-specific install hint for the question tool;
  current hosts ship `ask_user_question` natively, so the line was dead weight.
- Everything else is verbatim from upstream cef1927.

## sync-status

Synced. Re-diff against the upstream repo head when refreshing; keep the local
trim above on merge.
