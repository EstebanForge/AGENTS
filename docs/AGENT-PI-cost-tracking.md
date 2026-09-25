# Pi Token Cost Tracking

Reproducible token-spend tracking for the [pi](https://pi) coding agent: the
extension, the ledger, the pricing model, and the multi-environment layout.
Reflects this machine as of 2026-09-25.

> Companion to [AGENT-PI.md](AGENT-PI.md) (reproduce the pi setup). The
> tracking extension is listed there under packages. A legacy scripts stack
> from the cost-counter era is kept in `scripts/pi-cost-tracker/`; see
> [Legacy scripts](#legacy-scripts-cost-counter-era).

---

## Goal

Track token spend in detail (input / output / cache read / cache write),
historically and persistently, to make provider decisions as the market shifts.
The reference provider is **z.ai GLM Coding Plan**, model `glm-5.3-flash`
(current pi default; `defaultProvider: zai`), but the tracker is
provider-agnostic (prices live in one editable file).

---

## Current stack: `@estebanforge/pi-token-cost-ledger`

Install:

```
pi install npm:@estebanforge/pi-token-cost-ledger
```

One extension does everything the old scripts stack did:

- Hooks every assistant message and appends one JSON line to a per-day ledger.
- Computes cost at write time from its own price table: **real USD** and
  **API-equivalent USD**.
- Exposes `/token-usage` with by-model and by-period breakdowns and an
  SVG/PNG chart dashboard. No host-side scripts, no cron, no monthly rollup.

Reports (`/token-usage`):

```
/token-usage                   opens a range menu (bare, in TUI)
/token-usage today
/token-usage day [YYYY-MM-DD]      today, or a specific day
/token-usage week [N]              current ISO week; N = weeks ago
/token-usage days [N]              rolling N-day window incl. today (default 30)
/token-usage month [YYYY-MM]       current month, or a specific one
/token-usage year [YYYY]           current year, or a specific one
/token-usage all                   full history
/token-usage model <name>          one model across all history, by month
/token-usage chart [period]        usage dashboard (SVG; PNG if rsvg-convert or inkscape on PATH)
```

Each report prints: total (real $, api-equiv $, tokens, calls), a by-model
breakdown, and by-period subtotals when the range spans more than one period.

---

## Ledger format

Path: `<root>/YYYY/MM/DD.jsonl` (one file per day), one line per assistant
message. Costs are stamped at write time in real USD:

```json
{"ts":1788266582541,"provider":"zai","model":"glm-5.3-flash",
 "tokens":{"input":70031,"output":540,"cacheRead":0,"cacheWrite":0},
 "cost":{"input":0.0105,"output":0.00027,"cacheRead":0,"cacheWrite":0,"total":0.01077}}
```

Multi-client safe (append-only). Do not edit these files by hand.

### Ledger roots (multi-environment)

pi can run in more than one environment on a machine (host + a construct-cli
sandbox). The setup stays unified and host-owned: each pi instance appends to
its own ledger wherever it runs; ledgers are disjoint, so the union is the
true total. No dedup needed.

| Environment | ledger root | role |
| --- | --- | --- |
| **Host** | `~/.pi/extensions-data/estebanforge/pi-token-cost-ledger/` | primary: ledger + `prices.json` override |
| **Sandbox** | `~/.config/construct-cli/home/.pi/extensions-data/estebanforge/pi-token-cost-ledger/` | producer only: raw ledger + its own prices |

Root resolution: `PI_COST_LEDGER` (single) > `PI_COST_LEDGERS`
(colon-separated) > `roots.conf` in the host root (one path per line, first
root = primary) > built-in default (host + construct sandbox when it exists).
A missing root is warned and skipped; the host-only case degrades gracefully.

---

## Prices: one editable file

The extension ships a bundled price table. At runtime it is overridden by:

```
~/.pi/extensions-data/estebanforge/pi-token-cost-ledger/prices.json
```

Edit THAT file when prices change. Format: API prices per 1M tokens, one entry
per model: `{"model": {"i": input, "c": cacheRead, "o": output}}`. Source: the
models.dev catalog (first-party providers: zai, anthropic, minimax, google,
openai). The `_doc` and `_refresh` keys inside the file carry the provenance
and the extraction recipe. Context-tiered models use the default tier
(<200K context), which covers normal coding sessions.

Current reference entries (override on this machine, fetched 2026-08-26):

| Model | Input | Cache read | Output |
| --- | --- | --- | --- |
| glm-5.3-flash | $0.15 | $0.03 | $0.50 |
| glm-5.2 | $1.4 | $0.26 | $4.4 |

The sandbox keeps its own copy of `prices.json` and prices its own writes.
Nothing is re-priced retroactively; reports read the costs stamped in the
ledger.

---

## Decision: which extension

Two generations. The ledger extension won.

| Extension | Fits? | Why |
| --- | --- | --- |
| `@estebanforge/pi-token-cost-ledger` | **YES (installed)** | Per-day JSONL ledger with cache breakdown, real + api-equiv USD, `/token-usage` reports + charts, multi-root |
| `@ctogg/pi-cost-counter` | replaced | Old ledger extension; needed host-side scripts for every report |
| `@porche/pi-usage` | no (redundant) | Provider quotas only |
| `pi-token-burden` | no | System-prompt composition, not spend |
| `pi-token-count` | no | Live footer, no history |
| `@yusukeshib/pi-token-counter` | no | Inline tool-output annotation, no history |

**Final stack:**
- **Quotas across all tools** -> OpenUsage (kept separate)
- **Token spend ledger + value analysis** -> `@estebanforge/pi-token-cost-ledger`

---

## The core idea: API-equivalent cost

On a flat coding plan the **marginal cost per token is $0** (you pay the
subscription regardless). That is useless for comparison.

**API-equivalent** = what the same tokens would cost on pay-as-you-go API. That
is the apples-to-apples axis vs Anthropic/OpenAI. e.g. a blended ~$0.85/Mtok vs
Claude Sonnet pay-as-you-go ($3/M in, $15/M out): the flat plan is several times
cheaper per token.

**Value multiplier** (a flat-plan provider's own claim, e.g. 15-30x your fee in
API-equivalent):
```
multiplier = monthly_API_equiv_USD / your_monthly_fee
```
Every `/token-usage` report shows both figures, so the multiplier is one
division after any report.

---

## Cache convention: input excludes cacheRead

`tokens.input` **excludes** `cacheRead` (Anthropic-style buckets). Proof: the
ledger contains records with `cacheRead > input`, impossible if input included
cache. Cost per call:
```
total = (input * i) + (cacheRead * c) + (output * o)
```
The extension applies this at write time. There is no runtime toggle in the
current stack; the old `CACHE_CONV=included` escape hatch belonged to the
legacy scripts.

---

## z.ai GLM Coding Plan pricing (reference, researched 2026-06-19)

Plan tiers and prompt limits (official docs.z.ai/devpack/overview):

| Plan | 5hr prompts | Weekly prompts | Price |
| --- | --- | --- | --- |
| Lite | ~80 | ~400 | $18/mo (official "starting at 18") |
| Pro | ~400 | ~2,000 | sources conflict (see below) |
| Max | ~1,600 | ~8,000 | ~$160/mo |

Pro price conflict (two secondary sources):
- HyScaler (Jun 18, cites z.ai): **$72/mo** undiscounted, **$50.40** yearly (30% off)
- aitoolanalysis (Jun 13-18): ~**$30/mo**, "promotional, varies by region"

Official docs only confirm "starting at $18". **Your billing is ground truth.**
Confirm which you pay, then use it in the multiplier calc.

GLM API prices (official docs.z.ai/guides/overview/pricing), per 1M tokens:

| Model | Input | Cached | Output |
| --- | --- | --- | --- |
| GLM-5.2 | $1.4 | $0.26 | $4.4 |
| GLM-5-Turbo | $1.2 | $0.24 | $4.0 |
| GLM-4.7 | $0.6 | $0.11 | $2.2 |

Quota notes: GLM-5.2/5-Turbo burn 3x at peak (14:00-18:00 UTC+8), 2x off-peak;
1x off-peak promo runs through end of September 2026. The current default
`glm-5.3-flash` prices far below GLM-5.2 (see the table in Prices) and carries
its own promo note in `prices.json`.

---

## Maintenance checklist

- **Prices change** -> edit
  `~/.pi/extensions-data/estebanforge/pi-token-cost-ledger/prices.json`
  (and the sandbox copy if you use sandbox sessions). The next
  `/token-usage` picks it up for new writes.
- **Refresh prices from source** -> follow `_refresh` inside `prices.json`
  (models.dev catalog extract).
- **Switch provider / model** -> add the model to `prices.json` before the
  first session on it, or those calls report tokens with a $0 cost.
- **Check live spend** -> `/token-usage month`, `/token-usage days 30`, or
  bare `/token-usage` for the menu.
- **Trend / history** -> `/token-usage year` or `/token-usage all`;
  `/token-usage chart` for a visual dashboard.
- **Add an environment** -> add its ledger root to `roots.conf` in the host
  root, or set `PI_COST_LEDGERS`.
- **Replicate on a new machine** ->
  `pi install npm:@estebanforge/pi-token-cost-ledger`. It starts its own
  ledger at the first call. No backfill.

---

## Legacy scripts (cost-counter era)

The first generation: `@ctogg/pi-cost-counter` extension plus host-side
scripts (`api-equiv.sh`, `monthly-rollup.sh`, the `tokens` menu, a cron
rollup). This machine no longer runs any of it. The repo keeps the stack in
`scripts/pi-cost-tracker/` for reference or for a machine that prefers
host-side reporting. Only a stale ledger remnant survives at
`~/.pi/cost-tracker/2026/` (July data, cost-counter era, all `$0` costs).

| File (in `scripts/pi-cost-tracker/`) | Role |
| --- | --- |
| `api-equiv.sh` | ad-hoc combined cost view |
| `monthly-rollup.sh` | squash a month into an archive + trend CSV |
| `prices.json` | old per-model price table |
| `roots.conf.example` | template for the old roots.conf |
| `tokens.zsh` | interactive menu function |
| `install.sh` | one-command deploy of the above |

Do not deploy both generations on one machine: they use different roots and
would split the history.

---

## Known limitations

- Ledger starts at install time. No backfill of older usage.
- API prices are provider-specific. Other providers need entries in `prices.json`.
- A model missing from `prices.json` reports token counts with `total: $0`.
- Context-tiered models price at the default tier; huge-context calls price off.
- Host and sandbox keep separate `prices.json` copies; sync them if you use both.
- Combined totals assume roots stay **disjoint** (verified for host + sandbox).
- Day boundaries use local system time.

---

## Quick command reference

```
/token-usage                       # menu (today / week / month / year / all)
/token-usage days 30               # rolling 30-day report
/token-usage model glm-5.3-flash   # one model, all history, by month
/token-usage chart all             # SVG dashboard (+PNG if converter on PATH)
```

Raw ledger pull across all roots (jq):

```bash
cat ~/.pi/extensions-data/estebanforge/pi-token-cost-ledger/2026/09/*.jsonl \
    ~/.config/construct-cli/home/.pi/extensions-data/estebanforge/pi-token-cost-ledger/2026/09/*.jsonl \
  | jq -r '[.ts,.provider,.model,.tokens.input,.tokens.output,.tokens.cacheRead,.cost.total] | @csv'
```
