# META

source: https://github.com/ARYANK-08/agentic-dev-kit/blob/main/skills/explain/SKILL.md
upstream-repo: ARYANK-08/agentic-dev-kit
upstream-author: ARYANK-08
license: none (no LICENSE file upstream at sync time)
repo-created: 2026-10-02
last-synced: 2026-10-02
upstream-commit: 0573ad9 (2026-10-02)
sync-status: synced (one local delta: upstream tool references embedded)

## Provenance

Skill-only copy from the upstream `agentic-dev-kit` collection ("Markdown
skills to improve the SDLC with Claude Code"). Vendored into the central
skills repo on first import; reaches agents through the
`~/.agents/skills/<name>` symlink sync.

## What changed locally

The upstream body depends on Claude Code built-ins (the Artifact tool,
`artifact-design`, `artifact-diagramming`) and on HeyGen's
`faceless-explainer` plugin skill. None run on this stack, so the references
are replaced with embedded, standalone equivalents:

- Rich diagrams: inline SVG mechanics (native shapes, viewBox, currentColor,
  marker arrowheads, figure and figcaption), condensed from the archived
  artifact-diagramming skill.
- HTML pages: standalone-file build notes (token theming for light and dark,
  type and layout rules, access basics), condensed from the archived
  artifact-design skill.
- Explainer videos: the ladder rung is restored with a summary of the
  HyperFrames pipeline and a storyboard-plus-script fallback when the CLI or
  the audio account is missing.

Research sources (2026-10-02): archived built-ins at
asgeirtj/system_prompts_leaks (Anthropic/claude-code/skills/artifact-design
and .../artifact-diagramming), cross-checked against
Piebald-AI/claude-code-system-prompts; the faceless-explainer skill at
heygen-com/hyperframes (skills/faceless-explainer/SKILL.md). The built-ins
ship inside the Claude Code CLI; no official public copy exists.

## sync-status

Synced with one local delta: upstream tool references replaced by embedded
standalone equivalents (see What changed locally). On refresh, re-diff
against upstream `skills/explain/SKILL.md`, re-apply the replacement, and
keep both sections accurate if upstream drifts.
