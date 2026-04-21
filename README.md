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
- Backs up existing real files/directories before linking.
- `unlink` restores the most recent backup automatically.
- Sorting: Displays regular agents first, followed by `construct_` agents.

---

## Supported Agents

### Instructions (AGENTS.md / CLAUDE.md / etc.)

| Agent | Path | Notes |
|-------|------|-------|
| Standard | `~/.agents/AGENTS.md` | Emerging standard path |
| Gemini | `~/.gemini/GEMINI.md` | Custom filename |
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

### Skills

Agents that natively read `~/.agents/skills/` (covered by **Standard**, no dedicated entry needed):
- Gemini, Codex, Opencode.

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

---

## Skills

Skills are shared agent capabilities stored in `./skills/`. Each skill is a subdirectory containing a `SKILL.md` file with a YAML frontmatter block (`name`, `description`) followed by the skill's instructions.

All skills must follow the Agent Skills specification: https://agentskills.io/specification

### Available Skills

| Skill | Description |
|-------|-------------|
| `refactor-pass` | Perform a refactor pass focused on simplicity after recent changes. |
| `codex-delegate` | Use OpenAI Codex CLI for complex debugging and code analysis. |
| `orchestrate` | Structured workflow orchestration and subagent delegation. |
| `plan` | Thorough plan review across architecture, code quality, and performance. |
| `humanizer` | Remove signs of AI-generated writing from text. |

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

## License

This project is licensed. See `LICENSE` for details.
