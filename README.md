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

- `configs/mcp_servers.json` — MCP server registry for the `mcp-cli-ent` CLI (per-machine config: `~/.config/mcp-cli-ent/mcp_servers.json`). This repo copy is the portable source of truth; machines provision from it. Pi itself has no MCP layer; its docs, memory, and codegraph needs run on native pi extensions.

Detailed Pi configuration reference: [docs/AGENT-PI.md](docs/AGENT-PI.md).

### Pi Extensions

Pi packages installed in this instance: full list and purposes live in [docs/AGENT-PI.md](docs/AGENT-PI.md#extensions), verified via `pi list`.

## License

This project is licensed. See `LICENSE` for details.
