# META

source: https://github.com/backnotprop/bro/blob/main/skills/facts/SKILL.md
upstream-repo: backnotprop/bro
upstream-author: backnotprop
license: none (upstream has no LICENSE file)
repo-created: 2026-04-22
last-synced: 2026-11-24
upstream-commit: 08f40b4 (2026-11-23)
sync-status: custom (anti-jargon rules and forbidden words enforcement)

## Provenance

Copied directly from `backnotprop/bro` (`skills/facts/SKILL.md`). That repo
ships two small skills, `bro` and `facts`; this is the `facts` one.

Note: the sibling `bro` skill has a different origin (a prompt from a social
media screenshot that many people copied). `facts` itself was taken from the
`backnotprop/bro` repo.

## What changed locally

The local copy wraps the trailing guidance paragraph in
`<meta-rule>...</meta-rule>` tags. Upstream presents it as plain text.
Otherwise verbatim.

## License note

The upstream repo carries no LICENSE file, so it defaults to all rights
reserved. Kept in this tree as a personal copy; do not re-publish it under
MIT or any other license here without upstream permission.

## sync-status

Near-verbatim. Re-pull from the link above; preserve the local `<meta-rule>`
tags on merge.

## 2026-11-24 check (upstream 08f40b4)

Upstream tightened the body prompt and added an explicit-invocation-only
description guard ("never otherwise; do not invoke automatically"). Both
adopted verbatim; `<meta-rule>` wrap preserved.
