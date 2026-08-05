#!/usr/bin/env bash
# mmdc-verify.sh — validate Mermaid diagrams by rendering them with mmdc.
# Render success == valid. Exits non-zero if any diagram fails to render.
#
# Handles:
#   - standalone *.mmd files
#   - ```mermaid fenced blocks inside *.md / *.mdoc (extracted to temp, with
#     source-line tracking so parse-error lines map back to the real file)
#   - the container sandbox crash, via an auto-created no-sandbox puppeteer config
#
# Usage:
#   mmdc-verify.sh [path...]        # files or dirs; default: cwd
#   MMDC_PUPPETEER_CONFIG=/p.json mmdc-verify.sh ...   # your own puppeteer config
#
# Output, one line per diagram:
#   PASS  <source>
#   FAIL  <source>:<line>  <parse error>
# Nothing is written to the repo; temp files live under $TMPDIR (/tmp).
#
# Exit codes: 0 all render-clean | 1 render-broken | 2 setup/sandbox | 127 mmdc missing

set -euo pipefail

command -v mmdc >/dev/null 2>&1 || { echo "mmdc not found. npm i -g @mermaid-js/mermaid-cli" >&2; exit 127; }

paths=("$@")
[[ ${#paths[@]} -eq 0 ]] && paths=(".")

work="$(mktemp -d -t mmdc-verify.XXXXXX)"
trap 'rm -rf "$work"' EXIT

# Puppeteer config (no-sandbox for containers). Override via env.
cfg="${MMDC_PUPPETEER_CONFIG:-}"
if [[ -z "$cfg" ]]; then
  cfg="$work/puppeteer.json"
  printf '{"args":["--no-sandbox","--disable-setuid-sandbox","--disable-dev-shm-usage"]}' > "$cfg"
fi
mkdir -p "$work/out"

# Preflight: prove mmdc can launch at all (catches sandbox/container issues
# before they masquerade as broken diagrams).
printf 'graph TD\n  A-->B\n' > "$work/preflight.mmd"
if ! mmdc -i "$work/preflight.mmd" -o "$work/preflight.svg" -p "$cfg" -q 2>"$work/preflight.err"; then
  echo "mmdc could not render a known-good diagram — setup/sandbox problem, not a diagram problem:" >&2
  sed 's/^/    /' "$work/preflight.err" >&2
  echo "    fix: pass a puppeteer config with --no-sandbox (see MMDC_PUPPETEER_CONFIG)." >&2
  exit 2
fi

# Collect candidate files. Handle file vs dir paths: fd only searches dirs,
# so file args are added directly by extension, dir args are walked with fd.
mmd_files=()
md_files=()
for p in "${paths[@]}"; do
  if [[ -f "$p" ]]; then
    case "$p" in
      *.mmd)  mmd_files+=("$p") ;;
      *.md)   md_files+=("$p") ;;
      *.mdoc) md_files+=("$p") ;;
    esac
  elif [[ -d "$p" ]]; then
    while IFS= read -r f; do mmd_files+=("$f"); done < <(fd -e mmd  . "$p" --type f 2>/dev/null || true)
    while IFS= read -r f; do md_files+=("$f");  done < <(fd -e md   . "$p" --type f 2>/dev/null || true)
    while IFS= read -r f; do md_files+=("$f");  done < <(fd -e mdoc . "$p" --type f 2>/dev/null || true)
  else
    echo "path not found: $p" >&2
  fi
done

# Keep only docs that actually contain a mermaid fence.
md_with_fences=()
for f in "${md_files[@]+"${md_files[@]}"}"; do
  rg -q '^```mermaid' "$f" 2>/dev/null && md_with_fences+=("$f")
done

# manifest: tempfile<TAB>source<TAB>fence_lineno
manifest="$work/manifest.tsv"
: > "$manifest"

# Extract each fenced block, recording the source line of the opening fence.
for f in "${md_with_fences[@]+"${md_with_fences[@]}"}"; do
  awk -v outdir="$work" -v src="$f" -v manifest="$manifest" '
    /^```mermaid/ {
      inblock=1; fence_line=NR; idx++;
      sane = src; gsub(/[^a-zA-Z0-9]/, "_", sane);
      outfile=sprintf("%s/%s__%d.mmd", outdir, sane, idx);
      next
    }
    /^```/ && inblock { inblock=0; print outfile "\t" src "\t" fence_line > manifest; next }
    inblock { print > outfile }
  ' "$f"
done

# Standalone .mmd files: copy in, fence offset = 0 (mmdc's line N is already
# absolute; the offset is only needed for fenced blocks).
i=0
for f in "${mmd_files[@]+"${mmd_files[@]}"}"; do
  cp "$f" "$work/mmd_$i.mmd"
  printf '%s\t%s\t0\n' "$work/mmd_$i.mmd" "$f" >> "$manifest"
  i=$((i + 1))
done

if [[ ! -s "$manifest" ]]; then
  echo "no mermaid diagrams found under: ${paths[*]}" >&2
  exit 0
fi

fail=0
while IFS=$'\t' read -r tmp src fence; do
  [[ -n "$tmp" ]] || continue
  err="$work/err"
  if mmdc -i "$tmp" -o "$work/out/$(basename "${tmp%.mmd}").svg" -p "$cfg" -q >/dev/null 2>"$err"; then
    printf 'PASS  %s\n' "$src"
    continue
  fi
  ln="$(grep -oE 'on line [0-9]+' "$err" | head -1 | grep -oE '[0-9]+' || true)"
  src_line="?"
  [[ -n "$ln" ]] && src_line=$((fence + ln))
  msg="$(grep 'Parse error' "$err" | head -1 || true)"
  [[ -z "$msg" ]] && msg="$(head -1 "$err")"
  printf 'FAIL  %s:%s  %s\n' "$src" "$src_line" "$msg"
  fail=1
done < "$manifest"

exit "$fail"
