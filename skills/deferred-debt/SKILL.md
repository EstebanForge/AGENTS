---
name: deferred-debt
description: >
  Harvest every DEBT: comment in the codebase into a debt ledger, so deliberate
  shortcuts get tracked instead of rotting into "later means never". A DEBT:
  comment names a shortcut's ceiling and its upgrade trigger. Use when the user
  says "tech debt", "what did we defer", "list the shortcuts", "debt ledger",
  "DEBT ledger", "/deferred-debt", or "what's marked to do later". One-shot
  report, changes nothing.
---

# Deferred Debt

Every deliberate shortcut is marked with a `DEBT:` comment naming its ceiling
and upgrade trigger. This collects them into one ledger so a deferral cannot
quietly become permanent.

## The marker convention

In code, mark a deliberate simplification that cuts a real corner with a known
ceiling:

`# DEBT: <ceiling>; upgrade when <trigger>`

- **ceiling** = the limit of the shortcut (global lock, O(n^2) scan, naive
  heuristic, single-process assumption, no retry, hardcoded value).
- **trigger** = the measurable condition that says upgrade now (throughput >
  X, payload > Y, a second caller appears, a profiler says so).

The ceiling without a trigger rots. The trigger is what turns "later" into a
decision instead of a shrine.

Examples:

`# DEBT: global lock, blocks all writers; upgrade when per-account write rate > 50/s`

`// DEBT: O(n^2) scan, fine under 1k rows; upgrade when dataset > 5k or add index`

`# DEBT: naive whitespace split, no quoted-CSV; upgrade when a field contains a comma`

## Scan

Grep the repo for the marker, skipping `node_modules`, `.git`, build output,
and vendored dirs:

`rg -n 'DEBT:' .`

Each hit is one ledger row.

## Output

One row per marker, grouped by file:

`<path>:<line> ceiling: <ceiling>. upgrade: <trigger>.`

Pull the ceiling and trigger straight from the comment text.

Flag the rot risk: any `DEBT:` comment that names no trigger gets a `no-trigger`
tag. Those are the ones that silently rot, they have no condition that ever
fires the upgrade.

End with: `<N> markers (<M> with no trigger).` Nothing found: `No DEBT: markers. Clean ledger.`

## Persist (optional)

To keep the ledger around, ask first. On confirmation, write it to
`DEBT-LEDGER.md` at the repo root, one section per file, rerun on demand.
Never write without asking.

## Boundaries

Reads and reports only, changes nothing (except an explicit, confirmed write
of `DEBT-LEDGER.md`). Does not judge whether a shortcut is justified, only
collects them. To act on a row, fix it in code and drop the marker; this
skill does not edit code. One-shot. "stop deferred-debt" or "normal mode" to
revert.
