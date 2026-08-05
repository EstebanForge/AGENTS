# mcp-cli-ent

A reference skill for the `mcp-cli-ent` CLI, a Go-based standalone client for Model Context Protocol (MCP) servers. The agent loads `SKILL.md` on demand to list servers, inspect tool schemas, call tools, and manage persistent browser sessions. Output is JSON by default, structured for programmatic consumption.

## Installation

### Manual install (only the skill file)

```bash
mkdir -p ~/.claude/skills/mcp-cli-ent
cp SKILL.md ~/.claude/skills/mcp-cli-ent/
```

## Usage

The skill is invoked when the task needs MCP server discovery, schema inspection, or a tool call. Or ask the agent directly:

```
Read the mcp-cli-ent skill and list the context7 tools.
```

## What is inside

`SKILL.md` documents:

- **Quick start** - discover, list-tools, search, call, human-readable output.
- **Output modes** - compact discovery index, full tool details, `--human`, `--verbose`, and structured error responses.
- **Flags** - `--search`, `--human`, `--verbose`, `--refresh`, `--clear-cache`, `--config`, `--timeout`.
- **Workflows** - tool discovery and execution, session management (persistent browser state), and daemon management.

## Version History

- **1.0.0** - Initial curated reference.

## Source

Skill curated and maintained by [EstebanForge](https://github.com/EstebanForge). Upstream: the `mcp-cli-ent` CLI.

## License

MIT
