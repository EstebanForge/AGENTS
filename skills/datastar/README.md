# datastar

A reference skill for the [Datastar](https://data-star.dev) hypermedia framework. The agent loads `SKILL.md` on demand when working with Datastar, `data-*` attributes, SSE patch events, or backend-driven HTML apps. It covers signals, modifiers, data attributes, actions, SSE integration, and the common patterns (CQRS, click-to-edit, active search, infinite scroll, bulk update).

## Installation

### Manual install (only the skill file)

```bash
mkdir -p ~/.claude/skills/datastar
cp SKILL.md EXAMPLES.md ~/.claude/skills/datastar/
```

## Usage

The skill is invoked automatically when the description matches (Datastar work, `data-*` attributes, SSE patch events). Or ask the agent directly:

```
Read the datastar skill and build a click-to-edit form.
```

## What is inside

- **`SKILL.md`** - the full reference: signals (`$`), modifiers (`__`), data attributes, actions (`@`), expressions, SSE event types, response content types, SDK list, patterns and best practices, anti-patterns, and Pro features.
- **`EXAMPLES.md`** - 17 self-contained, idiomatic examples: Active Search, Click to Edit, Bulk Update, Edit Row, Delete Row, File Upload, Form Submission, Infinite Scroll, Inline Validation, Lazy Tabs, Progress Bar, TodoMVC, Sortable, Web Component, Event Delegation, Signal Watcher, Custom Plugin.

## Notes

- Datastar uses `Function()` constructors, so Content Security Policy requires `unsafe-eval`.
- The official docs at `data-star.dev` can be fetched on demand for deeper reference.

## Version History

- **1.0.0** - Initial curated reference.

## Source

Skill curated and maintained by [EstebanForge](https://github.com/EstebanForge). Upstream: [Datastar](https://data-star.dev).

## License

MIT
