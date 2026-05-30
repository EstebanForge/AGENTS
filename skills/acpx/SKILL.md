---
name: acpx
description: Use acpx as a headless ACP CLI for agent-to-agent communication, including prompt/exec/sessions workflows, session scoping, queueing, permissions, and output formats.
---

# acpx

## When to use this skill

Use this skill when you need to run coding agents through `acpx`, manage persistent ACP sessions, queue prompts, or consume structured agent output from scripts.

## What acpx is

`acpx` is a headless, scriptable CLI client for the Agent Client Protocol (ACP). It is built for agent-to-agent communication over the command line and avoids PTY scraping.

Core capabilities:

- Persistent multi-turn sessions per repo/cwd
- One-shot execution mode (`exec`)
- Named parallel sessions (`-s/--session`)
- Queue-aware prompt submission with optional fire-and-forget (`--no-wait`)
- Cooperative cancel command (`cancel`) for in-flight turns
- Graceful cancellation via ACP `session/cancel` on interrupt
- Session control methods (`set-mode`, `set <key> <value>`)
- Agent reconnect/resume after dead subprocess detection
- Prompt input via stdin or `--file`
- Config files with global+project merge and `config show|init`
- Session metadata/history inspection (`sessions show`, `sessions history`)
- Local agent process checks via `status`
- Stable ACP client methods for filesystem and terminal requests
- Stable ACP `authenticate` handshake via env/config credentials
- Structured streaming output (`text`, `json`, `quiet`) with optional `--suppress-reads`
- Built-in agent registry plus raw `--agent` escape hatch

## Install

```bash
npm i -g acpx
```

For normal session reuse, prefer a global install over `npx`.

## Command model

`prompt` is the default verb.

```bash
acpx [global_options] [prompt_text...]
acpx [global_options] prompt [prompt_options] [prompt_text...]
acpx [global_options] exec [prompt_options] [prompt_text...]
acpx [global_options] cancel [-s <name>]
acpx [global_options] set-mode <mode> [-s <name>]
acpx [global_options] set <key> <value> [-s <name>]
acpx [global_options] status [-s <name>]
acpx [global_options] sessions [list | new [--name <name>] | close [name] | show [name] | history [name] [--limit <count>]]
acpx [global_options] config [show | init]

acpx [global_options] <agent> [prompt_options] [prompt_text...]
acpx [global_options] <agent> prompt [prompt_options] [prompt_text...]
acpx [global_options] <agent> exec [prompt_options] [prompt_text...]
acpx [global_options] <agent> cancel [-s <name>]
acpx [global_options] <agent> set-mode <mode> [-s <name>]
acpx [global_options] <agent> set <key> <value> [-s <name>]
acpx [global_options] <agent> status [-s <name>]
acpx [global_options] <agent> sessions [list | new [--name <name>] | close [name] | show [name] | history [name] [--limit <count>]]
```

If prompt text is omitted and stdin is piped, `acpx` reads prompt text from stdin.

## Built-in agent registry

Friendly agent names resolve to commands:

- `pi` -> `npx pi-acp`
- `openclaw` -> `openclaw acp`
- `codex` -> `npx @zed-industries/codex-acp`
- `claude` -> `npx -y @agentclientprotocol/claude-agent-acp` (ACPX-owned package range)
- `cursor` -> `cursor-agent acp`
- `copilot` -> `copilot --acp --stdio`
- `droid` -> `droid exec --output-format acp` (`factory-droid` and `factorydroid` also resolve to `droid`)
- `iflow` -> `iflow --experimental-acp`
- `kilocode` -> `npx -y @kilocode/cli acp`
- `kimi` -> `kimi acp`
- `kiro` -> `kiro-cli-chat acp`
- `opencode` -> `npx -y opencode-ai acp`
- `qoder` -> `qodercli --acp`
  Forwards Qoder-native `--allowed-tools` and `--max-turns` startup flags from `acpx` session options.
- `qwen` -> `qwen --acp`
- `trae` -> `traecli acp serve`

