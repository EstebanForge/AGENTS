# impeccable (vendored, offline)

Frontend design guidance for AI coding agents. Vendored for control: **no `npx`, no network,
no auto-run, no prompt injection we didn't choose.** License: Apache-2.0 (see `LICENSE`).

## Layout

```
skills/impeccable/
  SKILL.md          core design guidance: color/typo/layout/motion rules,
                    "absolute bans", "AI slop test", command routing (audited)
  reference/*.md    28 deep-dive command references (brand, product, critique,
                    polish, typeset, colorize, etc.) - knowledge, read on demand
  detect/           offline anti-pattern detector (44 deterministic rules; see scope)
  lib/              detector dependency (local config read/write only)
  LICENSE           Apache-2.0, retained from upstream as the license requires
```

## How to use

Read on demand during frontend work:
- Entry point: `skills/impeccable/SKILL.md`
- Per-command depth: `skills/impeccable/reference/<command>.md`
- Objective quality check: `node skills/impeccable/detect/detect-antipatterns.mjs <files>`
  - `--json` for machine output
  - `--help` for flags (inline ignores, design-system context, provider tells)

## What was STRIPPED (and why)

Upstream ships an install + live session system. The following were removed because
they are prompt-injection or uncontrolled-mutation surfaces:

| Stripped | Upstream behavior | Risk |
|---|---|---|
| `npx impeccable install` | Downloads skill files over network from `impeccable.style`, writes into `.pi/`, `.claude/`, etc. auto-loaded every session | Untrusted remote prompt content, auto-loaded |
| `context.mjs` (setup step 1) | Phones home to `impeccable.style` every session, emits `UPDATE_AVAILABLE` directive that asks the agent to act | Network + behavior direction |
| Hooks (`hook.mjs`, `hooks on`) | After-edit hook auto-runs detector, injects findings as **system reminders** into agent context | Auto-injected prompt content |
| Pin/Unpin (`pin.mjs`) | Writes shortcuts into every harness dir in the project | Uncontrolled filesystem mutation |
| Live mode (`live*.mjs`) | Browser sessions, network, agent-driven DOM mutation | Largest blast radius; not vendored |
| `palette.mjs` | Offline, but invoked as a hard "MUST"; downgraded to manual OKLCH choice per SKILL.md color guidance | Reduced auto-run surface |
| `critique-storage.mjs`, `detect-csp.mjs` | Persistence/CSP helpers bundled with critique + live flows | Not vendored; `reference/critique.md`, `polish.md`, `init.md` patched to skip these steps |

`reference/hooks.md` and `reference/live.md` remain as **documentation of the upstream
flow** with a NOT VENDORED banner at the top; we do not execute them. Residual
`{{scripts_path}}` mentions inside `reference/*.md` describe upstream machinery we did
not vendor.

## Offline scope (precise)

- Scanning **files and directories** with the detector: fully offline, no network.
- Scanning an **https:// URL**: launches Puppeteer and makes external requests to that
  host (inherent to URL scanning). Don't pass URLs to the detector if you want zero
  network egress.
- The only other network call in `detect/` is a `localhost` dev-server port probe (only
  when scanning a directory that looks like a framework project).

## Updating

Re-clone upstream to `/tmp`, diff against this copy, and merge prose changes by hand.
Never run the upstream installer against this tree. The detector is self-contained
under `detect/` (+ `lib/`); no network needed to run it.
