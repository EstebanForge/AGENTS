---
name: proof-of-work
description: Format and attach proof-of-work artifacts (screenshots, CLI output, test logs). Use when compiling verification evidence for pull requests, tickets, or status updates.
---

# Proof of Work

Capture and format evidence that proves software changes. Proof can be visual media or terminal command outputs.

Use `agent-browser` or `headless-ui-screenshot` to capture visual evidence. This skill manages evidence formatting and delivery across platforms.

## Core Rules

The default mode is **result-only**. Capture the final state or output.
A baseline before-state is **optional**. Only capture a before-state when the task asks for a comparison or when diagnosing a regression.
Never fabricate proof. Never replace visual proof with logs when UI changes occur.
Keep paths clean and free of whitespace.

## Evidence Capture

### 1. Web UI Changes
Use `agent-browser` for web capture:
- Viewport screenshot: `agent-browser screenshot captures/result.png`
- Full-page screenshot: `agent-browser screenshot --full captures/result.png`
- Screen recording: `agent-browser record start captures/result.mp4` -> interact -> `agent-browser record stop`

For full-page before/after screenshot pairs, make both files the same pixel height so top edges align in tables. Add bottom-only padding to the shorter page via DOM evaluation before capture.

### 2. Desktop or Headless UI Changes
Use `headless-ui-screenshot` for desktop GUI apps running under Xvfb.

### 3. CLI or Backend Output
For non-visual changes, capture the exact command execution and exit code:
```bash
npm test -- path/to/test.ts 2>&1 | tee /tmp/test-proof.log
```

## Formatter Script

The bundled script at `scripts/format.mjs` formats media evidence and marker blocks.

### Supported Flags
- `--after <file...>`: Local result media (required, repeatable).
- `--before <file...>`: Optional baseline media (repeatable, matches count of `--after`).
- `--label <text...>`: Label for each pair or result.
- `--summary <text>`: Short summary of what the evidence demonstrates.
- `--target <github|slack|asana|markdown>`: Target platform format (default: `github`).
- `--body-file <file>`: File to insert or replace the marked proof block.
- `--attach-list`: Output list of file paths to attach.
- `--attribution <name>`: Credit for proof author.
- `--before-video-url <url...>`: Stable GitHub attachment URL for baseline video.
- `--after-video-url <url...>`: Stable GitHub attachment URL for result video.

## Target Workflows

### 1. GitHub Pull Requests
GitHub uses markdown tables for images and HTML tables for videos.

Format and update a PR description:
```bash
PR=123
gh pr view "$PR" --json body --jq .body > /tmp/pr-body.md

node <skill-dir>/scripts/format.mjs \
  --target github \
  --body-file /tmp/pr-body.md \
  --after captures/result.png \
  > /tmp/pr-body-next.md

ATTACH_ARGS=()
while IFS= read -r file; do
  ATTACH_ARGS+=(--attach "$file")
done < <(
  node <skill-dir>/scripts/format.mjs \
    --attach-list \
    --after captures/result.png
)

gh pr edit "$PR" --body-file /tmp/pr-body-next.md "${ATTACH_ARGS[@]}"
```

For optional before-and-after comparison on GitHub:
```bash
node <skill-dir>/scripts/format.mjs \
  --target github \
  --body-file /tmp/pr-body.md \
  --before captures/before.png \
  --after captures/after.png \
  > /tmp/pr-body-next.md
```

#### Publish GitHub Video Tables
Local videos do not render inside HTML `<video>` tags directly. Use the two-step upload:
1. Upload local video files in a temporary PR comment:
```bash
gh pr comment "$PR" --body "Temporary upload" --attach captures/result.mp4
```
2. Retrieve the permanent GitHub attachment URL from the comment via `gh api`.
3. Format the final video table:
```bash
node <skill-dir>/scripts/format.mjs \
  --target github \
  --body-file /tmp/pr-body.md \
  --after-video-url https://github.com/user-attachments/assets/AFTER_ID \
  > /tmp/pr-body-next.md

gh pr edit "$PR" --body-file /tmp/pr-body-next.md
```
4. Verify the PR renders the video with controls, then delete the temporary comment.

### 2. Slack Updates
Slack messages require short summaries and attached media.
When authoring Slack text as the user, follow the gate protocol and read `~/.agents/skills/esteban-voice/SKILL.md` first.

Generate the proof summary:
```bash
node <skill-dir>/scripts/format.mjs \
  --target slack \
  --after captures/result.png \
  --label "Modal layout fix" \
  --summary "Resolved layout shift on payment modal."
```

Post via `slack_post_message` with the formatted text and media path.

### 3. Asana Task Resolutions
Asana tasks require structured resolution context and attachments.
When authoring Asana text as the user, follow the gate protocol and read `~/.agents/skills/esteban-voice/SKILL.md` first.

Generate the proof summary:
```bash
node <skill-dir>/scripts/format.mjs \
  --target asana \
  --after captures/result.png \
  --label "Desktop checkout"
```

Add comment via `asana_add_comment` with the text and attach the image or video file.

### 4. Local Markdown Notes
Generate standard GitHub-flavored Markdown for handoff notes or ticket descriptions:
```bash
node <skill-dir>/scripts/format.mjs \
  --target markdown \
  --after captures/result.png \
  --summary "Verified checkout flow end-to-end." \
  > /tmp/proof.md
```
