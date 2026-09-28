---
description: Explore the project and create or update AGENTS.md
argument-hint: "[extra instructions]"
---
You are running the /init routine for this project.

Goal: explore the project, then create or update `AGENTS.md` in the project root. The file is an operating guide for any coding agent working here later: it must let a fresh agent become productive fast, without reading the whole codebase.

## Phase 1 - Explore

Use file reads and targeted searches (read/grep/ls; shell only when needed). Work efficiently; avoid dumping huge files into context.

1. **Identify the stack.** Start at the root: README*, package manifests (package.json, pyproject.toml, go.mod, Cargo.toml, pom.xml, build.gradle*, Makefile, CMakeLists.txt, *.csproj, ...), lockfiles (they reveal the package manager), and CI configs (.github/workflows/, .gitlab-ci.yml, Jenkinsfile, ...).
2. **Find the real commands.** Install, build, dev-run, test (full and single), typecheck, lint, format. Copy them verbatim from scripts, taskfiles, or CI steps. Never invent a command; if one is missing, say so.
3. **Map the architecture.** Focus on what no single file reveals: entry points, main directories and what each owns, how major pieces communicate (HTTP, queues, events), monorepo/workspace layout, codegen steps, and generated or vendored code that must not be hand-edited.
4. **Extract conventions.** Formatter/linter configs, testing framework and where tests live, naming and import conventions, error-handling patterns.
5. **Read the git history and contribution docs.** Summarize commit message style from `git log` (format, scope, tense). Note PR requirements if CONTRIBUTING.md, PR templates, or branch conventions exist.
6. **Harvest existing guidance.** Read every agent doc present: `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `.cursorrules`, `.cursor/rules/`, `.windsurfrules`, `CONTRIBUTING.md`. Many repos have only `CLAUDE.md`; its content is usually the most valuable input. Fold still-valid content into the new file. Never modify or delete those originals.

## Phase 2 - Write AGENTS.md

Keep only sections that add value for this project; omit the rest. Give concrete examples where helpful (commands, paths, naming patterns).

- **Project overview**: what this is, 1-3 sentences.
- **Setup**: prerequisites and install/bootstrap commands.
- **Commands**: build, dev-run, test (all + single), typecheck, lint, format. Copy-paste runnable.
- **Architecture**: directory map with one-line responsibilities, key data flow, important boundaries, workspace/monorepo layout, warnings for generated code.
- **Conventions & gotchas**: style and naming rules from formatter/linter configs, testing framework and test location, error-handling patterns, and anything an agent would otherwise learn the hard way: codegen or migration steps required after certain edits, version pins, platform quirks.
- **Commit & PR guidelines**: commit message style observed in history; PR requirements (descriptions, linked issues, review expectations) if documented.

Rules:

- If `AGENTS.md` exists, treat it as the base: preserve still-accurate content, refresh stale parts, remove only what is clearly wrong. When in doubt, keep existing material.
- If it does not exist but other agent docs do, use the richest as the base and rephrase tool-specific wording ("Claude should..." becomes neutral phrasing that addresses any agent).
- Aim for ~120 lines or fewer. Terse bullets beat prose.
- Include only commands verified in the repo. State uncertainty instead of guessing.
- No secrets, tokens, or personal absolute paths.
- If the additional user instructions below are in a language other than English, write AGENTS.md in that language; otherwise write it in English.

## Additional user instructions

Weigh these against the guidance above; reconcile differences sensibly rather than following blindly. If "(none)", ignore this section.

${@:-(none)}
