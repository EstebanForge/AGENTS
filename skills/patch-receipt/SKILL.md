---
name: patch-receipt
description: Create structured before-and-after proof of work for code changes. Use when capturing screenshots, recordings, test output, or API responses to verify bug fixes, features, or pull requests.
---

# PatchReceipt

Create inspectable before-and-after evidence with tools and connections already available in the project. Do not require the PatchReceipt npm package. Drive behavioral verification, capture, FFmpeg processing, HTTP checks, hashing, and the final summary directly.

Adapt command examples to the active operating system. Treat them as argument templates, not text to paste blindly. Invoke subprocesses with an argument-array API whenever possible. Never interpolate recipe values into command strings. If only a shell is available, validate first, quote each argument for that shell, and reject control characters and metacharacters.

## Operating rules

- Define one falsifiable claim before changing code.
- Capture the real before state first. If the fix already exists, recover the base revision in a separate worktree and disclose that reconstruction.
- Keep conditions comparable: viewport or device, route or screen, seed data, account/app state, request, timing, locale, orientation, and interaction sequence.
- Prefer the project's targeted test as the behavioral authority. Use an automation or device connection to drive and capture the same scenario, not to replace stronger existing assertions.
- Discover capabilities without installing, upgrading, reconfiguring, or starting an external server, browser debugging port, emulator, simulator, SDK, or package unless the user explicitly approves it.
- Never fabricate missing evidence or describe logs as visual proof.
- Keep inputs and outputs under `.patchreceipt/<id>/`; use a lowercase hyphenated id.
- Preserve source evidence unchanged. Write annotations and normalized comparisons as new files.
- Use normal rectangular outlines around the claimed subject without obscuring behavior.
- Refuse existing output targets, symlinks, filesystem aliases, platform reparse points, and non-regular source files. Never follow a path outside the proof workspace.
- Do not publish, upload, or comment on a pull request without explicit approval immediately before that external action.

## Choose a workflow

- Use `media` for existing PNG, JPEG, or MP4 evidence.
- Use `http` for the same request executed against before and after targets.
- Use `web` for a browser scenario verified and captured directly with `agent-browser`.
- Use `android` for a native UI test plus adb capture.
- Use `ios` for XCTest/XCUITest plus iOS Simulator capture.

Create separate receipts when UI and API evidence prove distinct claims. Use video only when motion or interaction order matters; otherwise prefer two precise screenshots.

## Prepare the workspace

Refuse to proceed if `.patchreceipt/<id>/output` exists. Build in a randomly named sibling staging directory, verify it, then atomically rename it to `output` without overwriting.

```text
.patchreceipt/<id>/
├── recipe.json
├── source/
│   ├── before.png, before.jpg, or before.mp4
│   └── after.png, after.jpg, or after.mp4
└── output/
    ├── before-annotated.png or .mp4
    ├── after-annotated.png or .mp4
    ├── comparison.png or .mp4
    ├── preview.gif                 # video only
    ├── before-http.json            # HTTP only
    ├── after-http.json             # HTTP only
    ├── verification.json           # executed browser/mobile checks
    ├── receipt.json
    ├── SHA256SUMS
    └── proof.md
```

Write `recipe.json` before capture. Record:

- `format: "patch-receipt-agent/v1"` and `mode: "agent-driven"`
- `id`, `claim`, and `kind`: `media`, `http`, `web`, `android`, or `ios`
- exact before/after acquisition conditions and source paths
- `surface`, selected driver, stable scenario steps, role-specific assertions, and capture checkpoints for web/mobile
- rectangular annotations with `target`, normalized `x`, `y`, `width`, `height`, `color`, and `thickness`
- `from` and `to` seconds for transient video annotations
- a sanitized HTTP request shape and separate before/after expectations for HTTP

Do not put credentials, cookies, tokens, personal data, device identifiers, or private hostnames in the recipe. Resolve the proof root once, inspect every existing path component with `lstat`, reject links and reparse points, and require every source and destination real path to remain inside that root.

## Execute verification

1. Inventory existing targeted tests and currently connected browser, emulator, simulator, or device tools. Do not probe unrelated accounts, tabs, apps, devices, or network targets.
2. Prefer an existing targeted project test, then use an already connected automation surface for interaction and capture. If automation is unavailable, accept reviewed user-supplied media with driver `manual` and status `not-run`; never claim the behavior was executed.
3. Give each scenario step, assertion, and capture checkpoint a stable id. Define separate expected before and after outcomes. An intentionally failing before assertion can be correct evidence.
4. Execute the same scenario once per role under matched conditions. Record sanitized exit codes and observed assertions. Do not weaken assertions, silently change state, or retry with different conditions.
5. Write `<staging>/verification.json` with `schemaVersion: 1`, `surface`, sanitized driver name/version, sanitized target metadata, scenario steps, checkpoints, per-role expected and observed assertions, and overall `passed`, `failed`, or `not-run` status. It becomes `output/verification.json` only through the final atomic rename. Use `passed` only when both roles match their declared expectations; never create or write under `output/` before that rename.
6. Treat console output, network summaries, accessibility snapshots, traces, test logs, `.xcresult`, and logcat as supplementary and potentially sensitive. Persist only bounded, reviewed, redacted excerpts or hashes.

