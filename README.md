# OpenClaw Command Center

Source of truth for the OpenClaw multi-agent environment. Pull this repo and OpenClaw is fully wired.

**Version:** OpenClaw 2026.3.24+
**Agents:** 16 (Milo, Elon, Cortana, Sentinel, Themis, Cerberus, Pulse, Sagan, Quant, Neo, Cornelius, Hemingway, Jonny, Kairo, Zuck, Hermes)

---

## Branch Strategy

| Branch | Purpose |
|--------|---------|
| `main` | Daily working branch — agent tuning, goal edits, script fixes |
| `stable` | Locked config — only updated via formal Gotcha/RedTeam session + PR |

Tag stable releases: `v2026.3.27`, etc.

---

## Structure

```
OpenClawMaster/
├── openclaw.json          Main config (no secrets — uses ${ENV_VAR} placeholders)
├── .env.example           Template for ~/.openclaw/.env
├── agents/                Agent persona .md files (16 agents)
├── goals/                 Workflow definitions (DFB chain, manifest)
├── scripts/               Utility scripts (heartbeat, key-check, market-data, watchdog)
├── launchd/               macOS daemon templates (gateway + watchdog only)
├── docs/                  Architecture docs (handoff protocol, QA gates, state schema)
├── config/                YAML configs (models, routing, channels, parallelism, tools)
└── state/                 Live state (active projects, decision log, artifacts, memory)
```

---

## Fresh Install

```bash
# 1. Clone this repo
git clone https://github.com/MiloTheAssistant/OpenClawMaster.git \
  /Volumes/MiloCache/MiloLocalBak/OpenClawMaster

# 2. Install OpenClaw (clean)
curl -fsSL https://openclaw.ai/install.sh | bash

# 3. Copy config from repo
cp /Volumes/MiloCache/MiloLocalBak/OpenClawMaster/openclaw.json ~/.openclaw/openclaw.json

# 4. Set up .env (copy from backup — never from repo)
cp /Volumes/MiloCache/MiloLocalBak/snapshots/YYYY-MM-DD/.env ~/.openclaw/.env
# Add missing keys: PERPLEXITY_API_KEY, DISCORD_BOT_TOKEN, FIRECRAWL_API_KEY

# 5. Copy agent personas
cp /Volumes/MiloCache/MiloLocalBak/OpenClawMaster/agents/*.md ~/.agents/

# 6. Copy scripts + goals
cp /Volumes/MiloCache/MiloLocalBak/OpenClawMaster/scripts/* ~/.openclaw/workspace/scripts/
cp /Volumes/MiloCache/MiloLocalBak/OpenClawMaster/goals/* ~/.openclaw/workspace/goals/

# 7. Install macOS Companion App (replaces Command Center)
# Open OpenClaw-{version}.dmg from Downloads → drag to /Applications

# 8. Re-auth OpenAI Codex (for Elon / gpt-5.4)
openclaw auth openai-codex
```

---

## Providers

| Provider | Agent(s) | Key |
|----------|----------|-----|
| Ollama (local) | Cortana, Pulse, Hemingway, Sentinel, Quant, Kairo, Zuck, Hermes, Cornelius | (no key needed) |
| NVIDIA NIM | Milo, Elon, Neo, Themis, Cerberus | `NVIDIA_NIM_API_KEY` |
| Perplexity | Sagan | `PERPLEXITY_API_KEY` |
| Z.ai | Jonny, Sentinel (escalation) | `ZAI_API_KEY` |
| OpenAI Codex | Elon (escalation), Sagan (escalation) | OAuth |
| Ollama Pro (cloud) | Milo (fallback) | `OLLAMA_API_KEY` |

**Blocked:** Anthropic API — policy conflict with OpenClaw harness.

---

## Active Workflows

| Workflow | Schedule | Chain |
|---------|----------|-------|
| Daily Financial Briefing | 8:45 AM CT, weekdays | Cortana → Pulse+Sagan → Hemingway → Sentinel → Zuck |
| Market Signal Scanner | 1:30–5:30 PM CT, weekdays | Pulse → Sagan (if impact ≥ 8) |
| Gateway Key Health | Every 30 min | check-gateway-keys.py → Telegram silent |
| Heartbeat | Hourly | heartbeat.sh → Telegram announce |

---

## Skills Enabled

| Skill | Purpose |
|-------|---------|
| GitHub CLI | Repo management, PR creation |
| Git CLI | Version control |
| Firecrawl | Web research (Sagan, Neo — DFB chain) |
| Discord | DFB delivery (Zuck → #dfb channel) |
| Telegram | Heartbeat, key health alerts, Milo DMs |

**QMD:** Present in skills dir but NOT activated. Enable when ready.

---

## Secrets

- `.env` lives at `~/.openclaw/.env` — **never committed**
- Backup kept at `/Volumes/MiloCache/MiloLocalBak/snapshots/`
- See `.env.example` for all required keys
