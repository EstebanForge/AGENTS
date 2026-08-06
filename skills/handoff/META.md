# ORIGIN

source: https://github.com/mattpocock/skills/blob/main/skills/productivity/handoff
upstream-category: productivity
sync-status: forked
last-synced: 2026-08-05
upstream-commit: v1.2.0

## Fork notes

- **Save location: workspace by default.** We write the handoff doc into the current workspace unless the user asks elsewhere. Upstream writes to the OS temp dir (`$TMPDIR` / `/tmp`).
  - Why: a fresh agent starts in the workspace, the file is visible in plain sight, and it survives container/restart teardowns (temp dirs don't). Tradeoff accepted: handoffs show in `git status` and could be committed by mistake — mitigated by user awareness.
- Adopted upstream's `specs` terminology (was `PRDs`) in the don't-duplicate line.

## v1.2.0 merge (2026-08-05)

No SKILL.md change. The #763 "handoff was oversold" item narrows handoff's
role in the `/ask-matt` router and docs (`PHASE-BOUNDARIES.md`) — it does not
edit this skill's body. Upstream's temp-dir save location (unchanged since
the prior baseline) remains a deliberate local fork, kept on the rationale
above.