Do not persist usernames, home paths, device serials, simulator UDIDs, browser profile paths, cookies, authorization data, signing identities, provisioning profiles, Apple account data, complete internal URLs, or stable hashes of target identifiers. Persist only a random per-receipt browser/device label, OS/API version, viewport or screen size, and orientation.

## Verify web work

1. Drive browser interaction directly through `agent-browser`. Do not require Playwright, Puppeteer, or external browser MCP servers.
2. For element discovery and inspection, run `agent-browser snapshot -i` to obtain the compact accessibility tree with `@eN` references. Execute interactions with `agent-browser click @eN`, `agent-browser fill @eN "text"`, and `agent-browser press @eN Key`.
3. For visual checkpoints, capture images directly with `agent-browser screenshot SOURCE.png` (viewport) or `agent-browser screenshot --full SOURCE.png` (full page) into the proof workspace.
4. For motion capture, start recording with `agent-browser record start SOURCE.mp4`, execute the target scenario, and stop with `agent-browser record stop`. Enforce a maximum 180-second duration.
5. For DOM, console, or state assertions, evaluate JavaScript directly via `agent-browser eval "<expression>"`. Record observed assertion values into `verification.json`.
6. For session isolation, pass a unique session identifier via `agent-browser --session <id>` to ensure pristine cookies, local storage, and authentication state.
7. Match URL, viewport dimensions (`agent-browser set viewport <width> <height>`), color scheme, seed data, and interaction sequence between before and after runs.

## Verify Android work

1. Require `adb` and inspect `adb devices -l`. Stop if no target is available. If more than one is available, require explicit selection. Pass `-s SERIAL` to every command and never persist the serial.
2. Prefer the repository's existing Compose, Espresso, UI Automator, or instrumentation test. Inspect the Gradle task and test selector. Prefer an emulator; obtain approval before installing, clearing data, changing permissions, or using a physical device or production-signed app.
3. Capture PNG bytes with the argument-array equivalent of `adb -s SERIAL exec-out screencap -p` and write stdout directly to a new `source/` file without decoding or logging it.
4. For motion, generate a cryptographically random nonce and preflight that `/sdcard/Download/patchreceipt-<id>-<nonce>.mp4` is absent. Run `adb -s SERIAL shell screenrecord --time-limit SECONDS DEVICE_PATH` for at most 180 seconds. In a `finally` path on success, timeout, disconnect, pull failure, hash failure, or interruption, gracefully stop and then hard-stop the exact recording process if needed, delete only that exact remote file, remove partial local capture files, and abort the staging directory. Pull, probe, and hash the completed file before committing it.
5. Record only sanitized model, Android/API version, resolution, density, orientation, app id, build variant, and test result. Redact logcat and test output before persistence.

## Verify iOS work

1. Support iOS Simulator. Require `xcrun`, list available booted simulators, and require explicit selection when more than one is booted. Pass the selected UDID to every command but never persist it.
2. Prefer an existing XCTest/XCUITest target or test plan. Inspect the scheme, destination, and test selector before a targeted `xcodebuild test`. Do not alter signing, provisioning, Apple accounts, entitlements, or app data without approval.
3. Capture PNG with `xcrun simctl io UDID screenshot SOURCE.png`. For motion, use a cryptographically random absent staging filename, run `xcrun simctl io UDID recordVideo SOURCE.mp4`, stop gracefully with SIGINT at the declared checkpoint, and enforce a maximum 180-second duration. In a `finally` path on every exit, terminate the exact recorder if still running, delete partial local captures, and abort staging.
4. Record only sanitized simulator model, iOS version, resolution, orientation, bundle id, build configuration, and test result. Copy only reviewed artifacts from `.xcresult`.
5. Do not claim portable physical iPhone or iPad capture. Accept reviewed XCTest screenshot attachments as manual inputs and disclose that PatchReceipt did not drive the physical-device capture.

## Process media

