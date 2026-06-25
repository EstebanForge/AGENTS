# Pi Configuration Reference

> Reproduce this pi setup on a fresh machine. Prompts are symlinked from the repo; skills are synced via `manage.sh`.

## Settings (`~/.pi/agent/settings.json`)

Canonical source in this repo: [`../configs/settings.json`](../configs/settings.json). Key fields:

```json
{
  "defaultProvider": "zai",
  "defaultModel": "glm-5.2",
  "defaultThinkingLevel": "high",
  "enabledModels": [
    "zai/glm-5.1",
    "google/gemini-2.5-flash",
    "google/gemini-2.5-pro",
    "google/gemini-3.1-flash-lite",
    "google/gemini-3.5-flash",
    "deepseek/deepseek-v4-flash",
    "deepseek/deepseek-v4-pro",
    "minimax/MiniMax-M3",
    "zai/glm-5.2",
    "claude-bridge/claude-opus-4-8",
    "claude-bridge/claude-haiku-4-5",
    "claude-bridge/claude-sonnet-4-6"
  ]
}
```

## Custom Providers (`~/.pi/agent/models.json`)

Mirrors the live file. `deepseek` and `lmstudio` are custom; `zai` is custom (GLM-5.2 via the Anthropic-style endpoint). Other providers in `enabledModels` (`google`, `minimax`, `claude-bridge`) use pi's built-in provider registry.

```json
{
  "providers": {
    "lmstudio": {
      "baseUrl": "http://192.168.10.44:1234/v1",
      "api": "openai-completions",
      "apiKey": "lmstudio",
      "compat": {
        "supportsDeveloperRole": false,
        "supportsReasoningEffort": false
      },
      "models": [
        { "id": "google/gemma-4-12b", "name": "Gemma 4 12B (LMStudio)", "input": ["text", "image"], "contextWindow": 131072 },
        { "id": "qwen/qwen3.5-35b-a3b", "name": "Qwen 3.5 35B A3B (LMStudio)", "input": ["text"], "contextWindow": 131072 },
        { "id": "qwen/qwen3.5-9b", "name": "Qwen 3.5 9B (LMStudio)", "input": ["text"], "contextWindow": 131072 },
        { "id": "microsoft/phi-4", "name": "Phi-4 (LMStudio)", "input": ["text"], "contextWindow": 16384 },
        { "id": "microsoft/phi-4-reasoning-plus", "name": "Phi-4 Reasoning+ (LMStudio)", "reasoning": true, "input": ["text"], "contextWindow": 16384 },
        { "id": "openai/gpt-oss-20b", "name": "GPT-OSS 20B (LMStudio)", "input": ["text"], "contextWindow": 131072 },
        { "id": "qwen/qwen3-coder-30b", "name": "Qwen3 Coder 30B (LMStudio)", "input": ["text"], "contextWindow": 131072 },
        { "id": "mistralai/ministral-3-14b-reasoning", "name": "Ministral 3 14B Reasoning (LMStudio)", "reasoning": true, "input": ["text"], "contextWindow": 131072 }
      ]
    },
    "deepseek": {
      "baseUrl": "https://api.deepseek.com",
      "api": "openai-completions",
      "apiKey": "$DEEPSEEK_API_KEY",
      "models": [
        {
          "id": "deepseek-v4-pro",
          "name": "DeepSeek V4 Pro",
          "contextWindow": 1000000,
          "maxTokens": 384000,
          "input": ["text"],
          "reasoning": true,
          "cost": { "input": 1.74, "output": 3.48, "cacheRead": 0.145, "cacheWrite": 0 },
          "compat": {
            "requiresReasoningContentOnAssistantMessages": true,
            "thinkingFormat": "deepseek",
            "reasoningEffortMap": {
              "minimal": "high", "low": "high", "medium": "high", "high": "high", "xhigh": "max"
            }
          }
        },
        {
          "id": "deepseek-v4-flash",
          "name": "DeepSeek V4 Flash",
          "contextWindow": 1000000,
          "maxTokens": 384000,
          "input": ["text"],
          "reasoning": true,
          "cost": { "input": 0.14, "output": 0.28, "cacheRead": 0.028, "cacheWrite": 0 },
          "compat": {
            "requiresReasoningContentOnAssistantMessages": true,
            "thinkingFormat": "deepseek",
            "reasoningEffortMap": {
              "minimal": "high", "low": "high", "medium": "high", "high": "high", "xhigh": "max"
            }
          }
        }
      ]
    },
    "zai": {
      "baseUrl": "https://api.z.ai/api/anthropic",
      "api": "anthropic-messages",
      "models": [
        {
          "id": "glm-5.2",
          "name": "GLM-5.2",
          "reasoning": true,
          "input": ["text"],
          "contextWindow": 1000000,
          "maxTokens": 131072
        }
      ]
    }
  }
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

Canonical registry in this repo: [`../configs/mcp_servers.json`](../configs/mcp_servers.json). The live `~/.pi/agent/mcp.json` is empty; servers are provisioned from the repo registry.

Enabled servers:

- `agentmemory` — cross-session memory (native `pi-agentmemory` extension)
- `ai-vision` — image/video analysis (Gemini)
- `brave-search` — web search, images, news
- `codegraph` — local code knowledge graph
- `context7` — library docs and snippets
- `deepwiki` — public repository documentation

Disabled but available: `chrome-devtools`, `playwright`, `sequential-thinking`, `time`, `cipher`.

## Extensions (`settings.json`)

Installed packages (all active, 30 total). Verified via `pi list`. Canonical source: [`../configs/settings.json`](../configs/settings.json).

```json
"packages": [
  "npm:pi-librarian",
  "npm:@sherif-fanous/pi-rtk",
  "git:github.com/ferologics/pi-notify",
  "npm:pi-web-providers",
  "npm:pi-autoresearch",
  "npm:pi-acp",
  "npm:@tintinweb/pi-tasks",
  "npm:pi-context-usage",
  "git:github.com/code-yeongyu/pi-nested-agents-md",
  "npm:pi-init",
  "npm:@ff-labs/pi-fff",
  "npm:@upstash/context7-pi",
  "npm:@estebanforge/pi-agentmemory",
  "npm:@mcowger/pi-better-messages-cache",
  "npm:glm-vision",
  "npm:pi-token-speed",
  "npm:pi-diff-review",
  "npm:@narumitw/pi-auto-thinking",
  "npm:@juicesharp/rpiv-ask-user-question",
  "npm:@ctogg/pi-cost-counter",
  "npm:pi-token-burden",
  "npm:@gotgenes/pi-subagents",
  "npm:@estebanforge/pi-go-review",
  "npm:@estebanforge/pi-rust-review",
  "npm:pi-claude-bridge",
  "npm:@estebanforge/pi-php-review",
  { "source": "npm:@estebanforge/pi-glm-tweaks", "extensions": ["+extensions/index.ts"] },
  "npm:@estebanforge/pi-ts-review",
  "npm:@estebanforge/pi-js-review",
  "npm:@estebanforge/pi-codegraph-enhanced"
]
```

> `@ctogg/pi-cost-counter` writes the spend ledger consumed by the token cost
> tracker. Full setup + scripts + installer: [AGENT-PI-cost-tracking.md](AGENT-PI-cost-tracking.md).
