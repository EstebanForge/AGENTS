# META

source: https://github.com/modem-dev/skills/blob/main/write-discoverable-code/SKILL.md
upstream-repo: modem-dev/skills
upstream-author: benvinegar (Ben Vinegar, Modem)
license: MIT
repo-created: 2026-07-20
backing-article: https://modem.dev/blog/how-coding-agents-read-your-code
last-synced: 2026-11-24
upstream-commit: edcdedb (2026-07-20)
sync-status: verbatim (body); description modernized, license stays in META

## Provenance

Vendored verbatim from Modem's skills repo. The skill is the publishable form
of Ben Vinegar's measured discoverability work, which the commit message calls
"the measured discoverability skill (v4)". The backing blog post
("How coding agents read your code (and how to write for them)") explains the
measurement basis (the ~700k-line monorepo stats: 1-word exported names
globally unique 61%, 3-word 96%, 4+ words 98%).

## Text match

Byte-for-byte identical to upstream, including the three numbered sections
(Names are search queries; Types are the documentation agents can't skip;
Say it where the search lands), the quick checklist, and all the measured
stats and examples.

## What changed locally

- The upstream frontmatter carries `license: MIT` after the description
  block. The local copy omits that line (everything else in the frontmatter
  and body is identical).

## sync-status

Verbatim. Re-pull from the link above if refreshing.

## 2026-11-24 check (upstream edcdedb)

Body still byte-for-byte identical. Upstream's richer multi-line description
(trigger branches: "whenever writing or renaming code") adopted, folded to
the house single-line frontmatter style. License line stays omitted here
(recorded in this META per repo convention).
