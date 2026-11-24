# ORIGIN

This skill merges two upstream sources. Both are MIT-licensed.

sync-status: adapted (two-upstream hand-merge, engine swapped 2026-11-24)
last-synced: 2026-11-24
upstream-commit: danyuchn 65c8ab6 (2026-11-20); woosal1337 3b2c715 (2026-11-23)

## Sources

| File | Source | Author | License |
|---|---|---|---|
| rules, modes, lint gate | https://github.com/woosal1337/blog/tree/main/videos/ep01-the-cure-for-ai-slop | Ege Çelebi | MIT, Copyright (c) 2026 Ege Çelebi |
| `ste-lint.py` engine (2026-11-24 swap) | https://github.com/danyuchn/asd-ste100-skill (`scripts/ste-lint.py` at 65c8ab6) | danyuchn | MIT |
| rule categories, process, "no back-channel reader" framing, before/after examples | https://github.com/danyuchn/asd-ste100-skill | danyuchn | MIT |
| `WRITING-RULES.md`, `EXAMPLES.md` | https://github.com/danyuchn/asd-ste100-skill (`references/`, `examples/`) | danyuchn | MIT |

The MIT notice from Ege Çelebi's blog repo:

> Copyright (c) 2026 Ege Çelebi. Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction ... THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND ... (full text upstream).

## Fork notes

- **Operationalizes an existing project directive.** `AGENTS.md` already tells the agent to communicate in ASD-STE100. This skill is the rule set and the machine checker for that directive.
- **Bakes in the repo em-dash ban.** STE bans only the semicolon. `AGENTS.md` bans em dashes too. The rules table treats both as hard punctuation rules.
- **Single source of truth for word lists.** The full banned-word, marketing-adjective, and phrasal-verb lists live in `ste-lint.py`, not copied into a markdown file. `SKILL.md` lists only the highest-signal examples.

## 2026-11-24 engine swap (upstream 65c8ab6)

Upstream grew `ste-lint.py` from the small shared ancestor into a 3400+-line
rule engine (RULES table, synonym groups, code-fence and filename awareness,
inline selftest). Adopted as the engine; ported the house lists into its RULES
table as new/extended rows, all named "house" in comments: em-dash ban,
banned-verb list, modal-hedge fillers, extended phrasal-verb and
marketing-adjective regexes. Verified: `--selftest` passes; the old coverage
test (leverage/utilize/em-dash/hedge/phrasal) hits every ported rule.
`WRITING-RULES.md` upstream delta is prose reorganization of the same rule
categories, no new rules; kept local (carries the house em-dash content).
Refresh procedure: re-diff upstream scripts/ste-lint.py; re-apply the house
RULES rows if upstream restructures the table.
- **Boundary with `humanizer`.** STE strips voice. Humanizer keeps and adds voice. The description routes marketing, essays, and any voice-bearing text to `humanizer`.
- **Experiment data left upstream.** The blog repo also carries the cross-model experiment (experiment-results.md, run-openai.py, before-after-samples.md). That is episode evidence, not skill material, so it stays at the source link above.

## sync-status

Content adapted and merged from the two upstreams above. Not a verbatim sync of either. Re-merge by hand against the linked commits.
