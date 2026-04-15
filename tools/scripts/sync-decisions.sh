#!/usr/bin/env bash
# sync-decisions — sync new rows from state/Decision_Log.md → Mission Control Decisions board.
#
# Runs every 5 minutes via openclaw cron. Tracks the last synced decision ID
# in ~/.openclaw/state/decisions-sync.json so it only pushes new entries.
#
# Usage:
#   tools/scripts/sync-decisions.sh          # normal run
#   tools/scripts/sync-decisions.sh --reset  # re-sync from beginning (debug)

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
LOG="$ROOT/state/Decision_Log.md"
STATE_DIR="$HOME/.openclaw/state"
STATE_FILE="$STATE_DIR/decisions-sync.json"
MC_PUSH="$ROOT/tools/scripts/mc-push.sh"

mkdir -p "$STATE_DIR"

# Handle --reset
if [[ "${1:-}" == "--reset" ]]; then
  rm -f "$STATE_FILE"
  echo "reset: cleared $STATE_FILE"
fi

# Read last synced ID
LAST_ID=""
if [[ -f "$STATE_FILE" ]]; then
  LAST_ID=$(python3 -c "import json; print(json.load(open('$STATE_FILE')).get('last_id',''))")
fi

# Parse Decision_Log.md and find new rows
python3 << PYEOF > /tmp/sync-decisions-new.json
import re, json, sys

LAST_ID = "$LAST_ID"
log_path = "$LOG"

with open(log_path) as f:
    lines = f.readlines()

new_entries = []
seen_last = (LAST_ID == "")  # if no checkpoint, sync everything

for line in lines:
    line = line.rstrip()
    if not line.startswith("| DEC-"):
        continue
    # Parse row: | DEC-001 | 2026-04-10 | Decision text | Made By | Context |
    parts = [p.strip() for p in line.strip("|").split("|")]
    if len(parts) < 5:
        continue
    dec_id, date, decision, made_by, context = parts[0], parts[1], parts[2], parts[3], parts[4]

    if seen_last:
        new_entries.append({
            "id": dec_id,
            "date": date,
            "decision": decision,
            "made_by": made_by,
            "context": context,
        })
    elif dec_id == LAST_ID:
        seen_last = True

json.dump(new_entries, sys.stdout)
PYEOF

NEW_COUNT=$(python3 -c "import json; print(len(json.load(open('/tmp/sync-decisions-new.json'))))")

if [[ "$NEW_COUNT" == "0" ]]; then
  echo "sync-decisions: no new entries"
  exit 0
fi

echo "sync-decisions: pushing $NEW_COUNT new entries"

# Push each new entry as a task on the Decisions board
python3 << PYEOF
import json, subprocess
entries = json.load(open('/tmp/sync-decisions-new.json'))
for e in entries:
    title = f"{e['id']}: {e['decision'][:80]}"
    description = f"**Decision:** {e['decision']}\n\n**Date:** {e['date']}\n**Made by:** {e['made_by']}\n**Context:** {e['context']}"
    subprocess.run([
        "$MC_PUSH", "task",
        "--board", "decisions",
        "--title", title,
        "--description", description,
        "--priority", "low",
        "--status", "done",
        "--field", f"source_agent={e['made_by'].lower()}",
        "--field", f"run_id={e['id']}",
    ], check=False, capture_output=True)
    print(f"  pushed {e['id']}")

# Save new checkpoint (last entry's id)
if entries:
    with open("$STATE_FILE", 'w') as f:
        json.dump({"last_id": entries[-1]["id"]}, f)
PYEOF

rm -f /tmp/sync-decisions-new.json
echo "sync-decisions: done"
