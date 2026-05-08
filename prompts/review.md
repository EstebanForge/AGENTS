---
description: Review code changes for correctness, regressions, security, and requirement fit
argument-hint: "<focus-files-or-area>"
---
Review code changes for correctness, regressions, security, and requirement fit.

Focus: $1
<!-- If focus is vague or missing, read `git diff` / staged changes to discover modified files. -->

Context / original requirement:
<!-- FILL IN: what is this change supposed to accomplish? -->
-

For each issue found, provide:
- Concrete file and line reference
- Why it's a problem
- Suggested fix (if straightforward)

Checklist:
- Logic gaps and edge cases
- Security issues (XSS, CSRF, injection, privilege escalation, unescaped output)
- Silent failures / swallowed errors / missing error returns
- Backwards compatibility breaks (renames, signature changes, removed filters)
- Inconsistent return values or types
- Unreachable code or dead paths
- Test coverage for the changed paths (are tests missing or now invalid?)
- Performance implications (N+1 queries, large in-memory structures, unnecessary loops)
