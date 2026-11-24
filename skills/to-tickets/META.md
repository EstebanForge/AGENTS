# META

source: https://github.com/mattpocock/skills/blob/main/skills/engineering/to-tickets/SKILL.md
upstream-repo: mattpocock/skills
upstream-author: Matt Pocock
license: MIT
related-upstream: prd-to-issues (older sibling, root-level, not the base)
sync-status: adapted (localized), not verbatim
last-synced: 2026-11-24
upstream-commit: abeeaf9 (2026-11-19)

## Provenance

Adapted from Matt Pocock's `to-tickets` skill. The structure and several
passages are verbatim from upstream; the local version binds it to this
project's templates and output gate. (Matt Pocock also ships an older
`prd-to-issues`; the local copy descends from the newer `to-tickets`.)

## What changed locally

- **Local template bindings.** References `../_templates/issue-tracker.md`,
  `../_templates/triage-labels.md`, and `../_templates/human-output-gate.md`.
- **Human-output gate (hard).** Adds a per-ticket approval gate before each
  `gh issue create` (not in upstream).
- **GitHub-only.** Deliberately drops upstream's local-markdown mode, the
  wide-refactor expand-contract exception, the frontier concept, and
  single-context-window sizing. See `../_templates/issue-tracker.md`.
- **Voice.** Directs titles/bodies to Esteban's formal voice.

## History

- 2026-08-05: renamed back from `to-issues` to `to-tickets` to use upstream
  names. Unit terminology reverted issues -> tickets; "issue tracker",
  "GitHub issue", and `gh issue create` are kept as the system terms
  (matching upstream's mental model). v1.2.0 sync: #502 (local-markdown
  one-file-per-ticket) is N/A — this fork is GitHub-only.

## 2026-11-24 merge (upstream abeeaf9)

- Adopted: blocking-edges step ("Give each ticket its **blocking edges**"),
  the expanded expand–contract wide-refactor section (re-adopted on user
  decision; originally dropped in the v1.2.0 fork), quiz refinements
  ("What it delivers", edge-correctness check), refreshed description
  (GitHub-adapted), punctuation.
- Still deliberately dropped (GitHub-only simplification): local-markdown
  publish mode, upstream's "Work the frontier" line (the local
  dependency-order publish line covers it), single-context-window slice
  sizing, tracker-branching publish step, dual local/issue templates.
- Kept local: `_templates` bindings, per-ticket human-output gate, single
  GitHub ticket template, Hard rules + voice Notes sections.

## sync-status

Adapted. Re-merge by diffing the upstream `to-tickets` link; preserve the
local template bindings, human-output gate, GitHub-only simplification, and
voice note.
