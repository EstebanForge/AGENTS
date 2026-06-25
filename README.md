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
- Backs up existing real files/directories before linking.
- `unlink` restores the most recent backup automatically.
- Sorting: Displays regular agents first, followed by `construct_` agents.

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

---

## Skills

Skills are shared agent capabilities stored in `./skills/`. Each skill is a subdirectory containing a `SKILL.md` file with a YAML frontmatter block (`name`, `description`) followed by the skill's instructions.

All skills must follow the Agent Skills specification: https://agentskills.io/specification

### Available Skills

| Skill | Description |
|-------|-------------|
| `acpx` | Use acpx as a headless ACP CLI for agent-to-agent communication. |
| `agent-browser` | Browser automation CLI for AI agents — navigate, click, fill forms, screenshot, scrape, and test web apps. |
| `codebase-design` | Shared vocabulary for designing deep modules — interface, depth, seam, adapter. |
| `commit` | Read this skill before making git commits. |
| `datastar` | Build reactive hypermedia-driven web apps using Datastar. Signals, data-* attributes, SSE backend events, actions, and patterns like CQRS, active search, infinite scroll. |
| `design-taste-frontend` | Senior UI/UX Engineer. Architect digital interfaces overriding default LLM biases. |
| `diagnosing-bugs` | Disciplined diagnosis loop for hard bugs and perf regressions: reproduce, minimise, hypothesise, instrument, fix, regression-test. |
| `domain-modeling` | Build and sharpen a project's domain model; maintain `CONTEXT.md` and ADRs inline. |
| `grill-me` | Relentless interview to sharpen a plan or design (user-invoked wrapper for `/grilling`). |
| `grill-with-docs` | Relentless interview that also builds the domain model (glossary + ADRs) as you go. |
| `grilling` | The reusable interview loop behind `grill-me` and `grill-with-docs`. |
| `handoff` | Compact the current conversation into a handoff document for another agent to pick up. |
| `humanizer` | Remove signs of AI-generated writing from text. |
| `improve-codebase-architecture` | Scan a codebase for deepening opportunities, present them as a visual HTML report, then grill through whichever one you pick. |
| `mcp-cli-ent` | Interact with MCP servers using the `mcp-cli-ent` command-line client. |
| `mermaid-diagrams` | Validate and fix Mermaid diagrams by rendering them with the official mermaid-cli (mmdc). mmdc has no lint mode; rendering is the validation. |
| `noacp` | File-based session protocol for agents without ACP support (`agy`, etc.). |
| `orchestrate` | Structured workflow orchestration for non-trivial tasks. |
| `plan` | Thorough plan review across architecture, code quality, tests, and performance. |
| `prd-to-plan` | Turn a PRD into a multi-phase implementation plan using tracer-bullet vertical slices. |
| `pull-request` | Open a GitHub pull request from the current branch: branch safety, commit delegation, push, and `gh pr create` with an attribution-free description. |
| `refactor-pass` | Perform a refactor pass focused on simplicity after recent changes. |
| `request-refactor-plan` | Create a detailed refactor plan with tiny commits via user interview. |
| `review-pull-request` | Review a GitHub PR for bugs, regressions, security holes, and risky changes; produce a severity-ordered verdict and submit it via `gh`. |
| `tdd` | Test-driven development with a red-green-refactor loop, one vertical slice at a time. |
| `teach` | Teach the user a new skill or concept over multiple sessions in a stateful workspace. |
| `to-issues` | Break a plan, spec, or PRD into independently-grabbable issues using vertical slices. |
| `to-prd` | Turn the current conversation into a PRD and publish it to the issue tracker. |
| `writing-great-skills` | Reference for writing and editing skills well — the vocabulary and principles that make a skill predictable. |

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

- `configs/settings.json` — Pi agent settings (provider, model, packages, UI). Mirrors `~/.pi/agent/settings.json`.
- `configs/mcp_servers.json` — Pi MCP server registry. Mirrors `~/.pi/agent/mcp_servers.json`.

Detailed Pi configuration reference: [docs/AGENT-PI.md](docs/AGENT-PI.md).

### Pi Extensions

Pi packages installed in this instance (30 total, verified via `pi list`). Canonical list tracked in [`configs/settings.json`](configs/settings.json).

| Package | Purpose |
|---------|---------|
| `pi-librarian` | GitHub research scout for code/docs lookup |
| `@sherif-fanous/pi-rtk` | Token-saving command proxy |
| `git:ferologics/pi-notify` | Event notifications |
| `pi-web-providers` | Web search/contents/research/answer providers |
| `pi-autoresearch` | Autonomous experiment loop |
| `pi-acp` | Headless ACP CLI for agent-to-agent comms |
| `@tintinweb/pi-tasks` | Task management |
| `pi-context-usage` | Context budget visibility |
| `git:code-yeongyu/pi-nested-agents-md` | Nested-agent markdown handling |
| `pi-init` | AGENTS.md initialization |
| `@ff-labs/pi-fff` | Fuzzy file finder / grep |
| `@upstash/context7-pi` | Library docs + snippets |
| `@estebanforge/pi-agentmemory` | Cross-session memory (native extension) |
| `@mcowger/pi-better-messages-cache` | Improved message caching |
| `glm-vision` | GLM vision (image input) |
| `pi-token-speed` | Token speed display |
| `pi-diff-review` | Diff review |
| `@narumitw/pi-auto-thinking` | Automatic thinking-level control |
| `@juicesharp/rpiv-ask-user-question` | Structured user-question tool |
| `@estebanforge/pi-codegraph-enhanced` | Local code knowledge graph (replaces `@vndv/pi-codegraph`) |
| `@ctogg/pi-cost-counter` | Spend ledger for token cost tracking |
| `pi-token-burden` | Token burden display |
| `@gotgenes/pi-subagents` | Subagent execution |
| `@estebanforge/pi-go-review` | Go review (100 Go Mistakes checklist) |
| `@estebanforge/pi-rust-review` | Rust review (code smells guide) |
| `pi-claude-bridge` | Bridge to Claude models |
| `@estebanforge/pi-php-review` | PHP review (8.2+ anti-patterns) |
| `@estebanforge/pi-glm-tweaks` | GLM provider tweaks (`+extensions/index.ts`) |
| `@estebanforge/pi-ts-review` | TypeScript / React review |
| `@estebanforge/pi-js-review` | JavaScript review |

## License

This project is licensed. See `LICENSE` for details.
