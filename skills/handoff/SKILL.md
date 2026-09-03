---
name: handoff
description: Compact the current conversation into a handoff document for another agent to pick up.
argument-hint: "What will the next session be used for?"
disable-model-invocation: true
---

Write a handoff document capturing the current execution state so a fresh agent can continue work. Save it into the current workspace (the directory the agent is running in) by default. If the user asks for a different folder, save there instead.

Structure the handoff as an explicit execution state rather than a narrative prose summary. Free-form text loses exact relational dependencies:

1. **Active Goal**: Precise objective, requirements, and acceptance criteria.
2. **Verified Facts**: Confirmed environment states, paths, behaviors, and constraints.
3. **Rejected Paths**: Hypotheses tested and disproven, failed commands, and rejected designs.
4. **Active Files**: Exact file paths, line ranges modified, and uncommitted changes.
5. **Next Action**: Single concrete command or code change to execute next.
6. **Suggested Skills**: Specific skills the next agent should load.

Do not duplicate content already captured in other artifacts (specs, plans, ADRs, issues, commits, diffs). Reference them by path or URL instead.

Redact sensitive information, such as API keys, passwords, or personally identifiable information.

If the user passed arguments, treat them as the focus for the next session and align the state accordingly.
