#!/usr/bin/env bash
# Gateway restart — clean unload/load cycle with health verification
set -euo pipefail

PLIST="$HOME/Library/LaunchAgents/ai.openclaw.gateway.plist"
LABEL="ai.openclaw.gateway"

# Phase 5 canonical agent set — only these folders are kept
# Any other folder (mc-*, lead-*, retired agents) is ephemeral and pruned on restart
CANONICAL_AGENTS=("main" "sagan" "neo" "hermes" "sentinel" "cortana" "cornelius")

echo "[gateway] Stopping..."
launchctl unload -F "$PLIST" 2>/dev/null || true
# Force-kill anything still holding the port
lsof -ti :18789 | xargs kill -9 2>/dev/null || true
sleep 2

echo "[gateway] Pruning stale agent folders..."
# Preserve canonical agents (Phase 5) AND MC-managed dynamic agents:
#   - mc-gateway-*  → MC gateway system agent, auto-registered
#   - lead-*        → MC board lead agents, created per board
AGENTS_DIR="$HOME/.openclaw/agents"
PRUNED=0
for folder in "$AGENTS_DIR"/*/; do
  name=$(basename "$folder")
  keep=false
  # Check canonical list
  for canonical in "${CANONICAL_AGENTS[@]}"; do
    [[ "$name" == "$canonical" ]] && keep=true && break
  done
  # Preserve MC-managed dynamic agents
  [[ "$name" == mc-gateway-* || "$name" == lead-* ]] && keep=true
  if [[ "$keep" == "false" ]]; then
    echo "[gateway]   removing stale: $name"
    rm -rf "$folder"
    ((PRUNED++)) || true
  fi
done
[[ "$PRUNED" -eq 0 ]] && echo "[gateway]   agent folders clean" || echo "[gateway]   pruned $PRUNED stale folder(s)"

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
