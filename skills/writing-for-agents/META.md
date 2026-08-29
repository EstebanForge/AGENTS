# ORIGIN

source: https://github.com/mattpocock/skills/blob/main/skills/productivity/writing-for-agents
upstream-category: productivity
sync-status: synced
last-synced: 2026-08-05
upstream-commit: v1.2.0

## Fork notes

Content-identical to upstream v1.2.0 (excludes upstream-only `agents/`
manifest).

## v1.2.0 merge (2026-08-05) — breaking rename

Followed upstream #763 in full. The prior `writing-great-skills` directory
was git-mv'd to `writing-for-agents` (history preserved). Changes applied:

- **Renamed.** `writing-great-skills` -> `writing-for-agents`. Scope widened
  from "skills" to any document an agent consumes (skills, `AGENTS.md` /
  `CLAUDE.md`, docs reached by a pointer).
- **GLOSSARY.md merged into SKILL.md.** The standalone `GLOSSARY.md` is gone;
  its terms (Predictability, context pointer, the two loads, information
  hierarchy, leading words, etc.) now live as sections of `SKILL.md`. One
  authoritative treatment per term.
- **SKILL-MECHANICS.md split out.** The skill-only mechanics (frontmatter,
  model- vs user-invoked, router skills, the invocation cut of splitting)
  moved to a new sibling file reached by pointer.
- **Now model-invoked.** `disable-model-invocation` removed; the description
  carries the trigger branches (creating/editing skills, modifying
  `AGENTS.md`/`CLAUDE.md`). Fires autonomously; user reach is preserved.
- **"Cache" added to pruning.** The environment (`package.json` scripts,
  config, directory layout, `--help`) is a source of truth; a doc that
  restates a one-file lookup is a cache that goes stale. Cache only what the
  agent cannot find by looking.

No local mods existed at the prior baseline, so nothing had to be reconciled.
README.md reference updated (was `writing-great-skills`).

## patterns.md convention (2026-08-28) — local addition

Local addition, not upstream. Preserve on next sync. New "Pattern notes"
section in SKILL-MECHANICS.md; pointer in SKILL.md extended to name it.

- **Two audiences.** `SKILL.md` serves the executor at runtime;
  `patterns.md` (sibling file) serves the editor across sessions. History
  stays out of the runtime path.
- **Entry shape.** One pattern per entry: `Observed` (evidence), `Rule`
  (workaround), `Executor` (`all` | executor name), `Status` (`active` |
  `rejected` | `promoted`). `rejected` entries record "tried X, rejected
  because Y" and stay until the tool they describe is gone — they stop
  future editors re-proposing known failures. Promoted entries become
  tombstones; the rule text moves to `SKILL.md`.
- **Triggers.** The editor reads `patterns.md` before editing `SKILL.md`,
  and writes an entry in the same session where the skill misled the
  executor.
- **Executor-agnostic procedure.** Executor-specific workarounds live in
  `patterns.md`, labeled with the executor; `SKILL.md` procedure stays
  universal. A weak executor's crutch can break a strong one.
- **Promote on stability.** A pattern consulted on nearly every edit moves
  into `SKILL.md`; entry deleted. Evidence still gathering stays put.

Source: WikiSkill (arXiv 2608.27454) — persistent wiki layer between raw
experience and skills; the wiki carries most measured gains (+15 pts
ablation); rejected-proposal audit trail prevents re-proposals; model-specific
workarounds caused negative transfer across models.

Amended 2026-08-28 after peer review: added Executor field, editor
read/write triggers, promoted tombstones, rejected-entry invalidation.
