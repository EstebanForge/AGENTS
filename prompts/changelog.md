---
description: Generate changelog entry from git commit range
argument-hint: "<from-ref> [to-ref]"
---
Generate a changelog entry for changes from commit $1 to ${2:-HEAD}.

1. Read the existing CHANGELOG.md (or equivalent) to match its heading style and category labels.
2. Run: `git log $1..${2:-HEAD} --oneline --no-merges` to list commits.
3. Categorize meaningful changes as:
   - **Added** — new features, endpoints, UI elements
   - **Changed** — behavior changes, dependency bumps, refactors
   - **Fixed** — bug fixes
   - **Removed** — dropped features, deprecated APIs
   - **Security** — vulnerability fixes
4. Infer the new version from change magnitude (semver). If unclear, ask before drafting.

Exclude:
- Formatting-only commits
- Internal test refactors with no user impact
- CI/configuration noise
- Merge commits

Highlight:
- Public API changes
- Breaking changes (mark as **BREAKING**)
- User-facing fixes
- Dependency version bumps

Output: A markdown changelog section, ready to paste into CHANGELOG.md.
