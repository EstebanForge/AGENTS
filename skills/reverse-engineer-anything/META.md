# META

source: https://github.com/morluto/rea/tree/main/skills/reverse-engineer-anything
upstream-repo: morluto/rea
upstream-author: morluto
license: MIT (LICENSE at repo root, Copyright (c) 2026 morluto)
repo-created: 2026-10-04
last-synced: 2026-10-04
upstream-commit: 405732a (2026-10-04)
sync-status: synced (verbatim)

## Provenance

The routing skill bundled with REA ("Reverse Engineer Anything", npm
`rea-agents`). Upstream ships it as the payload of `rea setup`'s agent
integration, which registers the REA MCP server and installs this skill into
the detected agent's skill directory in one transaction. Vendored here
skill-only so the routing guidance is available untethered from the `rea`
setup wizard: it reaches agents through the central `~/.agents/skills/<name>`
symlink sync, and `rea setup` stays optional.

Skill assets: `SKILL.md` plus five guides under `references/`
(native-and-artifacts, javascript-applications, runtime-observation,
evidence-workflows, controlled-replay), copied byte-for-byte.

## What changed locally

Nothing. Verbatim copy, no trims, no rewrites. The body references REA-only
tooling (the `rea` CLI via `npx rea-agents`, the REA MCP server with tools
such as `open_binary` and `analyze_javascript_application`, Hopper or Ghidra
providers). Those are not installed on this stack by default; the skill's own
readiness section handles the gap (run `doctor` only when REA tools are
missing or stale, propose `setup` only after that). If REA is never installed,
the skill routes nothing and degrades to inert guidance.

## sync-status

Synced verbatim at upstream commit 405732a. On refresh, re-copy the upstream
`skills/reverse-engineer-anything/` directory and re-diff byte-for-byte; the
frontmatter `metadata` block (version, tool_count, catalog_digest) tracks
upstream releases and must never be edited locally.
