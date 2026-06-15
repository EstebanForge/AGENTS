# Add a z.ai GLM model to Pi

Wire a z.ai GLM model into pi's `zai` provider over the **Anthropic** endpoint. No version bump, no restart.

Keep BOTH environments in sync (same files, same edits):

| Env | Root |
|-----|------|
| Host (pi) | `~/.pi/agent/` |
| Construct | `~/.config/construct-cli/home/.pi/agent/` |

Files touched: `models.json`, `settings.json`, and (for `zai`) the extension `index.ts`.

## Endpoints (prefer Anthropic)

| Endpoint | URL | Used by |
|----------|-----|---------|
| Anthropic compat | `https://api.z.ai/api/anthropic` | **Default/preferred**. Faster. |
| OpenAI coding paas | `https://api.z.ai/api/coding/paas/v4` | Pi built-in `zai`, `$ZAI_API_KEY` |

Same key may work on only one endpoint. Coding Plan keys often work only on Anthropic.

## 1. Probe the id + plan

```bash
# Anthropic route
curl -sS -X POST "https://api.z.ai/api/anthropic/v1/messages" \
  -H "x-api-key: $ZAI_API_KEY" -H "anthropic-version: 2023-06-01" -H "content-type: application/json" \
  -d '{"model":"glm-5.2","max_tokens":8,"messages":[{"role":"user","content":"ping"}]}'
```

| Response | Meaning | Action |
|----------|---------|--------|
| `200` + text/reasoning | Model up | Proceed |
| `1113` Insufficient balance | Recognized, no quota | Top up |
| `1211` Unknown Model | id wrong | Check provider docs |
| `1311` plan does not include access | Subscription limit | **Cannot wire.** Plan-blocked. |

If `1311`: the model is gated by subscription on both endpoints. Config cannot fix it. Remove it from `enabledModels` to clear the warning. (Example: `glm-5v-turbo`.)

## 2. Check the registry + what pi sees

```bash
# Built-in definitions
PIAI=$(npm root -g)/@earendil-works/pi-coding-agent/node_modules/@earendil-works/pi-ai
grep -B1 -A14 '"zai":' "$PIAI/dist/models.generated.js" | head -80

# What pi actually resolves (may differ from registry; see Step 3)
pi --list-models zai
```

Copy `baseUrl`, `compat`, `contextWindow`, `maxTokens` from a sibling model in the registry.

## 3. Gotcha: extension overrides `models.json` for `zai`

`@howaboua/pi-glm-via-anthropic` calls `pi.registerProvider("zai", {...})` over the Anthropic endpoint with a **hardcoded** model list (`glm-5.1`, `glm-5-turbo`, `glm-4.7`, `glm-4.5-air`).

`registerProvider` **WINS** over `models.json`. A `zai.models` block is ignored while the extension is active.

Symptom: model added to `models.json` never shows; `enabledModels` prints `Warning: No models match pattern "zai/<id>"` even when the model is a registry built-in.

`pi --list-models zai` then shows only the extension's list. If a model you added is missing, the extension is why.

## 4. Wire it (patch BOTH layers)

Belt and suspenders: patch the extension (authoritative while enabled) AND keep `models.json` (fallback if the extension is disabled/uninstalled). Both point at Anthropic, so disabling the extension changes nothing.

### Layer 1: extension MODELS array (node_modules, non-durable)

Reapply after every `pi install` / upgrade of this package. Two identical copies:

```
<env-root>/npm/node_modules/@howaboua/pi-glm-via-anthropic/index.ts
```

Add the model as the first entry of `MODELS`. Match the existing schema (no `compat`, no `thinkingLevelMap`, Anthropic route):

```ts
export const MODELS = [
	{
		id: "glm-5.2",
		name: "GLM-5.2",
		reasoning: true,
		input: ["text"] as const,
		cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
		contextWindow: 1000000,
		maxTokens: 131072,
	},
	// ...existing entries
];
```

### Layer 2: `models.json` (durable fallback)

Both envs. Must set the Anthropic endpoint, not a bare `models` array.

```json
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
```

## 5. Mark scoped + default

`settings.json`, both envs:

- Add `"zai/glm-5.2"` to `enabledModels` (the `/model` subset).
- Set `"defaultModel": "glm-5.2"`, `"defaultProvider": "zai"` if it is the primary.
- Remove any plan-blocked ids (e.g. `zai/glm-5v-turbo`) from `enabledModels`.

`/model` reloads `models.json` on every open. No restart, no `/reload`.

## 6. Validate

```bash
python3 -c "import json; json.load(open('<env-root>/models.json')); print('valid')"
pi --list-models zai | grep glm-5.2          # must appear
pi --list-models zai 2>&1 1>/dev/null        # zero "No models match" warnings
pi -p --provider zai --model glm-5.2 "Reply with just: pong"
```

## Don't

- Don't assume `models.json` reaches a provider an extension re-registered. Extension wins; patch it too (Step 3/4).
- Don't set OpenAI `compat`/`thinkingLevelMap` on an Anthropic-route model. Match the extension schema.
- Don't set `apiKey` in the `zai` block; the env var / `auth.json` resolves it.
- Don't use `modelOverrides` for net-new ids (it only tweaks existing entries).
- Don't invent `cost`. Built-in/extension default is zero.
- Don't skip the smoke test. Registered != callable.

## Memory

After a successful add, save: model id, endpoint, `compat`/schema, plan status. Future sessions skip re-probing.
