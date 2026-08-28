# review-my-go

A skill that reviews Go changes (working tree, staged, commit, or range) against the 100 Go Mistakes checklist from [100go.co](https://100go.co/). Findings cite mistake numbers, carry a category (Bug/Critical, Suggestion, Nit), and end in an Approve / Request Changes / Needs Discussion verdict.

Successor of the `@estebanforge/pi-go-review` pi extension (deprecated 2026).

## Install

```bash
ln -s "$(pwd)" ~/.agents/skills/review-my-go
```

Or copy the folder into any agent skills directory.

## Usage

Ask your agent: "Review my Go." Point at a commit or range for narrower scope: "Review my Go, commit abc123."
