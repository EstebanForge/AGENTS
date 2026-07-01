# PORT.md — How this skill was vendored

Reproducible audit record of the work that turned the upstream "impeccable"
agent skill into this self-contained, offline, locally-controlled copy. If you
want to re-derive it, update it, or verify nothing was missed, follow this end
to end. Every step is something a human ran; nothing here was automated by the
upstream installer.

## Why a port exists

The upstream project ships an installer (`npx impeccable install`) that
downloads skill files over the network and writes them into agent harness
directories (`.pi/`, `.claude/`, etc.) so they auto-load every session. That is
a prompt-injection surface the project owner is not willing to accept: skills
you do not control are skills that can direct the agent without consent.

The goal of this port: keep the genuinely valuable knowledge (design guidance
prose + a deterministic offline anti-pattern detector), strip every auto-run /
network / auto-inject / filesystem-mutation surface, and own the result as
plain files under our own version control.

## Source of record

- Upstream: `pbakaus/impeccable` on GitHub (Apache-2.0).
- Pinned commit at port time: `c979ac37c361da564dcce100a4f2623d94ef54c8`
  ("Sync generated provider output", 2026-06-29). Upstream `package.json`
  version: `3.1.0`. No release tags at port time.
- Re-derivation starts by cloning that exact commit into `/tmp` and following
  the steps below. Do NOT run the upstream installer against this tree; the
  whole point of the port is to bypass it.

## What was copied verbatim

| Destination | Upstream source | Treatment |
|---|---|---|
| `SKILL.md` | `skill/SKILL.src.md` | Copied, then edited (see below) |
| `reference/*.md` (28 files) | `skill/reference/*.md` | Copied verbatim, then patched (see below) |
| `detect/` (19 files) | `cli/engine/` | Copied verbatim, offline engine only |
| `lib/impeccable-config.mjs`, `lib/download-providers.js` | `cli/lib/` | Copied because the detector imports them |
| `LICENSE` | `LICENSE` | Copied (Apache-2.0 notice retention) |

Approximate sizes at port time: `SKILL.md` 24K, `reference/` 396K, `detect/`
616K, `lib/` 28K.

## What was NOT copied (stripped surfaces)

| Upstream piece | Why stripped |
|---|---|
| `npx impeccable install` (`cli/bin/commands/skills.mjs`) | Downloads files over network from `impeccable.style`, writes into harness dirs, auto-loads every session. The primary vector the port exists to avoid. |
| `skill/scripts/context.mjs` | Phones home to `impeccable.style` each session, emits an `UPDATE_AVAILABLE` directive that directs agent behavior. |
| `skill/scripts/hooks*.mjs` | After-edit hook auto-runs the detector and injects findings as **system reminders** into agent context (injection surface). |
| `skill/scripts/pin.mjs` | Writes shortcuts into every harness dir present in the project (uncontrolled FS mutation). |
| `skill/scripts/live*.mjs` (~15 files) | Browser sessions, network, agent-driven DOM mutation. Largest blast radius. |
| `skill/scripts/palette.mjs` | Offline, but upstream invokes it as a hard "MUST"; downgraded to a manual OKLCH choice. |
| `skill/scripts/critique-storage.mjs` | Persistence helper tied to critique/live; not vendored, flows patched to skip. |
| `skill/scripts/detect-csp.mjs` | CSP patching tied to live mode; not vendored, flows patched to skip. |
| `skill/scripts/context-signals.mjs` | Routing helper that auto-ran on no-arg invocation; replaced with direct project-state reads. |

## Edits made to `SKILL.md`

Diff `skill/SKILL.src.md` (upstream) against this `SKILL.md` to see every
change. Summary:

1. **Frontmatter `allowed-tools` removed.** Upstream whitelisted
   `Bash(npx impeccable *)` and `Bash(node {{scripts_path}}/*)` so the agent
   could auto-run scripts. Removed; a `note:` field documents the vendoring.
2. **Setup section rewritten.** Upstream step 1 was "MUST run `context.mjs`
   per session" (the phone-home step). Replaced with offline equivalents: read
   the project directly, read the matching register reference, pick OKLCH
   colors manually for new projects, run the detector manually.
3. **Routing rules rewritten.** The no-arg branch no longer runs
   `context-signals.mjs`; it reads project state (PRODUCT.md/DESIGN.md
   presence, dirty git tree, existing tokens) and reasons over heuristics. The
   detector call now points at the local offline path instead of
   `{{scripts_path}}/detect.mjs`.
4. **Pin / Unpin section** rewritten to state it is NOT VENDORED and that
   upstream pin writes into harness dirs (filesystem mutation we do not want).
5. **Hooks section** rewritten to state it is NOT VENDORED and explain why
   (auto-injects system reminders). Points users at the manual detector.
