# ORIGIN

source: https://github.com/mattpocock/skills/blob/main/skills/engineering/implement
upstream-category: engineering
sync-status: adapted (commit step bound to local gate)
last-synced: 2026-11-24
upstream-commit: abeeaf9 (2026-11-19)

## Provenance

Adapted from Matt Pocock's `implement` skill (the execution leg of the
`to-spec` -> `to-tickets` -> `implement` flow). Body is near-verbatim; the
final commit step is bound to this project's human-output gate and the
`git_commit` tool — commits are never auto-posted.

## References to sibling skills

- `/code-review` — vendored locally (`skills/code-review`, 2026-08-28). The
  implement loop's closing review step now resolves.

## 2026-11-24 merge (upstream abeeaf9)

- Adopted upstream's ticket-reference line verbatim (platform-neutral).
- Upstream's new TDD line ("Call the Skill tool with 'tdd'") reworded to
  "Work test-first (see /writing-good-tests)": pi has no Skill tool and
  upstream's `tdd` skill is not vendored; `writing-good-tests` is the local
  equivalent.
- Kept local: commit gate binding and `/code-review` phrasing (upstream
  reverted both to plain/Claude-specific wording).
