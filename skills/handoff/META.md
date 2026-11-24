# ORIGIN

source: https://github.com/mattpocock/skills/blob/main/skills/productivity/handoff
upstream-category: productivity
sync-status: forked (workspace save + structured state kept local)
last-synced: 2026-11-24
upstream-commit: abeeaf9 (2026-11-19)

## Fork notes

- **Save location: workspace by default.** We write the handoff doc into the current workspace unless the user asks elsewhere. Upstream writes to the OS temp dir (`$TMPDIR` / `/tmp`).
  - Why: a fresh agent starts in the workspace, the file is visible in plain sight, and it survives container/restart teardowns (temp dirs don't). Tradeoff accepted: handoffs show in `git status` and could be committed by mistake — mitigated by user awareness.
- Adopted upstream's `specs` terminology (was `PRDs`) in the don't-duplicate line.

## 2026-11-24 check (upstream abeeaf9)

Upstream landed the #763 follow-through in the body and moved against this
fork on three fronts. All three divergences are deliberate, keep on refresh:

1. **Save location.** Upstream now states the OS temp dir explicitly
   ("not the current workspace"). Local keeps workspace-by-default.
2. **Structure.** Upstream dropped the 6-field execution-state block
   (Active Goal / Verified Facts / Rejected Paths / Active Files / Next
   Action / Suggested Skills) for a narrative summary plus a one-line
   suggested-skills mention. Local keeps the structured state.
3. **Phrasing.** Upstream's suggested-skills line says "call the Skill
   tool for"; Claude Code specific, not carried.

## v1.2.0 merge (2026-08-05)

No SKILL.md change. The #763 "handoff was oversold" item narrows handoff's
role in the `/ask-matt` router and docs (`PHASE-BOUNDARIES.md`) — it does not
edit this skill's body. Upstream's temp-dir save location (unchanged since
the prior baseline) remains a deliberate local fork, kept on the rationale
above.
