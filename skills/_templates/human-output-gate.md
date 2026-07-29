# Human-output gate

Applies to any text published under Esteban's name to an external surface: git commit messages, GitHub PR titles and bodies, PR reviews and review comments, and GitHub issue titles and bodies. Once posted, these read as the human's own words. They are never auto-posted.

## Rule (hard)

Before running the command that posts the text (`git commit`, `gh pr create`, `gh pr review`, `gh pr comment`, `gh api .../pulls/<N>/comments`, `gh issue create`, etc.), you MUST:

1. **Render the complete, final message** exactly as it will be posted. Title and body, in full, not a summary. Use a fenced code block so whitespace, bullets, and emoji are visible.
2. **Name the destination** and, where relevant, the event (e.g. "PR review REQUEST_CHANGES on #42", "Issue: <title>", "Commit message").
3. **STOP. Wait for an explicit decision.** Do not run the post command until the user gives one of:
   - **Approve** ("post", "ship", "go", "looks good") -> post exactly as shown.
   - **Amend** -> apply the edit, re-render the full message, then STOP and wait again. Loop until approved.
   - **Cancel** (or silence / no clear answer) -> abort. Post nothing.

Never assume approval. **Silence is a cancel.** If the user gives a new instruction mid-loop ("also fix the typo"), treat it as an amend, then re-render the whole message before asking again.

## Scope

- **One gate per post.** A review body, a PR description, an issue, a commit message each get their own gate.
- **Batch posts gate one at a time.** If a skill publishes several issues in a row, render and gate each before its own create command. A blanket "approve all" is not valid unless the user has seen every full body.

## What is not gated

Local-only artifacts the user already reviews directly: draft files, plan files, local markdown, anything that stays in the working tree. No gate needed; the user sees the file.
