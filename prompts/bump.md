---
description: Bump version (major|minor|patch) and add changelog entry
argument-hint: "<version-type> <project>"
---
Bump the $1 version by one for $2.

1. Detect the last tag: `git describe --tags --abbrev=0`
2. List changes since that tag: `git log <last-tag>..HEAD --oneline --no-merges`
3. Read the existing CHANGELOG.md to match its format and heading style.
4. Draft a new changelog entry for the inferred version.

Version files in this project (auto-detect; list any known ones):
<!-- FILL IN OR DELETE — I will scan for composer.json, package.json, plugin headers, etc. -->
-

Semver sanity check:
- Patch = bug fixes, docs, internal refactors
- Minor = new features, non-breaking additions
- Major = breaking changes, removed APIs, renamed namespaces
If the requested bump level conflicts with the actual changes, flag it.

Focus description of changes (optional context):
<!-- FILL IN OR DELETE -->
-
