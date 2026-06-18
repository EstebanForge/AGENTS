# MCP Servers

Central registry of MCP servers used across all agents.
When adding a new server, update this file first, then apply to each agent's config.

## Servers

### agentmemory

Cross-session memory (recall, save, search). Requires local agentmemory service.

```json
{
  "enabled": true,
  "command": "npx",
  "args": ["-y", "@agentmemory/mcp"],
  "directTools": true,
  "persistent": false,
  "timeout": 30
}
```

### chrome-devtools

Browser automation: console, navigation, screenshots.

```json
{
  "enabled": false,
  "command": "npx",
  "args": ["-y", "chrome-devtools-mcp@latest", "--isolated"],
  "persistent": true,
  "timeout": 60
}
```

### playwright

Browser automation: elements, snapshots, interactions.

```json
{
  "enabled": false,
  "command": "npx",
  "args": ["-y", "@playwright/mcp@latest"],
  "persistent": true,
  "timeout": 60
}
```

### sequential-thinking

Problem-solving and planning.

```json
{
  "enabled": false,
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"],
  "persistent": false,
  "timeout": 30
}
```

### context7

Code library docs and snippets.

**Pi**: Native via `@upstash/context7-pi` extension (tools: `resolve-library-id`, `query-docs`). No MCP config needed.

**Other agents**: MCP server config below.

```json
{
  "enabled": true,
  "command": "npx",
  "args": ["-y", "@upstash/context7-mcp", "--api-key", "${CONTEXT7_API_KEY}"],
  "persistent": false,
  "timeout": 30
}
```

### deepwiki

Repository documentation from public Git repos.

```json
{
  "enabled": true,
  "command": "npx",
  "args": ["-y", "mcp-remote", "https://mcp.deepwiki.com/mcp"],
  "persistent": false,
  "timeout": 30
}
```

### brave-search

Search the web, images, videos, news + AI summaries.

```json
{
  "enabled": true,
  "command": "npx",
  "args": ["-y", "@brave/brave-search-mcp-server"],
  "env": {
    "BRAVE_API_KEY": "${BRAVE_API_KEY}"
  },
  "persistent": false,
  "timeout": 30
}
```

### time

Current time and timezone conversions.

```json
{
  "enabled": false,
  "command": "uvx",
  "args": ["mcp-server-time"],
  "persistent": false,
  "timeout": 30
}
```

### cipher

Memory layer for coding agents: auto-generate AI memories, IDE switching, team sharing.

```json
{
  "enabled": false,
  "type": "stdio",
  "command": "cipher",
  "args": ["--mode", "mcp"],
  "env": {
    "MCP_SERVER_MODE": "aggregator",
    "OPENAI_API_KEY": "${OPENAI_API_KEY}",
    "ANTHROPIC_API_KEY": "${ANTHROPIC_API_KEY}"
  },
  "persistent": false,
  "timeout": 30
}
```

### ai-vision

Image and video analysis via AI vision models (Google provider).

```json
{
  "enabled": true,
  "command": "npx",
  "args": ["-y", "ai-vision-mcp"],
  "env": {
    "IMAGE_PROVIDER": "google",
    "VIDEO_PROVIDER": "google",
    "GEMINI_API_KEY": "${GEMINI_API_KEY}"
  },
  "persistent": false,
  "timeout": 300
}
```

### codegraph

Local code knowledge graph. Symbol search, call graphs, impact analysis. 100% local.

```json
{
  "enabled": true,
  "command": "codegraph",
  "args": ["serve", "--mcp"],
  "persistent": false,
  "timeout": 30
}
```

## Agent config paths

Paths where MCP servers are configured per agent. Format and location vary.

| Agent | Config path | Format |
|---|---|---|
| **Pi** | `~/.pi/agent/mcp.json` | JSON (`mcpServers`) |
| **Antigravity** | `~/.gemini/antigravity/mcp_config.json` | JSON (`mcpServers`) |
| **Antigravity CLI** | `~/.gemini/antigravity-cli/mcp_config.json` | JSON (`mcpServers`) |
| **Antigravity IDE** | `~/.gemini/antigravity-ide/mcp_config.json` | JSON (`mcpServers`) |
| **Claude Code** | `~/.claude.json` | JSON (`mcpServers`) |
| **Codex** | `~/.codex/config.toml` | TOML (`[mcp_servers.*]`) |
| **Opencode** | `~/.config/opencode/opencode.json` | JSON (`mcp` key) |
| **Qwen** | `~/.qwen/settings.json` | JSON (`mcpServers`) |
| **Amp** | `~/.config/amp/settings.json` | JSON (check docs) |
| **Copilot** | `~/.copilot/mcp-config.json` | JSON |
| **Factory (Droid)** | `~/.factory/mcp.json` | JSON (`mcpServers`) |
| **Goose** | `~/.config/goose/config.yaml` | YAML (`extensions`) |
| **Kilocode** | `~/.config/kilo/kilo.jsonc` | JSONC (`mcp`) |
| **Cline** | `~/.cline/data/settings/cline_mcp_settings.json` | JSON (`mcpServers`) |
| **VS Code** | `~/Library/Application Support/Code/User/mcp.json` | JSON |


### Construct-cli variants

| Agent | Config path |
|---|---|
| **Antigravity** | `~/.config/construct-cli/home/.gemini/antigravity/mcp_config.json` |
| **Antigravity CLI** | `~/.config/construct-cli/home/.gemini/antigravity-cli/mcp_config.json` |
| **Antigravity IDE** | `~/.config/construct-cli/home/.gemini/antigravity-ide/mcp_config.json` |
| **Claude Code** | `~/.config/construct-cli/home/.claude.json` |
| **Codex** | `~/.config/construct-cli/home/.codex/config.toml` |
| **Opencode** | `~/.config/construct-cli/home/.config/opencode/opencode.json` |
| **Pi** | `~/.config/construct-cli/home/.pi/agent/mcp.json` |
| **Qwen** | `~/.config/construct-cli/home/.qwen/settings.json` |
| **Amp** | `~/.config/construct-cli/home/.config/amp/settings.json` |
| **Copilot** | `~/.config/construct-cli/home/.copilot/mcp-config.json` |
| **Factory (Droid)** | `~/.config/construct-cli/home/.factory/mcp.json` |
| **Goose** | `~/.config/construct-cli/home/.config/goose/config.yaml` |
| **Kilocode** | `~/.config/construct-cli/home/.config/kilo/kilo.jsonc` |
| **Cline** | `~/.config/construct-cli/home/.cline/data/settings/cline_mcp_settings.json` |

## Format notes

Not all agents use the same JSON schema. Key differences:

- **Pi, Antigravity, Claude, Copilot, Factory, Cline, Qwen**: `{ "mcpServers": { "name": { "command": "...", "args": [...] } } }`
- **Codex**: TOML. `[mcp_servers.name]` with `command = "..."`, `args = [...]`, `[mcp_servers.name.env]`
- **Opencode**: `{ "mcp": { "name": { "command": "...", "args": [...] } } }` (note: `mcp` not `mcpServers`)
- **Goose**: YAML `extensions` list. Each entry has `name`, `transport.type`, `transport.command`, `transport.args`, `env`
- **Kilocode**: JSONC `{ "mcp": { "name": { "type": "local", "command": ["cmd", "arg"] } } }` (command is array, not separate command+args)

## Adding a new server

1. Add the server config block to the **Servers** section above.
2. Convert format per agent using the **Format notes**.
3. Apply to each agent config path listed above.
4. Restart the agent.

## Removing a server

1. Remove from **Servers** section above.
2. Remove from each agent config path.
3. Restart the agent.
