# review-my-javascript

A skill that reviews JavaScript changes (working tree, staged, commit, or range) against a JS flaws rubric. It targets the semantic and security flaws Biome / ESLint do not catch: async races, prototype pollution, injection, ReDoS, event-loop blocking. Findings cite entry numbers and end in an Approve / Request Changes / Needs Discussion verdict.

Successor of the `@estebanforge/pi-js-review` pi extension (deprecated 2026).

## Install

```bash
ln -s "$(pwd)" ~/.agents/skills/review-my-javascript
```

Or copy the folder into any agent skills directory.

## Usage

Ask your agent: "Review my JavaScript." Point at a commit or range for narrower scope: "Review my JavaScript, src/api."
