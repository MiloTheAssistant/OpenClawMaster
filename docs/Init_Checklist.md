# Init_Checklist.md

## Purpose
Bootstrapping protocol for Mission Control. Run on fresh start, after crash, or when environment integrity is uncertain.

## When to Run
- First session in a new environment
- After system crash or unexpected shutdown
- After hardware change or OS update
- When agent behavior seems degraded or state appears stale
- After `SYSTEM.md` or `config/*.yaml` modifications

---

## Pre-Flight Checks

### 1. Verify Infrastructure Services

```bash
# Docker Desktop must be running (required for OpenClaw)
docker info > /dev/null 2>&1 && echo "✅ Docker running" || echo "❌ Docker not running — start Docker Desktop"

# Ollama must be serving
curl -s http://localhost:11434/api/tags > /dev/null 2>&1 && echo "✅ Ollama running" || echo "❌ Ollama not running — run: ollama serve"

# OpenClaw must be reachable
curl -s http://localhost:18789/health > /dev/null 2>&1 && echo "✅ OpenClaw running" || echo "❌ OpenClaw not reachable on port 18789"
```

### 2. Verify External Volume

```bash
# Home directory must be accessible
[ -d "/Volumes/BotCentral/Users/milo" ] && echo "✅ External volume mounted" || echo "❌ External volume not mounted at /Volumes/BotCentral"

# Agent prompts must exist
[ -d "/Volumes/BotCentral/Users/milo/Documents/agents" ] && echo "✅ Agent prompts directory exists" || echo "❌ Agent prompts missing"

# OpenClaw workspace must exist
[ -d "/Volumes/BotCentral/Users/milo/.openclaw/workspace/mission-control" ] && echo "✅ OpenClaw workspace exists" || echo "❌ OpenClaw workspace missing"
```

### 3. Verify Environment Variables

```bash
# Required API keys (check existence, not values)
[ -n "$NVIDIA_NIM_API_KEY" ] && echo "✅ NVIDIA_NIM_API_KEY set" || echo "❌ NVIDIA_NIM_API_KEY missing"
[ -n "$ANTHROPIC_API_KEY" ] && echo "✅ ANTHROPIC_API_KEY set" || echo "❌ ANTHROPIC_API_KEY missing"
[ -n "$OPENAI_API_KEY" ] && echo "✅ OPENAI_API_KEY set" || echo "❌ OPENAI_API_KEY missing"
[ -n "$PERPLEXITY_API_KEY" ] && echo "✅ PERPLEXITY_API_KEY set" || echo "❌ PERPLEXITY_API_KEY missing"
[ -n "$DISCORD_WEBHOOK_URL" ] && echo "✅ DISCORD_WEBHOOK_URL set" || echo "❌ DISCORD_WEBHOOK_URL missing"
[ -n "$TELEGRAM_BOT_TOKEN" ] && echo "✅ TELEGRAM_BOT_TOKEN set" || echo "❌ TELEGRAM_BOT_TOKEN missing"
```

### 4. Verify Local Models Available

```bash
# Check that key local models are pulled
ollama list 2>/dev/null | grep -q "nemotron-3-nano" && echo "✅ nemotron-3-nano available" || echo "❌ nemotron-3-nano not pulled — run: ollama pull nemotron-3-nano"
ollama list 2>/dev/null | grep -q "qwen3.5" && echo "✅ qwen3.5 available" || echo "❌ qwen3.5 not pulled"
ollama list 2>/dev/null | grep -q "qwen3:14b" && echo "✅ qwen3:14b available" || echo "❌ qwen3:14b not pulled"
ollama list 2>/dev/null | grep -q "glm-4.7-flash" && echo "✅ glm-4.7-flash available" || echo "❌ glm-4.7-flash not pulled"
ollama list 2>/dev/null | grep -q "qwen3-coder-next" && echo "✅ qwen3-coder-next available" || echo "❌ qwen3-coder-next not pulled"
```

### 5. Verify State Files Exist and Are Parseable

```bash
# State files must exist
for f in state/Active_Projects.md state/Artifacts_Index.md state/Decision_Log.md state/memory/MEMORY.md; do
  [ -f "$f" ] && echo "✅ $f exists" || echo "❌ $f missing — needs initialization"
done

# Config files must exist
for f in config/models.yaml config/tools.yaml config/routing.yaml config/workflows.yaml config/channels.yaml config/parallelism.yaml; do
  [ -f "$f" ] && echo "✅ $f exists" || echo "❌ $f missing — critical config gap"
done
```

### 6. Initialize Memory If Missing

```bash
# Create memory directory structure if absent
mkdir -p state/memory/logs

# Create today's daily log if absent
TODAY=$(date +%Y-%m-%d)
LOG_FILE="state/memory/logs/${TODAY}.md"
if [ ! -f "$LOG_FILE" ]; then
  cat > "$LOG_FILE" << EOF
# Daily Log: ${TODAY}

> Session log for $(date +'%A, %B %d, %Y')

---

## Events & Notes

EOF
  echo "✅ Created daily log: $LOG_FILE"
else
  echo "✅ Daily log exists: $LOG_FILE"
fi

# Create MEMORY.md if absent
if [ ! -f "state/memory/MEMORY.md" ]; then
  echo "❌ MEMORY.md missing — create from template in GotchaFramework.md"
else
  echo "✅ MEMORY.md exists"
fi
```

---

## Post-Check Actions

| Result | Action |
|---|---|
| All ✅ | System ready — Milo may accept tasks |
| Any ❌ in infrastructure (Docker, Ollama, OpenClaw) | Resolve before accepting tasks — agents cannot function without serving infrastructure |
| Any ❌ in environment variables | Add missing keys to `~/.zshrc` and `source ~/.zshrc` |
| Any ❌ in local models | Pull missing models: `ollama pull <model>` |
| Any ❌ in state/config files | Restore from backup or recreate from templates |

## Recovery Priority Order
1. Docker Desktop → start it
2. Ollama → `ollama serve`
3. External volume → mount `/Volumes/BotCentral`
4. Environment variables → add to `~/.zshrc`
5. OpenClaw → verify workspace and restart
6. Local models → `ollama pull` missing models
7. State files → restore or recreate
8. Memory → initialize from template

---

*This checklist should complete in under 60 seconds on a healthy system. Any failure that takes longer to resolve should be logged through Cortana as a `recent_failures` entry with `failure_type: infrastructure`.*
