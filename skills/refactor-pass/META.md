# META

source: https://github.com/stympy/skills/blob/main/refactor-pass/SKILL.md
upstream-repo: stympy/skills
upstream-author: stympy (Ryan Bates)
license: none (no LICENSE file upstream; default is all rights reserved)
repo-created: 2026-02-21
last-synced: 2026-11-24
upstream-commit: f9c0ea9 (2026-02-23)
sync-status: near-verbatim (valid frontmatter kept; see 2026-11-24 check)

## Provenance

Vendored verbatim from `stympy/skills` (`refactor-pass/SKILL.md`). The
frontmatter and body match byte-for-byte (same title, same four-step
workflow, same bullet list including "Remove dead code and dead paths",
"Straighten logic flows", "Remove excessive parameters", "Remove premature
optimization").

## Ruled out

- `garriguv` gist "Refactor Pass Skill" (2026-03-13,
  https://gist.github.com/garriguv/8965e11bc65da172403137a6871ecf14) - a later
  variant that adds an "## Overview" section the local copy does not have. A
  fork, not the source.

## License note

The upstream `stympy/skills` repo carries no LICENSE file, so it defaults to
all rights reserved. Kept here as a personal copy; do not re-publish it under
MIT or any other license without upstream permission.

## sync-status

Near-verbatim. Re-pull from the link above if refreshing.

## 2026-11-24 check (upstream f9c0ea9)

Upstream's only edit since the vendoring commit broke the frontmatter: name
and description collapsed onto one line, which no compliant loader parses.
Adopted the new description text as a proper second frontmatter line.
Deliberately kept local: the "Actively apply the DRY, KISS, and YAGNI
principles." line (upstream removed it; house technical standards keep it)
and the valid two-line frontmatter. Re-check upstream's frontmatter before
any future verbatim re-pull.
