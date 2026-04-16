#!/bin/bash
# Heartbeat — Mission Control health check
# Outputs nothing (clean) or one issue per line (problems found)

issues=()

# 1. State files present and non-empty
for f in \
    "/Volumes/BotCentral/Users/milo/.openclaw/workspace/mission-control/state/Active_Projects.md" \
    "/Volumes/BotCentral/Users/milo/.openclaw/workspace/mission-control/state/Artifacts_Index.md" \
    "/Volumes/BotCentral/Users/milo/.openclaw/workspace/mission-control/state/Decision_Log.md"; do
    name=$(basename "$f")
    [ ! -f "$f" ] && issues+=("$name missing") && continue
    [ ! -s "$f" ] && issues+=("$name empty")
done

# 2. Blocked projects
if grep -q "status: blocked" "/Volumes/BotCentral/Users/milo/.openclaw/workspace/mission-control/state/Active_Projects.md" 2>/dev/null; then
    issues+=("Blocked project in Active_Projects.md")
fi

# 3. Gateway reachable
gateway=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:18789/health)
[ "$gateway" -ne 200 ] && issues+=("Gateway down: HTTP $gateway")

# 4. Ollama reachable
ollama=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:11434/api/tags)
[ "$ollama" -ne 200 ] && issues+=("Ollama down: HTTP $ollama")

# 5. Repeated agent failures in last 24h
error_count=$(find /Volumes/BotCentral/Users/milo/.openclaw/workspace/mission-control/state/memory/logs -name "*.md" -mtime -1 -exec grep -h "Agent failed" {} \; 2>/dev/null | wc -l | tr -d ' ')
[ "$error_count" -ge 3 ] && issues+=("3+ Agent failed errors in 24h (check logs)")

# Output
if [ ${#issues[@]} -eq 0 ]; then
    echo "HEARTBEAT_OK"
else
    printf '%s\n' "${issues[@]}"
fi
