#!/usr/bin/env bash
# mc-push — push events into Mission Control via REST API
#
# Usage:
#   mc-push task     --board <name> --title "..." --description "..." [--priority high] [--field key=value ...]
#   mc-push comment  --task <task-id> --body "..."
#   mc-push list     --board <name>
#
# Boards: ops | approvals | decisions | knowledge
# Fields: complexity_score, model_used, token_count, source_agent, dispatched_by, run_id

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CONFIG="$ROOT/config/mission-control.yaml"
SECRETS="$HOME/.openclaw/secrets.json"

die() { echo "mc-push: $*" >&2; exit 1; }

[[ -f "$CONFIG" ]] || die "config not found: $CONFIG"
[[ -f "$SECRETS" ]] || die "secrets not found: $SECRETS"

# Resolve auth token from secrets.json
TOKEN=$(python3 -c "import json; d=json.load(open('$SECRETS')); print(d.get('MISSION_CONTROL_AUTH_TOKEN',''))")
[[ -n "$TOKEN" ]] || die "MISSION_CONTROL_AUTH_TOKEN missing from $SECRETS"

# Read config values via python (yaml dependency is risky in a shell script, use a simple parser)
read_cfg() {
  python3 -c "
import sys
with open('$CONFIG') as f:
    lines = f.readlines()
in_section = False
for line in lines:
    if line.rstrip().endswith(':') and not line.startswith(' '):
        in_section = line.strip().rstrip(':') == '$1'
        continue
    if in_section and line.startswith('  ') and ':' in line:
        k, v = line.strip().split(':', 1)
        v = v.strip().split('#', 1)[0].strip()
        if k == '$2':
            print(v)
            break
"
}

API_BASE=$(grep -E '^api_base:' "$CONFIG" | cut -d':' -f2- | xargs)

resolve_board() {
  read_cfg boards "$1"
}

resolve_field() {
  read_cfg custom_fields "$1"
}

# ─────────────────────────────────────────────────────────────
# Commands
# ─────────────────────────────────────────────────────────────

cmd_task() {
  local board="" title="" description="" priority="medium" agent="" status="inbox"
  declare -a fields=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --board)       board="$2"; shift 2 ;;
      --title)       title="$2"; shift 2 ;;
      --description) description="$2"; shift 2 ;;
      --priority)    priority="$2"; shift 2 ;;
      --agent)       agent="$2"; shift 2 ;;
      --status)      status="$2"; shift 2 ;;
      --field)       fields+=("$2"); shift 2 ;;
      *) die "unknown arg: $1" ;;
    esac
  done

  [[ -n "$board" ]] || die "--board required"
  [[ -n "$title" ]] || die "--title required"

  local board_id
  board_id=$(resolve_board "$board")
  [[ -n "$board_id" ]] || die "unknown board: $board"

  # Build custom_field_values dict keyed by field_key (not UUID).
  local cfv="{}"
  if [[ ${#fields[@]} -gt 0 ]]; then
    cfv=$(python3 -c "
import sys, json
integer_fields = {'complexity_score', 'token_count'}
out = {}
for entry in sys.argv[1:]:
    if '=' not in entry:
        continue
    k, v = entry.split('=', 1)
    if k in integer_fields:
        try: v = int(v)
        except: pass
    out[k] = v
print(json.dumps(out))
" "${fields[@]}")
  fi

  local body
  body=$(python3 -c "
import json, sys
body = {
    'board_id': '$board_id',
    'title': '''$title''',
    'description': '''${description:-}''',
    'status': '$status',
    'priority': '$priority',
    'custom_field_values': json.loads('$cfv'),
}
print(json.dumps(body))
")

  curl -sS -X POST "$API_BASE/boards/$board_id/tasks" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "$body"
  echo
}

cmd_comment() {
  local task_id="" body=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --task) task_id="$2"; shift 2 ;;
      --body) body="$2"; shift 2 ;;
      *) die "unknown arg: $1" ;;
    esac
  done
  [[ -n "$task_id" ]] || die "--task required"
  [[ -n "$body" ]] || die "--body required"

  # Comments live under a board; we need the board id for the task.
  # The Task itself will be looked up by ID via the generic tasks route.
  curl -sS -X POST "$API_BASE/tasks/$task_id/comments" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "$(python3 -c "import json; print(json.dumps({'body':'''$body'''}))")"
  echo
}

cmd_list() {
  local board=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --board) board="$2"; shift 2 ;;
      *) die "unknown arg: $1" ;;
    esac
  done
  [[ -n "$board" ]] || die "--board required"
  local board_id
  board_id=$(resolve_board "$board")
  curl -sS "$API_BASE/boards/$board_id/tasks" -H "Authorization: Bearer $TOKEN"
  echo
}

# ─────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────

[[ $# -gt 0 ]] || die "usage: mc-push {task|comment|list} [args]"

cmd="$1"; shift
case "$cmd" in
  task)    cmd_task "$@" ;;
  comment) cmd_comment "$@" ;;
  list)    cmd_list "$@" ;;
  *) die "unknown command: $cmd (valid: task, comment, list)" ;;
esac
