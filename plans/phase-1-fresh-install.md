# Phase 1: Fresh Install — Mac Mini + 4TB Drive

## Context
Clean slate install on Mac Mini M4 Pro (64GB). The 4TB external drive is ALREADY the home directory at `/Volumes/BotCentral/Users/milo`. Official install methods for Ollama and OpenClaw to track upstream upgrades easily.

---

## 1.1 — Verify Home Directory (already set)

```bash
# Confirm home is on 4TB drive
echo ~
# Expected: /Volumes/BotCentral/Users/milo

df -h /Volumes/BotCentral
# Expected: 4TB volume mounted
```

### Directory Layout on 4TB Drive
```
/Volumes/BotCentral/Users/milo/
├── .ollama/
│   └── models/                    # Ollama model weights (100GB+)
├── .openclaw/
│   ├── .env                       # API keys (never in git)
│   ├── openclaw.json              # Runtime config
│   ├── memory/                    # Session memory
│   ├── workspace/
│   │   ├── USER.md                # Milo identity files
│   │   ├── IDENTITY.md
│   │   ├── SOUL.md
│   │   ├── AGENTS.md
│   │   ├── HEARTBEAT.md
│   │   └── smart-memory/          # SQLite + embeddings (until migrated to 2Brain)
│   └── logs/                      # Gateway, watchdog logs
├── repos/
│   ├── OpenClawMaster/            # Governance hub
│   ├── ClawCode/                  # Execution + tools + dashboard
│   └── 2Brain/                    # Second Brain knowledge base
└── Documents/
    └── agents/tasks/              # Task-specific prompts
```

---

## 1.2 — Prerequisites

```bash
# Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Node.js 24 (required by OpenClaw)
brew install node@24

# Git + GitHub CLI
brew install git gh
gh auth login

# Python 3 (for scripts)
brew install python3
```

---

## 1.3 — Install Ollama (official)

```bash
# Official install via brew — tracks upgrades automatically
brew install ollama

# Start service
brew services start ollama

# Verify models survived migration (if copied from old drive)
ollama list

# Pull new 2026 models (see Phase 3 for rationale)
ollama pull gemma4:27b
ollama pull gpt-oss:20b
ollama pull nemotron-3-nano:4b
ollama pull nomic-embed-text
ollama pull glm-4.7-flash
ollama pull qwen3-coder-next:latest
ollama pull qwen3.5:35b-a3b-codingnvfp4

# Verify
ollama list
```

---

## 1.4 — Install OpenClaw (official)

```bash
# Official install — follows upstream upgrades via `openclaw update`
curl -fsSL https://openclaw.ai/install.sh | bash

# Verify
openclaw --version

# Guided setup — registers gateway daemon, sets up workspace
openclaw onboard --install-daemon
```

### Upgrade Path (for future updates)
```bash
# Single command — auto-detects install type, migrates config, restarts gateway
openclaw update

# Or manual via npm
npm install -g openclaw@latest
openclaw doctor && openclaw gateway restart
```

**Always back up `~/.openclaw/` before upgrading.**

---

## 1.5 — Clone Repos

```bash
mkdir -p ~/repos && cd ~/repos

# OpenClawMaster — already exists on GitHub
git clone https://github.com/MiloTheAssistant/OpenClawMaster.git
cd OpenClawMaster && git checkout claude/review-gotcha-framework-V856z && cd ..

# ClawCode — already exists on GitHub
git clone https://github.com/MiloTheAssistant/ClawCode.git

# 2Brain — already exists on GitHub
git clone https://github.com/MiloTheAssistant/Second-Brain-Skill-2Brain.git 2Brain
```

---

## 1.6 — Apply Config from Repo

```bash
# Copy runtime config
cp ~/repos/OpenClawMaster/openclaw.json ~/.openclaw/openclaw.json

# Copy API keys from backup (rotated keys from Phase 0)
cp /path/to/backup/.env ~/.openclaw/.env

# Copy agent personas
cp ~/repos/OpenClawMaster/agents/*.md ~/.agents/
```

---

## 1.7 — Restore Identity Files

```bash
SNAP="/path/to/snapshot"

for f in USER.md IDENTITY.md SOUL.md AGENTS.md HEARTBEAT.md; do
  cp "$SNAP/$f" ~/.openclaw/workspace/ 2>/dev/null
done

# Restore session memory
cp -r "$SNAP/memory/" ~/.openclaw/memory/

# Restore smart-memory (temporary — moves to 2Brain in Phase 6)
cp -r "$SNAP/smart-memory/" ~/.openclaw/workspace/smart-memory/
```

---

## Verification

- [ ] `~` resolves to `/Volumes/BotCentral/Users/milo`
- [ ] `ollama list` shows all expected models
- [ ] `openclaw --version` returns current version
- [ ] `~/.openclaw/openclaw.json` exists
- [ ] `~/.openclaw/.env` exists with rotated keys
- [ ] Identity files present in `~/.openclaw/workspace/`
- [ ] All three repos cloned in `~/repos/`
- [ ] Gateway running: `curl http://localhost:18789/health`
