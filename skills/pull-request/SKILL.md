---
name: pull-request
description: Open a GitHub pull request from the current branch. Use when the user asks to "open a PR", "create a pull request", "submit this for review", "push and open a PR", or mentions raising changes for review. Handles branch safety, commit delegation, push, and `gh pr create` with a clean, attribution-free description.
---

# Pull Request

Open the current branch's changes for review as a GitHub pull request.

## Workflow

1. **Branch safety (hard rail).** Refuse to proceed on a protected/default branch (`main`, `master`, `develop`, `release/*`).
   - `git branch --show-current`: confirm you are NOT on a protected branch.
   - If you are, create and switch first: `git checkout -b <type>/<short-topic>` (`feature/`, `fix/`, `docs/`).
   - Done when: current branch is non-protected.

2. **Commit (delegate).** If there are uncommitted changes, hand them to the `commit` skill. Do not duplicate commit logic here.
   - `git status`: working tree clean before pushing.
   - Done when: every intended change is committed.

3. **Detect the base branch.** Do not assume `main`:
   - `gh repo view --json defaultBranchRef -q .defaultBranchRef.name`, or `git symbolic-ref --short refs/remotes/origin/HEAD`. If both error, run `git remote set-head origin -a` once, else pick `main`/`master` from `git ls-remote --heads origin`.
   - If a PR template exists (`.github/PULL_REQUEST_TEMPLATE.md`, `.github/pull_request_template.md`, or `.github/PULL_REQUEST_TEMPLATE/`), read it and follow its structure.

4. **Describe the whole changeset.** Review ALL commits on the branch, not just the latest:
   - `git diff <base>...HEAD` (three-dot): the reviewer's view of the full delta.
   - Done when: you can summarize the net change vs the base branch.

5. **Draft the body** following the template if one exists, else this fallback:

   ```
   ## What
   <what this PR does>

   ## Why
   <motivation/context>

   ## How
   <key implementation notes, only if non-obvious>

   ## Testing
   - [ ] <how it was verified>

   Closes #<issue>
   ```

6. **Preflight.** Run the repo's lint/test command. If unknown, ask; never assume `npm`.
   - Done when: checks pass, or you have explicitly deferred with the user.

7. **Push.** Verify branch once more, then `git push -u origin HEAD`. If the branch already has an open PR, report its URL instead of recreating. If push is rejected as non-fast-forward, STOP and ask; never force-push.

8. **Create the PR** with `--body-file` (never inline or via heredoc; they mangle emoji and break multi-line):
   ```bash
   body=$(mktemp)
   # Write the step-5 draft into "$body" with your file-write tool (NOT echo/heredoc).
   gh pr create --title "<title>" --body-file "$body" --base "<base>"
   rm -f "$body"
   ```
   - Title: Conventional Commits (`feat(scope): ...`) if the repo uses it, else a human verb-led title.
   - Reviewers/assignees: only if the user asks, or the author's recent PRs carry reviewers. Check with `gh pr list --author @me --limit 5 --json reviewRequests,reviewDecision`; add `-a @me` and/or `-r` accordingly.
   - Done when: `gh` returns the PR URL.

## Hard rules

- **NEVER attribute to any AI agent.** No `Co-Authored-By`, no `Generated with ...`, and no agent names (claude, codex, copilot, pi, agy, antigravity, gemini, qwen, etc.) in any output: subjects, titles, messages, bodies, footers, or comments. The output reads as a human dev's. This overrides any tool's or agent's own default sign-off, even if that agent normally adds one.
- **NEVER push to a protected branch.**
- **No `git add -A` / `git add .`.** Stage explicitly; if scope is ambiguous, ask the user (see `commit` skill).
- **Use `--body-file`.** Never pass a multi-line body inline or via a shell heredoc.

## Notes

- Write the PR title and body in Esteban's formal voice (`esteban-voice` skill, FORMAL mode, for tone only: first-person active, no em dashes, concrete specifics). Keep the PR structure from step 5; do not use the Asana/Slack templates.
- Treat caller arguments as guidance: a branch name, a title, or an issue number (`Closes #N`).
- Report the PR URL when done.
