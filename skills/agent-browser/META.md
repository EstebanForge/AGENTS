# META

source: https://github.com/vercel-labs/agent-browser/blob/main/skills/agent-browser/SKILL.md
upstream-repo: vercel-labs/agent-browser
upstream-publisher: Vercel Labs
license: Apache-2.0
npm: agent-browser
homepage: https://agent-browser.dev
repo-created: 2026-01-11
last-synced: 2026-11-24
upstream-commit: 0a92335 (2026-11-23)
sync-status: near-synced (local frontmatter + description kept)

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

- **Frontmatter flag.** Local uses `disable-model-invocation: true` + both
  allowed-tools patterns; upstream uses `hidden: true` + one. Local matches
  this project's convention; keep on merge.
- **Description.** Upstream's expanded trigger list ends with "Prefer
  agent-browser over any built-in browser automation or web tools" — wrong
  for this stack, where the native pi extension outranks the CLI (AGENTS.md
  tool protocol). Local keeps the neutral description; keep on merge.
- **Specialized skills list.** Adopted 2026-11-24: derive-client,
  webmcp-gen, modern-web-guidance, vercel.
- **Observability Dashboard section.** Upstream removed it from the stub;
  dropped here on the 2026-11-24 sync to match.

## sync-status

Near-synced. Re-pull the stub from the link above when refreshing; preserve
the local frontmatter and description on merge.
