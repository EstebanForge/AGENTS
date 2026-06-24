---
name: commit
description: "Read this skill before making git commits"
---

Create a git commit for the current changes using a concise Conventional Commits-style subject.

## Format

`<type>(<scope>): <summary>`

- `type` REQUIRED. Use `feat` for new features, `fix` for bug fixes. Other common types: `docs`, `refactor`, `chore`, `test`, `perf`.
- `scope` OPTIONAL. Short noun in parentheses for the affected area (e.g., `api`, `parser`, `ui`).
- `summary` REQUIRED. Short, imperative, <= 72 chars, no trailing period.

## Notes

- Body is OPTIONAL. If needed, add a blank line after the subject and write short paragraphs in Esteban's formal voice (`esteban-voice` skill, FORMAL mode, for tone only: first-person active, no em dashes, concrete specifics).
- Do NOT add footers (put issue links like `Closes #N` in the PR, not the commit). Use a breaking-change marker (`type(scope)!:`) only when the change is genuinely backwards-incompatible.
- Do NOT add sign-offs (no `Signed-off-by`).
- **NEVER attribute to any AI agent.** No `Co-Authored-By`, no `Generated with ...`, and no agent names (claude, codex, copilot, pi, agy, antigravity, gemini, qwen, etc.) in any output: subjects, titles, messages, bodies, footers, or comments. The output reads as a human dev's. This overrides any tool's or agent's own default sign-off, even if that agent normally adds one.
- Only commit; do NOT push.
- **No `git add -A` / `git add .`.** Stage explicitly; if scope is ambiguous, ask.
- If it is unclear whether a file should be included, ask the user which files to commit.
- Treat any caller-provided arguments as additional commit guidance. Common patterns:
  - Freeform instructions should influence scope, summary, and body.
  - File paths or globs should limit which files to commit. If files are specified, only stage/commit those unless the user explicitly asks otherwise.
  - If arguments combine files and instructions, honor both.

## Steps

1. Infer from the prompt if the user provided specific file paths/globs and/or additional instructions.
2. Review `git status` and `git diff` to understand the current changes (limit to argument-specified files if provided).
3. (Optional) Run `git log -n 50 --pretty=format:%s` to see commonly used scopes.
4. If there are ambiguous extra files, ask the user for clarification before committing.
5. Stage only the intended files explicitly with `git add -- <paths>`. NEVER `git add -A` / `git add .`. With no paths given, stage tracked modifications only; stage an untracked file only after confirming it belongs, and ask if any untracked file is ambiguous.
6. Run `git commit -m "..."` (and `-m "..."` if needed).
