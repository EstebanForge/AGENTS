---
name: to-tickets
description: Break a plan, spec, or the current conversation into a set of tracer-bullet GitHub tickets, each declaring its blocking edges.
disable-model-invocation: true
---

# To Tickets

Break a plan into independently-grabbable tickets using vertical slices (tracer bullets).

The issue tracker and triage label vocabulary are defined in [`../_templates/issue-tracker.md`](../_templates/issue-tracker.md) and [`../_templates/triage-labels.md`](../_templates/triage-labels.md).

## Process

### 1. Gather context

Work from whatever is already in the conversation context. If the user passes an issue reference (issue number, URL, or path) as an argument, fetch it from the issue tracker and read its full body and comments.

### 2. Explore the codebase (optional)

If you have not already explored the codebase, do so to understand the current state of the code. Ticket titles and descriptions should use the project's domain glossary vocabulary, and respect ADRs in the area you're touching.

Look for opportunities to prefactor the code to make the implementation easier. "Make the change easy, then make the easy change."

### 3. Draft vertical slices

<vertical-slice-rules>

- Each slice cuts a narrow but COMPLETE path through every layer (schema, API, UI, tests): vertical, NOT a horizontal slice of one layer
- A completed slice is demoable or verifiable on its own
- Any prefactoring should be done first

</vertical-slice-rules>

Give each ticket its **blocking edges**: the other tickets that must complete before it can start. A ticket with no blockers can start immediately.

**Wide refactors are the exception to vertical slicing.** A **wide refactor** is one mechanical change (rename a column, retype a shared symbol) whose **blast radius** fans across the whole codebase, so a single edit breaks thousands of call sites at once and no vertical slice can land green. Don't force it into a tracer bullet; sequence it as **expand–contract**. First expand: add the new form beside the old so nothing breaks. Then migrate the call sites over in batches sized by blast radius (per package, per directory), each batch its own ticket blocked by the expand, keeping CI green batch to batch because the old form still exists. Finally contract: delete the old form once no caller remains, in a ticket blocked by every migrate batch. When even the batches can't stay green alone, keep the sequence but let them share an integration branch that all block a final integrate-and-verify ticket; green is promised only there.

### 4. Quiz the user

Present the proposed breakdown as a numbered list. For each ticket, show:

- **Title**: short descriptive name
- **Blocked by**: which other tickets (if any) must complete first
- **What it delivers**: the end-to-end behaviour this ticket makes work

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- Are the blocking edges correct: does each ticket only depend on tickets that genuinely gate it?
- Should any tickets be merged or split further?

Iterate until the user approves the breakdown.

### 5. Publish the tickets to the issue tracker

For each approved slice, publish a new ticket to the issue tracker (a GitHub issue). **Repo templates win (hard):** if the repo ships issue templates (`.github/ISSUE_TEMPLATE/`), use the one that fits each ticket instead of the template below. Otherwise use the ticket body template. These tickets are considered ready for AFK agents, so publish them with the correct triage label unless instructed otherwise.

**Human-output gate (hard), per ticket.** Before each create, render the full ticket title and body exactly as they will be posted, the body in a fenced block, then STOP. Do not run `gh issue create` until the user approves, amends, or cancels that ticket. Re-render after any amendment and wait again. Silence is a cancel. A blanket approve over several tickets is not valid: the user must see each full body. Full rules in [`../_templates/human-output-gate.md`](../_templates/human-output-gate.md).

Publish tickets in dependency order (blockers first) so you can reference real issue identifiers in the "Blocked by" field.

<ticket-template>
## Parent

A reference to the parent issue on the issue tracker (if the source was an existing issue, otherwise omit this section).

## What to build

A concise description of this vertical slice. Describe the end-to-end behavior, not layer-by-layer implementation.

Avoid specific file paths or code snippets — they go stale fast. Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it here and note briefly that it came from a prototype. Trim to the decision-rich parts — not a working demo, just the important bits.

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Blocked by

- A reference to the blocking ticket (if any)

Or "None - can start immediately" if no blockers.

</ticket-template>

Do NOT close or modify any parent issue.

## Hard rules

- **Gate every ticket before posting (hard).** Never auto-create. Render each ticket's full title and body to the user, then STOP and wait for approve / amend / cancel, one ticket at a time. See [`../_templates/human-output-gate.md`](../_templates/human-output-gate.md).
- **Human word budget (hard).** Match human developer scale (40-90 words per ticket description; hard ceiling 120 words). Keep vertical slice descriptions dense and actionable. Zero prose filler.

## Notes

- Write ticket titles and bodies in Esteban's formal voice (`esteban-voice` skill, FORMAL mode, for tone only: first-person active, no em dashes, concrete specifics, human word budgets). Keep the ticket template structure from step 5.
