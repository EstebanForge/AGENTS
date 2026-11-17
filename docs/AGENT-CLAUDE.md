# Claude Code Configuration Reference

> Reproduce this Claude Code setup on a fresh machine. The rulebook and skills are provisioned by this repo's `manage.sh`; plugins are installed with `claude plugin install`.

## Rulebook and skills

- `~/.claude/CLAUDE.md` — symlink to this repo's `AGENTS.md` (manage.sh `Claude` entry).
- `~/.claude/skills/` — same repo-managed set as `~/.agents/skills/` (symlinked per skill).
- `~/.claude/GEMINI.md` — symlink to `AGENTS.md` beside it.
- `~/.claude/AGENTS.md` — a local Claude-specific rulebook, not managed by this repo; `manage.sh` targets only `CLAUDE.md` for Claude and never touches it.

## Plugins (user scope)

Installed plugins, per `~/.claude/plugins/installed_plugins.json`. Versions are omitted on purpose; plugins auto-update and a pinned number goes stale fast.

| Plugin | Marketplace | Marketplace repo |
| --- | --- | --- |
| `compound-engineering` | `compound-engineering-plugin` | `EveryInc/compound-engineering-plugin` |
| `context7` | `claude-plugins-official` | `anthropics/claude-plugins-official` |
| `tamp` | `sliday` | `sliday/claude-plugins` |
| `claude-hud` | `claude-hud` | `jarrodwatts/claude-hud` |
| `agentmemory` | `agentmemory` | `rohitg00/agentmemory` |
| `rust-analyzer-lsp` | `claude-plugins-official` | `anthropics/claude-plugins-official` |

Install pattern: add the marketplace repo, then install the plugin (second line is the construct-cli sandbox variant):

```
claude plugin marketplace add sliday/claude-plugins && claude plugin install tamp@sliday

ns-claude plugin marketplace add sliday/claude-plugins && ns-claude plugin install tamp@sliday
```

## Hooks

Two hook scripts live in `~/.claude/hooks/`; both are installed and overwritten by their own tools, so never edit them in place:

- `herdr-agent-state.sh` — managed by `herdr` (integration `claude`); custom hooks go beside it.
- `rtk-rewrite.sh` — managed by `rtk` (`rtk-hook-version: 3`, with `.rtk-hook.sha256` as its integrity checksum); rewrites shell commands through `rtk rewrite` for token savings (needs `rtk >= 0.23.0`, `jq`).

## MCP

MCP servers for Claude Code follow the central registry: [MCP-SERVERS.md](MCP-SERVERS.md) (config path `~/.claude.json`).
