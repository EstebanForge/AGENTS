# AGENTS

Minimal, robust, and secure agent workflows for AGENTS.

The core `AGENTS.md` instructions follow the [TOON](https://toonformat.dev) documentation format; this README summarizes how to use that rulebook inside any agent workspace.

## Overview

- Purpose: Provide a concise, senior-engineer-friendly protocol and standards for building and operating coding agents.
- Scope: Documentation and standards that guide agent behavior across planning, execution, and verification.
- Clear workflow protocol: Search → Plan → Execute → Verify.
- Todo tracking with explicit states: `[ ]` not-started, `[x]` completed, `[-]` removed.
- Tool protocol for efficient, transparent usage.
- Technical standards emphasizing DRY, KISS, YAGNI, and performance.
- Security baseline: sanitize inputs, CSRF protection, capability checks.

## AGENTS.md

View [AGENTS.md](AGENTS.md) for the full rulebook.

---

# Centralization Manager

Centralize agent configuration management across all AI coding agents. Maintains a single source of truth for agent rules and shared skills via symlinks.

- **Central AGENTS.md:** `./AGENTS.md`
- **Central Skills:** `./skills/`

---

## Quick Start

```bash
# Link everything
./manage-agents.sh link
./manage-skills.sh link

# Verify status
./manage-agents.sh status
./manage-skills.sh status

# Remove all symlinks and restore originals
./manage-agents.sh unlink
./manage-skills.sh unlink
```

---

## manage-agents.sh

Manages symlinks from each agent's config file to the central `AGENTS.md`.

```bash
./manage-agents.sh link       # Symlink all agents to ./AGENTS.md
./manage-agents.sh status     # Show symlink status for all agents
./manage-agents.sh unlink     # Remove symlinks, restore backups
./manage-agents.sh help       # Show help
```

**Behavior:**
- Creates parent directories if missing.
- Backs up any existing file with a timestamp before linking.
- Links if the agent's config folder exists on the machine, even if the target file doesn't yet — skips only if the agent is not installed.
- `unlink` restores the most recent backup automatically.
- VSCode and Windsurf paths are auto-detected at runtime.
- construct-cli paths are auto-detected when `~/.config/construct-cli/config.toml` is present.

---

## manage-skills.sh

Manages symlinks from each agent's skills directory to the central `./skills/` folder.

```bash
./manage-skills.sh link       # Symlink all agents to ./skills/
./manage-skills.sh status     # Show symlink status for all agents
./manage-skills.sh unlink     # Remove symlinks, restore backups

./manage-skills.sh help       # Show help (includes dynamic agent count)
```

**Behavior:**
- Creates parent directories if missing.
- Backs up any existing directory with a timestamp before linking.
- If agents are already linked, prompts to re-link them all (useful to fix issues).
- `unlink` restores the most recent backup automatically.
- construct-cli paths are auto-detected when `~/.config/construct-cli/config.toml` is present.

---

## Supported Agents

### AGENTS.md — Core (12, always active)

| Agent | Path | Notes |
|-------|------|-------|
| Gemini | `~/.gemini/GEMINI.md` | Custom filename |
| Claude | `~/.claude/CLAUDE.md` | Custom filename |
| Amp | `~/.config/amp/AGENTS.md` | |
| Qwen | `~/.qwen/QWEN.md` | Custom filename — default is `QWEN.md`, configurable via `context.fileName` |
| Copilot | `~/.copilot/copilot-instructions.md` | Custom filename |
| OpenCode | `~/.config/opencode/AGENTS.md` | |
| Cline | `~/Documents/Cline/Rules/AGENTS.md` | Primary path |
| Cline Alt | `~/Cline/Rules/AGENTS.md` | Alternate path |
| Codex | `~/.codex/AGENTS.md` | |
| Factory (Droid) | `~/.factory/AGENTS.md` | |
| Goose | `~/.config/goose/AGENTS.md` | Also reads `.goosehints`; canonical global is `~/.config/goose/.goosehints` |
| Kilo Code | `~/.kilocode/rules/AGENTS.md` | |

### AGENTS.md — Auto-detected

| Agent | Path | Condition |
|-------|------|-----------|
| VSCode | `~/Library/Application Support/Code/User/prompts/AGENTS.md.instructions.md` | macOS, if file exists |
| VSCode | `~/.config/Code/User/prompts/AGENTS.md.instructions.md` | Linux, if file exists |
| Windsurf | `~/.codeium/windsurf/memories/global_rules.md` | If file exists |

### AGENTS.md — construct-cli (detected if `~/.config/construct-cli/config.toml` exists)

| Agent | Path |
|-------|------|
| Gemini | `~/.config/construct-cli/home/.gemini/GEMINI.md` |
| Claude | `~/.config/construct-cli/home/.claude/CLAUDE.md` |
| Amp | `~/.config/construct-cli/home/.config/amp/AGENTS.md` |
| Qwen | `~/.config/construct-cli/home/.qwen/QWEN.md` |
| Copilot | `~/.config/construct-cli/home/.copilot/copilot-instructions.md` |
| OpenCode | `~/.config/construct-cli/home/.config/opencode/AGENTS.md` |
| Cline | `~/.config/construct-cli/home/.cline/AGENTS.md` |
| Codex | `~/.config/construct-cli/home/.codex/AGENTS.md` |
| Droid | `~/.config/construct-cli/home/.factory/AGENTS.md` |
| Goose | `~/.config/construct-cli/home/.config/goose/AGENTS.md` |
| Kilo Code | `~/.config/construct-cli/home/.kilocode/rules/AGENTS.md` |
| Pi | `~/.config/construct-cli/home/.pi/agent/AGENTS.md` |

### Skills — Core (9, always active)

Agents that natively read `~/.agents/skills/` — covered by the **Standard** symlink, no dedicated entry needed:

| Agent | Native path |
|-------|-------------|
| Gemini | `~/.agents/skills/` |
| OpenCode | `~/.agents/skills/` |
| Codex | `~/.agents/skills/` |

Agents with dedicated symlinks:

| Agent | Path |
|-------|------|
| Standard | `~/.agents/skills/` |
| Claude | `~/.claude/skills/` |
| Amp | `~/.config/agents/skills/` |
| Qwen | `~/.qwen/skills/` |
| Copilot | `~/.copilot/skills/` |
| Cline | `~/.cline/skills/` |
| Droid | `~/.factory/skills/` |
| Goose | `~/.config/goose/skills/` |
| Kilo Code | `~/.kilocode/skills/` |
| Pi | `~/.pi/agent/skills/` |

### Skills — construct-cli (detected if `~/.config/construct-cli/config.toml` exists)

Agents that natively read `~/.agents/skills/` within the construct-cli home — covered by **construct_Standard**:

| Agent | Native path |
|-------|-------------|
| Gemini | `~/.config/construct-cli/home/.agents/skills/` |
| OpenCode | `~/.config/construct-cli/home/.agents/skills/` |
| Codex | `~/.config/construct-cli/home/.agents/skills/` |

Agents with dedicated symlinks:

| Agent | Path |
|-------|------|
| Standard | `~/.config/construct-cli/home/.agents/skills/` |
| Claude | `~/.config/construct-cli/home/.claude/skills/` |
| Amp | `~/.config/construct-cli/home/.config/amp/skills/` |
| Qwen | `~/.config/construct-cli/home/.qwen/skills/` |
| Copilot | `~/.config/construct-cli/home/.copilot/skills/` |
| Cline | `~/.config/construct-cli/home/.cline/skills/` |
| Droid | `~/.config/construct-cli/home/.factory/skills/` |
| Goose | `~/.config/construct-cli/home/.config/goose/skills/` |
| Kilo Code | `~/.config/construct-cli/home/.kilocode/skills/` |
| Pi | `~/.config/construct-cli/home/.pi/agent/skills/` |

---

## Skills

Skills are shared agent capabilities stored in `./skills/`. Each skill is a subdirectory containing a `SKILL.md` file with a YAML frontmatter block (`name`, `description`) followed by the skill's instructions.

All skills must follow the Agent Skills specification: https://agentskills.io/specification

### Available Skills

| Skill | Description |
|-------|-------------|
| `refactor-pass` | Perform a refactor pass focused on simplicity after recent changes. Removes dead code, straightens logic flows, removes excessive parameters and premature optimization. Runs build/tests to verify. |
| `codex-delegate` | Use OpenAI Codex CLI for complex debugging and code analysis via a file-based question/answer pattern (`/tmp/question.txt` → `/tmp/reply.txt`). |
| `orchestrate` | Structured workflow orchestration: plan-first execution, subagent delegation, self-improvement loops, verification gates, elegance checks, and autonomous bug fixing. |
| `plan` | Thorough plan review across architecture, code quality, tests, and performance. Presents numbered issues with lettered options, concrete tradeoffs, and opinionated recommendations. Asks for user input before proceeding. |

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
description: One-line description used by agents to decide when to invoke this skill.
---

# My Skill

...instructions...
```

---

## License

This project is licensed. See `LICENSE` for details.
