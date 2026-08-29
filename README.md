# AGENTS

Minimal, robust, and secure agent workflows for AGENTS.

The core `AGENTS.md` instructions follow the [TOON](https://toonformat.dev) documentation format; this README summarizes how to use that rulebook inside any agent workspace.

## Overview

- Purpose: Provide a concise, senior-engineer-friendly protocol and standards for building and operating coding agents.
- Scope: Documentation and standards that guide agent behavior across planning, execution, and verification.
- Portable config backup: track Pi and other agent settings under `./configs/` to reproduce the full setup on a new machine.
- Clear workflow protocol: Search → Plan → Execute → Verify.
- Todo tracking with explicit states: `[ ]` not-started, `[x]` completed, `[-]` removed.
- Tool protocol for efficient, transparent usage.
- Technical standards emphasizing DRY, KISS, YAGNI, and performance.
- Security baseline: sanitize inputs, CSRF protection, capability checks.

## AGENTS.md

View [AGENTS.md](AGENTS.md) for the full rulebook.

---

# Centralization Manager

Centralize agent configuration management across all AI coding agents. Maintains a single source of truth for agent rules and shared skills.

- **Central AGENTS.md:** `./AGENTS.md`
- **Central Skills:** `./skills/`

The unified `manage.sh` script handles both instructions and skills in a single pass.

---

## Quick Start

Run the manager without arguments for an interactive menu:

```bash
./manage.sh
```

Or use command-line arguments:

```bash
# Smart Sync (Link/Copy everything)
./manage.sh link

# Force Sync (Overwrite existing links/copies)
./manage.sh link --force

# Verify status
./manage.sh status

# Restore original state (Unlink/Remove copies)
./manage.sh unlink
```

---

## manage.sh

The unified manager for both instructions (`AGENTS.md`) and skills.

**Behavior:**
- **Standard Mode:** Uses symlinks for local efficiency.
- **construct-cli Mode:** Uses surgical direct copies (files and folders) for Docker compatibility.
- Automatically detects VSCode, Windsurf, and construct-cli environments.
- Creates parent directories if missing.
- Backs up existing instruction files (e.g. a pre-existing `CLAUDE.md`) before linking. Skill entries are never backed up: on a name collision the central copy replaces the local one, and git history is the backup.
- `unlink` restores instruction-file backups automatically.
- Sorting: Displays regular agents first, followed by `construct_` agents.
- Also drives the **fuse-agents** shell plugin install/uninstall (see below).

---

## Shell Plugins

### fuse-agents

[fuse-agents](https://github.com/EstebanForge/fuse-agents) is a cross-shell plugin (Bash & Zsh) that auto-fuses per-project AI config files (`CLAUDE.md`, `GEMINI.md`) into a unified `AGENTS.md` with symlink management on every directory change.

This repo bootstraps it reproducibly: the menu entry clones the plugin to a throwaway location under `/tmp` and hands off to the plugin's own installer/uninstaller. No local checkout assumed, works on any machine with `git`.

**Menu options (5 and 6):**

```bash
./manage.sh
# 5) Install fuse-agents plugin
# 6) Uninstall fuse-agents plugin
```

**Direct script:**

```bash
./scripts/fuse-agents.sh install     # clone to /tmp + run install.sh
./scripts/fuse-agents.sh uninstall   # clone to /tmp + run uninstall.sh
```

**What the installer does (in the plugin repo):**
- Copies the plugin into `~/.zsh/plugins/fuse-agents` (or `~/.bash/...`).
- Creates `~/.zshrc` / `~/.bashrc` if missing, and appends the `source` line.
- Idempotent: re-runs skip duplicate wiring.

**What the uninstaller does:**
- Strips only the `# Load Fuse Agents plugin` block from the rc file (other config preserved).
- Removes the plugin directory and the empty `plugins/` parent if it ends up empty.
- Safe no-op if never installed.

After either action, restart your shell (or `source ~/.zshrc` / `~/.bashrc`).

---

## Supported Agents

### Instructions (AGENTS.md / CLAUDE.md / etc.)

| Agent | Path | Notes |
|-------|------|-------|
| Standard | `~/.agents/AGENTS.md` | Emerging standard path |
| Antigravity | `~/.gemini/GEMINI.md` | Reads both GEMINI.md and AGENTS.md (backward compat) |
| Claude | `~/.claude/CLAUDE.md` | Custom filename |
| Qwen | `~/.qwen/QWEN.md` | Custom filename |
| Amp | `~/.config/amp/AGENTS.md` | |
| Opencode | `~/.config/opencode/AGENTS.md` | |
| Codex | `~/.codex/AGENTS.md` | |
| Copilot | `~/.copilot/copilot-instructions.md` | Custom filename |
| Factory | `~/.factory/AGENTS.md` | |
| Goose | `~/.config/goose/AGENTS.md` | |
| Kilocode | `~/.kilocode/rules/AGENTS.md` | |
| Cline | `~/Documents/Cline/Rules/AGENTS.md` | |
| Pi | `~/.pi/agent/AGENTS.md` | |
| Zcode | `~/.zcode/AGENTS.md` | |

### Skills

Agents that natively read `~/.agents/skills/` (covered by **Standard**, no dedicated entry needed):
- Antigravity, Codex, Opencode.

Agents with dedicated synchronization:

| Agent | Path |
|-------|------|
| Standard | `~/.agents/skills/` |
| Claude | `~/.claude/skills/` |
| Qwen | `~/.qwen/skills/` |
| Amp | `~/.config/amp/skills/` |
| Copilot | `~/.copilot/skills/` |
| Cline | `~/.cline/skills/` |
| Factory | `~/.factory/skills/` |
| Goose | `~/.config/goose/skills/` |
| Kilocode | `~/.kilocode/skills/` |
| Pi | `~/.pi/agent/skills/` |
| Zcode | `~/.zcode/skills/` |

---

## Skills

Skills are shared agent capabilities stored in `./skills/`. Each skill is a subdirectory containing a `SKILL.md` file with a YAML frontmatter block (`name`, `description`) followed by the skill's instructions.

All skills must follow the Agent Skills specification: https://agentskills.io/specification

Browse `./skills/` for the current set; each `SKILL.md` frontmatter carries the description, and vendored skills carry a `META.md` recording their upstream source and local deltas.

### Adding a Skill

```
skills/
└── my-skill/
    └── SKILL.md
```

`SKILL.md` structure:

```markdown
---
name: my-skill
description: One-line description used by agents.
---

# My Skill

...instructions...
```

---

## Configs

The `configs/` directory holds portable agent configuration used to reproduce the full setup on another machine. Currently:

- `configs/settings.json` — Pi agent settings (provider, model, packages, UI). Source of truth: the live config on this machine (`~/.pi/agent/settings.json`); this repo mirrors it. The construct-cli sandbox and other machines consume from this repo.
- `configs/mcp_servers.json` — Pi MCP server registry. Source of truth for the server set. The live `mcp.json` on this machine is intentionally empty (MCP servers replaced by pi packages: context7, agentmemory, codegraph); machines that still use MCP servers provision from this registry.

Detailed Pi configuration reference: [docs/AGENT-PI.md](docs/AGENT-PI.md).

### Pi Extensions

Pi packages installed in this instance (47 total, verified via `pi list`). Canonical list tracked in [`configs/settings.json`](configs/settings.json).

| Package | Purpose |
|---------|---------|
| `pi-rtk-optimizer` | RTK command rewriting + tool-output compaction |
| `git:ferologics/pi-notify` | Event notifications |
| `pi-web-providers` | Web search/contents/research/answer providers |
| `@tintinweb/pi-tasks` | Task management |
| `pi-context-usage` | Context budget visibility |
| `git:code-yeongyu/pi-nested-agents-md` | Nested-agent markdown handling |
| `pi-init` | AGENTS.md initialization |
| `@ff-labs/pi-fff` | Fuzzy file finder / grep (extensions filtered) |
| `@upstash/context7-pi` | Library docs + snippets |
| `@estebanforge/pi-agentmemory` | Cross-session memory (native extension) |
| `pi-vision-handoff` | Vision-model handoff for image input (replaces glm-vision) |
| `pi-token-speed` | Token speed display |
| `pi-diff-review` | Diff review |
| `@juicesharp/rpiv-ask-user-question` | Structured user-question tool |
| `pi-token-burden` | Token burden display |
| `@tintinweb/pi-subagents` | Subagent execution (replaces `@gotgenes/pi-subagents`) |
| `pi-claude-bridge` | Bridge to Claude models |
| `@estebanforge/pi-glm-tweaks` | GLM provider tweaks (`+extensions/index.ts`) |
| `@estebanforge/pi-codegraph-enhanced` | Local code knowledge graph |
| `@estebanforge/pi-antigravity-bridge` | Native Antigravity (Gemini) bridge (replaces ask-antigravity) |
| `@estebanforge/pi-ask-codex` | Delegate to OpenAI Codex (GPT) peer agent |
| `@estebanforge/pi-slack-me` | Slack read/post/search as the user (user token) |
| `@pi-kaush/pi-inline-skill-identifier` | Highlight `$skill` aliases, route inline skill refs |
| `@mobrienv/pi-tidy-tools` | Compact, reason-first tool output with layouts/diffs |
| `git:jnsahaj/pi-agent-browser-screenshot` | Inline headless-browser screenshots in the TUI |
| `git:tmustier/pi-queue-steer` | Visible steering/follow-up queues with inline editing |
| `@estebanforge/pi-token-cost-ledger` | Token cost ledger (replaces `@ctogg/pi-cost-counter`) |
| `npm:pi-unified-exec` | Unified exec backend (sessions, long-running, set_on_exit) |
| `npm:@tmustier/pi-session-recap` | Session recap (turn budget, state) |
| `@thurstonsand/pi-librarian` | Multi-repo codebase research and synthesis |
| `pi-agent-browser-native` | Native headless browser automation (open, click, fill, snapshot, eval) |
| `pi-visualize-code-changes` | Mermaid before/after/diff diagrams of code changes |
| `git:github.com/earendil-works/pi-review-loop` | Iterative automated code review loop |
| `pi-qmd-adaptive-search` | Local semantic file discovery (qmd-indexed, adaptive) |
| `@pi-stef/atlassian` | Jira + Confluence (issues, stories, pages) |
| `@estebanforge/pi-git-me` | Git/GitHub writes as the user (commit, PR, review via gh) |
| `@tmustier/pi-tab-status` | Terminal tab status indicators for Pi sessions |
| `git:dodo-reach/pi-clarify` | Rewrites rough prompts into precise technical prompts before sending |
| `@estebanforge/pi-asana-me` | Asana tasks/projects/comments over REST (replaces pi-asana) |
| `@estebanforge/pi-show-me-the-meat` | Abridge diffs to the lines that carry the change |
| `@estebanforge/pi-ask-claude` | Delegate to Claude peer agent (isolated or continued session) |
| `@estebanforge/pi-hostname` | Show hostname context in sessions |

## License

This project is licensed. See `LICENSE` for details.
