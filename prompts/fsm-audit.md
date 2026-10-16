---
description: Audit a module for hidden state machines and propose an explicit FSM refactor
argument-hint: "<module-or-files>"
---
Audit $1 for implicit state machines. Analysis only — do not modify code. If $1 is empty or vague, ask.

Smells to look for:
- 3+ lifecycle states encoded as booleans, nullable fields, or status strings (2+ booleans on one lifecycle already counts)
- Status fields written directly from multiple places, no central transition
- Repeated status guard clauses across handlers and jobs
- Timestamp columns acting as state (cancelled_at, paid_at)
- Verdict strings or enums that decide the next step of a process
- Counters, attempt limits, or date checks acting as transition guards
- Cron or queue workers scanning for status values
- Side effects (mail, jobs, DB writes) interleaved with state changes
- Wait/resume flows held open by blocking calls or polling
- "Should never happen" else/default branches

Method:
1. Cite file:line for every state write, state read, and guard.
2. Trace every writer of each state field repo-wide, not only inside $1.

For each finding, pick one verdict:
- `refactor`: worth it. Name the states and events, show the transition matrix as a markdown table (rows = states, columns = events), map current stored values to enum cases, and propose the refactor and tests per the fsm-design skill protocol.
- `machine, not worth it`: a machine exists but a skip-list reason applies. Cite the reason.
- `not a machine`.

Lead with the bugs: mark every illegal pair the current code permits today.

If nothing crosses the finding threshold (2+ states and 1+ transition, each cited), report: "No hidden machine. Checked: <smells> in <files>." Do not invent states to justify a refactor.
