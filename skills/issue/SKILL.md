---
name: issue
description: Create or manage GitHub issues using the gh CLI. Use when opening a new issue, filing a bug report, or updating issue status and labels.
---

# Issue

Create or manage standalone GitHub issues with the `gh` CLI. Tracker conventions in [`../_templates/issue-tracker.md`](../_templates/issue-tracker.md).

## Scope

Standalone work only: a bug report, feature request, story, or task that makes sense without a parent. Work that belongs to a bigger story goes through `to-tickets` (it links children to a parent).

## Create an issue

1. **Repo templates win (hard).** If the repo ships issue templates (`.github/ISSUE_TEMPLATE/`), read the one that fits and write the body to match its structure. The template below is the fallback.
2. **Gather the facts.** From the conversation: what, why, acceptance criteria, affected area. Missing critical facts? Ask before drafting.
3. **Title.** Conventional Commits prefix (`fix(scope): ...`) if the repo uses it, else a human verb-led title.
4. **Draft the body** following the repo template, else this fallback:

   ```
   ## Summary
   <1-2 sentences: what and why>

   ## Requirements
   - <requirement>

   ## Acceptance Criteria
   - [ ] <criterion>

   ## Technical Notes
   <references, constraints, only if non-obvious>

   ## Out of Scope
   <what this issue does not cover, if anything>
   ```

5. **Labels.** Run `gh label list` and use only labels that exist in the repo. Add one type label (`bug`, `enhancement`, `documentation`, `question`), area label(s) for the affected code, and a severity label for bugs. The repo has no such labels? Skip them; do not invent.
6. **Human-output gate (hard).** Render the full issue title and body exactly as they will be posted, the body in a fenced block, plus the destination repo if not the current one. STOP. Do not run `gh issue create` until the user approves, amends, or cancels. Silence is a cancel. Full rules in [`../_templates/human-output-gate.md`](../_templates/human-output-gate.md).
7. **Create** with `--body-file` (never inline or via heredoc; they mangle multi-line bodies):

   ```bash
   body=$(mktemp)
   # Write the step-4 draft into "$body" with your file-write tool (NOT echo/heredoc).
   gh issue create --title "<title>" --body-file "$body" --label <label>
   rm -f "$body"
   ```
   - Done when: `gh` returns the issue URL. Report it.

## Manage an issue

Quick reference (`gh issue`):

- **View**: `gh issue view <number> --comments`
- **Comment**: `gh issue comment <number> --body-file <file>` (gate the comment text first, hard)
- **Edit**: `gh issue edit <number> --title "..."` / `--add-label ...` / `--remove-label ...`
- **Close**: `gh issue close <number> --comment "..."` (gate the comment)
- **Reopen**: `gh issue reopen <number>`
- **List**: `gh issue list --state open --label <label> --assignee @me`

Comments, label changes, and close text publish under Esteban's name: gate each before posting (hard).

## Hard rules

- **Gate every post (hard).** Never auto-create or auto-comment. Render, STOP, wait for approve / amend / cancel. See [`../_templates/human-output-gate.md`](../_templates/human-output-gate.md).
- **Repo templates win (hard).** `.github/ISSUE_TEMPLATE/` first; this skill's template is the fallback. Third-party maintainers' conventions come first.
- **NEVER attribute to any AI agent.** No `Generated with ...` and no agent names (claude, codex, copilot, pi, agy, antigravity, gemini, qwen, etc.) in titles, bodies, or comments. The output reads as a human dev's.
- **No invented labels or assignees.** Labels from `gh label list` only; assignees only when the user asks.

## Notes

- Write issue titles and bodies in Esteban's formal voice (`esteban-voice` skill, FORMAL mode, for tone only: first-person active, no em dashes, concrete specifics). Keep the structure from the repo template or step 4.
- Treat caller arguments as guidance: issue number, title draft, labels, target repo (`-R OWNER/REPO`).
