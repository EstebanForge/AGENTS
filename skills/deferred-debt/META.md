# META

source: https://github.com/DietrichGebert/ponytail/blob/HEAD/skills/ponytail-debt/SKILL.md
upstream-repo: DietrichGebert/ponytail
upstream-author: Dietrich Gebert
license: MIT
homepage: https://ponytail.dev
sync-status: adapted (renamed + expanded), not verbatim

## Provenance

Adapted from the `ponytail-debt` skill in the `DietrichGebert/ponytail` repo.
The core idea is upstream's: harvest inline deferral comments into a ledger so
a shortcut cannot rot into "later means never", and tag any marker with no
upgrade trigger as the rot risk. The local version is a rename fork with a
more formal marker convention.

## What changed locally

- **Marker renamed.** Upstream `ponytail:` -> local `DEBT:`.
- **Names renamed.** Skill `ponytail-debt` -> `deferred-debt`; ledger file
  `PONYTAIL-DEBT.md` -> `DEBT-LEDGER.md`.
- **Formal marker syntax.** Local codifies
  `# DEBT: <ceiling>; upgrade when <trigger>` and defines `ceiling` and
  `trigger` explicitly, with three worked examples. Upstream is looser
  ("ceiling and upgrade path").
- **Tooling and output.** Local prefers `rg`, skips vendored dirs, and
  tightens the row format to `ceiling: ... upgrade: ...`.
- **Persist gate.** Local adds an explicit "ask first" confirmation before
  writing `DEBT-LEDGER.md`.

## sync-status

Adapted, not synced. The concept and framing track upstream; the marker name
and the convention detail are local. Re-merge by reading upstream and folding
in any new framing by hand, keeping the `DEBT:` marker name.
