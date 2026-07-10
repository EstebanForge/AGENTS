---
name: simplify-review
description: >
  Code review focused exclusively on over-engineering. Finds what to delete or
  shrink: reinvented standard library, unneeded dependencies, speculative
  abstractions, dead flexibility. One line per finding: location, what to cut,
  what replaces it. List-only, does not apply fixes. Use when the user says
  "is this over-engineered", "what can we delete from this diff", "simplify
  review", "review for complexity", or invokes /simplify-review. Complements
  review-pull-request (correctness) and refactor-pass (applies + verifies).
---

# Simplify Review

Review a diff for unnecessary complexity. One line per finding: location, what
to cut, what replaces it. The diff's best outcome is getting shorter.

## Scope

Over-engineering and complexity only. This is a distinct lens from:
- `review-pull-request` = correctness, security, breaking changes, perf.
- `refactor-pass` = applies changes and runs build/tests to verify.

This skill lists what could be cut. It applies nothing.

## Workflow

1. Get the diff. Explicit ref/r range, else the working tree: `git diff` or
   `git diff <base>...HEAD`. If the diff is empty or missing, STOP and report
   the error. Never review on an empty diff.
2. Filter noise. Skip generated, vendored, lock files (`*.min.js`, `*.lock`,
   `dist/`, `build/`, `vendor/`, `node_modules/`, `*_pb2.py`, images). Note
   them changed, do not review.
3. Hunt over-engineering in what was added or changed. One line per finding.
4. End with the score. Stop.

## Tags

`<location>: <tag>: <what to cut>. <replacement>.`

- `delete` = dead code, unused flexibility, speculative feature, wrapper that
  only delegates. Replacement: nothing.
- `stdlib` = hand-rolled thing the standard library ships. Name the function.
- `native` = dependency or code doing what the platform already does. Name the
  feature.
- `yagni` = abstraction with one implementation, config nobody sets, layer with
  one caller.
- `shrink` = same logic, fewer lines. Show the shorter form.

## Examples

Avoid hedging prose ("this might be more complex than necessary, have you
considered..."). State the cut:

`L12-38: stdlib: 27-line email validator class. "@" in email is 1 line; real validation is the confirmation mail.`

`L4: native: moment.js imported for one format call. Intl.DateTimeFormat, 0 deps.`

`repo.py:88: yagni: AbstractRepository with one implementation. Inline it until a second one exists.`

`L52-71: delete: retry wrapper around an idempotent local call. Nothing replaces it.`

`L30-44: shrink: manual loop builds dict. dict(zip(keys, values)), 1 line.`

## Scoring

End with the only metric that matters: `net: -<N> lines possible.`

Nothing to cut: `Lean already. Ship.` and stop.

## Boundaries

Scope: over-engineering and complexity only. Correctness bugs, security holes,
and performance are out of scope. Route them to `review-pull-request`, do not
mix them in here. A single smoke test, `assert`-based self-check, or one small
test is the minimum check, not bloat; never flag it for deletion. "stop
simplify-review" or "normal mode": revert to verbose review style.
