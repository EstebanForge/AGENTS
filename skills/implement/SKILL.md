---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets.

Use /tdd where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, use /code-review to review the work.

Commit your work to the current branch through the `git_commit` tool — the agent drafts the message and the user approves it in an editable preview. Commits are gated, never auto-posted. See [`../_templates/human-output-gate.md`](../_templates/human-output-gate.md).
