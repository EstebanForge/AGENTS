# ORIGIN

source: https://github.com/mattpocock/skills/blob/main/skills/engineering/implement
upstream-category: engineering
sync-status: adapted (commit step bound to local gate)
last-synced: 2026-08-05
upstream-commit: v1.2.0

## Provenance

Adapted from Matt Pocock's `implement` skill (the execution leg of the
`to-spec` -> `to-tickets` -> `implement` flow). Body is near-verbatim; the
final commit step is bound to this project's human-output gate and the
`git_commit` tool — commits are never auto-posted.

## References to sibling skills

- `/tdd` — vendored locally (`skills/tdd`).
- `/code-review` — referenced upstream but **not** vendored here. The
  implement loop's review step points at a skill this tree does not yet
  carry; flag for a future add, or substitute `review-pull-request` /
  `simplify-review` per context.
