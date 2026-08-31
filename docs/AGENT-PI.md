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
- `deepwiki` — public repository documentation

Disabled but available: `chrome-devtools`, `playwright`, `sequential-thinking`, `time`, `cipher`.

## Extensions

Installed packages (all active, 47 total). Verified via `pi list`.

```json
"packages": [
  "git:github.com/ferologics/pi-notify",
  "npm:pi-web-providers",
  "npm:@tintinweb/pi-tasks",
  "npm:pi-context-usage",
  "git:github.com/code-yeongyu/pi-nested-agents-md",
  "npm:pi-init",
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
  "npm:pi-rtk-optimizer",
  "npm:@estebanforge/pi-ask-codex",
  "npm:@estebanforge/pi-slack-me",
  "npm:@pi-kaush/pi-inline-skill-identifier",
  "npm:@mobrienv/pi-tidy-tools",
  "git:github.com/jnsahaj/pi-agent-browser-screenshot",
  "git:github.com/tmustier/pi-queue-steer",
  "npm:@estebanforge/pi-token-cost-ledger",
  "npm:pi-unified-exec",
  "npm:@tmustier/pi-session-recap",
  "npm:pi-qmd-adaptive-search",
  "npm:pi-vision-handoff",
  "npm:@thurstonsand/pi-librarian",
  "npm:pi-agent-browser-native",
  "npm:pi-visualize-code-changes",
  "git:github.com/earendil-works/pi-review-loop",
  "npm:@estebanforge/pi-antigravity-bridge",
  "npm:@pi-stef/atlassian",
  "npm:@estebanforge/pi-git-me",
  "npm:@tmustier/pi-tab-status",
  "git:github.com/dodo-reach/pi-clarify",
  "npm:@estebanforge/pi-asana-me",
  "npm:@tintinweb/pi-subagents",
  "npm:@estebanforge/pi-show-me-the-meat",
  "npm:@estebanforge/pi-ask-claude",
  "npm:@estebanforge/pi-hostname"
]
```

> `@estebanforge/pi-token-cost-ledger` writes the spend ledger consumed by
> the token cost tracker (replaces the deprecated `@ctogg/pi-cost-counter`).
> Full setup + scripts + installer: [AGENT-PI-cost-tracking.md](AGENT-PI-cost-tracking.md).
