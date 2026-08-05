# mermaid-diagram-fixer

A skill that validates and fixes Mermaid diagrams by rendering them with the official `@mermaid-js/mermaid-cli` (`mmdc`). Use it when a diagram is broken or not rendering, when you edit `.mmd` files or ```` ```mermaid ```` fenced blocks, or for CI-style render checks. `mmdc` has no lint mode, so a render that exits 0 is the only correctness signal. This skill runs a tight render, diagnose, fix, re-render loop until every diagram in scope is render-clean.

## Installation

### Manual install (the skill plus helper)

```bash
mkdir -p ~/.claude/skills/mermaid-diagram-fixer
cp SKILL.md ~/.claude/skills/mermaid-diagram-fixer/
cp -r scripts ~/.claude/skills/mermaid-diagram-fixer/
```

Requires `mmdc` on PATH: `npm i -g @mermaid-js/mermaid-cli`.

## Usage

The skill activates when the task matches: validating or fixing Mermaid, editing `.mmd` or fenced blocks, a diagram that will not render. Or invoke it directly:

```
/mermaid-diagram-fixer
```

```
Validate the mermaid diagrams in docs/ and fix the broken ones.
```

Scope it to a file, a directory, or the current diff. It does not validate the whole repo unless you ask.

## What it does

- **Inventory.** Finds every diagram in scope: standalone `*.mmd` files and ```` ```mermaid ```` fenced blocks inside Markdown.
- **Render-verify.** Renders each with `mmdc`, captures exit code and stderr, and prints one verdict per diagram: render-clean, or render-broken with the parse error.
- **Diagnose.** Maps each parse error to a source file and line. For fenced blocks the error's "line N" is block-relative; the helper maps it back to the real source line.
- **Fix.** Surgical edits, one diagram at a time, re-rendering after each edit. Common fixes ranked: edge and arrow syntax, special-character labels, node-shape brackets, `subgraph` and `end`, keywords and direction.
- **Confirm and clean up.** Re-runs the batch verdict so no diagram regressed, and keeps all throwaway artifacts (extracted `.mmd`, output `.svg`, the puppeteer config) under `/tmp`, never in the repo.

## The container gotcha

`mmdc` drives headless Chromium. In containers and CI it crashes on launch with `Operation not permitted` (the PID namespace sandbox). That is a tool problem, not a diagram problem. The skill renders a trivial known-good diagram first and applies a `--no-sandbox` puppeteer config, so a launch failure fails fast instead of masquerading as broken diagrams.

## Helper

`scripts/mmdc-verify.sh [paths...]` inventories diagrams, extracts fenced blocks while tracking source line offsets, renders each with a no-sandbox config, and prints one verdict line per diagram. Exit codes: `0` all render-clean, `1` at least one render-broken, `2` setup or sandbox failure, `127` `mmdc` not installed.

## Notes

- **Render-clean is not the same as correct.** A clean render proves a diagram parses, not that it says what the author meant. If the complaint is "it renders but looks wrong", read the diagram against the intended structure.
- **Reads and reports only**, except for the surgical fix edits you ask for. One-shot.

## Source

Authored and maintained by [EstebanForge](https://github.com/EstebanForge).

## Version History

- **1.0.0** - Initial release.

## License

MIT
