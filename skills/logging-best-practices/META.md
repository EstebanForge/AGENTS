# META

source: https://github.com/boristane/agent-skills/blob/main/skills/logging-best-practices/SKILL.md
upstream-repo: boristane/agent-skills
upstream-author: Boris Tane (boristane)
license: MIT (declared in SKILL.md frontmatter; upstream repo ships no LICENSE file)
repo-created: 2026-09-08
last-synced: 2026-09-08
upstream-commit: 8aa14dd (2026-01-21)
sync-status: adapted (local writing pass, see What changed locally)

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

## What changed locally

- **Description carries trigger branches.** Upstream's description stated identity
  only ("logging best practices... for powerful debugging and analytics"). Local
  pointer states the pattern and the branches that fire it: writing, reviewing,
  or planning logging for a service.
- **Guidelines section collapsed to pointers.** Four subsections restated the
  bullets of the rules/ files they routed to; each is now one line naming the
  file and its branch. Body restatement cut, routing kept.
- **Body version line cut.** `Version: 1.0.0` duplicated the frontmatter and
  metadata.json.

## sync-status

Adapted. On refresh, re-diff against the linked file and keep the local
pointer description and collapsed Reference Files section.
