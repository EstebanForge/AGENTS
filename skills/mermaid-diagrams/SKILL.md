---
name: mermaid-diagrams
description: Validate and fix Mermaid diagrams by rendering them with the official mermaid-cli (mmdc). Use when the user asks to validate/check/fix/lint Mermaid, reports a diagram is broken/not rendering, edits .mmd files or ```mermaid fenced blocks, or wants CI-style diagram checks. mmdc has no lint mode; a render that exits 0 is the only correctness signal.
---

# Mermaid Diagrams

Keep Mermaid diagrams **render-clean**: every diagram renders without a parse error. There is no Mermaid linter. The official tool, `@mermaid-js/mermaid-cli` (binary `mmdc`), is a renderer, and **to validate a diagram is to render it.** A render that exits 0 is your only correctness signal; a non-zero exit plus a parse error is the bug.

Two modes (validate, fix) share one loop: render → read the verdict → fix → re-render, one diagram at a time, until render-clean.

## Setup — the container gotcha

`mmdc` drives headless Chromium. In containers and CI it crashes on launch with `Failed to launch the browser process ... Operation not permitted` (PID namespace sandbox). This is mmdc's documented "Linux sandbox issue." A launch failure is a **tool** problem, not a diagram problem — do not touch any diagram until one known-good diagram renders.

Fix: launch Chromium with `--no-sandbox` via a puppeteer config:

```json
{ "args": ["--no-sandbox", "--disable-setuid-sandbox", "--disable-dev-shm-usage"] }
```

`mmdc -i diag.mmd -o /tmp/out.svg -p puppeteer-config.json`. The helper script creates and applies this config automatically. `--no-sandbox` is a deliberate tradeoff for agent/CI contexts; on a trusted dev box you may drop it.

Completion criterion — mmdc runs:
- [ ] `command -v mmdc` succeeds (else `npm i -g @mermaid-js/mermaid-cli`, or one-off `npx -p @mermaid-js/mermaid-cli mmdc ...`).
- [ ] A trivial `graph TD / A-->B` renders to SVG. If this fails, you have a setup or sandbox problem — fix it before anything else.

## Phase 1 — Inventory

Find every diagram the change touches. Two forms:
- Standalone `*.mmd` files (`fd -e mmd`).
- ```` ```mermaid ```` fenced blocks inside `*.md` / `*.mdoc` (`rg -l '^```mermaid'`).

Scope to what the user asked about (a file, a dir, the diff). Do not validate the whole repo unless asked. The helper script takes paths and does both.

Completion criterion — every diagram accounted for:
- [ ] A list mapping each diagram to its source file and (for fenced blocks) its line range. You need this to edit in Phase 4.

## Phase 2 — Render-verify

Run mmdc once per diagram, capture exit code + stderr. The helper script does this in batch and prints one verdict line per diagram. Read each:

- Exit 0 + SVG written → **render-clean**. Done with that one.
- Non-zero → **render-broken**. stderr holds the parse error: `Parse error on line N`, a `^` column marker, and the list of expected tokens. That is your diagnosis.

Completion criterion — a verdict for every diagram:
- [ ] Each diagram marked render-clean or render-broken, with the parse error (if any) captured.

## Phase 3 — Diagnose

The parse error names a **line and column inside the block**, plus expected tokens. Two traps:

1. **Offset.** For a fenced block, "line N" is relative to the block's first content line, not the markdown file. Add the fence's source line to map back. The helper script reports the mapped source line already; if running mmdc by hand, compute it.
2. **Render-clean ≠ correct.** Mermaid silently renders some malformed-but-parseable input — a node referenced but never shaped, a dangling edge, a label that swallowed a bracket. A clean render proves the diagram parses, not that it says what the author meant. If the user reports "it renders but looks wrong," read the diagram against the intended structure, not just mmdc's verdict.

Map the expected-tokens list to the actual token at the column. The fix is almost always a syntax token where the parser wanted one of the expected set.

Completion criterion — a located, named cause per render-broken diagram:
- [ ] For each failure: source file + line + the offending token + which expected token it should have been.

## Phase 4 — Fix

Surgical edits only, one diagram at a time. After each edit, **re-render that diagram** — a tight red/green on the render is the whole skill. Do not batch-edit then test once.

Common fixes, most common first:
- **Edge/arrow syntax.** `-->`, `-.->`, `===>`, `-- text -->` each have one exact form. A stray `-` or space breaks the line.
- **Labels with special chars** (`(`, `)`, `,`, `:`, `"`) must be quoted: `A["foo (bar)"]`.
- **Node shapes are positional brackets** — `[box]`, `(round)`, `{diamond}`, `((circle))`, `[(cylinder)]`. Mismatched or nested brackets fail.
- **`subgraph` needs a name and a matching `end`.** A stray or missing `end` is a frequent cause.
- **Keywords/direction.** `graph` vs `flowchart`, `direction` inside a subgraph, stray chars on trailing blank lines.

Completion criterion — render-clean and minimal:
- [ ] The edited diagram re-renders to exit 0.
- [ ] The edit changes only what was broken — no restyling, reflow, or "while I'm here" rewrites.
- [ ] Re-run Phase 2 on the whole inventory: no diagram regressed.

## Phase 5 — Confirm + clean up

- [ ] Every diagram in scope is render-clean (re-run the batch verdict).
- [ ] No throwaway artifacts committed: extracted `.mmd`, output `.svg`, and the puppeteer config live under `/tmp`, never in the repo. `git status` is clean of them.
- [ ] If you changed a diagram, the commit message states what was broken and the token fix.

## Failure modes

- **Treating a launch failure as a broken diagram.** `Operation not permitted` is the sandbox, not your syntax. Render a known-good diagram first.
- **Editing the wrong line.** Parse-error line numbers are block-relative for fenced blocks. Always map to the source line before editing.
- **Trusting render-clean too much.** A clean render proves the diagram parses, not that it is correct. Read it when the complaint is "looks wrong."
- **Batch-editing.** Editing several diagrams then rendering once hides which edit fixed or broke what. One diagram, one render.
- **Committing artifacts.** SVGs and temp configs are trash in a docs repo. Keep them in `/tmp`.

## Helper script

`scripts/mmdc-verify.sh [paths...]` — inventories diagrams under the given paths (default: cwd), extracts fenced blocks to a temp dir while tracking source line offsets, renders each with a no-sandbox puppeteer config, and prints one verdict line per diagram:

```
PASS  docs/diagram.md
FAIL  docs/diagram.md:42  Parse error on line 4: ... got 'NEWLINE'
```

Exit codes: `0` all render-clean, `1` at least one render-broken, `2` setup/sandbox failure (mmdc could not render a known-good diagram), `127` mmdc not installed. It preflights with a trivial render so a sandbox crash fails fast and unambiguously rather than masquerading as broken diagrams. All temp files live under `/tmp`; nothing is written to the repo.