Rules:

- Default agent is `codex` for top-level `prompt`, `exec`, and `sessions`.
- Unknown positional agent tokens are treated as raw agent commands.
- `--agent <command>` explicitly sets a raw ACP adapter command.
- Do not combine a positional agent and `--agent` in the same command.

## Commands

### Prompt (default, persistent session)

Implicit:

```bash
acpx codex 'fix flaky tests'
```

Explicit:

```bash
acpx codex prompt 'fix flaky tests'
acpx prompt 'fix flaky tests'   # defaults to codex
```

Behavior:

- Uses a saved session for the session scope key
- Auto-resumes prior session when one exists for that scope
- If no session exists for the scope, exits with `NO_SESSION` and prompts for `sessions new`
- Is queue-aware when another prompt is already running for the same session
- On interrupt during an active turn, sends ACP `session/cancel` before force-kill fallback

Prompt options:

- `-s, --session <name>`: use a named session within the same cwd
- `--no-wait`: enqueue and return immediately when session is already busy
- `-f, --file <path>`: read prompt text from file (`-` means stdin)

### Exec (one-shot)

```bash
acpx exec 'summarize this repo'
acpx codex exec 'summarize this repo'
```

Behavior:

- Runs a single prompt in a temporary ACP session
- Does not reuse or save persistent session state

### Cancel / Mode / Config / Model

```bash
acpx codex cancel
acpx codex set-mode auto
acpx codex set thought_level high
acpx codex set model gpt-5.4
```

Behavior:

- `cancel`: sends cooperative `session/cancel` through queue-owner IPC.
- `set-mode`: calls ACP `session/set_mode`.
- `set-mode` mode ids are adapter-defined; unsupported values are rejected by the adapter (often `Invalid params`).
- `set`: calls ACP `session/set_config_option`.
- For codex, `thought_level` is accepted as a compatibility alias for codex-acp `reasoning_effort`.
- `--model <id>`: Claude-compatible adapters may consume session creation metadata; other agents must advertise ACP models and support `session/set_model`, otherwise `acpx` fails clearly instead of silently falling back.
- `set model <id>`: calls `session/set_model`. This is the generic ACP method for mid-session model switching.
- `set-mode`/`set` route through queue-owner IPC when active, otherwise reconnect directly.

### Sessions

```bash
acpx sessions
acpx sessions list
acpx sessions new
acpx sessions new --name backend
acpx sessions close
acpx sessions close backend
acpx sessions show
acpx sessions history --limit 20
acpx status

acpx codex sessions
acpx codex sessions new --name backend
acpx codex sessions close backend
acpx codex sessions show backend
acpx codex sessions history backend --limit 20
acpx codex status
```

Behavior:

- `sessions` and `sessions list` are equivalent
- `new` creates a fresh session for the current `(agentCommand, cwd, optional name)` scope
- `new --name <name>` targets a named session scope
- when `new` replaces an existing open session in that scope, the old one is soft-closed
- `close` targets current cwd default session
- `close <name>` targets current cwd named session
- `show [name]` prints stored metadata for that scoped session
- `history [name]` prints stored turn history previews (default 20, use `--limit`)

## Global options

- `--agent <command>`: raw ACP agent command (escape hatch)
- `--cwd <dir>`: working directory for session scope (default: current directory)
- `--approve-all`: auto-approve all permission requests
- `--approve-reads`: auto-approve reads/searches, prompt for writes (default mode)
- `--deny-all`: deny all permission requests
- `--format <fmt>`: output format (`text`, `json`, `quiet`)
- `--suppress-reads`: suppress raw read-file contents while preserving the selected format
- `--timeout <seconds>`: max wait time (positive number)
- `--ttl <seconds>`: queue owner idle TTL before shutdown (default `300`, `0` disables TTL)
- `--model <id>`: request an agent model during session creation; non-Claude agents must advertise ACP models and support `session/set_model`
- `--verbose`: verbose ACP/debug logs to stderr

Permission flags are mutually exclusive.

