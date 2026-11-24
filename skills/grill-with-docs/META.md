# ORIGIN

source: https://github.com/mattpocock/skills/blob/main/skills/engineering/grill-with-docs
upstream-category: engineering
sync-status: adapted (delegation phrasing kept local)
last-synced: 2026-11-24
upstream-commit: abeeaf9 (2026-11-19)

## Fork notes

Content-identical to upstream (excludes upstream-only `agents/` manifest),
except the delegation line.

## 2026-11-24 check (upstream abeeaf9)

Upstream's only delta flips the delegation line to Claude Code Skill-tool
phrasing ("Call the Skill tool twice, for 'grilling' and 'domain-modeling'").
Deliberately not adopted: this stack has no Skill tool, so the local line
keeps /-invocation wording. Future refreshes: re-diff and look for content
changes beyond that line.

## v1.2.0 merge (2026-08-05)

No SKILL.md change: grill-with-docs delegates to `/grilling` (+
`/domain-modeling`), which is where the #593 round-by-round frontier change
landed. The grill-with-docs body is unchanged.
