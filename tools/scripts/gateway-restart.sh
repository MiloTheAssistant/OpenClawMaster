#!/usr/bin/env bash
# Gateway restart — clean unload/load cycle with health verification
set -euo pipefail

PLIST="$HOME/Library/LaunchAgents/ai.openclaw.gateway.plist"
LABEL="ai.openclaw.gateway"

echo "[gateway] Stopping..."
launchctl unload -F "$PLIST" 2>/dev/null || true
sleep 2

echo "[gateway] Starting..."
launchctl load -F "$PLIST"
sleep 4

echo "[gateway] Checking health..."
HEALTH=$(openclaw gateway call health --json 2>/dev/null | grep -o '"ok":[a-z]*' | head -1)

if [[ "$HEALTH" == '"ok":true' ]]; then
  AGENT_COUNT=$(openclaw gateway call health --json 2>/dev/null | python3 -c "
import sys, json
raw = sys.stdin.read()
start = raw.find('{')
if start >= 0:
    data = json.loads(raw[start:])
    print(len(data.get('agents', [])))
else:
    print(0)
" 2>/dev/null)
  echo "[gateway] Healthy — $AGENT_COUNT agents loaded"
else
  echo "[gateway] WARNING: health check failed"
  echo "[gateway] Check logs: tail -20 ~/.openclaw/logs/gateway.err.log"
  exit 1
fi

# Check for MCP failures
MCP_FAILS=$(tail -30 "$HOME/.openclaw/logs/gateway.err.log" 2>/dev/null | grep -c "failed to start" || true)
if [[ "$MCP_FAILS" -gt 0 ]]; then
  echo "[gateway] WARNING: $MCP_FAILS MCP server(s) failed to start"
  tail -30 "$HOME/.openclaw/logs/gateway.err.log" | grep "failed to start"
fi
