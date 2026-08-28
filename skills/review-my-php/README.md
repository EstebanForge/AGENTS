# review-my-php

A skill that reviews PHP changes (working tree, staged, commit, or range) against a PHP 8.2+ anti-patterns rubric. Findings cite entry numbers, quote the fix from the Do-This examples, and end in an Approve / Request Changes / Needs Discussion verdict.

Successor of the `@estebanforge/pi-php-review` pi extension (deprecated 2026).

## Install

```bash
ln -s "$(pwd)" ~/.agents/skills/review-my-php
```

Or copy the folder into any agent skills directory.

## Usage

Ask your agent: "Review my PHP." Point at a commit or range for narrower scope: "Review my PHP, src/Service."
