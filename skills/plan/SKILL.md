---
name: plan
description: Review technical plans and execution strategies. Use when evaluating architecture tradeoffs, test plans, or implementation roadmaps before writing code.
---

# Plan Mode Review

Review this plan thoroughly before making any code changes. For every issue or recommendation, explain the concrete tradeoffs, give an opinionated recommendation, and ask for my input before assuming a direction.

My engineering preferences (use these to guide your recommendations):

- DRY is important—flag repetition aggressively.
- Well-tested code is non-negotiable; I'd rather have too many tests than too few.
- I want code that's "engineered enough" — not under-engineered (fragile, hacky) and not over-engineered (premature abstraction, unnecessary complexity).
- I err on the side of handling more edge cases, not fewer; thoughtfulness > speed.
- Bias toward explicit over clever.

## 1. Architecture Review

Evaluate:

- Overall system design and component boundaries.
- Dependency graph and coupling concerns.
- Data flow patterns and potential bottlenecks.
- Scaling characteristics and single points of failure.
- Security architecture (auth, data access, API boundaries).

## 2. Code Quality Review

Evaluate:

- Code organization and module structure.
- DRY violations—be aggressive here.
- Error handling patterns and missing edge cases (call these out explicitly).
- Technical debt hotspots.
- Areas that are over-engineered or under-engineered relative to my preferences.

## 3. Test Review

Evaluate:

- Test coverage gaps (unit, integration, e2e).
- Test quality and assertion strength.
- Missing edge case coverage—be thorough.
- Untested failure modes and error paths.

## 4. Performance Review

Evaluate:

- N+1 queries and database access patterns.
- Memory-usage concerns.
- Caching opportunities.
- Slow or high-complexity code paths.

## For Each Issue You Find

For every specific issue (bug, smell, design concern, or risk):

- Describe the problem concretely, with file and line references.
- Present 2–3 options, including "do nothing" where that's reasonable.
- For each option, specify: implementation effort, risk, impact on other code, and maintenance burden.
- Give me your recommended option and why, mapped to my preferences above.
- Then explicitly ask whether I agree or want to choose a different direction before proceeding.

## Workflow and Interaction

- Do not assume my priorities on timeline or scale.
- After each section, pause and ask for my feedback before moving on.

## Process Reward Verification Gate (Plan-to-Execute Barrier)

Before transitioning from Plan to Execute in `workflow_protocol`, the plan MUST pass this deterministic 4-part Process Reward Model (PRM) verification gate. No code edits are permitted until all four criteria are verified:

1. **Reproduction (Fail-First):** Provide a concrete runnable command (test runner, curl, or CLI invocation) that reproduces the failure or proves the absence of the requested feature before modifying production code.
2. **Blast Radius (CodeGraph Mapping):** List all direct and transitive callers, callees, and consumers affected by the planned change with concrete `file:line` references.
3. **State Boundaries & Invariants:** Define explicit FSM states, event enums, and transition guards (per `fsm-design`), or exact input/output preconditions and postconditions. Reject boolean flag soup.
4. **Rollback & Halt Condition:** Specify a concrete revert command (`git checkout -- <files>`) and an execution loop budget (maximum 3 correction iterations before halting to report).

For architectural changes or critical refactors, execute an adversarial peer check via `prompts/peer-review.md` (Diagnosis challenge frame) before executing code edits.

---

BEFORE YOU START:

Ask if I want one of two options:

1/ BIG CHANGE: Work through this interactively, one section at a time (Architecture → Code Quality → Tests → Performance) with at most 4 top issues in each section.

2/ SMALL CHANGE: Work through interactively ONE question per review section.

FOR EACH STAGE OF REVIEW: output the explanation and pros and cons of each stage's questions AND your opinionated recommendation and why, and then use AskUserQuestion. Also NUMBER issues and then give LETTERS for options and when using AskUserQuestion make sure each option clearly labels the issue NUMBER and option LETTER so the user doesn't get confused. Make the recommended option always the 1st option.
