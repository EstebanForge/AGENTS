# META

source: https://github.com/openclaw/acpx/blob/main/skills/acpx/SKILL.md
upstream-repo: openclaw/acpx
upstream-author: OpenClaw Team
license: MIT
npm: acpx
repo-created: 2026-02-17
sync-status: stale (behind upstream)

## Provenance

This skill documents the `acpx` CLI and is vendored from the `openclaw/acpx`
repository, which ships it at `skills/acpx/SKILL.md`. The local copy is an
earlier sync: its frontmatter `description` and body predate several upstream
additions, so it is not a verbatim copy of `main`.

## What is behind upstream

The local copy lacks features the upstream skill now documents:

- System prompt override (`--system-prompt` / `--append-system-prompt`) and
  Claude settings isolation (`ACPX_CLAUDE_INCLUDE_USER_SETTINGS`).
- Multi-agent flows (`acpx flow run`, the `acpx/flows` authoring API:
  `defineFlow`, `decision`, `decisionEdge`, `acp`, `action`, `compute`,
  `checkpoint`).
- `compare` command and `sessions ensure / prune / export / import`.
- Newer registry agents (`gemini`, `mux`, `pool`, `zeroclaw`, `fast-agent`,
  `grok-build`) and Devin ACP compatibility.
- Permission policy flags (`--policy`, `--non-interactive-permissions`,
  `--allowed-tools`, `--max-turns`, `--prompt-retries`, `--no-fs`,
  `--no-terminal`, `--json-strict`).

## Fork notes

- **Local edits.** The body is close to upstream but the frontmatter
  `description` is shorter, and a local "Antigravity (agy) redirect" section
  plus an "Agent quirks" / "Direct agent usage" block are present locally.
  These look project-specific, not upstream.
- **Re-sync by hand.** Do not overwrite the local copy from `main` blindly;
  diff first and merge, preserving the local agy redirect and any
  project-specific guidance.

## sync-status

Stale. Re-merge against the linked file when refreshing.
