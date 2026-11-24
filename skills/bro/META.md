# META

source: https://github.com/backnotprop/bro/blob/main/skills/bro/SKILL.md
upstream-repo: backnotprop/bro
upstream-author: backnotprop
license: none (upstream repo ships no LICENSE file, no license declared)
repo-created: 2026-07-15 (vendored from backnotprop/bro-skills, since renamed)
last-synced: 2026-11-24
upstream-commit: 08f40b4 (2026-11-23)
sync-status: custom (anti-jargon rules and forbidden words enforcement)

## Provenance

Vendored copy of backnotprop/bro `bro`, imported on 2026-07-15 from
backnotprop/bro-skills. The upstream repo was later renamed; bro-skills
301-redirects to bro. A one-skill prompt: restate the last message in
plain human language, no jargon. `disable-model-invocation: true`, so
it fires only when the human types `/bro`.

## Layout

`SKILL.md` contains the expanded anti-jargon rules, forbidden words list,
and translation guide. `README.md` is repo-local; upstream ships no
README under skills/bro/.

## What changed locally

Expanded `SKILL.md` with explicit anti-jargon rules, the forbidden words list
from `AGENTS.md`, plain everyday word substitutions, em dash ban, and
before/after examples.

## sync-status

Custom. Modified locally from upstream to enforce anti-jargon and plain-human
communication rules.

## 2026-11-24 check (upstream 08f40b4)

Upstream is still the 7-line minimal prompt (reworded since ae59583). The
local 57-line expansion strictly supersedes it; nothing to adopt. Re-check
only if upstream grows real rules.