> ⚠️ **Position matters**: Global options must come **before** the agent name. Prompt options (`-s`, `--no-wait`, `--file`) come **after** the agent name. Mixing up the positions passes flags to the wrong layer.

Full ordering: `acpx [global_options] [agent] [prompt_options] [prompt_text]`

```bash
# ✅ Correct
acpx --approve-all --format json claude -s feature-x 'continue the refactor'
#    ^^^ global ^^^              ^^^^^ ^^^ prompt ^^^
#                                agent  session name

# ❌ Wrong — -s is a prompt option, not global; claude receives it raw
acpx -s feature-x --approve-all claude 'continue the refactor'

# ❌ Wrong — --approve-all passed to agent, may be rejected
acpx claude --approve-all -s feature-x 'continue the refactor'
```

`--agent` (escape hatch) is a global option and cannot be combined with a positional agent name:

```bash
acpx --agent './bin/custom-acp --profile ci' 'run validation'  # ✅
# acpx --agent ./custom codex 'prompt'                         # ❌ USAGE ERROR
```

## Direct agent usage (outside acpx)

Each agent has its own native CLI. Useful when acpx is unavailable or for quick one-shot prompts:

| Agent | CLI command | Interactive | Print (non-interactive) | ACP mode |
|-------|------------|-------------|--------------------------|----------|
| `antigravity` (agy) | `agy` | `agy -i` | `agy -p 'prompt'` or `agy --prompt 'prompt'` | Not supported (no ACP mode) |
| `codex` | `codex` | `codex` | `codex -q 'prompt'` | via acpx |
| `claude` | `claude` | `claude` | `claude -p 'prompt'` | via acpx |

**Note**: `-p` / `--print` / `--prompt` all require a prompt argument. Omitting it causes `flag needs an argument: -p`.

## Agent quirks

Agents in the built-in registry behave differently over ACP. Know what to expect:

| Agent | Output style | Auth | Notes |
|-------|-------------|------|-------|
| `codex` | Clean, direct text | Ambient `OPENAI_API_KEY` | Default agent; most consistent. `thought_level` maps to `reasoning_effort`. |
| `claude` | Direct text, occasionally verbose | API key or OAuth | May hit **rate limits** — error includes reset time (`resets HH:MM UTC`). Retry after the window. |
| `antigravity` (agy) | Direct text | Ambient `ANTIGRAVITY_API_KEY` | No ACP support. Use direct CLI only: `agy -p 'prompt'` for one-shot, `agy -i` for interactive. |
| `copilot` | Terse/minimal — often just the answer | GitHub OAuth | No reasoning trace, no adornment. Good for scripted extraction. |
| `opencode` | N/A | `opencode-login` (custom) | **ACP adapter may not work** — session/new requires strict `cwd` and `mcpServers` params. Auth flow is separate from acpx. Prefer `opencode run` natively. |
| `cursor` | Direct text | `cursor-auth` (custom) | Requires Cursor auth; ACP adapter is still maturing. |
| `qoder` | Direct text | API key | Accepts `--allowed-tools` and `--max-turns` startup flags forwarded from acpx session options. |
| `pi` | Standard text | Ambient provider key | Self-hosted via `npx pi-acp`. |

### Rate limits

Adapters (especially hosted models) can hit API rate limits. Common patterns:

- **Claude**: `You've hit your limit · resets HH:MM UTC` — wait until the reset time.
- **OpenAI-based** (Codex, etc.): `429 Rate Limit` — back off and retry.

acpx propagates the error as-is from the adapter; there is no internal retry logic.

### Error recovery

| Exit code | Error | Cause | Recovery |
|-----------|-------|-------|----------|
| `4` | `NO_SESSION` | No session for this scope | `acpx <agent> sessions new` or `sessions ensure` |
| `5` | `PERMISSION_DENIED` | All permission requests denied | Add `--approve-all` or `--approve-reads`; or set `defaultPermissions` in config |
| `3` | `TIMEOUT` | `--timeout` exceeded | Increase `--timeout` or remove it |
| `2` | `USAGE` | Bad flags, conflicting flags | Fix invocation; check flag ordering |
| `1` | `RUNTIME` | Agent/protocol/auth error | Run with `--verbose`; check `acp.message` in `--format json` output |
| `130` | Interrupted | `Ctrl+C` / SIGINT | Expected; session is still resumable |

