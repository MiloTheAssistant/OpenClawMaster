#!/bin/bash
# gateway-watchdog.sh — Checks OpenClaw gateway health and restarts if down
# Runs every 5 minutes via launchd

HEALTH_URL="http://localhost:18789/health"
SERVICE="ai.openclaw.gateway"
LOG="/Volumes/BotCentral/Users/milo/.openclaw/logs/gateway-watchdog.log"
UID_VAL=$(id -u)

timestamp() { date '+%Y-%m-%dT%H:%M:%S%z'; }

response=$(curl -s --max-time 5 "$HEALTH_URL" 2>/dev/null)
status=$(echo "$response" | python3 -c "import json,sys; print(json.load(sys.stdin).get('status',''))" 2>/dev/null)

if [ "$status" = "live" ]; then
    # Healthy — silent exit
    exit 0
fi

# Not healthy — log and restart
echo "$(timestamp) [watchdog] Gateway not healthy (status='$status'). Attempting kickstart." >> "$LOG"
launchctl kickstart -k "gui/${UID_VAL}/${SERVICE}" >> "$LOG" 2>&1
sleep 10

# Verify recovery
response2=$(curl -s --max-time 5 "$HEALTH_URL" 2>/dev/null)
status2=$(echo "$response2" | python3 -c "import json,sys; print(json.load(sys.stdin).get('status',''))" 2>/dev/null)

if [ "$status2" = "live" ]; then
    echo "$(timestamp) [watchdog] Recovery successful — gateway is live." >> "$LOG"
else
    echo "$(timestamp) [watchdog] Recovery FAILED — gateway still not responding after kickstart." >> "$LOG"
fi
