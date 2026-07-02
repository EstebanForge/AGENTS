#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_FILE="$SCRIPT_DIR/agents.json"
NOACP_DIR="${NOACP_DIR:-/tmp/noacp}"

# Dependency check
for dep in jq timeout; do
  command -v "$dep" >/dev/null || { echo "ERROR: Required: $dep" >&2; exit 1; }
done

die() { echo "ERROR: $*" >&2; exit 1; }
usage() { cat <<'HELP'
Usage: session.sh <command> [args]

Commands:
  new <agent> [id]          Create session, print file path
  prompt <file> [opts] [text]  Send prompt, get response
    --timeout N             Override timeout (seconds)
    --file prompt.txt       Read prompt text from file
  history <file>            Print readable history
  list                      List active sessions
  close <file>              Close session
  delete <file>             Delete session file
  validate <file>           Validate session file

Env:
  NOACP_DIR   Session directory (default: /tmp/noacp)
HELP
exit 1; }

xml_escape() { sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'; }
xml_unescape() { sed 's/\&lt;/</g; s/\&gt;/>/g; s/\&amp;/\&/g'; }

# Portable in-place sed: BSD (macOS) needs empty suffix arg, GNU (Linux) does not
sed_inplace() {
  if sed --version >/dev/null 2>&1; then
    sed -i "$@"       # GNU sed
  else
    sed -i '' "$@"    # BSD sed (macOS)
  fi
}

# Resolve agent config from agents.json
agent_config() {
  local agent="$1"
  local cfg
  cfg=$(jq -r --arg a "$agent" '.[$a]' "$AGENTS_FILE" 2>/dev/null) \
    || die "Agent '$agent' not found in $AGENTS_FILE"
  [[ "$cfg" == "null" ]] && die "Agent '$agent' not found in $AGENTS_FILE"
  echo "$cfg"
}

agent_field() {
  local cfg="$1" field="$2"
  echo "$cfg" | jq -r ".$field"
}

current_turn() {
  local file="$1"
  local count=0
  count=$(grep -c '<orchestrator turn=' "$file" 2>/dev/null) || true
  echo "$count"
}

current_ts() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }
gen_id() { LC_ALL=C tr -dc 'a-f0-9' < /dev/urandom | head -c 8; }

# Portably extract attribute value (no grep -P)
attr_val() {
  local file="$1" attr="$2"
  sed -n "s/.*${attr}=\"\([^\"]*\)\".*/\1/p" "$file" | head -1
}

cmd_new() {
  local agent="${1:-}" id="${2:-$(gen_id)}"
  [[ -z "$agent" ]] && die "Usage: session.sh new <agent> [id]"
  [[ "$id" =~ ^[a-zA-Z0-9_-]+$ ]] || die "Invalid id: alphanumeric/hyphens/underscores only"
  # Validate agent exists
  agent_config "$agent" > /dev/null

  mkdir -p "$NOACP_DIR"
  local file="$NOACP_DIR/${id}.xml"
  [[ -f "$file" ]] && die "Session $id already exists: $file"

  cat > "$file" <<EOF
<session agent="${agent}" id="${id}" created="$(current_ts)">
</session>
EOF
  echo "$file"
}

