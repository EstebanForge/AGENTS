# META

source: https://github.com/mattpocock/skills/blob/main/skills/engineering/to-spec/SKILL.md
upstream-repo: mattpocock/skills
upstream-author: Matt Pocock
license: MIT
sync-status: near-verbatim (renamed spec -> PRD)

## Provenance

Near-verbatim fork of Matt Pocock's `to-spec` skill. The skill, its process,
and its template are upstream's; the local copy renames it `to-prd` and
substitutes "PRD" for "spec" throughout. This is the third Matt Pocock skill
in this tree's planning cluster (with `prd-to-plan` and `to-issues`).

## Verbatim from upstream

- Opening line: "This skill takes the current conversation context and
  codebase understanding and produces a [spec/PRD]. Do NOT interview the
  user - just synthesize what you already know."
- The 3-step process: explore the repo (domain glossary, ADRs), sketch test
  seams (prefer existing, highest seam, ideal count is one, confirm with
  user), write + publish with the `ready-for-agent` triage label.
- The full document template: Problem Statement, Solution, User Stories
  (with the "mobile bank customer" example), Implementation Decisions,
  Testing Decisions, Out of Scope, Further Notes.
- The prototype-snippet exception (state machine, reducer, schema, type
  shape; trim to decision-rich parts).

## What changed locally

- **Renamed.** `to-spec` -> `to-prd`; "spec" -> "PRD" in the description,
  body, and the "Out of Scope for this ..." template line.
- **Template wrapper tags.** Local wraps the template in
  `<prd-template>...</prd-template>` and the example in
  `<user-story-example>...</user-story-example>`; upstream uses plain
  indented blocks.
- **Local template bindings.** Replaces upstream's "run
  `/setup-matt-pocock-skills`" line with references to
  `../_templates/issue-tracker.md` and `../_templates/triage-labels.md`.
- **Voice.** Local adds a Notes section directing the PRD to Esteban's
  formal voice.

## sync-status

Near-verbatim. Re-pull from the link above; keep the `to-prd` name, the
local template bindings, the wrapper tags, and the voice note on merge.
