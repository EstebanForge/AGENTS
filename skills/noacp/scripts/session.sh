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
  prompt <file> "text"      Send prompt, get response
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
  grep -c '<orchestrator turn=' "$file" 2>/dev/null || echo 0
}

current_ts() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }
gen_id() { tr -dc 'a-f0-9' < /dev/urandom | head -c 8; }

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
  local file="${1:-}" prompt="${2:-}"
  [[ -z "$file" ]] && die "Usage: session.sh prompt <file> \"prompt text\""
  [[ -z "$prompt" ]] && die "Prompt text required"
  [[ -f "$file" ]] || die "Session file not found: $file"

  # Extract agent name from session tag (portable)
  local agent
  agent=$(attr_val "$file" "agent")
  [[ -z "$agent" ]] && die "No agent attribute in session file"

  local cfg
  cfg=$(agent_config "$agent")
  local cmd input_mode
  cmd=$(agent_field "$cfg" "command")
  input_mode=$(agent_field "$cfg" "input_mode")
  [[ "$input_mode" == "null" ]] && input_mode="flag"
  local timeout_val
  timeout_val=$(agent_field "$cfg" "timeout_default")
  [[ "$timeout_val" == "null" ]] && timeout_val=120

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
  sed -i '/^<\/session>$/d' "$file"
  printf '<orchestrator turn="%d" ts="%s">%s</orchestrator>\n' "$turn" "$ts" "$prompt_escaped" >> "$file"

  # Build agent invocation based on input_mode
  local response exit_code
  case "$input_mode" in
    flag)
      local print_flag
      print_flag=$(agent_field "$cfg" "print_flag")
      response=$(timeout "$timeout_val" "$cmd" "$print_flag" "$(cat "$file")" 2>/dev/null) && exit_code=0 || exit_code=$?
      ;;
    stdin)
      response=$(timeout "$timeout_val" "$cmd" < <(cat "$file") 2>/dev/null) && exit_code=0 || exit_code=$?
      ;;
    file)
      response=$(timeout "$timeout_val" "$cmd" "$file" 2>/dev/null) && exit_code=0 || exit_code=$?
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

  # Print agent response (unescaped for readability)
  echo "$response" | xml_unescape
}

cmd_history() {
  local file="${1:-}"
  [[ -z "$file" ]] && die "Usage: session.sh history <file>"
  [[ -f "$file" ]] || die "Session file not found: $file"

  echo "=== Session: $(basename "$file") ==="
  # Extract turn pairs using awk - handle multiline content between tags
  awk -v unescape_script='s/\&lt;/</g; s/\&gt;/>/g; s/\&amp;/\&/g' '
    /<orchestrator turn=/ {
      match($0, /turn="[0-9]+"/)
      t=substr($0, RSTART+6, RLENGTH-7)
      sub(/.*<orchestrator[^>]*>/, "")
      sub(/<\/orchestrator>.*/, "")
      unescape_script
      printf "\n--- Turn %s (orchestrator) ---\n%s\n", t, $0
      next
    }
    /<agent turn=/ {
      match($0, /turn="[0-9]+"/)
      t=substr($0, RSTART+6, RLENGTH-7)
      sub(/.*<agent[^>]*>/, "")
      sub(/<\/agent>.*/, "")
      unescape_script
      printf "--- Turn %s (agent) ---\n%s\n", t, $0
      next
    }
  ' "$file"
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
    turns=$(grep -c '<orchestrator turn=' "$f" 2>/dev/null || echo 0)
    closed=$(grep -c 'closed="true"' "$f" 2>/dev/null || echo 0)
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
  sed -i '/^<\/session>$/d' "$file"
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
  local closed
  closed=$(grep -c 'closed="true"' "$f" 2>/dev/null || echo 0)
  if [[ "$closed" -gt 0 ]]; then
    echo "WARN: session is closed"
  fi

  # Check turn monotonicity from orchestrator blocks
  local turns
  turns=$(grep -oE '<orchestrator turn="[0-9]+"' "$file" | grep -oE '[0-9]+' | sort -un | tr '\n' ' ')
  local expected=1
  for t in $turns; do
    [[ "$t" -eq "$expected" ]] || { echo "FAIL: expected turn $expected, got $t"; errors=$((errors+1)); }
    expected=$((expected + 1))
  done

  # Check paired blocks
  local orch_count agent_count
  orch_count=$(grep -c '<orchestrator turn=' "$file" 2>/dev/null || echo 0)
  agent_count=$(grep -c '<agent turn=' "$file" 2>/dev/null || echo 0)
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
