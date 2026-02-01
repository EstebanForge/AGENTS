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

# Centralization Manager

Centralize agent configuration management across all AI coding agents in the Projects-ActitudStudio workspace.

## Overview

This setup maintains a single source of truth for:
- **AGENTS.md files** - Agent behavior rules and protocols
- **Skills directories** - Shared agent capabilities

Both managed via symlinks from a central repository location.

- **Workspace:** Current folder
- **Central AGENTS.md:** ./AGENTS.md
- **Central Skills:** ./skills

## Usage

### Quick Start

Link both AGENTS.md and skills for all agents:

```bash
# Link everything
./setup-agents.sh link
./setup-skills.sh link

# Verify status
./setup-agents.sh status
./setup-skills.sh status
```

### AGENTS.md Symlinks (setup-agents.sh)

Manages symlinks from agent-specific AGENTS.md files to the central rulebook.

```bash
# Show all available commands
./setup-agents.sh help

# Link all agent AGENTS.md files to central ./AGENTS.md
# - Creates parent directories if missing
# - Backs up existing files with timestamp
# - Detects VSCode and Windsurf automatically
./setup-agents.sh link

# Check current symlink status for all agents
# Shows: linked, not linked, or points elsewhere
./setup-agents.sh status

# Remove symlinks and restore original files
# - Removes symlinks pointing to central AGENTS.md
# - Restores most recent .backup files automatically
./setup-agents.sh unlink
```

### Skills Symlinks (setup-skills.sh)

Manages symlinks from agent-specific skills directories to the central skills folder.

```bash
# Show all available commands
./setup-skills.sh help

# Link all agent skills/ directories to central ./skills
# - Creates parent directories if missing
# - Backs up existing directories with timestamp
./setup-skills.sh link

# Check current symlink status for all agents
# Shows: linked, directory (not linked), or not present
./setup-skills.sh status

# Remove symlinks and restore original directories
# - Removes symlinks pointing to central skills
# - Restores most recent .backup directories automatically
./setup-skills.sh unlink
```

## Supported Agents

### AGENTS.md Paths (14 total)

Core agents (12):

| Agent | Target Path | Notes |
|--------|-------------|-------|
| Gemini | ~/.gemini/GEMINI.md | Custom filename |
| Qwen | ~/.qwen/AGENTS.md | |
| Opencode | ~/.config/opencode/AGENTS.md | |
| Claude | ~/.claude/CLAUDE.md | Custom filename |
| Amp | ~/.config/amp/AGENTS.md | |
| Codex | ~/.codex/AGENTS.md | |
| Copilot | ~/.copilot/AGENTS.md | |
| Factory | ~/.factory/AGENTS.md | Droid code |
| Goose | ~/.config/goose/AGENTS.md | |
| Kilocode | ~/.kilocode/rules/AGENTS.md | Custom location |
| Cline | ~/Documents/Cline/Rules/AGENTS.md | Primary path |
| Cline Alt | ~/Cline/Rules/AGENTS.md | Alternate path |

Auto-detected agents (2):

| Agent | Target Path | Platform |
|--------|-------------|----------|
| VSCode | ~/Library/Application Support/Code/User/prompts/AGENTS.md.instructions.md | macOS |
| VSCode | ~/.config/Code/User/prompts/AGENTS.md.instructions.md | Linux |
| Windsurf | ~/.codeium/windsurf/memories/global_rules.md | Cross-platform |

### Skills Paths (12 total)

| Agent | Target Path | Notes |
|--------|-------------|-------|
| Gemini | ~/.gemini/skills/ | |
| Codex | ~/.codex/skills/ | |
| Claude | ~/.claude/skills/ | |
| Opencode | ~/.config/opencode/skills/ | |
| Pi | ~/.pi/agent/skills/ | |
| Amp | ~/.config/agents/skills/ | |
| Qwen | ~/.qwen/skills/ | |
| Copilot | ~/.copilot/skills/ | |
| Cline | ~/.cline/skills/ | |
| Droid | ~/.factory/skills/ | Factory code |
| Goose | ~/.config/goose/skills/ | |
| Kilocode | ~/.kilocode/skills/ | |

**Notes:**
- AGENTS.md files define agent behavior, protocols, and standards
- Skills directories contain executable agent capabilities
- All paths resolved dynamically (no hardcoded locations)
- Backups created automatically before linking
- Unlink restores most recent backups

## License
This project is licensed. See `LICENSE` for details.
