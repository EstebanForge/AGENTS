# Pi Token Cost Tracking

Reproducible token-spend tracking for the [pi](https://pi) coding agent: which
extension, the scripts, the pricing model, the unified multi-environment
architecture, and a one-command installer.

> Companion to [AGENT-PI.md](AGENT-PI.md) (reproduce the pi setup). The
> `@ctogg/pi-cost-counter` extension is already listed there under packages.

---

## Goal

Track token spend in detail (input / output / cache read / cache write),
historically and persistently, to make provider decisions as the market shifts.
The reference provider is **z.ai GLM Coding Plan**, model `glm-5.2`, but the
tracker is provider-agnostic (prices live in one editable file).

---

## Install / Replicate (any machine)

Everything ships in `scripts/pi-cost-tracker/`. One command deploys it:

```bash
git clone <this repo> && cd AGENTS
./scripts/pi-cost-tracker/install.sh
```

`install.sh` is idempotent and does:

1. Copies `api-equiv.sh`, `monthly-rollup.sh`, `prices.json` to `~/.pi/cost-tracker/`.
2. Generates `roots.conf` (host always; auto-detects a construct-cli sandbox home if present).
3. Installs the `@ctogg/pi-cost-counter` pi extension (if `pi` is on PATH).
4. Adds the `tokens` menu function to your shell rc (idempotent marker block).

Then open a new shell and run:

```
tokens
```

Files in `scripts/pi-cost-tracker/`:

| File | Role |
| --- | --- |
| `api-equiv.sh` | live / ad-hoc combined cost view |
| `monthly-rollup.sh` | squash a month into the archive + trend CSV |
| `prices.json` | single source of truth for per-model API prices |
| `roots.conf.example` | template for `roots.conf` (paths are machine-specific) |
| `tokens.zsh` | canonical `tokens()` interactive menu function |
| `install.sh` | one-command deploy |

---

## Environments (unified, host-owned)

pi can run in more than one environment on a machine (e.g. host + a
construct-cli sandbox). The setup is **unified and host-owned**: one set of
scripts on the host reads **all** ledger roots and reports a combined total.

| Environment | pi home | role |
| --- | --- | --- |
| **Host** | `~/.pi/` | owner: scripts, `prices.json`, `monthly/` archive |
| **Sandbox** (optional) | e.g. `~/.config/construct-cli/home/.pi/` | producer only: raw ledger |

- `@ctogg/pi-cost-counter` is installed in every environment. Each pi instance
  writes its own ledger wherever it runs. Ledgers are **disjoint** (each call is
  logged once, by whichever env ran it), so the union is the true total. **No
  dedup needed.**
- Because the sandbox home is a real dir on the host filesystem, the host scripts
  read its ledger in place. **No raw-data sync ever needed.**
- Scripts live only on the host. The sandbox keeps just its raw
  `YYYY/MM/DD.jsonl` ledger.
- Which roots are read is controlled by `roots.conf`. Precedence:
  `PI_COST_LEDGER` (singular, legacy) > `PI_COST_LEDGERS` (colon-separated) >
  `roots.conf` > built-in default (host + detected sandbox).
  The **first** root is "primary": `prices.json` and `monthly/` live there.
- A missing/absent root is warned and skipped; the host-only case degrades
  gracefully rather than failing.

---

## Decision: which extension

Five were analyzed. Only one fits the goal (detailed, historical, persistent,
per-call ledger with cache breakdown):

| Extension | Fits? | Why |
| --- | --- | --- |
| `@ctogg/pi-cost-counter` | **YES (installed)** | Append-only JSONL ledger, per-call tokens + cache + cost, queryable, CSV-exportable |
| `@porche/pi-usage` | no (redundant) | Provider quotas only |
| `pi-token-burden` | no | System-prompt composition, not spend |
| `pi-token-count` | no | Live footer, no history |
| `@yusukeshib/pi-token-counter` | no | Inline tool-output annotation, no history |

**Final stack:**
- **Quotas across all tools** -> OpenUsage (kept separate)
- **Token spend ledger + value analysis** -> `@ctogg/pi-cost-counter` + these scripts

---

## What the extension does

```
pi install npm:@ctogg/pi-cost-counter
```

It hooks `message_end`, reads pi's `usage` object, and appends one JSON line per
LLM call. **Its `cost` field is $0 for any provider pi has no pricing for.**
Token counts remain accurate; the custom scripts compute cost from `prices.json`.

---

## Ledger format (cost-counter owns this)

Path: `<root>/YYYY/MM/DD.jsonl` (one file per day), written in every environment.

Each line:
```json
{"ts":1781875370624,"provider":"zai","model":"glm-5.2",
 "tokens":{"input":35032,"output":187,"cacheRead":128,"cacheWrite":0},
 "cost":{"input":0,"output":0,"cacheRead":0,"cacheWrite":0,"total":0}}
```

Multi-client safe (append-only). Do not edit these files by hand.

---

## Custom scripts (host `~/.pi/cost-tracker/`)

### `roots.conf` - the ledger roots to read

Plain text, one path per line; `#` comments and blank lines ignored. The first
root is primary (`prices.json` + `monthly/` live there). Template:
`roots.conf.example`. Runtime overrides (no edit): `PI_COST_LEDGERS=/a:/b`
(PATH-style) or `PI_COST_LEDGER=/a` (legacy single-root).

### `prices.json` - single source of truth for prices

Both scripts read this. Edit ONE file when prices change.

```json
{
  "_doc": "GLM API prices per 1M tokens (input / cache-read / output). cacheWrite = 0.",
  "glm-5.2":     {"i": 1.4,  "c": 0.26, "o": 4.4},
  "glm-5-turbo": {"i": 1.2,  "c": 0.24, "o": 4.0},
  "glm-4.7":     {"i": 0.6,  "c": 0.11, "o": 2.2}
}
```

### `api-equiv.sh` - live cost view (combined, all roots)

```
usage: api-equiv.sh [YYYY/MM | YYYY/MM/DD | all]
  api-equiv.sh             # all history (all roots)
  api-equiv.sh 2026/06     # one month
  api-equiv.sh 2026/06/19  # one day

env:
  CACHE_CONV=separate|included   (default: separate)
  PI_COST_LEDGERS=/a:/b          (override roots.conf)
  PI_COST_LEDGER=/a              (legacy: single root)
```

### `monthly-rollup.sh` - the archive (12 files/year + trend CSV)

Reads all roots for a month; writes the archive to the primary root only.
Idempotent.

```
usage: monthly-rollup.sh [YYYY/MM]
  monthly-rollup.sh         # previous month (cron default)
  monthly-rollup.sh 2026/06 # a specific month
```

Outputs (host primary root only):
```
~/.pi/cost-tracker/monthly/
  YYYY-MM.json   summary + by_model + by_day
  history.csv    one row per month (trend), upserted
```

### `tokens` - the interactive menu

The `tokens()` function (in `tokens.zsh`, deployed by `install.sh`) presents a
numbered menu so you never have to remember the scripts:

```
1) live spend — this month        4) squash month into archive (+ trend)
2) live spend — all history       5) show trend (history.csv)
3) live spend — specific range    6) show archive detail for a month
                                  q) quit
```

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
Needs a full month of ledger data to be meaningful. Run it after each monthly
rollup once you have ~30 days.

---

## Cache convention: default `separate`

`tokens.input` **excludes** `cacheRead` (Anthropic-style buckets). Proof: records
can show `cacheRead > input`, impossible if input included cache. The default
`separate` mode is correct and gives the accurate (higher) cost:
```
api_cost = (input * in_rate) + (cacheRead * cache_rate) + (output * out_rate)
```
`CACHE_CONV=included` is available if a future provider lumps cache into input.
If unsure, run both and compare; if any record shows `cacheRead > input`, the
buckets are separate.

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
1x off-peak promo runs through end of September 2026.

---

## Monthly automation (optional)

No automation is required; the menu and scripts run on demand. If you want a
hands-off monthly archive on a machine that has cron, add via `crontab -e`:

```
0 1 1 * * CACHE_CONV=separate $HOME/.pi/cost-tracker/monthly-rollup.sh >> $HOME/.pi/cost-tracker/monthly/cron.log 2>&1
```

Fires 01:00 on the 1st, archives the previous month. `monthly-rollup.sh` is
idempotent, so manual re-runs are always safe.

---

## Maintenance checklist

- **Prices change** -> edit `~/.pi/cost-tracker/prices.json` only. Both scripts
  pick it up. Re-run `monthly-rollup.sh <month>` to refresh that month.
- **Switch provider / model** -> add the model to `prices.json`; verify the cache
  convention with `CACHE_CONV=included api-equiv.sh` and compare.
- **New month, no cron** -> run `tokens` (option 4) or `monthly-rollup.sh`.
- **Check live spend** -> `tokens` (option 1 or 2).
- **Trend across months** -> `tokens` (option 5) or `monthly/history.csv`.
- **Add an environment** -> add its `<root>` path to `roots.conf` on a new line.
- **Replicate on a new machine** -> `./scripts/pi-cost-tracker/install.sh`.

---

## Known limitations

- Ledger starts at install time. No backfill of older usage.
- API prices are provider-specific. Other providers need entries in `prices.json`.
- `blended $/Mtok` is a rough single metric; input and output price at different
  rates, so compare API-equivalent totals for precision.
- cost-counter `$` field stays $0 where pi has no pricing configured. Use the
  scripts for cost.
- Day boundaries use local system time.
- `monthly-rollup.sh` "previous month" uses GNU `date -d` with BSD `date -v`
  fallback; verify on your platform if the date math looks off.
- Combined total assumes roots stay **disjoint** (verified for host + sandbox).
  If a setup ever double-logs the same call across roots, add a `ts`-dedup guard.
- A missing root is warned and skipped; it degrades to the available roots.

---

## Quick command reference

```bash
# interactive menu (everything, no memorizing)
tokens

# live, all history (all roots)
~/.pi/cost-tracker/api-equiv.sh

# this month
~/.pi/cost-tracker/api-equiv.sh 2026/06

# roll up a month into the archive (+ trend row)
~/.pi/cost-tracker/monthly-rollup.sh 2026/06

# view the trend
column -t -s, ~/.pi/cost-tracker/monthly/history.csv

# raw CSV export across ALL roots (jq)
for r in $(grep -vE '^#|^$' ~/.pi/cost-tracker/roots.conf); do
  cat "$r"/2026/06/*.jsonl
done | jq -r '[.ts,.provider,.model,.tokens.input,.tokens.output,.tokens.cacheRead] | @csv'
```
