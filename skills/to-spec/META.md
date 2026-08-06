# META

source: https://github.com/mattpocock/skills/blob/main/skills/engineering/to-spec/SKILL.md
upstream-repo: mattpocock/skills
upstream-author: Matt Pocock
license: MIT
sync-status: near-verbatim (local template bindings + voice note)
last-synced: 2026-08-05
upstream-commit: v1.2.0

## Provenance

Near-verbatim fork of Matt Pocock's `to-spec` skill. The skill, its process,
and its template are upstream's. Local mods are limited to template bindings,
wrapper tags, and a voice note (below). Part of this tree's planning cluster
with `to-tickets` and `implement`.

## What changed locally

- **Local template bindings.** Replaces upstream's "run
  `/setup-matt-pocock-skills`" line with references to
  `../_templates/issue-tracker.md` and `../_templates/triage-labels.md`.
- **Template wrapper tags.** Wraps the template in
  `<spec-template>...</spec-template>` and the example in
  `<user-story-example>...</user-story-example>`; upstream uses plain
  indented blocks.
- **Voice.** Adds a Notes section directing the spec to Esteban's formal
  voice.

## History

- 2026-08-05: renamed back from `to-prd` to `to-spec` to use upstream names
  (PRD -> spec terminology reverted throughout). v1.2.0 sync: #734 (drop the
  "you may know this as a PRD" parenthetical) was a no-op here — this fork
  already used its own terminology.
