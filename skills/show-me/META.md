# ORIGIN

source: https://github.com/humanlayer/skills/blob/main/plugins/show-me/skills/show-me/SKILL.md
upstream-repo: humanlayer/skills
upstream-publisher: Humanlayer
license: MIT
homepage: https://github.com/humanlayer/skills
sync-status: synced (verbatim upstream, em-dash replaced with parentheses)
last-synced: 2026-11-24
upstream-commit: bba9d13 (2026-09-12)

## Provenance

Port of Humanlayer's `show-me` skill. Provides visual explanations during conversations using the smallest clear representation: pseudocode, call trees, component hierarchies, file trees, Mermaid diagrams, visual diffs, or standalone HTML artifacts.

## What changed locally

- Replaced em-dash in HTML artifact bullet with parentheses per repository style rules.

## 2026-11-24 check (upstream bba9d13)

Upstream added `disable-model-invocation: true` (user-invoked only).
Deliberately not adopted: the local description carries trigger branches and
the skill is useful autonomously. The em-dash regression in the HTML bullet
is likewise not adopted. No other upstream changes.

## Requirements

- Browser opener (e.g. `agent-browser` or system `open`) when viewing standalone HTML artifacts.
