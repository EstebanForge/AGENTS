# review-my-typescript

A skill that reviews TypeScript and React changes (working tree, staged, commit, or range) against a TS + React rubric. It targets the semantic gaps typescript-eslint (strict) and eslint-plugin-react-hooks do not catch: effect cleanup, races, derived state, mutation, stale updaters, unsafe casts. Findings cite entry numbers and end in an Approve / Request Changes / Needs Discussion verdict.

Successor of the `@estebanforge/pi-ts-review` pi extension (deprecated 2026).

## Install

```bash
ln -s "$(pwd)" ~/.agents/skills/review-my-typescript
```

Or copy the folder into any agent skills directory.

## Usage

Ask your agent: "Review my TypeScript." Point at a commit or range for narrower scope: "Review my TypeScript, src/components."
