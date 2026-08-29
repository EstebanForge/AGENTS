# Skill mechanics

The skill-specific branch of [`writing-for-agents`](SKILL.md): what changes when the document is a skill — frontmatter, the invocation choice, router skills, and the pattern notes beside the file. Everything else about writing it is the universal reference in `SKILL.md`.

## Invocation

Two choices, trading the two loads:

- A **model-invoked** skill keeps a `description`, so the agent can fire it autonomously — and other skills can reach it. You can still type its name: model-invocation always _includes_ user reach; a description only ever adds agent discovery, never removes the human's. The description is the skill's top-level context pointer, forced to stay loaded at all times — permanent context load in exchange for discoverability. A model-invoked skill whose content is all reference is also one home for shared reference: another skill can invoke it, so reference needed by several skills lives in one place. Mechanics: omit `disable-model-invocation`, and write a model-facing description carrying the trigger branches (the pointer-writing rules in `SKILL.md` apply in full).
- A **user-invoked** skill strips the description from the agent's reach: only the human typing its name can invoke it, and no other skill can. Zero context load, but it spends cognitive load — you are the index that must remember it exists. Mechanics: set `disable-model-invocation: true`; the `description` becomes human-facing — a one-line summary, trigger lists stripped.

Pick model-invocation only when the agent must reach the skill on its own, or another skill must. If it only ever fires by hand, make it user-invoked and pay no context load.

Shared reference that two user-invoked skills both need can live in neither — with no descriptions, neither can fire the other. Push it to a plain file outside the skill system: external reference any skill can point at.

## Splitting by invocation

The invocation cut of splitting (the sequence cut lives in `SKILL.md`): split off a model-invoked skill when you have a distinct leading word that should trigger it on its own — a trigger word you actually use in your prompts — or another skill must reach it. You pay context load for the new always-loaded description, so that independent reach has to be worth it.

## Router skills

When user-invoked skills multiply past what you can remember, that piled-up cognitive load is cured by a **router skill**: one user-invoked skill that names the others and when to reach for each, so the human has one skill to remember instead of many. It can only hint, never fire them: user-invoked skills have no description, so nothing but the human can reach them.

## Pattern notes

A skill serves two audiences, and they read different files. The **executor** loads `SKILL.md` at runtime; the **editor** maintains it across sessions. The executor needs procedure — steps, rules, completion criteria. The editor needs history — what failed, what worked, what was already tried and turned down. Mixing the two bloats the runtime path and scatters the history.

Keep the history in `patterns.md`, a sibling of `SKILL.md`, one entry per pattern — a recurring failure mode or winning strategy:

```
## <pattern name>

Observed: <what happened, on what task, when>
Rule: <the workaround or strategy, one line>
Executor: <all | <executor name>>
Status: active | rejected (<why, date>) | promoted (<SKILL.md section, date>)
```

The file is editor-only disclosed reference: the executor never loads it at runtime, so it costs zero context load. Two triggers keep the loop closed: the editor reads `patterns.md` before touching `SKILL.md`, and writes an entry after any run where the skill misled the executor — same session, while the evidence is fresh.

The `rejected` entries are the point: "tried X, rejected because Y" stops a future editor from re-proposing it. Prune `active` entries that stop firing, and retire a `rejected` entry when the tool or environment it describes is gone; every other `rejected` entry stays — it is the cheapest insurance in the file. A promoted entry becomes a tombstone (`Status: promoted`) pointing at its new home, so `SKILL.md` stays the single source of truth for procedure while the evidence trail survives.

Two boundary rules:

- **Executor-agnostic procedure.** A rule in `SKILL.md` states the universal procedure. A step that exists only because one executor mishandles it goes in `patterns.md`, labeled with the executor — never inlined into the procedure, where it constrains every other executor. A weak executor's crutch can break a strong one.
- **Promote on stability.** A pattern reached on nearly every edit is procedure trying to escape: move the rule into `SKILL.md` and mark the entry `promoted`. Evidence still gathering stays put.
