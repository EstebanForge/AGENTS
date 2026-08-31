# Pi Configuration Reference

> Reproduce this pi setup on a fresh machine. Prompts are symlinked from the repo; skills are synced via `manage.sh`.

## Settings (`~/.pi/agent/settings.json`)

Source of truth: the live config on this machine (`~/.pi/agent/settings.json`); this repo's [`../configs/settings.json`](../configs/settings.json) mirrors it. Other machines (construct-cli sandbox included) consume from this repo. Key fields:

```json
{
  "defaultProvider": "zai",
  "defaultModel": "glm-5.3-flash",
  "defaultThinkingLevel": "high",
  "enabledModels": [
    "deepseek/deepseek-v4-flash",
    "deepseek/deepseek-v4-pro",
    "google/gemini-3.6-flash",
    "minimax/MiniMax-M3",
    "claude-bridge/claude-fable-5",
    "claude-bridge/claude-opus-5",
    "claude-bridge/claude-sonnet-5",
    "antigravity/gemini-3-6-flash",
    "antigravity/gemini-3-1-pro",
    "antigravity/claude-sonnet-4-6",
    "antigravity/claude-opus-4-6-thinking",
    "zai/glm-5.3",
    "zai/glm-5.2"
  ]
}
```

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

We use `mcp-cli-ent` cli tool, to avoid native MCP context pollution on Pi. So no Pi extension for MCP servers is required.
Canonical registry in this repo: [`../configs/mcp_servers.json`](../configs/mcp_servers.json). The live `mcp.json` on this machine is intentionally empty (MCP servers replaced by pi packages: context7, agentmemory, codegraph); machines that still use MCP servers provision from the repo registry.

Enabled servers:

- `agentmemory` — cross-session memory (native `pi-agentmemory` extension)
- `ai-vision` — image/video analysis (Gemini)
- `brave-search` — web search, images, news
- `codegraph` — local code knowledge graph
- `context7` — library docs and snippets
- `deepwiki` — public repository documentation

Disabled but available: `chrome-devtools`, `playwright`, `sequential-thinking`, `time`, `cipher`.

## Extensions (`settings.json`)

Installed packages (all active, 47 total). Verified via `pi list`. Canonical source: [`../configs/settings.json`](../configs/settings.json).

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
