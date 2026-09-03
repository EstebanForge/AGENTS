# ORIGIN

source: https://github.com/vivekparekh8/patch-receipt/blob/main/standalone/patch-receipt/SKILL.md
upstream-repo: vivekparekh8/patch-receipt
upstream-author: Vivek Parekh
license: MIT
homepage: https://github.com/vivekparekh8/patch-receipt
sync-status: adapted (web verification replaced Playwright and MCP with agent-browser)
last-synced: 2026-09-03
upstream-commit: 624123d (2026-08-10)

## Provenance

Port of Vivek Parekh's standalone `patch-receipt` skill. Generates reproducible before-and-after proof bundles (`.patchreceipt/<id>/`) with raw assets, FFmpeg rectangular bounding-box annotations, HTTP captures, test verifications, and cryptographic SHA-256 checksums (`SHA256SUMS`).

## What changed locally

- **Web driver adapted to agent-browser.** Replaced all references to Playwright tests, Playwright MCP, and Chrome DevTools MCP with native `agent-browser` commands (`snapshot -i`, `click @eN`, `screenshot`, `record start/stop`, `eval`).
- **No external npm or MCP servers.** Zero package installations or external server configurations required for browser-driven evidence.

## Requirements

- `agent-browser` (for web execution, screenshots, and video recordings)
- `ffmpeg` and `ffprobe` (for bounding-box annotations, normalization, and GIF generation)
- `sha256sum` or `shasum` (for cryptographic receipt verification)
- Optional: `adb` (Android verification), `xcrun simctl` (iOS verification)
