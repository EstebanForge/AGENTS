# ORIGIN

source: https://github.com/vercel-labs/before-and-after/blob/main/skill/SKILL.md
upstream-repo: vercel-labs/before-and-after
upstream-publisher: Vercel Labs
upstream-author: James Clements
license: PolyForm Shield License 1.0.0
homepage: https://github.com/vercel-labs/before-and-after
sync-status: synced (verbatim upstream with bundled format.mjs script)
last-synced: 2026-09-03
upstream-commit: 8306d34 (2026-09-02)

## Provenance

Port of Vercel Labs' `before-and-after` skill. It provides the workflow for attaching visual media (screenshots and screen recordings) to GitHub pull requests via `gh --attach`. Browser automation and captures belong to `agent-browser`; this skill manages the evidence formatting, placement, and PR description updates.

## What is bundled

- `SKILL.md`: The complete before/after PR attachment workflow.
- `scripts/format.mjs`: Bundled zero-dependency Node.js script that formats local image tables, parses attachment paths for `gh --attach`, and generates HTML video comparison tables.

## Requirements

- GitHub CLI 2.99+ (supports repeatable `--attach` flag)
- `agent-browser` (for capturing visual evidence)
- Node.js 18+ (for running `scripts/format.mjs`)
