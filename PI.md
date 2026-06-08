# Pi Configuration Reference

> Reproduce this pi setup on a fresh machine. Skills and prompts are symlinked from the repo already.

## Settings (`~/.pi/agent/settings.json`)

```json
{
  "defaultProvider": "zai",
  "defaultModel": "glm-5.1",
  "defaultThinkingLevel": "medium",
  "transport": "auto",
  "editorPaddingX": 2,
  "steeringMode": "one-at-a-time",
  "followUpMode": "one-at-a-time",
  "treeFilterMode": "default",
  "compaction": { "enabled": true },
  "retry": { "enabled": true },
  "enabledModels": [
    "zai/glm-5.1",
    "google/gemini-2.5-flash",
    "google/gemini-2.5-pro",
    "google/gemini-3.1-flash-lite",
    "google/gemini-3.1-pro-preview",
    "google/gemini-3.5-flash",
    "zai/glm-5v-turbo",
    "deepseek/deepseek-v4-flash",
    "deepseek/deepseek-v4-pro",
    "minimax/MiniMax-M3",
    "lmstudio/google/gemma-4-12b"
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

## Subagent Review (`~/.pi/agent/pi-subagent-review.json`)

```json
{
  "model": "openai-codex/gpt-5.4",
  "thinking": "high",
  "summary": {
    "enabled": true,
    "model": "openai-codex/gpt-5.4",
    "thinking": "low"
  }
}
```

## MCP Servers (`~/.pi/agent/mcp.json`)

```json
{ "mcpServers": {} }
```

No servers configured in mcp.json. Available via `mcp-cli-ent`: deepwiki, context7, ai-vision, codegraph, brave-search, agentmemory.

## Extensions (`settings.json` -> packages)

```json
"packages": [
  "npm:pi-librarian",
  "npm:pi-subagents",
  "npm:@sherif-fanous/pi-rtk",
  "git:github.com/ferologics/pi-notify",
  "npm:pi-web-providers",
  "npm:pi-ask-user",
  "npm:@dreki-gg/pi-context7",
  "npm:pi-autoresearch",
  "npm:pi-acp",
  "npm:pi-claude-cli",
  "npm:@tintinweb/pi-tasks",
  "git:github.com/code-yeongyu/pi-nested-agents-md",
  "npm:@howaboua/pi-subagent-review",
  "npm:pi-init",
]
```