1. Confirm `ffmpeg` and `ffprobe`; record their version lines.
2. Require regular `.png`, `.jpg`, `.jpeg`, or `.mp4` sources. Probe with the argument-array equivalent of `ffprobe -v error -show_streams -show_format -of json FILE`; reject corrupt, unsupported, or mismatched media kinds.
3. Apply caps per source and derived artifact: 1 GiB per source, 2 GiB per output, 8,192 pixels on either axis, 67 megapixels per frame, and 10 minutes of video. Precompute complete comparison dimensions and scale both sides down equally. Monitor output size and delete staging output after a cap failure. Apply a five-minute timeout to each FFmpeg/FFprobe subprocess. Obtain approval for disclosed higher limits; never remove timeouts.
4. Hash untouched sources before processing.
5. Validate annotation numbers as finite; require `x,y >= 0`, `width,height > 0`, `x + width <= 1`, `y + height <= 1`, thickness integer 1–32, and `0 <= from < to <= duration`. Accept color only as exactly six hexadecimal digits prefixed by `#` or from `red`, `green`, `blue`, `yellow`, `magenta`, `cyan`, `white`, and `black`. Convert accepted hex to FFmpeg `0xRRGGBB`.
6. Convert normalized boxes to a drawbox expression such as `drawbox=x=iw*0.12:y=ih*0.18:w=iw*0.42:h=ih*0.36:color=0xff006e:t=5`. For timed video add the validated equivalent of `enable='between(t\,1.2\,3.5)'`.
7. Render images as metadata-free PNG with FFmpeg no-overwrite mode. Render MP4 as metadata-free H.264, even dimensions, square pixels, `yuv420p`, optional AAC audio, and fast start.
8. Normalize without stretching. Use the larger probed width/height as each side's canvas, preserve aspect ratio, center-pad, and stack horizontally. Normalize video to 30 fps, start at PTS zero, freeze-pad the shorter role, and disclose padding.
9. Create video GIF previews of at most 30 seconds and 960 pixels wide.
10. Probe every artifact; view images at full size, inspect representative frames, and play MP4s. Confirm the box is tight, visible, correctly timed, and not hiding evidence.

## Capture HTTP/API evidence

1. Default to user-controlled local, test, or ephemeral targets. Show exact origins, resolved IPs, method, relative path, header names, query keys, body shape, expected statuses, and mutation risk. Obtain approval for non-local, production-like, or state-changing requests.
2. Reject URL credentials, redirects, protocol changes, link-local/cloud-metadata addresses, and origin changes. Re-resolve immediately before connecting and stop on address change.
3. Execute the same approved request once per role with a default 10-second deadline. Read the response as a byte stream, count bytes before decoding, retain at most 65,536 bytes, cancel when the next chunk crosses the bound, then decode only retained bytes and mark truncation.
4. Reference secrets only through names matching `PATCHRECEIPT_SECRET_[A-Z0-9_]+`. Show and approve every requested name. Launch with a minimal environment containing only required system variables and approved names.
5. Never persist secret values. Scrub raw plus URL-, form-, and JSON-encoded variants from output. Redact authorization, cookie, token, API-key, password, secret, session, and credential fields case-insensitively.
6. Save one sanitized JSON capture per role with request, status, bounded response, duration, assertions, and result. Always assert status; recursively compare expected JSON subsets. Preserve failed evidence as `assertions-failed` and never present it as passing proof.

## Write the receipt and verify

Write `receipt.json` with format/mode, id, claim, kind, timestamp, sanitized agent and Git context, tool versions, command templates, acquisition conditions, annotations, normalization, source/artifact hashes, verification summary, HTTP assertions, and caveats. Always strip URL user information, credentials, query strings, fragments, local paths, hostname, username, device identifiers, and profile paths.

Finalize in this exact order:

1. Finish recipe, sources, reviewed scripts/logs, sanitized captures, `verification.json`, and media artifacts in staging.
2. Hash and verify them, probe media again, and re-evaluate saved assertions.
3. Write `receipt.json`, then `proof.md`, including the future verification command but no claimed checksum result.
4. Create `SHA256SUMS` with `sha256sum` or `shasum -a 256`. Include recipe, sources, reviewed scripts/logs, captures, verification ledger, media, receipt, and proof; exclude `SHA256SUMS` itself. Use paths relative to final `output`, such as `../recipe.json`, `../source/before.png`, and `comparison.png`, and sort bytewise.
5. Atomically rename staging to the absent `output` path.
6. Verify every entry from that exact `output` working directory with the equivalent of `sha256sum -c SHA256SUMS` or `shasum -a 256 -c SHA256SUMS`. Do not edit any hashed file afterward. Return the verification output. Exclude and disclose any separately saved verification log.

An agent-generated ledger supplies tamper evidence, not author identity or independent attestation.

## Return PR-ready proof

Write `proof.md` with the claim and pass/fail result, before-state provenance, matched/different conditions, role-relative asset links, verification driver and assertion table, annotated comparison, HTTP results when applicable, receipt/checksum paths, and limitations including reconstruction, normalization, padding, redaction, missing automation, and integrity scope.

Return the recipe path, output directory, verification status, checksum result, failed assertions, and concise disclosure. If the deterministic PatchReceipt CLI is available, offer it as a stricter media/HTTP alternative; do not require it or claim that an agent-driven receipt conforms to the CLI schema.
