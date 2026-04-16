#!/usr/bin/env bash
# Model health check — verify local models are available and cloud models respond
set -euo pipefail

echo "=== Local Ollama Models ==="
echo ""

# Check Ollama is running
if ! curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then
  echo "ERROR: Ollama is not running at localhost:11434"
  exit 1
fi

# List local models with sizes
curl -s http://localhost:11434/api/tags | python3 -c "
import sys, json
data = json.load(sys.stdin)
models = sorted(data.get('models', []), key=lambda x: x['size'], reverse=True)
for m in models:
    size_gb = m['size'] / (1024**3)
    tag = 'cloud' if size_gb < 0.01 else f'{size_gb:.1f}GB'
    print(f'  {m[\"name\"]:40s} {tag}')
print(f'\n  Total: {len(models)} models')
"

# Check currently loaded models
echo ""
echo "=== Currently Loaded ==="
LOADED=$(curl -s http://localhost:11434/api/ps | python3 -c "
import sys, json
data = json.load(sys.stdin)
models = data.get('models', [])
if not models:
    print('  (none)')
else:
    for m in models:
        vram = m.get('size_vram', 0) / (1024**3)
        print(f'  {m[\"name\"]:40s} {vram:.1f}GB VRAM')
" 2>/dev/null)
echo "$LOADED"

# Check gateway health
echo ""
echo "=== Gateway Agent Status ==="
openclaw gateway call health --json 2>/dev/null | python3 -c "
import sys, json
raw = sys.stdin.read()
start = raw.find('{')
if start >= 0:
    data = json.loads(raw[start:])
    agents = data.get('agents', [])
    for a in agents:
        name = a.get('agentId', '?')
        sessions = a.get('sessions', {}).get('count', 0)
        print(f'  {name:15s} sessions={sessions}')
    print(f'\n  Total: {len(agents)} agents, gateway ok={data.get(\"ok\")}')
else:
    print('  ERROR: could not parse gateway response')
" 2>/dev/null || echo "  ERROR: gateway not reachable"

# Quick cloud model ping
echo ""
echo "=== Cloud Model Ping ==="
for model in "glm-5.1:cloud" "minimax-m2.7:cloud"; do
  START=$(python3 -c "import time; print(int(time.time()*1000))")
  RESULT=$(echo "Reply OK" | ollama run "$model" 2>/dev/null | head -1)
  END=$(python3 -c "import time; print(int(time.time()*1000))")
  ELAPSED=$((END - START))
  if [[ -n "$RESULT" ]]; then
    echo "  $model — OK (${ELAPSED}ms)"
  else
    echo "  $model — FAILED"
  fi
done
