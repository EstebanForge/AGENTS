# ORIGIN

source: https://github.com/mattpocock/skills/blob/main/skills/engineering/wayfinder/SKILL.md
upstream-category: engineering
upstream-repo: mattpocock/skills
upstream-author: Matt Pocock
license: MIT
sync-status: adapted (untethered from mattpocock setup and tooling)
last-synced: 2026-11-24
upstream-commit: abeeaf9 (2026-11-19)

## Provenance

Adapted from Matt Pocock's `wayfinder` skill in mattpocock/skills (MIT). Used to chart multi-session planning maps with decision tickets on an issue tracker.

## What changed locally

- **Untethered from repo setup scripts.** Removed reference to `/setup-matt-pocock-skills`. Generalized issue tracker resolution to use repository conventions, GitHub CLI, or local markdown files.
- **Untethered skill invocations.** Replaced rigid Pocock `Skill` tool calls (`calls the Skill tool with "research"`, `call the Skill tool twice, for "grilling" and "domain-modeling"`) with standard skill consultations and subagent delegation.
- **Excluded upstream-only agents manifest.** Did not import upstream-specific `agents/openai.yaml`.
- **Unwrapped paragraphs.** Formatted markdown prose to one line per paragraph per repository documentation protocol.

## 2026-11-24 merge (upstream abeeaf9)

- Adopted: `wayfinder:` labels never carry triage labels; placeholder
  `#<n>` auto-link warning in the wiring pass; push research branch but
  open no PR; resolve-by-label rule; punctuation.
- Re-applied on merge (keep on refresh): local tracker resolution
  (configured tracker / `_templates` / local markdown, no setup script),
  /-invocation phrasing for grilling + domain-modeling + research
  (upstream says "Call the Skill tool", Claude Code only).