**Dead PID**: `acpx` detects a dead saved PID automatically on the next prompt, respawns the agent, and attempts `session/load`. If loading fails, it transparently falls back to `session/new`. No manual recovery needed -- just prompt again.

**Auth errors** surface as `RUNTIME` with `detailCode=AUTH_REQUIRED`. Set credentials via `ACPX_AUTH_<METHOD_ID>` env vars (e.g. `ACPX_AUTH_OPENAI_API_KEY`) or the config `auth` map.

**Idempotent session creation** -- safe to use in scripts before every prompt:

```bash
acpx claude sessions ensure          # get-or-create, no error if session already exists
acpx claude sessions ensure --name x
```

## Config files

Config files are merged in this order (later wins):

- global: `~/.acpx/config.json`
- project: `<cwd>/.acpxrc.json`

Supported keys:

- `defaultAgent`
- `defaultPermissions` (`approve-all`, `approve-reads`, `deny-all`)
- `ttl` (seconds)
- `timeout` (seconds or `null`)
- `format` (`text`, `json`, `quiet`)
- `agents` map (`name -> { command, args? }`)
- `auth` map (`authMethodId -> credential`)

Use `acpx config show` to inspect the resolved config and `acpx config init` to create the global template.

For ACP `authenticate` handshakes, use either config `auth` entries or explicit
`ACPX_AUTH_<METHOD_ID>` environment variables such as `ACPX_AUTH_OPENAI_API_KEY`.
Ambient provider env vars such as `OPENAI_API_KEY` are still passed through to
child agents, but they do not trigger ACP auth-method selection on their own.

## Session behavior

Persistent prompt sessions are scoped by:

- `agentCommand`
- absolute `cwd`
- optional session `name`

Persistence:

- Session records are stored in `~/.acpx/sessions/*.json`.
- `-s/--session` creates parallel named conversations in the same repo.
- Changing `--cwd` changes scope and therefore session lookup.
- closed sessions are retained on disk with `closed: true` and `closedAt`.
- auto-resume by scope skips closed sessions.

Resume behavior:

- Prompt mode attempts to reconnect to saved session.
- If adapter-side session is invalid/not found, `acpx` creates a fresh session and updates the saved record.
- explicitly selected session records can still be resumed via `loadSession` even if previously closed.
- dead saved PIDs are detected and reconnected on the next prompt.
- each completed prompt stores lightweight turn history previews in the session record.

## Prompt queueing and `--no-wait`

Queueing is per persistent session.

- The active `acpx` process for a running prompt becomes the queue owner.
- Other invocations submit prompts over local IPC.
- On Unix-like systems, queue IPC uses a Unix socket under `~/.acpx/queues/<hash>.sock`.
- Ownership is coordinated with a lock file under `~/.acpx/queues/<hash>.lock`.
- On Windows, named pipes are used instead of Unix sockets.
- after the queue drains, owner shutdown is governed by TTL (default 300s, configurable with `--ttl`).

Submission behavior:

- Default: enqueue and wait for queued prompt completion, streaming updates back.
- `--no-wait`: enqueue and return after queue acknowledgement.
- `Ctrl+C` during an active turn sends ACP `session/cancel`, waits briefly, then force-kills only if cancellation does not finish in time.
- `cancel` sends the same cooperative cancellation without requiring terminal signals.

## Output formats

Use `--format <fmt>`:

- `text` (default): human-readable stream with updates/tool status and done line
- `json`: NDJSON event stream (good for automation)
- `quiet`: final assistant text only
- `--suppress-reads`: replace raw read-file contents with `[read output suppressed]` in `text` and `json` output

Example automation:

