# ORIGIN

source: https://github.com/mattpocock/skills/blob/main/skills/engineering/wayfinder/SKILL.md
upstream-category: engineering
upstream-repo: mattpocock/skills
upstream-author: Matt Pocock
license: MIT
sync-status: adapted (untethered from mattpocock setup and tooling)
last-synced: 2026-09-25
upstream-commit: 3216582 (2026-08-19)

## Provenance

Adapted from Matt Pocock's `wayfinder` skill in mattpocock/skills (MIT). Used to chart multi-session planning maps with decision tickets on an issue tracker.

## What changed locally

- **Untethered from repo setup scripts.** Removed reference to `/setup-matt-pocock-skills`. Generalized issue tracker resolution to use repository conventions, GitHub CLI, or local markdown files.
- **Untethered skill invocations.** Replaced rigid Pocock `Skill` tool calls (`calls the Skill tool with "research"`, `call the Skill tool twice, for "grilling" and "domain-modeling"`) with standard skill consultations and subagent delegation.
- **Excluded upstream-only agents manifest.** Did not import upstream-specific `agents/openai.yaml`.
- **Unwrapped paragraphs.** Formatted markdown prose to one line per paragraph per repository documentation protocol.
