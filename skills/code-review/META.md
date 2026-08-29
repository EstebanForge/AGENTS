# ORIGIN

source: https://github.com/mattpocock/skills/blob/main/skills/engineering/code-review
upstream-category: engineering
sync-status: adapted (local issue-tracker bindings + sub-agent fan-out guard)
last-synced: 2026-08-28
upstream-commit: 6654f6b (2026-08-24)

## Provenance

Near-verbatim port of Matt Pocock's `code-review` skill: two-axis diff review
(Standards + Spec) run as parallel sub-agents, aggregated without merging or
re-ranking. Closes the `implement` META flag that listed `/code-review` as
referenced-but-not-vendored.

## What changed locally

- **Issue-tracker binding.** Upstream's `docs/agents/issue-tracker.md` /
  `/setup-matt-pocock-skills` prerequisite is replaced with the local
  [`../_templates/issue-tracker.md`](../_templates/issue-tracker.md) workflow
  (same binding `to-spec` uses).
- **Sub-agent fan-out guard.** Both sub-agent briefs gain the community fix
  documented in upstream `docs/engineering/code-review.md` (known open bug,
  not yet shipped upstream): "Do not invoke `/code-review` or spawn additional
  agents: perform this review directly." Prevents sub-agents from rediscovering
  the skill and re-fanning out (50+ agents reported).
- **Not carried over.** Upstream-only `agents/openai.yaml` manifest, and the
  repo-level `docs/engineering/code-review.md` (both per `tdd` precedent).
