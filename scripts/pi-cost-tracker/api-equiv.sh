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
BYMONTH=0; EXPORTCSV=0; EXPORTPATH=""
case "$SEL" in
  --by-month|-m) BYMONTH=1; SEL="all" ;;                        # all history, per-month table
  --export-csv)  EXPORTCSV=1; SEL="all"; EXPORTPATH="${2:-}" ;;  # last 12 months -> CSV
esac

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

if [ "$EXPORTCSV" = 1 ]; then
  # export last 12 months (current + 11 prior), per-month, to one CSV
  END_MO=$(date +%Y-%m)
  START_MO=$(date -v-11m +%Y-%m 2>/dev/null || date -d '11 months ago' +%Y-%m)
  OUT="${EXPORTPATH:-./pi-cost-last12months-$(date +%Y%m%d).csv}"
  cat "${files[@]}" | jq -rs --argjson p "$PRICES_JSON" --arg conv "$CACHE_CONV" \
      --arg start "$START_MO" --arg end "$END_MO" '
    def monthof: (.ts/1000 | floor | todate)[0:7];
    def noncached(r):
      if $conv == "included"
      then ([0, ((r.tokens.input//0) - (r.tokens.cacheRead//0))] | max)
      else (r.tokens.input//0) end;
    def cost(r): ($p[r.model] // {i:0,c:0,o:0}) as $q |
      ((noncached(r) * $q.i) + ((r.tokens.cacheRead//0) * $q.c) + ((r.tokens.output//0) * $q.o)) / 1e6;
    (group_by(monthof) | sort_by(.[0]|monthof) | map({
      month:(.[0]|monthof), calls:length,
      ti:(map(.tokens.input//0)|add),
      to:(map(.tokens.output//0)|add),
      tc:(map(.tokens.cacheRead//0)|add),
      ap:(map(cost(.))|add)
    })) as $rows |
    [ $rows[] | select(.month >= $start and .month <= $end) ] as $w |
    "month,calls,tokens_in,tokens_out,cache_read,total_tokens,api_usd,blended_usd_per_Mtok",
    ( $w[] | [ .month, .calls, .ti, .to, .tc, (.ti+.to+.tc), .ap, (.ap/((.ti+.to+.tc)/1e6)) ] | @csv )
  ' > "$OUT"
  echo "wrote $OUT  ($(wc -l < "$OUT") lines; window $START_MO..$END_MO)"
  exit 0
fi

if [ "$BYMONTH" = 1 ]; then
  # all history, grouped per month (compact table + grand total)
  cat "${files[@]}" | jq -rs --argjson p "$PRICES_JSON" --arg conv "$CACHE_CONV" '
    def monthof: (.ts/1000 | floor | todate)[0:7];
    def noncached(r):
      if $conv == "included"
      then ([0, ((r.tokens.input//0) - (r.tokens.cacheRead//0))] | max)
      else (r.tokens.input//0) end;
    def cost(r): ($p[r.model] // {i:0,c:0,o:0}) as $q |
      ((noncached(r) * $q.i) + ((r.tokens.cacheRead//0) * $q.c) + ((r.tokens.output//0) * $q.o)) / 1e6;
    def rnd3(x): (x * 1000 | round) / 1000;
    def rnd2(x): (x * 100 | round) / 100;
    # Chilean number format: '.' thousands, ',' decimal.
    def group3: if length <= 3 then . else (.[0:-3] | group3) + "." + .[-3:] end;
    def chilean: (tostring | split(".")) as $p | ($p[0] | group3) + (if ($p|length) > 1 then "," + $p[1] else "" end);
    (group_by(monthof) | sort_by(.[0]|monthof) | map({
      month:(.[0]|monthof), calls:length,
      ti:(map(.tokens.input//0)|add),
      to:(map(.tokens.output//0)|add),
      tc:(map(.tokens.cacheRead//0)|add),
      ap:(map(cost(.))|add)
    })) as $rows |
    ($rows | map(.calls)|add) as $nc | ($rows | map(.ti)|add) as $ti |
    ($rows | map(.to)|add) as $to  | ($rows | map(.tc)|add) as $tc |
    ($rows | map(.ap)|add) as $tap |
    def row(a): a | map(tostring) | join("|");
    "month|calls|tokens_in|tokens_out|cache_read|total|api_usd|blended_Mtok",
    ( $rows[] | row([.month, (.calls|chilean), (.ti|chilean), (.to|chilean), (.tc|chilean), ((.ti+.to+.tc)|chilean), (rnd3(.ap)|chilean), (rnd2(.ap/((.ti+.to+.tc)/1e6))|chilean)]) ),
    row(["TOTAL", ($nc|chilean), ($ti|chilean), ($to|chilean), ($tc|chilean), (($ti+$to+$tc)|chilean), (rnd3($tap)|chilean), (rnd2($tap/(($ti+$to+$tc)/1e6))|chilean)])
  ' | { column -t -s'|' 2>/dev/null || cat; }
  exit 0
fi

cat "${files[@]}" | jq -rs --argjson p "$PRICES_JSON" --arg sel "$SEL" --arg conv "$CACHE_CONV" '
  # Chilean number format: '.' thousands, ',' decimal.
  def group3: if length <= 3 then . else (.[0:-3] | group3) + "." + .[-3:] end;
  def chilean: (tostring | split(".")) as $p | ($p[0] | group3) + (if ($p|length) > 1 then "," + $p[1] else "" end);

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
calls:         \($t.calls | chilean)
tokens in:     \($t.tok_in | chilean)
tokens out:    \($t.tok_out | chilean)
cache read:    \($t.tok_cache | chilean)
total tokens:  \($all | chilean)
API-equiv:     $\(($t.api_usd * 1000 | round) / 1000 | chilean) USD
blended:       $\(($blend * 100 | round) / 100 | chilean) / Mtok

by model:
\($by | map("  \(.model)  calls=\(.calls | chilean)  in=\(.tok_in | chilean)  out=\(.tok_out | chilean)  cache=\(.tok_cache | chilean)  api=$\((.api_usd * 1000 | round) / 1000 | chilean)") | join("\n"))
"
'
