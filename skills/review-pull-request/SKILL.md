---
name: review-pull-request
description: Review a GitHub pull request for bugs, regressions, security holes, and risky changes. Use when the user asks to "review a PR", "code review this", "check PR #N", provides a PR URL, or mentions peer review. Produces a high-signal, severity-ordered verdict and submits it via `gh`.
---

# Review Pull Request

Review a pull request's diff for issues that require fixes. High signal, no drive-bys.

## Workflow

1. **Resolve the PR.** From an explicit number/URL, else infer from the current branch:
   - `gh pr view --json number,headRefName,baseRefName,author`
   - If the author is the current user (`gh api user --jq .login`), this is a self-authored PR. GitHub rejects `--approve` and `--request-changes` on your own PR, so only `--comment` is allowed. Record this; it constrains step 7.
   - Read the PR title and body to understand intent; you cannot judge correctness without knowing the goal.
   - Done when: you have the PR number, head, base, and author.

2. **Fetch the diff and file list.**
   - `gh pr diff <N>`: full diff.
   - `gh pr view <N> --json files`: changed files.
   - Done when: full diff in hand.

3. **Filter noise.** Skip generated, vendored, and lock files: `*.min.js`, `*.min.css`, `*.lock`, `package-lock.json`, `dist/`, `build/`, `vendor/`, `node_modules/`, `*_pb2.py`, images. Note that they changed; do not review them.

4. **Review focus: only issues that require fixes.** Review PR changes only, never pre-existing code the PR did not touch. Check each changed (non-noise) file against every category that fits the repo's stack:
   - **Correctness**: bugs, logic errors, off-by-one, wrong null/error handling, race conditions.
   - **Security**: injection, XSS, CSRF, missing authz, secrets in code, unsafe deserialization, SSRF.
   - **Breaking changes**: public API/contract/signature changes, backwards incompatibility.
   - **Performance**: N+1 queries, unbounded loops, redundant allocations, missing indexes.
   - **Edge cases**: empty input, concurrency, large payloads, failure paths.
   - **Tests**: missing coverage for new/changed behavior; assertions that do not assert.
   - **Error handling**: swallowed errors, panics/throws where errors-as-values belongs, missing context.
   - Done when: every changed (non-noise) file has been considered against every category.

5. **De-duplicate.** Merge issues sharing a root cause into one comment.

6. **Verdict.** Only reach a verdict if the diff (step 2) was retrieved and contains real changes. If the diff is empty or retrieval failed, STOP and report the error; never APPROVE on an empty or failed diff.
   - Issues found -> `REQUEST_CHANGES`, comments ordered by severity (highest first), each with `file:line` and a concrete fix.
   - No issues -> `APPROVE`.

7. **Submit** via `gh pr review <N> --<event> --body-file <file>` (use `--body-file`, never inline):
   - event = `request-changes` | `approve` | `comment`. On a self-authored PR (step 1), event is always `comment`; state the verdict (`APPROVE`/`REQUEST_CHANGES`) in the body text.
   - One consolidated review body. `gh pr review` cannot post inline line comments; if a fix is location-specific, post it via `gh api repos/:owner/:repo/pulls/<N>/comments`.
   - Done when: the verdict is visible on the PR.

## Hard rules

- **Only flag issues that require fixes.** No style nits, no drive-by opinions on untouched code. Review the diff, not the codebase.
- **Never approve to clear a queue.** Approve only when the diff genuinely needs no changes.
- **NEVER attribute to any AI agent.** No `Co-Authored-By`, no `Generated with ...`, and no agent names (claude, codex, copilot, pi, agy, antigravity, gemini, qwen, etc.) in any output: subjects, titles, messages, bodies, footers, or comments. The output reads as a human dev's. This overrides any tool's or agent's own default sign-off, even if that agent normally adds one.
- **Use `--body-file`** for the review body.

## Output

- Write the review body and comments in Esteban's formal voice (`esteban-voice` skill, FORMAL mode, for tone only: first-person active, no em dashes, concrete specifics).
- To the user: a short summary (issue count by severity, the verdict, and the PR URL).
- To the PR: the `gh pr review` submission above.