6. **Template variables resolved.** `{{model}}` -> `You`; `{{command_hint}}`
   -> `command`. Upstream `context.mjs` injected these; without it they would
   render as literal strings.

## Edits made to `reference/*.md`

The 28 reference files were copied verbatim, then patched where they
referenced un-vendored scripts. Five files needed active changes:

- `reference/critique.md` — `{{scripts_path}}/detect.mjs` call rewritten to
  `node detect/detect-antipatterns.mjs`; `critique-storage.mjs` slug/write/trend
  steps marked NOT VENDORED (persistence is skipped, critique is delivered
  inline); the live-server browser-evidence sub-step marked NOT VENDORED.
- `reference/polish.md` — the optional prior-critique lookup
  (`critique-storage.mjs`) marked NOT VENDORED.
- `reference/init.md` — Step 6 (live-mode config + `detect-csp.mjs`) replaced
  with a NOT VENDORED skip notice.
- `reference/live.md` — NOT VENDORED banner prepended; the body is retained
  as conceptual documentation of the upstream live flow only.
- `reference/hooks.md` — NOT VENDORED banner prepended; body retained as
  documentation only.

All 28 files: the `{{command_prefix}}impeccable` hand-off invocation was
normalized to `/impeccable` (the upstream template var does not resolve here).
A handful of illustrative `{{command_prefix}}command-name` placeholders remain
inside output templates in `audit.md` and `critique.md`; those are not
executable and are left as upstream wrote them.

## Edits made to detector code

Two lines in `detect/cli/main.mjs` (the dev-server suggestion printed to
stderr) were changed from `npx impeccable detect http://localhost:PORT` to
`node <path-to-skill>/detect/detect-antipatterns.mjs http://localhost:PORT`.
This removes the only `npx impeccable` string an agent could see in tool
output. Everything else under `detect/` and `lib/` is byte-identical to
upstream.

## Offline-scope claim (and its boundary)

The detector is fully offline **for file and directory targets**. Verified by
auditing every `fetch`/URL/network reference under `detect/` and `lib/`:

- `detect/node/file-system.mjs:162` — `fetch("http://localhost:PORT/")`, the
  `isPortListening` probe. Localhost only, fires once when scanning a
  directory that looks like a framework project. No external egress.
- `detect/engines/browser/detect-url.mjs` — launches Puppeteer to scan an
  **https URL target**. This makes external requests to that host. It only
  runs if the caller passes a URL; scanning local files never reaches it.
- `lib/impeccable-config.mjs` — pure local `fs` read/write of a config file.
  No `fetch`, no URLs. (Contains dead `setHookConsent`/`getHookConsent` code
  that is inert without the stripped hook mechanism.)

So: scan files/dirs for zero network egress; do not pass URLs to the detector
if you want to stay offline.

## Verification checklist (re-run after any update)

```sh
# 1. SKILL.md has no auto-run / npx / unresolved template vars.
rg -n 'scripts_path|command_prefix|\{\{model|\{\{command_hint|npx impeccable' SKILL.md

# 2. No critical script refs outside the two NOT VENDORED doc files.
#    (live.md and hooks.md are intentionally retained as upstream-flow docs;
#    every other reference file must have zero runnable script refs.)
rg -n '\{\{scripts_path\}\}/(detect|critique-storage|live-server|detect-csp|hook-admin)\.m?js' reference/ | rg -v 'reference/(live|hooks)\.md'

# 3. No upstream attribution inside agent-readable skill files.
rg -n 'pbakaus|impeccable/impeccable|github\.com/pbakaus' SKILL.md reference/ README.md

# 4. Detector runs offline and fires real findings.
printf '<h1 style="background:linear-gradient(#fff,#ccc);-webkit-background-clip:text;color:transparent">X</h1>' > /tmp/t.html
node detect/detect-antipatterns.mjs /tmp/t.html
rm -f /tmp/t.html

# 5. License retained.
test -f LICENSE
```

Each command should return nothing (or, for #4, one finding about gradient
text). Any hit on #1, #2, or #3 means a later merge reintroduced a stripped
surface; fix before committing.

## How to update this port

1. Clone upstream into `/tmp/impeccable` (pin a commit, record it here).
2. Diff `skill/SKILL.src.md`, `skill/reference/*.md`, and `cli/engine/`
   against this tree.
3. Merge prose changes by hand. Do NOT run the upstream installer; do NOT
   copy back any of the stripped scripts listed above.
4. Re-run the verification checklist.
5. Update the "Source of record" block above with the new commit and date.

## Attribution

Upstream is Apache-2.0 and is the original source of the design guidance and
the detector rules. The full Apache-2.0 license text is retained in
`LICENSE` as required for redistribution. The upstream project's identity is
intentionally absent from `SKILL.md`, `README.md`, and `reference/*.md` so
that agents loading this skill cannot infer they have access to upstream
tooling; this file is the canonical record of provenance for humans.
