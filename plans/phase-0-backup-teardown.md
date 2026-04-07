# Phase 0: Backup & Teardown

## Context
Before blowing away OpenClaw and Ollama on the Mac Mini, we must preserve everything that can't be regenerated — identity files, memory, state, API keys, and Ollama model weights.

---

## 0.1 — Critical Backups

### Identity Files (Milo is a blank slate without these)
```bash
SNAP="/Volumes/MiloCache/MiloLocalBak/snapshots/$(date +%Y-%m-%d)"
mkdir -p "$SNAP"

for f in USER.md IDENTITY.md SOUL.md AGENTS.md HEARTBEAT.md; do
  cp ~/.openclaw/workspace/"$f" "$SNAP/" 2>/dev/null
done
```

### Memory & State
```bash
# Session memory
cp -r ~/.openclaw/memory/ "$SNAP/memory/"

# Smart-memory SQLite (~974MB) + embeddings
cp -r ~/.openclaw/workspace/smart-memory/ "$SNAP/smart-memory/"

# State files from repo
cp -r ~/repos/OpenClawMaster/state/ "$SNAP/state/"
```

### Configuration
```bash
# API keys — NEVER in git
cp ~/.openclaw/.env "$SNAP/.env"

# Runtime config (may have local overrides vs repo)
cp ~/.openclaw/openclaw.json "$SNAP/openclaw.json"
```

### DFB Historical Data
```bash
cp -r ~/.openclaw/workspace/website/public/briefings/ "$SNAP/briefings/" 2>/dev/null
```

### Verify Repo is Pushed
```bash
cd ~/repos/OpenClawMaster && git status && git push
```

---

## 0.2 — Stop All Services

```bash
UID_VAL=$(id -u)
for label in \
  ai.openclaw.gateway \
  ai.openclaw.mission-control \
  com.openclaw.gateway-watchdog \
  com.milo.openclaw-key-watcher \
  com.openclaw.milo-sync-watcher \
  com.openclaw.milo-sync-watcher-workspace; do
  launchctl bootout "gui/${UID_VAL}" ~/Library/LaunchAgents/"${label}.plist" 2>/dev/null
done
```

---

## 0.3 — Preserve Ollama Models

**DO NOT delete `~/.ollama/models/`** — this directory contains all downloaded model weights (100GB+). The Ollama binary gets reinstalled; models are reused automatically.

```bash
# Verify models directory size before proceeding
du -sh ~/.ollama/models/

# List currently downloaded models
ollama list
```

If the 4TB drive is a NEW drive (not the current home), copy the models directory:
```bash
cp -r ~/.ollama/models/ /Volumes/CommandCenter/Users/milo/.ollama/models/
```

---

## 0.4 — Teardown

```bash
# Wipe OpenClaw runtime
rm -rf ~/.openclaw/
rm -rf ~/.agents/

# Remove old launchd plists
rm -f ~/Library/LaunchAgents/ai.openclaw.*.plist
rm -f ~/Library/LaunchAgents/com.openclaw.*.plist
rm -f ~/Library/LaunchAgents/com.milo.*.plist

# DO NOT run: rm -rf ~/.ollama/
```

---

## 0.5 — Security: Rotate Exposed Keys

The file `launchd/ai.openclaw.gateway.plist.template` in the repo contains live API keys in plaintext. After teardown and before fresh install:

1. Rotate ALL keys: ANTHROPIC_API_KEY, DISCORD_BOT_TOKEN, GITHUB_TOKEN, NVIDIA_NIM_API_KEY, OPENROUTER_API_KEY, PERPLEXITY_API_KEY, TELEGRAM_BOT_TOKEN, ZAI_API_KEY
2. Update the backup `.env` with rotated keys
3. Fix the plist template in the repo — replace live keys with `${VAR_NAME}` placeholders
4. Add a pre-commit hook to reject commits containing key patterns (`sk-ant-`, `nvapi-`, `ghp_`, `pplx-`)

---

## Verification

- [ ] Snapshot directory exists with: identity files, memory/, smart-memory/, state/, .env, openclaw.json
- [ ] `ollama list` shows all models still present
- [ ] All launchd services stopped (`launchctl list | grep -i openclaw` returns nothing)
- [ ] `~/.openclaw/` is deleted
- [ ] OpenClawMaster repo is fully pushed to GitHub
- [ ] All API keys rotated and new values saved to backup .env
