# META

source: https://github.com/kajisho5/ffmpeg-skill
upstream-repo: kajisho5/ffmpeg-skill
upstream-author: kajisho5
license: MIT (LICENSE at repo root, Copyright (c) 2026 kajisho5)
repo-created: 2026-10-04
last-synced: 2026-11-24
upstream-commit: bad487c (2026-11-23, release 4.7.1)
sync-status: synced (one local delta: demo media dropped)

## Provenance

Full-toolbox skill for local FFmpeg video/audio editing: root `SKILL.md`
router plus 42 Python tool scripts under `scripts/`, delivery templates under
`templates/`, deep-dive guides under `references/`, design docs under `docs/`,
an optional MCP server (`mcp/server.py`), and `package.json` (version
metadata). Python 3.9 standard library only; needs `ffmpeg`/`ffprobe` on PATH
at run time. Upstream distributes it through `npx ffmpeg-skill`
(`bin/install.js`), which copies a fixed payload (SKILL.md, scripts,
templates, references, docs, mcp, package.json) into agent skill directories.
Vendored here mirroring that payload so it reaches agents through the central
`~/.agents/skills/<name>` symlink sync; the npx installer stays optional.

## What changed locally

One trim, everything else byte-for-byte: dropped `docs/demos/` (12 MB of
demo GIFs) and `docs/demos.md` (their showcase page). Marketing weight,
referenced by no functional file in the payload.

Not vendored, outside upstream's own install payload: `.claude/skills/*`
(upstream's repo-development skills), `evals/`, `tests/`, `examples/`,
root `demos/`, `assets/`, `.claude-plugin/`, `bin/install.js`, and the repo
root docs (README, CHANGELOG, LICENSE, SECURITY, CONTRIBUTING). The upstream
LICENSE is recorded here instead of copied.

Upstream-specific references stay unedited per import convention: SKILL.md
mentions `npx ffmpeg-skill doctor` (falls back to
`python3 <skill-dir>/scripts/_contract.py doctor`, which is vendored), the
optional MCP server, and a companion skill at
github.com/kajisho5/color-grading-skill (not installed; the SKILL.md text
treats it as optional routing). FFmpeg itself is a run-time requirement, not
a vendor requirement; the skill's own doctor reports a missing tool.

## sync-status

Synced at upstream commit bad487c (release 4.7.1) on 2026-11-24: full payload
refresh (SKILL.md, scripts/ incl. new _common modules, templates/,
references/ incl. new flags.md, docs/, mcp/, package.json), demo-media trim
re-applied. docs/showcase.md is upstream-new and not part of the demos* trim,
but is marketing weight; dropped here alongside the demos trim on this sync.
On refresh, re-copy the upstream payload (SKILL.md, scripts, templates,
references, docs minus demos*, mcp, package.json), re-diff byte-for-byte, and
re-apply the demo media trim; keep both delta sections accurate if upstream
drifts.
