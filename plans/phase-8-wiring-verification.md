# Phase 8: Wiring, Config Updates & End-to-End Verification

## Context
Everything is installed. Now wire it all together — update config files, register cross-repo paths, run Init Checklist, and verify end-to-end with real workflows.

---

## 8.1 — OpenClaw Config Updates

### openclaw.json — Major Changes

1. **Remove Anthropic provider entirely**
2. **Update all workspace paths** from `/Volumes/BotCentral/Users/milo` → new home
3. **Update memorySearch.dbPath** → `~/repos/2Brain/data/brain.sqlite`
4. **Add Composio MCP server**
5. **Remove Gmail MCP servers** (after Composio verification)
6. **Update agent model assignments** per Phase 3

### config/models.yaml — Rewrite

Update all 16 agent entries with new model assignments from Phase 3. Key changes:
- Milo: nemotron-3-nano:4b (local, always-on)
- Elon: codex/gpt-5.4 (primary)
- 6 agents: gemma4:27b (local)
- Cortana: nemotron-3-nano:4b (shares Milo's model)
- Add code_execute tool model assignments

### config/tools.yaml — Path Updates

Update all script paths from `scripts/` → `~/repos/ClawCode/scripts/`:
```yaml
# Before:
script_path: scripts/heartbeat.sh
# After:
script_path: ~/repos/ClawCode/scripts/ops/heartbeat.sh
```

Add new tools:
- `code_execute` — coding agent (Phase 4)
- `2brain_read` / `2brain_write` — knowledge base access
- `cost_log` — cost tracking
- `dashboard_deploy` — Vercel deployment

### config/workflows.yaml — Output Path Updates

DFB output path:
```yaml
# Before:
output: ~/.openclaw/workspace/website/public/briefings/
# After:
output: ~/repos/2Brain/briefings/archive/
```

### Agent Frontmatter Updates

Update `model:` field in each `agents/*.md` file to match Phase 3 assignments.

---

## 8.2 — Launchd Daemon Updates

### Gateway Plist
- Update HOME path in environment variables
- Update log paths to new home
- Replace ALL live API keys with `${VAR_NAME}` placeholders
- Move template to `ClawCode/infra/launchd/templates/`

### Watchdog Plist
- Update script path to `~/repos/ClawCode/scripts/ops/gateway-watchdog.sh`
- Update HOME path

### Registration
```bash
# Use ClawCode's install script
bash ~/repos/ClawCode/infra/launchd/install_daemons.sh
```

---

## 8.3 — Pre-Commit Hook (Security)

Add to all three repos — reject commits containing API key patterns:

```bash
# ClawCode/infra/hooks/pre-commit
#!/bin/bash
PATTERNS='sk-ant-|nvapi-|ghp_|pplx-|gsk_|sk-proj-|MTQ4|xai-'
if git diff --cached --diff-filter=ACM | grep -qE "$PATTERNS"; then
  echo "ERROR: Potential API key detected in staged changes."
  echo "Remove the key and use environment variables instead."
  exit 1
fi
```

Install in each repo:
```bash
for repo in OpenClawMaster ClawCode 2Brain; do
  cp ~/repos/ClawCode/infra/hooks/pre-commit ~/repos/$repo/.git/hooks/pre-commit
  chmod +x ~/repos/$repo/.git/hooks/pre-commit
done
```

---

## 8.4 — Init Checklist (Updated for New Architecture)

Run `docs/Init_Checklist.md` with these updated checks:

### Infrastructure
- [ ] Ollama serving: `curl http://localhost:11434/api/tags`
- [ ] OpenClaw gateway: `curl http://localhost:18789/health`
- [ ] 4TB drive mounted: `df -h /Volumes/CommandCenter`
- [ ] Home directory correct: `echo ~` → `/Volumes/CommandCenter/Users/milo`

### Environment Variables
- [ ] All API keys set in `~/.openclaw/.env`:
  - NVIDIA_NIM_API_KEY
  - OPENAI_API_KEY (for Codex OAuth)
  - PERPLEXITY_API_KEY
  - ZAI_API_KEY
  - OLLAMA_API_KEY (for Pro cloud)
  - TELEGRAM_BOT_TOKEN
  - DISCORD_BOT_TOKEN
  - GITHUB_TOKEN
  - FIRECRAWL_API_KEY
  - COMPOSIO_API_KEY
  - CONTEXT7_API_KEY
  - COMPOSIO_API_KEY

### Local Models
- [ ] `ollama list` includes: nemotron-3-nano:4b, gemma4:27b, glm-4.7-flash, qwen3.5:35b-a3b-codingnvfp4, qwen3-coder-next:latest, gpt-oss:20b, nomic-embed-text

### Repos
- [ ] `~/repos/OpenClawMaster` — clean, on main or working branch
- [ ] `~/repos/ClawCode` — clean, scripts present
- [ ] `~/repos/2Brain` — clean, brain.sqlite present in data/

### State Files
- [ ] `state/Active_Projects.md` exists and parseable
- [ ] `state/Decision_Log.md` exists and parseable
- [ ] `state/Artifacts_Index.md` exists
- [ ] `state/memory/MEMORY.md` exists

### Memory
- [ ] `2Brain/data/brain.sqlite` — tables exist (run `.tables` check)
- [ ] `nomic-embed-text` model loaded
- [ ] OpenClaw memorySearch resolves against 2Brain path

### Identity
- [ ] `~/.openclaw/workspace/USER.md` exists
- [ ] `~/.openclaw/workspace/IDENTITY.md` exists
- [ ] `~/.openclaw/workspace/SOUL.md` exists

### Channels
- [ ] Telegram: send test message to Milo
- [ ] Discord: verify bot is in server and can post to #dfb

---

## 8.5 — End-to-End Verification Tests

### Test 1: Simple Milo Chat
```
→ Send Telegram message to Milo: "What time is it?"
← Milo responds within 3 seconds (nemotron-3-nano:4b, local)
```

### Test 2: DFB Workflow (Manual Trigger)
```
→ Trigger DFB workflow manually
← Pulse scans → Sagan researches → Hemingway formats → Sentinel reviews → Zuck posts to Discord #dfb
← Output saved to 2Brain/briefings/archive/YYYY-MM-DD.json
← Cost tracker has entries for each agent
← Memory ops log shows Cortana reads/writes
```

### Test 3: Escalation Path
```
→ Ask Milo a complex multi-domain question (complexity >= 3)
← Milo briefs Elon → Elon builds task graph → dispatches specialists → Sentinel QA → Milo delivers
```

### Test 4: Dashboard
```
→ Open http://localhost:3000
← All panels load with live data
← Agent roster shows correct models
← Cost tracker shows DFB test run costs
← Open Companion App Canvas → dashboard loads
```

### Test 5: 2Brain Knowledge Loop
```
→ Ingest a source: drop an article into 2Brain/raw/
→ Run ingest-source.md prompt
← Wiki article created/updated
← INDEX.md updated
← Memory ops log shows the write
```

### Test 6: Coding Agent
```
→ Ask Milo to write a simple utility script
← Elon dispatches to code_execute tool
← MiniMax M2.7 (or GPT-OSS) generates script in ClawCode/coding-agent/workspace/
← Sentinel reviews
← Milo presents for approval
```

### Test 7: Cornelius Exclusive Mode
```
→ Trigger an engineering task requiring Cornelius
← Ollama unloads standard models
← qwen3-coder-next:latest loads (51GB)
← Cornelius produces EXEC_PLAN
← Standard models reload after completion
```

### Test 8: OpenClaw Task Flow (v2026.4.2+)
```
→ Trigger DFB as a Task Flow (managed mode)
← openclaw flows shows active flow with revision tracking
← Simulate gateway restart mid-flow
← Flow resumes from interrupted step (not from scratch)
← openclaw flows recover <flow-id> works if needed
```

### Test 9: Dreaming (v2026.4.5)
```
→ Have a multi-topic conversation with Milo across several sessions
→ Wait for nightly Dreaming cycle (or trigger manually)
← DREAMS.md contains plain-English summary of consolidated signals
← MEMORY.md updated with promoted facts
← Cortana ingests notable DREAMS.md insights into 2Brain/raw/
```

### Test 10: Context7 Documentation Access
```
→ Ask Neo to reference current OpenClaw Task Flow docs
← Context7 MCP resolves live documentation
← Neo's output references current API/config syntax (not stale training data)
```

---

## 8.6 — Post-Verification Cleanup

1. **Commit all config changes** across all three repos
2. **Push to GitHub** — all three repos
3. **Tag a release** — `v2026.4.x-command-center` on OpenClawMaster
4. **Update state:**
   - `state/Active_Projects.md` — add Command Center re-architecture as completed
   - `state/Decision_Log.md` — log all architectural decisions made during this plan
   - `state/memory/MEMORY.md` — update system facts with new architecture
5. **Create snapshot backup** of the entire fresh setup

---

## Implementation Timeline

| Phase | Estimated Time | Dependencies |
|---|---|---|
| Phase 0: Backup & Teardown | 30 min | Access to Mac Mini |
| Phase 1: Fresh Install | 1 hour | Phase 0 complete |
| Phase 2: Three Repos | 30 min | Phase 1 complete |
| Phase 3: Model Routing | 1 hour | Phase 1 complete (model pulls) |
| Phase 4: Coding Agent | 30 min | Phase 2 + 3 complete |
| Phase 5: Skills & Tools | 1 hour | Phase 1 complete |
| Phase 6: 2Brain | 1 hour | Phase 2 + 5 complete |
| Phase 7: Dashboard | 2-4 hours | Phase 6 complete (needs data sources) |
| Phase 8: Wiring & Verification | 1-2 hours | All phases complete |
| **Total** | **~8-10 hours** | Spread across 1-2 days |

Phase 7 (Dashboard) can run in parallel with Phases 3-6 if Kairo starts with mock data and wires real data later.
