# META

source: https://github.com/mattpocock/skills/blob/main/prd-to-plan/SKILL.md
upstream-repo: mattpocock/skills
upstream-author: Matt Pocock
license: MIT
repo-created: 2026-02-03
sync-status: near-verbatim

## Provenance

Vendored from Matt Pocock's skills repo ("Skills For Real Engineers", straight
from his `.agents` directory). The frontmatter and body match upstream
verbatim. Matt Pocock's repo is also the source for several other skills in
this tree (e.g. `tdd`, `grill-me`, `grill-with-docs`, `grilling`, `handoff`,
`teach`, `diagnosing-bugs`, `domain-modeling`, `codebase-design`,
`improve-codebase-architecture`).

## What changed locally

The local copy wraps two blocks in XML-style tags that upstream presents as
plain indented content:

- `<vertical-slice-rules>...</vertical-slice-rules>` around the tracer-bullet
  rules list.
- `<plan-template>...</plan-template>` around the Markdown plan template.

No wording changes.

## sync-status

Near-verbatim. Re-pull from the link above; keep the local `<vertical-slice-rules>`
and `<plan-template>` wrapper tags on merge.
