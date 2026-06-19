#!/usr/bin/env bash
# api-equiv.sh — API-equivalent cost from the pi cost-counter token ledger.
#
# Unified: reads MULTIPLE ledger roots (host + construct sandbox by default) and
#          reports a COMBINED total. The two ledgers are disjoint (each pi
#          instance logs only its own calls), so the union is the true total.
#          No dedup needed.
#
# Ledger roots (first match wins):
#   PI_COST_LEDGER  (singular)    -> legacy single-root mode (only that root)
#   PI_COST_LEDGERS (colon-sep)   -> those roots, in order (PATH-style: a:b:c)
#   roots.conf      (one path/line, # comments) at the default tracker dir
#   default                       -> host ~/.pi/cost-tracker + construct home
# The FIRST root is "primary": prices.json + monthly/ archive live there.
#
# Prices: read from prices.json (GLM API, per 1M tokens). Edit that ONE file
#         when GLM prices change (docs.z.ai/guides/overview/pricing). cacheWrite = 0.
#
# Why API-equiv: on a flat coding plan the marginal cost/token = $0 (useless for
#                comparison). API-equiv = what the same tokens cost pay-as-you-go,
#                the apples-to-apples axis vs Anthropic/OpenAI.
#
# Cache convention (safety):
#   CACHE_CONV=separate  -> tokens.input EXCLUDES cacheRead (Anthropic-style). DEFAULT.
#   CACHE_CONV=included  -> tokens.input INCLUDES cacheRead (input is total prompt).
#   If unsure, run both and compare. If ANY record ever shows cacheRead > input, the
#   buckets are separate (a subset cannot exceed its whole).
#
# usage: CACHE_CONV=separate api-equiv.sh [YYYY/MM | YYYY/MM/DD | all]
set -euo pipefail

DEFAULT_TRACKER="$HOME/.pi/cost-tracker"
CONSTRUCT_TRACKER="$HOME/.config/construct-cli/home/.pi/cost-tracker"

# --- resolve ledger roots (precedence: singular > LEDGERS > roots.conf > default) ---
ROOTS=()
if [ -n "${PI_COST_LEDGER:-}" ]; then
  ROOTS=("$PI_COST_LEDGER")
elif [ -n "${PI_COST_LEDGERS:-}" ]; then
  IFS=':' read -ra _tmp <<< "$PI_COST_LEDGERS"
  ROOTS=("${_tmp[@]}")
elif [ -f "$DEFAULT_TRACKER/roots.conf" ]; then
  while IFS= read -r _line || [ -n "$_line" ]; do
    case "$_line" in
      ''|\#*) continue ;;
    esac
    _line="${_line#"${_line%%[![:space:]]*}"}"   # trim leading whitespace
    _line="${_line%"${_line##*[![:space:]]}"}"   # trim trailing whitespace
    ROOTS+=("$_line")
  done < "$DEFAULT_TRACKER/roots.conf"
else
  ROOTS=("$DEFAULT_TRACKER" "$CONSTRUCT_TRACKER")
fi
[ ${#ROOTS[@]} -gt 0 ] || ROOTS=("$DEFAULT_TRACKER")
PRIMARY="${ROOTS[0]}"

PRICES="${PI_COST_PRICES:-$PRIMARY/prices.json}"
CACHE_CONV="${CACHE_CONV:-separate}"

[ -f "$PRICES" ] || { echo "missing $PRICES"; exit 1; }

SEL="${1:-all}"

# --- gather *.jsonl across all roots, filter by selector, sort unique ---
all=()
for _root in "${ROOTS[@]}"; do
  [ -d "$_root" ] || { echo "warn: root missing, skipped: $_root" >&2; continue; }
  while IFS= read -r _f; do [ -n "$_f" ] && all+=("$_f"); done \
    < <(find -L "$_root" -name '*.jsonl' -type f 2>/dev/null)
done
if [ ${#all[@]} -eq 0 ]; then echo "no ledger files found"; exit 0; fi
if [ "$SEL" != "all" ]; then
  filt=()
  for _f in "${all[@]}"; do [[ "$_f" == *"$SEL"* ]] && filt+=("$_f"); done
  [ ${#filt[@]} -eq 0 ] && { echo "no ledger files matching '$SEL'"; exit 0; }
  all=("${filt[@]}")
fi
mapfile -t files < <(printf '%s\n' "${all[@]}" | sort -u)
[ ${#files[@]} -gt 0 ] || { echo "no ledger files matching '$SEL'"; exit 0; }

PRICES_JSON=$(cat "$PRICES")

cat "${files[@]}" | jq -rs --argjson p "$PRICES_JSON" --arg sel "$SEL" --arg conv "$CACHE_CONV" '
  def noncached(r):
    if $conv == "included"
    then ([0, ((r.tokens.input//0) - (r.tokens.cacheRead//0))] | max)
    else (r.tokens.input//0) end;
  def cost(r): ($p[r.model] // {i:0,c:0,o:0}) as $q |
    ((noncached(r) * $q.i) + ((r.tokens.cacheRead//0) * $q.c) + ((r.tokens.output//0) * $q.o)) / 1e6;

  (group_by(.model) | map({
    model: .[0].model, calls: length,
    tok_in:(map(.tokens.input//0)|add),
    tok_out:(map(.tokens.output//0)|add),
    tok_cache:(map(.tokens.cacheRead//0)|add),
    api_usd:(map(cost(.))|add)
  })) as $by |

  ({calls:length,
    tok_in:(map(.tokens.input//0)|add),
    tok_out:(map(.tokens.output//0)|add),
    tok_cache:(map(.tokens.cacheRead//0)|add),
    api_usd:(map(cost(.))|add)}) as $t |

  ($t.tok_in + $t.tok_cache + $t.tok_out) as $all |
  ($t.api_usd / (($all / 1e6))) as $blend |

  "range:        \($sel)
conv:         \($conv)   (input \((if $conv=="included" then "includes" else "excludes" end)) cacheRead)
calls:         \($t.calls)
tokens in:     \($t.tok_in)
tokens out:    \($t.tok_out)
cache read:    \($t.tok_cache)
total tokens:  \($all)
API-equiv:     $\(($t.api_usd * 1000 | round) / 1000) USD
blended:       $\(($blend * 100 | round) / 100) / Mtok

by model:
\($by | map("  \(.model)  calls=\(.calls)  in=\(.tok_in)  out=\(.tok_out)  cache=\(.tok_cache)  api=$\((.api_usd * 1000 | round) / 1000)") | join("\n"))
"
'
