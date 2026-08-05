# META

origin: uncertain (widely-copied AGENT.md template)
earliest-verbatim-public-match: https://gist.github.com/AxDSan/f19edb286db3aa70eb49e3d6b1fc2b7d (2026-02-02)
license: none stated in the circulating block
sync-status: adapted (wrapped as a skill; punctuation refined)

## Provenance

The skill body is the "Workflow Orchestration" block that circulates as a
copy-paste AGENT.md / lessons.md snippet. It is not original to this tree and
has no single identifiable author. The earliest verbatim public copy found is
the AxDSan gist above (2026-02-02); the same block appears, with minor
wording shifts, in several other public repos and gists from the same period.

## Text match

The local body matches the AxDSan gist near-verbatim (same six sections:
Plan Mode Default, Subagent Strategy, Self-Improvement Loop, Verification
Before Done, Demand Elegance, Autonomous Bug Fixing; same Task Management and
Core Principles blocks). Two small local refinements:

- Punctuation: local uses em dashes and curly quotes; the gist uses hyphens
  and straight quotes. The local copy descends from a polished intermediate,
  not the gist directly.
- Section 2 heading: local "Subagent Strategy" with a "Use subagents
  liberally" first bullet; the gist folds that into the heading text.

## Other public copies (same block, wrapped as a skill)

- `ckorhonen/claude-skills` `skills/agent-engineering/SKILL.md`
- `vxcozy/workflow-orchestration` `SKILL.md`
- `clasen/Skills` `AGENT.md`
- CodeLeom gist "Best practices and workflows to use with an AI agent"

None is clearly the OG; all look like copies of the same circulating template.

## Ruled out

- `addyosmani/agent-skills` (MIT, 2026-02-15, 81k stars) - a different 24-skill
  pack (spec-driven-development, test-driven-development, ...). It only shares
  the phrase "would a staff engineer approve this?" (its code-reviewer persona).
  Not the source of this skill.
- `haowjy/orchestrate` (MIT) - a multi-model `run-agent.sh` supervisor skill.
  Different content entirely despite the matching name. Not the source.

## Conclusion

Treat the body as a public template with no attribution owed. The SKILL.md
wrapper (name `orchestrate`, the description line) is the only locally-added
framing.
