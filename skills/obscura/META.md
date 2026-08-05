# META

source: https://github.com/h4ckf0r0day/obscura/blob/main/skills/obscura/SKILL.md
upstream-repo: h4ckf0r0day/obscura
upstream-author: SGavrl (h4ckf0r0day)
license: Apache-2.0
homepage: https://obscura.sh
repo-created: 2026-04-13
sync-status: adapted (Construct-env fork), not verbatim

## Provenance

The upstream `obscura` project ships its own agent skill at
`skills/obscura/SKILL.md`. The local skill documents the same tool (the
`obscura` / `obscura-worker` Rust fetch/scrape engine + CDP/MCP server) and
shares the command surface (`fetch`, `scrape`, `serve`, `mcp`, the global
`--stealth` flag, dump modes). It is a fork rewritten for this environment,
not a verbatim copy.

## Local-only (not in upstream)

- "obscura vs agent-browser" comparison and the escalate-to-agent-browser rule
  (ties it to this project's `agent-browser` skill).
- Construct install path: `~/.local/bin/obscura` on host, `construct build`
  post_install hook in the Construct container. Upstream uses `cargo build`.
- The `obscura-worker` binary.
- Recipes section (HN `--eval` extraction, `--dump assets` for SPA API
  discovery, binary `--dump original`, `networkidle0` + `--timeout` pairing).
- The GitHub ES-module crash note (exit 101,
  `TypeError: Cannot convert undefined or null to object`) as the escalation
  signal.
- `--v8-flags "--max-old-space-size=4096"` guardrail for JS heap limits.

## Upstream-only (not carried locally)

- "Why pick Obscura over Chrome" benchmark/resource table.
- `cargo build` build instructions and the stealth-feature build notes.
- Playwright/Puppeteer `connectOverCDP` / `browserWSEndpoint` code samples.
- Scaling profile and the crate safety section.

## sync-status

Adapted. Re-merge by diffing the upstream skill link above; preserve the
Construct install path, agent-browser comparison, and recipes on merge.
