#!/usr/bin/env bash
# monthly-rollup.sh — archive one month of pi cost-counter ledger into a summary file.
#
# Unified: reads MULTIPLE ledger roots (host + construct sandbox by default) and
#          rolls the COMBINED month into the archive. Ledgers are disjoint, so the
#          union is the true total. No dedup needed.
#
# Writes (the historical archive: 12 files/year + a trend CSV), on the PRIMARY
# root only:
#   <primary>/monthly/YYYY-MM.json   full month detail: summary + by_model + by_day
#   <primary>/monthly/history.csv    one row per month (trend view); upserted
#
# Idempotent: re-running overwrites the month file and upserts the CSV row.
#
# Ledger roots (first match wins): see api-equiv.sh header (PI_COST_LEDGER >
# PI_COST_LEDGERS > roots.conf > default). The FIRST root is "primary".
#
# Prices: read from prices.json (shared with api-equiv.sh). cacheWrite = 0.
# Cache convention: CACHE_CONV=separate|included (default separate), same as api-equiv.sh.
#
# usage: monthly-rollup.sh [YYYY/MM]
#   no arg   -> previous month   (cron default)
#   2026/06  -> that month
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

MONTH="${1:-}"
if [ -z "$MONTH" ]; then
  MONTH=$(date -d 'last month' '+%Y/%m' 2>/dev/null || date -v-1m '+%Y/%m')
fi
OUT_TAG="${MONTH//\//-}"   # 2026/06 -> 2026-06

OUTDIR="$PRIMARY/monthly"
mkdir -p "$OUTDIR"
OUTJSON="$OUTDIR/$OUT_TAG.json"
HISTCSV="$OUTDIR/history.csv"

# --- gather *.jsonl across all roots, filter by month, sort unique ---
all=()
for _root in "${ROOTS[@]}"; do
  [ -d "$_root" ] || { echo "warn: root missing, skipped: $_root" >&2; continue; }
  while IFS= read -r _f; do [ -n "$_f" ] && all+=("$_f"); done \
    < <(find -L "$_root" -name '*.jsonl' -type f 2>/dev/null)
done
if [ ${#all[@]} -eq 0 ]; then
  echo "no ledger files for $MONTH; nothing to roll up."
  exit 0
fi
filt=()
for _f in "${all[@]}"; do [[ "$_f" == *"$MONTH"* ]] && filt+=("$_f"); done
if [ ${#filt[@]} -eq 0 ]; then
  echo "no ledger files for $MONTH; nothing to roll up."
  exit 0
fi
mapfile -t files < <(printf '%s\n' "${filt[@]}" | sort -u)

PRICES_JSON=$(cat "$PRICES")

cat "${files[@]}" | jq -s --argjson p "$PRICES_JSON" --arg month "$OUT_TAG" --arg conv "$CACHE_CONV" '
  def dayof: (.ts/1000 | floor | todate)[0:10];
  def noncached(r):
    if $conv == "included"
    then ([0, ((r.tokens.input//0) - (r.tokens.cacheRead//0))] | max)
    else (r.tokens.input//0) end;
  def cost(r): ($p[r.model] // {i:0,c:0,o:0}) as $q |
    ((noncached(r) * $q.i) + ((r.tokens.cacheRead//0) * $q.c) + ((r.tokens.output//0) * $q.o)) / 1e6;

  {
    month: $month,
    cache_convention: $conv,
    prices_note: "GLM API per 1M tokens from prices.json; cacheWrite=0",
    summary: {
      calls:    length,
      tok_in:   (map(.tokens.input//0)|add),
      tok_out:  (map(.tokens.output//0)|add),
      tok_cache:(map(.tokens.cacheRead//0)|add),
      api_usd:  (map(cost(.))|add)
    },
    by_model: (group_by(.model) | map({
      model: .[0].model,
      calls: length,
      tok_in:(map(.tokens.input//0)|add),
      tok_out:(map(.tokens.output//0)|add),
      tok_cache:(map(.tokens.cacheRead//0)|add),
      api_usd:(map(cost(.))|add)
    })),
    by_day: (group_by(dayof) | map({
      day: (.[0] | dayof),
      calls: length,
      tok_in:(map(.tokens.input//0)|add),
      tok_out:(map(.tokens.output//0)|add),
      tok_cache:(map(.tokens.cacheRead//0)|add),
      api_usd:(map(cost(.))|add)
    }))
  }
' > "$OUTJSON"
echo "wrote $OUTJSON"

# upsert history.csv (one row per month)
HEADER="month,calls,tok_in,tok_out,tok_cache,api_usd,blended_usd_per_Mtok"
[ -f "$HISTCSV" ] || echo "$HEADER" > "$HISTCSV"

ROW=$(jq -r '
  .summary as $s |
  (($s.tok_in + $s.tok_cache + $s.tok_out) / 1e6) as $mtok |
  ($s.api_usd / $mtok) as $blend |
  [.month, $s.calls, $s.tok_in, $s.tok_out, $s.tok_cache, $s.api_usd, $blend] | @csv
' "$OUTJSON")

grep -v "^\"$OUT_TAG\"," "$HISTCSV" > "$HISTCSV.tmp" 2>/dev/null || true
mv "$HISTCSV.tmp" "$HISTCSV"
echo "$ROW" >> "$HISTCSV"
echo "upserted $OUT_TAG in $HISTCSV"
