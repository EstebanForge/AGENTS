---
name: fsm-design
description: Design domain logic, multi-step processes, and agent workflows as strict Finite State Machines. Use when a lifecycle has 3+ states, boolean flags multiply, work must resume across restarts or human delays, or repeated agent loops need orchestration.
---

# FSM Design

Explicit state machines make workflows robust to change: every future case is a new transition row, not a new branch.

## When to Use

Structural signals that a machine is hiding in the code:

- 3+ discrete lifecycle states (orders, payments, sync jobs, publishing pipelines).
- 2+ booleans on one lifecycle: the flag combinations are the states, and the illegal combinations are latent bugs. Independent flags are not one machine.
- Nullable fields or columns gating behavior (paid_at, shipped_at): before and after the value exists are different states.
- Verdict strings or enums deciding the next step: the verdict set is the event set. Read again later = state. Consumed once = event.
- Attempt or retry counters checked against a cap: the counter is context, the comparison is a guard.
- Waits that outlive the request or process (human review, days-long pauses): persistable wait states.
- Status written from multiple places with no central transition.

Economic signals that a machine is worth the cost:

- The lifecycle keeps gaining cases; each change should be a new transition, not a branch edit.
- Work must resume after restart, crash, or human delay.
- Multiple entry points mutate the same lifecycle.

Skip when:

- State is genuinely binary.
- A linear sequence with no branches, back-edges, or resume: plain sequential code.
- Status is derivable from existing data: compute it, do not store or machine it.
- A framework or installed library already owns the lifecycle: use it.
- Throwaway or exploratory code with no expected evolution.

These exclusions bound the multi-state rule in AGENTS.md.

## Protocol

1. **Single Writer:** transition() is the only code that mutates state. Direct assignment anywhere else is a defect.
2. **Define Discrete States:** Language-native enums only (JS: frozen constants). 15+ states: group hierarchically before flattening. Declare terminal states.
3. **Define Legal Events:** Event enums, named as past-tense facts (PAYMENT_CAPTURED).
4. **Transition Matrix:** (State, Event, Context) -> (State, Context). Guards: pure predicates over (state, event, context); false = rejected transition. Illegal transition: typed domain error carrying (state, event) — exception where idiomatic, error value where not.
5. **Side Effects Boundary:** Transitions are pure. Persist the new state and queued effects atomically (outbox); effects run after commit. Outbound messages are not FSM events. Clocks, randomness, and external output enter only as event payloads, never computed inside a transition.
6. **Concurrency:** Persisted machines: transition is a compare-and-set on (id, current state or version).
7. **Mandatory Tests:** Exhaustive State x Event product test. The expected table comes from the spec, never imported from production code. Legal pairs assert the next state; every other pair asserts rejection. Guard boundaries: cap-1, cap, cap+1.

## Agent Orchestration

The same protocol structures repeated agent processes:

- States are steps or waits. Each state that calls a model owns exactly one prompt: one prompt = one decision.
- Model output parses into the event enum at the boundary. Unknown event, or not offered from the current state: re-prompt up to N (tracked in context), then FAILED. A valid event illegal in the current state is a code defect: reject per the Protocol.
- Policy lives in transition guards (for example a revision cap), never in prompt prose.
- Human and slow-system waits are idle states: persist the snapshot, resume by event, any time later.
- Context holds raw data only. Replay re-runs recorded events; it never makes fresh model calls.
