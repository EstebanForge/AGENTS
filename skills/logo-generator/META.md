# ORIGIN

source: https://github.com/op7418/logo-generator-skill
upstream-category: logo generation
sync-status: synced
last-synced: 2026-08-19
upstream-commit: bf4e9ac

## Fork notes

Repo root skill, installed as-is. Upstream `name: logo-generator`
matches the local folder name; no rename needed, no content changes.

Files pulled: `SKILL.md`, `requirements.txt`, `.env.example`,
`scripts/svg_to_png.py`, `scripts/generate_showcase.py`,
`references/design_patterns.md`, `references/background_styles.md`,
`references/webgl_backgrounds.md`,
`assets/showcase_template.html`, `assets/background_library.html`.

Excluded: upstream `README.md` (repo marketing copy, not skill
content), `.gitignore`, `.DS_Store`.

Local divergences: none.

## Setup (skill-local, not part of origin)

1. `pip install -r requirements.txt` (google-genai, python-dotenv,
   cairosvg, Pillow).
2. `cp .env.example .env` and set `GEMINI_API_KEY` for Phase 4
   showcase generation. SVG generation (Phases 1-3) needs no API
   key.