```bash
acpx --format json codex exec 'review changed files' \
  | jq -r 'select(.type=="tool_call") | [.status, .title] | @tsv'
```

## Permission modes

- `--approve-all`: no interactive permission prompts
- `--approve-reads` (default): approve reads/searches, prompt for writes
- `--deny-all`: deny all permission requests

If every permission request is denied/cancelled and none approved, `acpx` exits with permission-denied status.

## Practical workflows

### First use: starting a session with an agent

Sessions must exist before `prompt` works. Exit code `4` / `NO_SESSION` means no session has been created for this scope yet.

```bash
# 1. Create the session (or use `sessions ensure` for idempotent get-or-create)
acpx claude sessions new

# 2. Send the first message
acpx claude 'here is the task: ...'

# 3. Continue — same session, context preserved
acpx claude 'now apply the fix'
acpx claude 'run the tests and summarize results'
```

Named sessions follow the same pattern:

```bash
acpx claude sessions new --name auth-refactor
acpx claude -s auth-refactor 'review the auth middleware'
acpx claude -s auth-refactor 'apply the changes'
```

### Recovering context after your own session resets

When your own context (Claude Code conversation) resets between sessions, the agent session persists on disk. Re-anchor by reading the session history before continuing:

```bash
# See all sessions for an agent in the current repo
acpx claude sessions list

# Read turn history to catch up on prior context
acpx claude sessions history --limit 20

# Named session history
acpx claude sessions history auth-refactor --limit 20

# Then continue — session is still live
acpx claude 'continuing from last session: now address the edge cases we identified'
```

If the agent subprocess died (dead PID), create a fresh session. The prior turn history is still on disk but the live connection is gone:

```bash
acpx claude sessions new   # replaces dead session, history previews remain
```

### Permission flag ordering

Global flags before agent:

```bash
# ✅ Correct
acpx --approve-all codex 'summarize changed files'

# ❌ Wrong — `--approve-all` passed to agent, may be rejected
acpx codex --approve-all 'summarize changed files'
```

### One-shot vs persistent

Use `exec` for stateless queries (no session saved):

```bash
acpx --format quiet exec 'Two plus two'       # -> 4
acpx --format quiet codex exec 'Two plus two'  # explicit agent
```

Use `prompt` (default) for multi-turn conversations with session persistence:

```bash
acpx codex 'analyze test output'   # creates/uses session
acpx codex 'now apply the fix'     # continues same session
```

### Named sessions

Create a named session first, then prompt:

```bash
acpx codex sessions new --name backend
acpx codex -s backend 'fix pagination bug'
acpx codex -s backend 'run tests'
```

### Direct Antigravity (agy) usage

`agy` has no ACP adapter. Use the native CLI directly:

```bash
# One-shot print mode
agy -p 'explain this function'

# Interactive session
agy -i
```

### Parallel named streams

Persistent repo assistant:

```bash
acpx codex 'inspect failing tests and propose a fix plan'
acpx codex 'apply the smallest safe fix and run tests'
```

Parallel named streams:

```bash
acpx codex -s backend 'fix API pagination bug'
acpx codex -s docs 'draft changelog entry for release'
```

Queue follow-up without waiting:

```bash
acpx codex 'run full test suite and investigate failures'
acpx codex --no-wait 'after tests, summarize root causes and next steps'
```

One-shot script step:

```bash
acpx --format quiet exec 'summarize repo purpose in 3 lines'
```

Machine-readable output for orchestration:

```bash
acpx --format json codex 'review current branch changes' > events.ndjson
```

Raw custom adapter command:

```bash
acpx --agent './bin/custom-acp-server --profile ci' 'run validation checks'
```

Flow run:

```bash
acpx flow run ./my-flow.ts --input-file ./flow-input.json
acpx flow run examples/flows/branch.flow.ts --input-json '{"task":"FIX: add a regression test"}'
```

Repo-scoped review with permissive mode:

```bash
acpx --cwd ~/repos/shop --approve-all codex -s pr-842 \
  'review PR #842 for regressions and propose minimal patch'
```
