---
description: Synthesize a recurring workflow, bug pattern, or lesson into a reusable agent skill
argument-hint: "<skill-name> [pattern or lesson description]"
---
Synthesize a reusable skill from recurring observations, lessons, or task workflows.

Input:
$@

Procedure:
1. **Deduplication Check:** Search existing skills in `skills/` using `codegraph` or directory scan. If an existing skill covers this domain, update its procedure or add an entry to its `patterns.md` instead of creating a duplicate.
2. **Determine Invocation Type:**
   - Model-invoked: Requires an action-verb leading `description` with explicit triggers and branches. Pick this when agents should autonomously discover and load the skill.
   - User-invoked: Set `disable-model-invocation: true`. Pick this when the skill runs only upon explicit user invocation to avoid context load.
3. **Scaffold Skill Files:**
   - Run `scripts/skill-synthesize.sh new <skill-name>` (add `--user-invoked` if user-only).
4. **Draft SKILL.md:**
   - Follow `writing-for-agents` and `SKILL-MECHANICS` standards.
   - Frontmatter: `name` matching folder, single-line description with leading verb.
   - Prose rule: 1 paragraph = 1 line. No column wrapping.
   - Sections: Context/Triggers, Protocol (discrete numbered steps), Edge Cases, Completion Criteria (checkboxes with verifiable commands).
   - Keep universal procedure in `SKILL.md`. Model-specific quirks or failure traces go into `patterns.md`.
5. **Draft patterns.md:**
   - Record observed failure modes, rule, target executor, and status (`active`).
6. **Validate & Link:**
   - Run `scripts/skill-synthesize.sh validate <skill-name>`.
   - Run `./manage.sh link` to project the new skill to all configured agent harnesses.
