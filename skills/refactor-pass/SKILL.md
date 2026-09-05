---
name: refactor-pass
description: Simplify code and eliminate dead code after recent changes. Use when requesting a focused refactoring pass, code cleanup, or simplification verified by tests.
---

# Refactor Pass

## Workflow

1. Review the changes just made and identify simplification opportunities.
2. Apply refactors to:
   - Remove dead code and dead paths.
   - Straighten logic flows.
   - Remove excessive parameters.
   - Remove premature optimization.
3. Run build/tests to verify behavior.
4. Identify optional abstractions or reusable patterns; only suggest them if they clearly improve clarity and keep suggestions brief.