cmd_prompt() {
  local file="" prompt=""
  local timeout_override=""
  local prompt_from_file=""

  # Parse options (interleaved: options and positionals in any order)
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --timeout)
        timeout_override="$2"; shift 2 ;;
      --file)
        prompt_from_file="$2"; shift 2 ;;
      -*)
        die "Unknown option: $1" ;;
      *)
        if [[ -z "$file" ]]; then
          file="$1"
        elif [[ -z "$prompt" ]]; then
          prompt="$1"
        fi
        shift ;;
    esac
  done

  [[ -z "$file" ]] && die "Usage: session.sh prompt <file> [--timeout N] [--file prompt.txt] [\"prompt text\"]"
  [[ -z "$prompt" && -z "$prompt_from_file" ]] && die "Prompt text required (arg or --file)"
  [[ -f "$file" ]] || die "Session file not found: $file"

  # Extract agent name from session tag (portable)
  local agent
  agent=$(attr_val "$file" "agent")
  [[ -z "$agent" ]] && die "No agent attribute in session file"

  # Read prompt from file if specified
  if [[ -n "$prompt_from_file" ]]; then
    [[ -f "$prompt_from_file" ]] || die "Prompt file not found: $prompt_from_file"
    prompt=$(cat "$prompt_from_file")
  fi

  local cfg
  cfg=$(agent_config "$agent")
  local cmd input_mode
  cmd=$(agent_field "$cfg" "command")
  input_mode=$(agent_field "$cfg" "input_mode")
  [[ "$input_mode" == "null" ]] && input_mode="flag"
  local timeout_val
  timeout_val=$(agent_field "$cfg" "timeout_default")
  [[ "$timeout_val" == "null" ]] && timeout_val=120
  # Per-call timeout override takes precedence
  [[ -n "$timeout_override" ]] && timeout_val="$timeout_override"

  # Calculate next turn
  local turn
  turn=$(current_turn "$file")
  turn=$((turn + 1))

  # Escape prompt for XML
  local prompt_escaped
  prompt_escaped=$(echo "$prompt" | xml_escape)

  local ts
  ts=$(current_ts)

  # Strip-and-append: remove </session>, append orchestrator block
  # This avoids all sed metacharacter issues
  sed_inplace '/^<\/session>$/d' "$file"
  printf '<orchestrator turn="%d" ts="%s">%s</orchestrator>\n' "$turn" "$ts" "$prompt_escaped" >> "$file"

  # Ensure session file is always valid even if agent crashes/times out
  cleanup_session() {
    if ! tail -1 "$file" | grep -q '</session>' 2>/dev/null; then
      printf '</session>\n' >> "$file"
    fi
  }
  trap cleanup_session EXIT

  # Build agent invocation based on input_mode
  local response exit_code
  # Optional --model flag from agents.json (e.g. agy model aliases)
  local model
  model=$(agent_field "$cfg" "model")
  local model_args=()
  if [[ "$model" != "null" && -n "$model" ]]; then
    model_args=(--model "$model")
  fi
  # For flag mode: check payload size against ARG_MAX
  # Linux ARG_MAX is typically 2MB; use conservative 1MB threshold
  if [[ "$input_mode" == "flag" ]]; then
    local payload_size
    payload_size=$(wc -c < "$file")
    if [[ "$payload_size" -gt 1048576 ]]; then
      die "Session file is ${payload_size} bytes, exceeds 1MB safe limit for flag input_mode. Use stdin or file input_mode instead, or shorten session history."
    fi
  fi
  case "$input_mode" in
    flag)
      local print_flag
      print_flag=$(agent_field "$cfg" "print_flag")
      response=$(timeout "$timeout_val" "$cmd" "${model_args[@]}" "$print_flag" "$(cat "$file")" 2>/dev/null) && exit_code=0 || exit_code=$?
      ;;
    stdin)
      response=$(timeout "$timeout_val" "$cmd" "${model_args[@]}" < <(cat "$file") 2>/dev/null) && exit_code=0 || exit_code=$?
      ;;
    file)
      response=$(timeout "$timeout_val" "$cmd" "${model_args[@]}" "$file" 2>/dev/null) && exit_code=0 || exit_code=$?
      ;;
    *)
      die "Unknown input_mode '$input_mode' for agent '$agent'"
      ;;
  esac

  if [[ $exit_code -eq 124 ]]; then
    die "Agent '$cmd' timed out after ${timeout_val}s"
  elif [[ $exit_code -ne 0 ]]; then
    die "Agent '$cmd' failed (exit $exit_code)"
  fi

  # Escape response for XML
  local response_escaped
  response_escaped=$(echo "$response" | xml_escape)

  # Append agent block and closing tag
  ts=$(current_ts)
  printf '<agent turn="%d" ts="%s">%s</agent>\n</session>\n' "$turn" "$ts" "$response_escaped" >> "$file"

  # Clear cleanup trap on success
  trap - EXIT

  # Print agent response (unescaped for readability)
  echo "$response" | xml_unescape
}

cmd_history() {
  local file="${1:-}"
  [[ -z "$file" ]] && die "Usage: session.sh history <file>"
  [[ -f "$file" ]] || die "Session file not found: $file"

  echo "=== Session: $(basename "$file") ==="
  awk '
    /<orchestrator turn="/ {
      match($0, /turn="[0-9]+"/)
      t=substr($0, RSTART+6, RLENGTH-7)
      printf "\n--- Turn %s (orchestrator) ---\n", t
      sub(/.*<orchestrator[^>]*>/, "")
      in_orch=1
    }
    in_orch {
      if (sub(/<\/orchestrator>.*/, "")) {
        print
        in_orch=0
      } else {
        print
      }
      next
    }
    /<agent turn="/ {
      match($0, /turn="[0-9]+"/)
      t=substr($0, RSTART+6, RLENGTH-7)
      printf "--- Turn %s (agent) ---\n", t
      sub(/.*<agent[^>]*>/, "")
      in_agent=1
    }
    in_agent {
      if (sub(/<\/agent>.*/, "")) {
        print
        in_agent=0
      } else {
        print
      }
      next
    }
  ' "$file" | xml_unescape
  echo ""
  echo "=== End ==="
}

