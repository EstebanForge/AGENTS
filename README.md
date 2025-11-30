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

## Bulk-update your agent prompts

Use the following snippet to open common agent prompt files; swap `subl` with your editor if needed:

macOS:

```bash
subl ~/.claude/CLAUDE.md &&
subl ~/.gemini/GEMINI.md &&
subl ~/.qwen/AGENTS.md &&
subl ~/.config/opencode/AGENTS.md &&
subl ~/Library/Application\ Support/Code/User/prompts/AGENTS.md.instructions.md &&
subl ~/.codeium/windsurf/memories/global_rules.md
```

Linux:

```bash
subl ~/.claude/CLAUDE.md &&
subl ~/.gemini/GEMINI.md &&
subl ~/.qwen/AGENTS.md &&
subl ~/.config/opencode/AGENTS.md &&
subl ~/.config/Code/User/prompts/AGENTS.md.instructions.md &&
subl ~/.codeium/windsurf/memories/global_rules.md
```

Ensure each file contains the rules from `AGENTS.md` plus any system-specific variations you require.

## License
This project is licensed. See `LICENSE` for details.
