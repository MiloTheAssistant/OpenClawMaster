# OpenClaw Command Center

Source of truth for the OpenClaw multi-agent environment. Pull this repo and OpenClaw is fully wired.

**Version:** OpenClaw 2026.4.12+
**Phase:** 5 — streamlined 7-agent roster
**Agents:** 7 active (Milo, Sagan, Neo, Hermes, Sentinel, Cortana, Cornelius)
**Retired:** Elon, Pulse, Quant, Hemingway, Jonny, Kairo, Zuck, Themis, Cerberus, Sentinel-RT — available for reactivation when proven workflows need them

---

## Operational Dashboards

| Dashboard | URL | Purpose |
|---|---|---|
| **Mission Control** | `http://localhost:3100` | Task boards, approvals, agent lifecycle |
| **OpenClaw Control UI** | `openclaw dashboard` → `http://localhost:18789` | Native agent/session/skill/cron monitoring |
| **2Brain Viewer** | `http://localhost:3200/wiki` | Read-only wiki + briefings reader (mobile-friendly) |

The legacy custom Command Center dashboard has been retired. See `ClawCode/dashboard.retired/README.md`.

---

## Branch Strategy

| Branch | Purpose |
|--------|---------|
| `main` | Daily working branch — agent tuning, goal edits, script fixes |

---

## Structure

```
OpenClawMaster/
├── openclaw.json          Main config reference (live runtime at ~/.openclaw/openclaw.json)
├── .env.example           Template for secrets (actual secrets at ~/.openclaw/secrets.json)
├── agents/                Agent persona .md files (7 active agents)
├── goals/                 Workflow definitions and task prompts
├── scripts/               Utility scripts
├── tools/scripts/         Operational helpers (mc-push, sync-decisions, gateway-restart, sync-agents-models, model-health-check)
├── docs/                  Architecture docs (routing matrix, profiles, handoff, parallelism, lifecycle)
├── config/                Runtime configs (models, routing, workflows, tools, channels, parallelism, mission-control)
├── state/                 Live state (active projects, decision log, artifacts, memory)
└── .claude/skills/        Claude Code skills (dispatch, ingest-source, add-agent, deploy-gateway)
```

---

## Fresh Install

```bash
# 1. Clone this repo
git clone https://github.com/MiloTheAssistant/OpenClawMaster.git \
  /Volumes/BotCentral/Users/milo/repos/OpenClawMaster

# 2. Install OpenClaw (clean)
curl -fsSL https://openclaw.ai/install.sh | bash

# 3. Copy config reference from repo
cp /Volumes/BotCentral/Users/milo/repos/OpenClawMaster/openclaw.json ~/.openclaw/openclaw.json

# 4. Set up secrets.json (never in git)
cp /Volumes/MiloCache/MiloLocalBak/snapshots/YYYY-MM-DD/secrets.json ~/.openclaw/secrets.json
chmod 600 ~/.openclaw/secrets.json

# 5. Copy agent personas
cp /Volumes/BotCentral/Users/milo/repos/OpenClawMaster/agents/*.md ~/.agents/

# 6. Install macOS Companion App (optional)
# Open OpenClaw-{version}.dmg from Downloads → drag to /Applications

# 7. Re-auth OpenAI Codex
openclaw auth openai-codex

# 8. Start Mission Control (requires Docker Desktop)
cd /Volumes/BotCentral/Users/milo/repos/openclaw-mission-control
docker compose --env-file .env up -d --build

# 9. Start 2Brain viewer (launchd)
launchctl load -F ~/Library/LaunchAgents/com.2brain-viewer.plist
```

---

## Providers

| Provider | Agent(s) | Key |
|----------|----------|-----|
| Ollama Local | Cortana, Cornelius | (no key needed) |
| Ollama Pro (cloud) | Milo, Hermes, Sentinel | `OLLAMA_API_KEY` |
| NVIDIA NIM | Neo | `NVIDIA_NIM_API_KEY` |
| Perplexity | Sagan | `PERPLEXITY_API_KEY` |
| Z.ai | Milo/Hermes/Sentinel (fallback) | `ZAI_API_KEY` |
| OpenAI Codex | Milo/Sagan/Neo (escalation) | OAuth |

**Blocked:** Anthropic API — policy conflict with OpenClaw harness.

---

## Active Workflows

| Workflow | Schedule | Chain |
|---------|----------|-------|
| Daily Financial Briefing | 7:00 AM CT, weekdays | Milo → Sagan → Hermes → Sentinel → Cortana |
| Market Signal Scanner | every 2h, market hours | Milo → Sagan → Cortana |
| Security Audit | midnight daily | Sentinel → Cortana → (pushes approvals to MC) |
| Memory Dreaming | 3 AM daily | memory-core plugin (Cortana) |
| Decision Log Sync | every 5 min | launchd → `sync-decisions.sh` → MC Decisions board |

---

## Skills & Tools

| Script | Purpose |
|-------|---------|
| `tools/scripts/mc-push.sh` | Push tasks, comments, approvals to Mission Control |
| `tools/scripts/sync-decisions.sh` | Sync Decision_Log.md → MC Decisions board |
| `tools/scripts/gateway-restart.sh` | Clean gateway unload/load with health check |
| `tools/scripts/sync-agents-models.sh` | Verify AGENTS.md ↔ models.yaml ↔ agents/*.md are in sync |
| `tools/scripts/model-health-check.sh` | Inventory local models + gateway status + cloud ping |

Claude Code skills under `.claude/skills/`: `ingest-source`, `dispatch`, `add-agent`, `deploy-gateway`.

---

## Secrets

- Secrets live at `~/.openclaw/secrets.json` — **never committed**, permissions `600`
- Config YAML uses OpenClaw SecretRef format (`source: file`, `id: /KEY_NAME`) to reference them
- Backup kept at `/Volumes/MiloCache/MiloLocalBak/snapshots/`

---

## References

- `AGENTS.md` — agent roster, authority chain, delegation flow
- `GotchaFramework.md` — 6-layer operating framework (Goals, Orchestration, Tools, Context, Hard prompts, Args)
- `CLAUDE.md` — session guidance for AI agents working in this repo
- `docs/Agent_Model_Routing_Matrix.md` — model assignments + escalation rules
- `docs/Router_Profiles.md` — reusable dispatch formations
