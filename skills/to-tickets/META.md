# META

source: https://github.com/mattpocock/skills/blob/main/skills/engineering/to-tickets/SKILL.md
upstream-repo: mattpocock/skills
upstream-author: Matt Pocock
license: MIT
related-upstream: prd-to-issues (older sibling, root-level, not the base)
sync-status: adapted (localized), not verbatim
last-synced: 2026-08-05
upstream-commit: v1.2.0

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

## sync-status

Adapted. Re-merge by diffing the upstream `to-tickets` link; preserve the
local template bindings, human-output gate, GitHub-only simplification, and
voice note.
