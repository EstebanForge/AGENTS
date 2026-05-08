---
description: Fix failing tests after application code changed (do not modify app code)
argument-hint: "<component>"
---
Code on $1 changed. Application code is assumed correct; we need to fix only the tests.

Failing test output:
<!-- PASTE OUTPUT HERE, or delete this block and I will run the tests myself -->

```

```

Files changed (application code):
<!-- LIST FILES, or delete this line and I will detect them from git -->
-

Workflow:
1. If no test output is pasted above, run the test suite and capture failures.
2. Read the failing test file(s) and the related application code.
3. Identify why the test fails (assertion mismatch, mock expectation, signature change, etc.).
4. Fix the test ONLY. Do NOT modify application source files.
5. Run tests again to confirm all pass.

Guardrail: If the test failure reveals an actual bug in the application code (not just a stale test), STOP and report the bug. Do not paper over it by patching the test.
