# META

source: https://github.com/mattpocock/skills/blob/main/skills/engineering/to-tickets/SKILL.md
upstream-repo: mattpocock/skills
upstream-author: Matt Pocock
license: MIT
related-upstream: prd-to-issues (older sibling, root-level, not the base)
sync-status: adapted (renamed + localized), not verbatim

## Provenance

Adapted from Matt Pocock's `to-tickets` skill. The structure and several
passages are verbatim from upstream; the local version renames it `to-issues`
and binds it to this project's templates and output gate. (Matt Pocock also
ships an older `prd-to-issues`; the local copy descends from the newer
`to-tickets`, not that one.)

## Verbatim from upstream (`to-tickets`)

- Frontmatter `disable-model-invocation: true` (absent on `prd-to-issues`).
- Step 1 "Gather context": "Work from whatever is already in the conversation
  context. If the user passes ... an issue number, URL, or path ... fetch it
  ... and read its full body and comments."
- Step 2 "Explore the codebase (optional)": domain-glossary vocabulary, ADRs,
  and the Kent Beck line "Make the change easy, then make the easy change."
- The tracer-bullet vertical-slice rules (complete path through every layer,
  demoable on its own, prefactor first).
- The quiz step (Title / Blocked by / covered stories; granularity,
  dependencies, merge-or-split questions).
- The issue body template (Parent, What to build, Acceptance criteria,
  Blocked by) and "Do NOT close or modify any parent issue."

## What changed locally

- **Renamed.** `to-tickets` -> `to-issues`; "tickets" wording becomes
  "issues"; "ready-for-agent" label becomes "AFK agents" framing.
- **Local template bindings.** References `../_templates/issue-tracker.md`,
  `../_templates/triage-labels.md`, and `../_templates/human-output-gate.md`.
- **Human-output gate (hard).** Local adds a per-issue approval gate before
  each `gh issue create` (not in upstream).
- **Voice.** Local directs titles/bodies to Esteban's formal voice.
- **Simplified.** Drops upstream's "sized to fit a single fresh context
  window" bullet, the wide-refactor expand-contract exception, the
  local-files-vs-tracker split, and the "frontier" concept.

## sync-status

Adapted. Re-merge by diffing the upstream `to-tickets` link; preserve the
local `to-issues` name, template bindings, human-output gate, and voice note.
