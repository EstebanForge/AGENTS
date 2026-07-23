# ORIGIN

source: https://github.com/mattpocock/skills/blob/main/skills/productivity/handoff
upstream-category: productivity
sync-status: forked
last-synced: 2026-07-23
upstream-commit: ed37663 (2026-07-21)

## Fork notes

- **Save location: workspace by default.** We write the handoff doc into the current workspace unless the user asks elsewhere. Upstream writes to the OS temp dir (`$TMPDIR` / `/tmp`).
  - Why: a fresh agent starts in the workspace, the file is visible in plain sight, and it survives container/restart teardowns (temp dirs don't). Tradeoff accepted: handoffs show in `git status` and could be committed by mistake — mitigated by user awareness.
- Adopted upstream's `specs` terminology (was `PRDs`) in the don't-duplicate line.