cmd_list() {
  mkdir -p "$NOACP_DIR"
  local count=0
  for f in "$NOACP_DIR"/*.xml; do
    [[ -f "$f" ]] || continue
    local agent id turns closed
    agent=$(attr_val "$f" "agent")
    id=$(attr_val "$f" "id")
    turns=$(grep -c '<orchestrator turn=' "$f" 2>/dev/null) || turns=0
    closed=$(grep -c 'closed="true"' "$f" 2>/dev/null) || closed=0
    local status="open"
    [[ "$closed" -gt 0 ]] && status="closed"
    printf "%-20s agent=%-8s turns=%-3s %-7s %s\n" "$(basename "$f")" "${agent:-?}" "$turns" "$status" "$f"
    count=$((count + 1))
  done
  [[ $count -eq 0 ]] && echo "No sessions in $NOACP_DIR"
}

cmd_close() {
  local file="${1:-}"
  [[ -z "$file" ]] && die "Usage: session.sh close <file>"
  [[ -f "$file" ]] || die "Session file not found: $file"

  # Strip-and-append closed metadata
  local ts
  ts=$(current_ts)
  sed_inplace '/^<\/session>$/d' "$file"
  printf '<meta closed="true" closedAt="%s"/>\n</session>\n' "$ts" >> "$file"
  echo "Closed: $file"
}

cmd_delete() {
  local file="${1:-}"
  [[ -z "$file" ]] && die "Usage: session.sh delete <file>"
  [[ -f "$file" ]] || die "Session file not found: $file"
  rm -f "$file"
  echo "Deleted: $file"
}

cmd_validate() {
  local file="${1:-}"
  [[ -z "$file" ]] && die "Usage: session.sh validate <file>"
  [[ -f "$file" ]] || die "Session file not found: $file"

  local errors=0

  # Check session tags
  head -1 "$file" | grep -q '<session ' || { echo "FAIL: missing opening <session> tag"; errors=$((errors+1)); }
  tail -1 "$file" | grep -q '</session>' || { echo "FAIL: missing closing </session> tag"; errors=$((errors+1)); }

  # Check agent attribute
  local agent
  agent=$(attr_val "$file" "agent")
  [[ -z "$agent" ]] && { echo "FAIL: no agent attribute"; errors=$((errors+1)); }

  # Check agent exists in registry
  if [[ -n "$agent" ]]; then
    agent_config "$agent" > /dev/null 2>&1 || { echo "FAIL: agent '$agent' not in registry"; errors=$((errors+1)); }
  fi

  # Check closed status
  local closed=0
  closed=$(grep -c 'closed="true"' "$file" 2>/dev/null) || true
  if [[ "$closed" -gt 0 ]]; then
    echo "WARN: session is closed"
  fi

  # Check turn monotonicity from orchestrator blocks
  local turns
  turns=$(grep -oE '<orchestrator turn="[0-9]+"' "$file" | grep -oE '[0-9]+' | sort -un | tr '\n' ' ') || turns=""
  local expected=1
  for t in $turns; do
    [[ "$t" -eq "$expected" ]] || { echo "FAIL: expected turn $expected, got $t"; errors=$((errors+1)); }
    expected=$((expected + 1))
  done

  # Check paired blocks
  local orch_count=0 agent_count=0
  orch_count=$(grep -c '<orchestrator turn=' "$file" 2>/dev/null) || true
  agent_count=$(grep -c '<agent turn=' "$file" 2>/dev/null) || true
  # Last turn may be in-flight (orchestrator without agent response yet)
  if [[ "$agent_count" -lt $((orch_count - 1)) ]]; then
    echo "FAIL: unpaired blocks ($orch_count orchestrator, $agent_count agent)"
    errors=$((errors+1))
  fi

  if [[ $errors -eq 0 ]]; then
    echo "OK: $file is valid (agent=$agent, turns=$((expected - 1)))"
  else
    echo "FAIL: $errors error(s)"
  fi
  return "$errors"
}

# Main dispatch
[[ $# -lt 1 ]] && usage
cmd="$1"; shift
case "$cmd" in
  new)      cmd_new "$@" ;;
  prompt)   cmd_prompt "$@" ;;
  history)  cmd_history "$@" ;;
  list)     cmd_list ;;
  close)    cmd_close "$@" ;;
  delete)   cmd_delete "$@" ;;
  validate) cmd_validate "$@" ;;
  *)        die "Unknown command: $cmd. Run 'session.sh' for usage." ;;
esac
