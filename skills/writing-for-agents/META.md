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
