# Pig Configuration Reference

> Pig is the Go implementation of Pi. This page records the paths Pig uses on this machine and how this repo wires it. Full upstream docs: `~/.pig/docs/` (also installed by `pig docs`).

Pig and Pi are fully separate: Pig keeps all state under `~/.pig` and never reads or writes Pi's `~/.pi`. Both run side by side on one machine without sharing settings, credentials, or sessions (upstream divergence D2).

## Configuration root

Pig picks one configuration root at startup:

| Order | Source | Root |
|---|---|---|
| 1 | `PIG_HOME` set and not empty | `$PIG_HOME` |
| 2 | `XDG_CONFIG_HOME` set | `$XDG_CONFIG_HOME/pig` |
| 3 | default | `~/.pig` |

The root holds: `agent/` (the agent directory), `piglets/`, `artifacts/piglets/`, `receipts/piglets/`, `state/<namespace>/`, and `docs/` (offline docs written by `pig docs`).

## Agent directory (`~/.pig/agent`)

Move only this directory with `PIG_CODING_AGENT_DIR`. Pi's `PI_CODING_AGENT_DIR` is ignored by Pig.

| Path | Purpose |
|---|---|
| `AGENTS.md` | Global instructions; symlinked from this repo by `manage.sh` (agent entry: `Pig`) |
| `prompts/` | Prompt templates; symlinked per-entry by `manage.sh` |
| `settings.json` | User settings, including package and resource declarations |
| `auth.json` | API keys and OAuth tokens |
| `models.json` | Custom endpoints and models |
| `trust.json` | Saved project trust decisions |
| `skills/` | User skills |
| `extensions/` | User extensions |
| `themes/` | User themes |
| `sessions/` | Saved sessions, one directory per project |
| `bin/` | Helper binaries Pig downloads for its tools (`fd`, `rg`) |
| `npm/`, `git/` | Packages installed at user scope (`pig install`) |

Skills: Pig also reads the standard `~/.agents/skills/` natively, so like Pi it needs no dedicated skills sync from `manage.sh`. That is the only standard path Pig honors: it does not read `~/.agents/AGENTS.md` or `~/.agents/prompts/`, so instructions and prompts keep their dedicated `~/.pig/agent/` entries.

After hand-editing any config file, run `/reload` in a session (or restart) so Pig picks it up.

## Project directory (`.pig/`)

Per-project config lives in `.pig/` inside the working directory only; Pig does not walk parent directories.

- `.pig/settings.json` — project settings; keys override the agent directory's
- `.pig/AGENTS.md`, `.pig/SYSTEM.md`, `.pig/APPEND_SYSTEM.md`
- `.pig/extensions/`, `.pig/skills/`, `.pig/prompts/`, `.pig/themes/`
- `.pig/npm/`, `.pig/git/` — packages installed with `pig install --local`
- `.pig/piglets/` — project Piglets

Pig asks for project trust before reading any of it; decisions land in `~/.pig/agent/trust.json`.

## Not yet ported from Pi

- Extensions/packages: the Pi npm package list in [AGENT-PI.md](AGENT-PI.md) is Pi-only. Pig uses its own package and Piglet system; wire up as needed.
- Cost tracking: `@estebanforge/pi-token-cost-ledger` is Pi-only. No Pig equivalent installed yet.
- MCP: Pig supports MCP definitions natively as package resources, but none are installed; current servers stay on the shared `mcp-cli-ent` config. See [MCP-SERVERS.md](MCP-SERVERS.md).
