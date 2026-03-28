# OpenClawMaster Setup Guide

Step-by-step fresh install guide. Follow in order — do not skip steps.

---

## Prerequisites

- macOS (tested on macOS 15+)
- Node.js v22.16+ (v24 recommended): `node --version`
- Git + GitHub CLI: `git --version && gh --version`
- Ollama running locally: `ollama serve`
- All API keys from `/Volumes/MiloCache/MiloLocalBak/snapshots/YYYY-MM-DD/.env`

---

## Step 1 — Backup (if upgrading)

```bash
# Backup memory BEFORE touching anything
SNAP="/Volumes/MiloCache/MiloLocalBak/snapshots/$(date +%Y-%m-%d)"
mkdir -p "$SNAP"

cp -r ~/.openclaw/memory/                  "$SNAP/memory/"
cp -r ~/.openclaw/workspace/smart-memory/  "$SNAP/smart-memory/"

# Workspace identity files — critical for Milo's sense of self and user context
# Without these, Milo wakes up with blank USER.md/IDENTITY.md/SOUL.md
cp ~/.openclaw/workspace/USER.md           "$SNAP/" 2>/dev/null || true
cp ~/.openclaw/workspace/IDENTITY.md       "$SNAP/" 2>/dev/null || true
cp ~/.openclaw/workspace/SOUL.md           "$SNAP/" 2>/dev/null || true
cp ~/.openclaw/workspace/AGENTS.md         "$SNAP/" 2>/dev/null || true
cp ~/.openclaw/workspace/HEARTBEAT.md      "$SNAP/" 2>/dev/null || true
```

---

## Step 2 — Stop All Services

```bash
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/ai.openclaw.gateway.plist
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/ai.openclaw.mission-control.plist
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.openclaw.gateway-watchdog.plist
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.milo.openclaw-key-watcher.plist
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.openclaw.milo-sync-watcher.plist
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.openclaw.milo-sync-watcher-workspace.plist
# Ignore errors for services that aren't loaded
```

---

## Step 3 — Wipe Old OpenClaw (DESTRUCTIVE)

**Only run this after Step 1 backup is confirmed complete.**

```bash
rm -rf ~/.openclaw/
rm -rf ~/.agents/
```

---

## Step 4 — Fresh Install

```bash
curl -fsSL https://openclaw.ai/install.sh | bash
# Follow prompts. This installs Node if needed, registers launchd daemon.
```

Verify:
```bash
openclaw --version   # Should show 2026.3.24 or later
```

---

## Step 5 — Clone Repo & Apply Config

```bash
# Confirm repo is already cloned at:
ls /Volumes/MiloCache/MiloLocalBak/OpenClawMaster/

# Apply openclaw.json from repo (overwrites the default generated one)
cp /Volumes/MiloCache/MiloLocalBak/OpenClawMaster/openclaw.json ~/.openclaw/openclaw.json
```

---

## Step 6 — Set Up .env

```bash
cp /Volumes/MiloCache/MiloLocalBak/snapshots/YYYY-MM-DD/.env ~/.openclaw/.env
```

Then open `~/.openclaw/.env` and ADD these 3 missing keys:
```
PERPLEXITY_API_KEY=pplx-...         # From gateway plist or Perplexity dashboard
DISCORD_BOT_TOKEN=MTQ4...           # From gateway plist or Discord developer portal
FIRECRAWL_API_KEY=fc-cbcd99ca...    # Already in gateway plist
OPENCLAW_GATEWAY_TOKEN=453a9c...    # Copy from old gateway plist EnvironmentVariables
```

---

## Step 7 — Copy Agent Personas

```bash
mkdir -p ~/.agents
cp /Volumes/MiloCache/MiloLocalBak/OpenClawMaster/agents/*.md ~/.agents/
ls ~/.agents/   # Should show 11 .md files
```

---

## Step 8 — Copy Scripts & Goals

```bash
mkdir -p ~/.openclaw/workspace/scripts
mkdir -p ~/.openclaw/workspace/goals

cp /Volumes/MiloCache/MiloLocalBak/OpenClawMaster/scripts/* ~/.openclaw/scripts/
cp /Volumes/MiloCache/MiloLocalBak/OpenClawMaster/scripts/* ~/.openclaw/workspace/scripts/
cp /Volumes/MiloCache/MiloLocalBak/OpenClawMaster/goals/* ~/.openclaw/workspace/goals/
```

---

## Step 9 — Update Gateway Plist

After `openclaw onboard --install-daemon` generates the new plist, update it with env vars:

1. Open `~/Library/LaunchAgents/ai.openclaw.gateway.plist`
2. Add all env vars from `.env` into `<key>EnvironmentVariables</key>` section
3. Use `launchd/ai.openclaw.gateway.plist.template` as reference

```bash
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/ai.openclaw.gateway.plist
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/ai.openclaw.gateway.plist
```

---

## Step 10 — Install macOS Companion App

- Open `OpenClaw-2026.3.24` from Downloads → drag to `/Applications`
- Launch → connects to gateway at `localhost:18789`
- **Do NOT re-register `ai.openclaw.mission-control.plist`** — companion app replaces it

---

## Step 11 — Restore Memory

```bash
SNAP="/Volumes/MiloCache/MiloLocalBak/snapshots/YYYY-MM-DD"

cp -r "$SNAP/memory/" ~/.openclaw/memory/

# smart-memory is ~974M — restore only if needed:
cp -r "$SNAP/smart-memory/" ~/.openclaw/workspace/smart-memory/

# Restore workspace identity files — prevents "hangover" blank-slate on first chat
# Without these Milo won't know who John is or have any personality context
for f in USER.md IDENTITY.md SOUL.md AGENTS.md HEARTBEAT.md; do
  [ -f "$SNAP/$f" ] && cp "$SNAP/$f" ~/.openclaw/workspace/"$f" && echo "Restored $f"
done
```

> **Why this matters:** `USER.md`, `IDENTITY.md`, and `SOUL.md` are Milo's "working memory" —
> they're what Milo reads at the start of every session to know who it is and who it's talking to.
> If these are blank, Milo wakes up as a stranger. The SQLite memory (`main.sqlite`) holds the
> deep history but isn't consulted until Milo explicitly runs a memory search.

---

## Step 12 — Re-auth OpenAI Codex (Elon)

```bash
openclaw auth openai-codex
# Follow OAuth flow to re-authenticate Elon's gpt-5.4 access
```

If OAuth fails, temporarily switch Elon to Claude in `openclaw.json`:
```json
{ "id": "elon", "model": "anthropic/claude-sonnet-4-6" }
```

---

## Verification Checklist

```bash
openclaw agents list          # → 12 agents shown
openclaw gateway status       # → port 18789 live
python3 ~/.openclaw/scripts/check-gateway-keys.py   # → all keys green
```

- Send Telegram message to Milo → should respond
- Check Discord #dfb for last DFB post
- Manually trigger DFB: `openclaw run goal daily_financial_briefing`
- Confirm `git remote -v` in OpenClawMaster → MiloTheAssistant/OpenClawMaster

---

## Notes

- **QMD skill:** Present but NOT activated. Enable when all agents are confirmed working.
- **DFB website:** Managed by `MiloTheAssistant/Milo` repo (Vercel). Separate from this repo.
- **AcademAI:** Managed by `MiloTheAssistant/AcademAi` repo. Separate from this repo.
- **Memory:** Never git-track `memory/` or `smart-memory/` — too large and too dynamic.
