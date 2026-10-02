# Pi Configuration Reference

> Reproduce this pi setup on a fresh machine. Prompts are symlinked from the repo; skills are synced via `manage.sh`.

## Web Providers (`~/.pi/agent/web-providers.json`)

```json
{
  "tools": {
    "search": "exa",
    "contents": "exa",
    "research": "exa",
    "answer": "exa"
  },
  "providers": {
    "brave": {
      "credentials": { "search": "REDACTED" }
    },
    "exa": {
      "credentials": { "api": "REDACTED" }
    }
  }
}
```

> Secrets redacted. Set `brave.credentials.search` and `exa.credentials.api` to your own keys. Not tracked in this repo.

## MCP Servers

Pi has no native MCP support. MCP servers run through the `mcp-cli-ent` CLI instead; each machine keeps its config at `~/.config/mcp-cli-ent/mcp_servers.json`, provisioned from the canonical registry in this repo: [`../configs/mcp_servers.json`](../configs/mcp_servers.json). Docs, memory, and codegraph are covered by native pi extensions, so no MCP servers are wired into Pi itself.

Enabled servers:

- `agentmemory` — cross-session memory (native `pi-agentmemory` extension)
- `ai-vision` — image/video analysis (Gemini)
- `brave-search` — web search, images, news
- `codegraph` — local code knowledge graph
- `context7` — library docs and snippets

Disabled but available: `chrome-devtools`, `playwright`, `sequential-thinking`, `deepwiki`, `time`, `cipher`.

## Extensions

Installed packages (all active, 41 total). Verified via `pi list`.

### Package sources and install commands

