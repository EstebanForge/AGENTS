# bro

A skill that restates the agent's last message in plain human language, with the jargon stripped out. Use it when the agent just said something dense or technical and you want it said again, simply, like a human talking to another human.

`disable-model-invocation: true` is set in the frontmatter, so the model will not auto-load this skill. It only runs when you ask for it explicitly.

## Installation

### Manual install (only the skill file)

```bash
mkdir -p ~/.claude/skills/bro
cp SKILL.md ~/.claude/skills/bro/
```

## Usage

In your agent, invoke the skill after a message you want restated:

```
/bro
```

Or ask the agent directly:

```
Bro that for me.
```

## Behavior

- Restates only the last message.
- Removes jargon, acronyms, and filler.
- Keeps it short and direct. No bullet dumps, no recitals of what it is about to say.

## Version History

- **1.0.0** - Initial release.

## Source

Source: [EstebanForge](https://github.com/EstebanForge).

## License

MIT
