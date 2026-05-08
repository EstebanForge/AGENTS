---
description: Analyze a bug report — root cause, affected paths, fix approach
argument-hint: "<component-or-bug-id>"
---
Analyze a bug report for $1. Independent analysis only — do not modify code.

Bug description:
<!-- FILL IN: what is the symptom? -->
-

Observed in:
<!-- FILL IN: environment, version, browser, etc. -->
-

Logs / evidence:
<!-- PASTE LOGS, STACK TRACES, OR SCREENSHOTS; delete block if none -->
```

```

Expected behavior:
<!-- FILL IN -->
-

Actual behavior:
<!-- FILL IN -->
-

Analysis steps:
1. If the codebase is available and the bug is reproducible, trace the execution path to identify the faulty code.
2. Identify the root cause (not just the symptom).
3. List all affected code paths and functions.
4. Assess regression likelihood (is this a recent change or long-standing?).
5. Propose a minimal fix with concrete file and line references.

If critical information is missing above, ask for it before proceeding.
