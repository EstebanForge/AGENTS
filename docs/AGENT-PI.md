# Pi Configuration Reference

> Reproduce this pi setup on a fresh machine. Skills and prompts are symlinked from the repo already.

## Settings (`~/.pi/agent/settings.json`)

```json
{
  "defaultProvider": "zai",
  "defaultModel": "glm-5.2",
  "defaultThinkingLevel": "low",
  "enabledModels": [
    "zai/glm-5.1",
    "google/gemini-2.5-flash",
    "google/gemini-2.5-pro",
    "google/gemini-3.1-flash-lite",
    "google/gemini-3.1-pro-preview",
    "google/gemini-3.5-flash",
    "deepseek/deepseek-v4-flash",
    "deepseek/deepseek-v4-pro",
    "minimax/MiniMax-M3",
    "lmstudio/google/gemma-4-12b",
    "zai/glm-5.2"
  ]
}
```

## Custom Providers (`~/.pi/agent/models.json`)

```json
{
  "providers": {
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
          "cost": { "input": 1.74, "output": 3.48, "cacheRead": 0.145 },
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
          "cost": { "input": 0.14, "output": 0.28, "cacheRead": 0.028 },
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
      "credentials": { "search": "BSAnmXrHzTnBDe1qL-hFIyNosYoV2F7" }
    },
    "exa": {
      "credentials": { "api": "REDACTED" }
    }
  }
}
```

> Note: Exa API key redacted. Set your own. Brave key is environment-specific.

## MCP Servers (`~/.pi/agent/mcp_servers.json`)

Enabled servers (canonical registry tracked in this repo: [`../configs/mcp_servers.json`](../configs/mcp_servers.json)):

- `agentmemory` — cross-session memory (native `pi-agentmemory` extension)
- `ai-vision` — image/video analysis (Gemini)
- `brave-search` — web search, images, news
- `codegraph` — local code knowledge graph
- `context7` — library docs and snippets
- `deepwiki` — public repository documentation

Disabled but available: `chrome-devtools`, `playwright`, `sequential-thinking`, `time`, `cipher`.

## Extensions (`settings.json`)

Installed packages (all active). Verified via `pi list`. No local extension files registered.

> `@ctogg/pi-cost-counter` writes the spend ledger consumed by the token cost
> tracker. Full setup + scripts + installer: [AGENT-PI-cost-tracking.md](AGENT-PI-cost-tracking.md).
>
> Canonical source tracked in this repo: [`../configs/settings.json`](../configs/settings.json).

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
  "npm:@vndv/pi-codegraph",
  "npm:@ctogg/pi-cost-counter",
  "npm:pi-token-burden",
  "npm:@gotgenes/pi-subagents",
  "npm:@estebanforge/pi-go-review",
  "npm:@estebanforge/pi-rust-review",
  "npm:pi-claude-bridge"
]
```