Each package was located in this order: 1. [pi.dev/packages](https://pi.dev/packages), 2. npm registry (keywords `pi-extension`, `pi-package`), 3. GitHub. First match wins. 37 of 41 are in the pi.dev catalog. 4 are GitHub-only.

| Package | Found on | Install command |
|---|---|---|
| `pi-notify` | pi.dev/packages | `pi install npm:pi-notify` |
| `pi-web-providers` | pi.dev/packages | `pi install npm:pi-web-providers` |
| `@tintinweb/pi-tasks` | pi.dev/packages | `pi install npm:@tintinweb/pi-tasks` |
| `pi-nested-agents-md` | GitHub | `pi install git:github.com/code-yeongyu/pi-nested-agents-md` |
| `@ff-labs/pi-fff` | pi.dev/packages | `pi install npm:@ff-labs/pi-fff` |
| `@upstash/context7-pi` | pi.dev/packages | `pi install npm:@upstash/context7-pi` |
| `@estebanforge/pi-agentmemory` | pi.dev/packages | `pi install npm:@estebanforge/pi-agentmemory` |
| `pi-token-speed` | pi.dev/packages | `pi install npm:pi-token-speed` |
| `pi-diff-review` | pi.dev/packages | `pi install npm:pi-diff-review` |
| `@juicesharp/rpiv-ask-user-question` | pi.dev/packages | `pi install npm:@juicesharp/rpiv-ask-user-question` |
| `pi-token-burden` | pi.dev/packages | `pi install npm:pi-token-burden` |
| `pi-claude-bridge` | pi.dev/packages | `pi install npm:pi-claude-bridge` |
| `@estebanforge/pi-glm-tweaks` | pi.dev/packages | `pi install npm:@estebanforge/pi-glm-tweaks`, then apply the `extensions` override shown below |
| `@estebanforge/pi-codegraph-enhanced` | pi.dev/packages | `pi install npm:@estebanforge/pi-codegraph-enhanced` |
| `@estebanforge/pi-rtk-optimizer` | pi.dev/packages | `pi install npm:@estebanforge/pi-rtk-optimizer` (maintained fork of the inactive MasuRii original) |
| `@estebanforge/pi-ask-codex` | pi.dev/packages | `pi install npm:@estebanforge/pi-ask-codex` |
| `@estebanforge/pi-slack-me` | pi.dev/packages | `pi install npm:@estebanforge/pi-slack-me` |
| `@pi-kaush/pi-inline-skill-identifier` | pi.dev/packages | `pi install npm:@pi-kaush/pi-inline-skill-identifier` |
| `pi-agent-browser-screenshot` | GitHub | `pi install git:github.com/jnsahaj/pi-agent-browser-screenshot` |
| `pi-queue-steer` | GitHub | `pi install git:github.com/tmustier/pi-queue-steer` |
| `@estebanforge/pi-token-cost-ledger` | pi.dev/packages | `pi install npm:@estebanforge/pi-token-cost-ledger` |
| `pi-unified-exec` | pi.dev/packages | `pi install npm:pi-unified-exec` |
| `@tmustier/pi-session-recap` | pi.dev/packages | `pi install npm:@tmustier/pi-session-recap` |
| `pi-vision-handoff` | pi.dev/packages | `pi install npm:pi-vision-handoff` |
| `@thurstonsand/pi-librarian` | pi.dev/packages | `pi install npm:@thurstonsand/pi-librarian` |
| `pi-agent-browser-native` | pi.dev/packages | `pi install npm:pi-agent-browser-native` |
| `pi-review-loop` | pi.dev/packages | `pi install npm:pi-review-loop` |
| `@pi-stef/atlassian` | pi.dev/packages | `pi install npm:@pi-stef/atlassian` |
| `@estebanforge/pi-git-me` | pi.dev/packages | `pi install npm:@estebanforge/pi-git-me` |
| `@tmustier/pi-tab-status` | pi.dev/packages | `pi install npm:@tmustier/pi-tab-status` |
| `pi-clarify` | pi.dev/packages | `pi install npm:pi-clarify` |
| `@estebanforge/pi-asana-me` | pi.dev/packages | `pi install npm:@estebanforge/pi-asana-me` |
| `@tintinweb/pi-subagents` | pi.dev/packages | `pi install npm:@tintinweb/pi-subagents` |
| `@estebanforge/pi-ask-claude` | pi.dev/packages | `pi install npm:@estebanforge/pi-ask-claude` |
| `@estebanforge/pi-hostname` | pi.dev/packages | `pi install npm:@estebanforge/pi-hostname` |
| `@estebanforge/pi-zendesk-me` | pi.dev/packages | `pi install npm:@estebanforge/pi-zendesk-me` |
| `@estebanforge/pi-antigravity-bridge` | pi.dev/packages | `pi install npm:@estebanforge/pi-antigravity-bridge` |
| `pi-redact-all` | pi.dev/packages | `pi install npm:pi-redact-all` |
| `pi-observational-memory` | pi.dev/packages | `pi install npm:pi-observational-memory` |
| `umputun/revdiff` | GitHub | `pi install https://github.com/umputun/revdiff` |
| `@estebanforge/pi-tool-display` | pi.dev/packages | `pi install npm:@estebanforge/pi-tool-display` (maintained fork of the inactive MasuRii original) |

Notes:

- `pi-agent-browser-screenshot`, `pi-nested-agents-md`, and `pi-queue-steer` are not in the pi.dev catalog and have no npm package under their bare or scoped names. GitHub is the only source; install with the `git:` form. `umputun/revdiff` is also outside the catalog and is installed here from the plain URL form, which clones the repo head the same way the `git:` form does.
- `pi-notify` and `pi-review-loop` are installed here with the `git:` form (see `packages` below). The catalog also publishes both on npm. The npm form tracks releases; the `git:` form tracks the repo head.
- The pi.dev catalog indexes npm packages tagged `pi-extension` or `pi-package`. A catalog page per package lives at `https://pi.dev/packages/<name>`.

```json
"packages": [
  "git:github.com/ferologics/pi-notify",
  "npm:pi-web-providers",
  "npm:@tintinweb/pi-tasks",
  "git:github.com/code-yeongyu/pi-nested-agents-md",
  "npm:@ff-labs/pi-fff",
  "npm:@upstash/context7-pi",
  "npm:@estebanforge/pi-agentmemory",
  "npm:pi-token-speed",
  "npm:pi-diff-review",
  "npm:@juicesharp/rpiv-ask-user-question",
  "npm:pi-token-burden",
  "npm:pi-claude-bridge",
  { "source": "npm:@estebanforge/pi-glm-tweaks", "extensions": ["+extensions/index.ts"] },
  "npm:@estebanforge/pi-codegraph-enhanced",
  "npm:@estebanforge/pi-rtk-optimizer",
  "npm:@estebanforge/pi-ask-codex",
  "npm:@estebanforge/pi-slack-me",
  "npm:@pi-kaush/pi-inline-skill-identifier",
  "git:github.com/jnsahaj/pi-agent-browser-screenshot",
  "git:github.com/tmustier/pi-queue-steer",
  "npm:@estebanforge/pi-token-cost-ledger",
  "npm:pi-unified-exec",
  "npm:@tmustier/pi-session-recap",
  "npm:pi-vision-handoff",
  "npm:@thurstonsand/pi-librarian",
  "npm:pi-agent-browser-native",
  "git:github.com/earendil-works/pi-review-loop",
  "npm:@pi-stef/atlassian",
  "npm:@estebanforge/pi-git-me",
  "npm:@tmustier/pi-tab-status",
  "git:github.com/dodo-reach/pi-clarify",
  "npm:@estebanforge/pi-asana-me",
  "npm:@tintinweb/pi-subagents",
  "npm:@estebanforge/pi-ask-claude",
  "npm:@estebanforge/pi-hostname",
  "npm:@estebanforge/pi-zendesk-me",
  "npm:@estebanforge/pi-antigravity-bridge",
  "npm:pi-redact-all",
  "npm:pi-observational-memory",
  "https://github.com/umputun/revdiff",
  "npm:@estebanforge/pi-tool-display"
]
```

> `@estebanforge/pi-token-cost-ledger` owns token-spend tracking end to end:
> a per-day JSONL ledger plus the `/token-usage` report (real USD and
> API-equivalent USD). It replaces the deprecated `@ctogg/pi-cost-counter`
> and the old host-side script stack.
> Full setup: [AGENT-PI-cost-tracking.md](AGENT-PI-cost-tracking.md).
