# META

source: https://gist.github.com/garrytan/001f9074cab1a8f545ebecbc73a813df (plan-exit-review v2.0.0, 2026-02-25)
upstream-repo: https://github.com/garrytan/gstack (skill: plan-eng-review)
upstream-author: Garry Tan (Y Combinator)
license: unverified (check gstack repo LICENSE; the gist carries none)
sync-status: adapted (simplified fork), not verbatim

## Provenance

Derived from Garry Tan's plan-review skill. The earliest artifact is the
gist above (`plan-exit-review`, created 2026-02-25); the maintained form is
`garrytan/gstack` `plan-eng-review` (v1.0.0+). The local `plan` skill is a
stripped-down adaptation of the same source.

## Verbatim shared content

- Opening directive: "Review this plan thoroughly before making any code
  changes. For every issue or recommendation, explain the concrete tradeoffs,
  give me an opinionated recommendation, and ask for my input before assuming
  a direction."
- The "My engineering preferences" block (DRY aggressively, "too many tests
  than too few", "engineered enough", "edge cases, not fewer; thoughtfulness
  > speed", "Bias toward explicit over clever").
- The four review sections: Architecture, Code Quality, Tests, Performance,
  with the same bullet lists.
- The per-issue structure: concrete file:line refs, 2-3 options including
  "do nothing", effort/risk/impact/maintenance burden, recommended option
  given and mapped to preferences.
- BIG CHANGE / SMALL CHANGE choice, NUMBER issues + LETTER options, and the
  `AskUserQuestion` interaction pattern.

## What the local copy dropped (present upstream)

- Step 0 Scope Challenge (and gstack's Scope gate hard STOP).
- The "Documentation and diagrams" ASCII-art section and diagram-maintenance
  rule.
- gstack-only additions: Cognitive Patterns, Required outputs (NOT in scope,
  What already exists, TODOS.md, Failure modes, Completion summary),
  Retrospective learning, Unresolved decisions, and the gstack preamble /
  template vars / bash design-doc check.
- Upstream's "do nothing" option framing is kept; upstream's "lead with your
  recommendation as a directive" is softened in the local description.

## License note

The gist carries no license. The `garrytan/gstack` repo license was not
confirmed in this pass; verify it before any redistribution beyond personal
use.

## sync-status

Adapted and simplified. Re-merge by diffing the gist and the gstack
`plan-eng-review` skill; the local copy intentionally keeps the lighter
4-section structure.
