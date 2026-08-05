# META

source: https://github.com/vercel-labs/agent-browser/blob/main/skills/agent-browser/SKILL.md
upstream-repo: vercel-labs/agent-browser
upstream-publisher: Vercel Labs
license: Apache-2.0
npm: agent-browser
homepage: https://agent-browser.dev
repo-created: 2026-01-11
sync-status: near-synced (minor drift)

## Provenance

This is the discovery stub shipped by the `agent-browser` CLI project
(`vercel-labs/agent-browser`). It is intentionally static: it only points the
agent at `agent-browser skills get core`, which serves version-matched content
from the installed CLI. The real usage guide lives upstream at
`skill-data/core/SKILL.md` and is fetched on demand, not vendored here.

## Relationship to other browser tooling

This skill is for the standalone `agent-browser` Rust CLI. It is separate from
pi's bundled `pi-agent-browser-native` extension, which has its own README and
command reference under the pi package install. Do not confuse the two.

## Drift vs upstream

- **Frontmatter flag.** Local uses `disable-model-invocation: true`; upstream
  uses `hidden: true`. Both suppress auto-invocation; the local flag matches
  this project's convention.
- **Missing specialized skill.** Upstream now lists
  `agent-browser skills get derive-client` (record a HAR, derive a standalone
  API client). The local stub predates it.

## sync-status

Near-synced. Re-pull the stub from the link above when refreshing; preserve the
local `disable-model-invocation: true` frontmatter on merge.
