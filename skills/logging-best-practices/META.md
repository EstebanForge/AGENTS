# META

source: https://github.com/boristane/agent-skills/blob/main/skills/logging-best-practices/SKILL.md
upstream-repo: boristane/agent-skills
upstream-author: Boris Tane (boristane)
license: MIT (declared in SKILL.md frontmatter; upstream repo ships no LICENSE file)
repo-created: 2026-09-08
last-synced: 2026-09-08
upstream-commit: 8aa14dd (2026-01-21)
sync-status: current (verbatim copy, no local edits)

## Provenance

Verbatim vendored copy of boristane/agent-skills `logging-best-practices`, imported
on 2026-09-08. Upstream teaches the wide events pattern (canonical log lines): one
context-rich structured event per request per service, emitted in a `finally`
block, with high-cardinality IDs, business context, and environment context.

## Layout

Upstream layout preserved: `SKILL.md` (agent instructions), `README.md` (human
overview), `metadata.json` (upstream version/references), `rules/` (four reference
files: wide-events, context, structure, pitfalls). The `rules/` files are the
canonical body; `SKILL.md` inlines a summary.

## sync-status

Current. Re-diff against the linked file when refreshing.
