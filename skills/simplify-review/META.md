# META

source: https://github.com/DietrichGebert/ponytail/blob/HEAD/skills/ponytail-review/SKILL.md
upstream-repo: DietrichGebert/ponytail
upstream-author: Dietrich Gebert
license: MIT
homepage: https://ponytail.dev
sync-status: adapted (renamed + expanded), not verbatim

## Provenance

Adapted from the `ponytail-review` skill in `DietrichGebert/ponytail` - the
same upstream repo as `deferred-debt` (which forks `ponytail-debt`). The core
idea, the five tags, the examples, and the scoring line are upstream's; the
local version renames the skill and adds a workflow.

## Verbatim shared content

- Description: "Code review focused exclusively on over-engineering. Finds
  what to delete: reinvented standard library, unneeded dependencies,
  speculative abstractions, dead flexibility. One line per finding: location,
  what to cut, what replaces it."
- The five tags with the same definitions: `delete`, `stdlib`, `native`,
  `yagni`, `shrink`.
- The same five examples (email validator, moment.js, AbstractRepository,
  retry wrapper, `dict(zip(...))`).
- Scoring: `net: -<N> lines possible.` and the empty case `Lean already. Ship.`
- Boundaries: over-engineering only; correctness/security/perf routed
  elsewhere.

## What changed locally

- **Renamed.** `ponytail-review` -> `simplify-review`. Revert command and
  description updated accordingly.
- **Workflow added.** Local adds a 4-step workflow (get the diff, filter
  noise, hunt, score) with an explicit noise-skip list (`*.min.js`, `*.lock`,
  `dist/`, `build/`, `vendor/`, `node_modules/`, `*_pb2.py`, images) and a
  STOP on empty diff. Upstream has no workflow section.
- **Sibling cross-references.** Local description ties it to this tree's
  `review-pull-request` (correctness) and `refactor-pass` (applies + verifies)
  as a complementary trio.
- **Emoji dropped.** Upstream marks good/bad examples with emoji; local states
  cuts directly.

## sync-status

Adapted, not synced. Re-merge by reading upstream and folding in any new
tags/examples by hand, keeping the `simplify-review` name and the local
workflow.
