# META

source: https://github.com/openclaw/acpx/blob/main/skills/acpx/SKILL.md
upstream-repo: openclaw/acpx
upstream-author: OpenClaw Team
license: MIT
npm: acpx
repo-created: 2026-02-17
last-synced: 2026-11-24
upstream-commit: e6a5e17 (2026-11-21)
sync-status: synced (local sections re-applied; see 2026-11-24 re-sync)

## Provenance

This skill documents the `acpx` CLI and is vendored from the `openclaw/acpx`
repository, which ships it at `skills/acpx/SKILL.md`. The local copy is an
earlier sync: its frontmatter `description` and body predate several upstream
additions, so it is not a verbatim copy of `main`.

## What is behind upstream

Resolved 2026-11-24 by full re-sync at e6a5e17. The gaps listed below are
now carried; kept as history:

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

- **Local sections, re-applied on the 2026-11-24 re-sync, keep on refresh:**
  "Antigravity (agy)" (rewritten: upstream now ships a native `antigravity`
  adapter, untested on this machine; noacp stays the proven fallback),
  "Direct agent usage (outside acpx)", "Agent quirks" (placed before
  "Config files").
- **Re-sync by hand.** Do not overwrite the local copy from `main` blindly;
  diff first and merge, preserving the local sections.

## sync-status

Synced at e6a5e17 (2026-11-21) with local sections re-applied. Re-merge by
hand when refreshing; preserve the fork notes above.
