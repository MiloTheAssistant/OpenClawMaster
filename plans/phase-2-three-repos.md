# Phase 2: Three-Repo Architecture

## Context
Separate concerns into three independently versionable repos. OpenClawMaster is the constitution (governance). ClawCode is the executive branch (execution). 2Brain is the library (knowledge).

---

## 2.1 — OpenClawMaster (Governance Hub)

**Repo:** `github.com/MiloTheAssistant/OpenClawMaster`
**Purpose:** Agent identity, GOTCHA framework, routing, model config, workflow definitions, state tracking.
**Already exists** — cleaned up in this session.

### Structure (current)
```
OpenClawMaster/
├── AGENTS.md                    # Agent roster, authority chain, delegation flow
├── CLAUDE.md                    # Session guidance for AI agents
├── GotchaFramework.md           # 6-layer operating framework
├── README.md                    # Overview + install steps
├── openclaw.json                # OpenClaw runtime config (canonical)
├── .env.example                 # API key template
├── agents/                      # 16 agent identity prompts
├── config/
│   ├── models.yaml              # Agent-to-model routing + fallback chains
│   ├── routing.yaml             # Router profiles (intelligence, campaign, etc.)
│   ├── workflows.yaml           # Workflow definitions + schedules
│   ├── parallelism.yaml         # Hardware constraints, exclusive models
│   ├── channels.yaml            # Distribution channels + posting policy
│   ├── tools.yaml               # Tool registry (canonical)
│   ├── tools_manifest.md        # Quick-scan tool index
│   └── workflows_manifest.md    # Quick-scan workflow index
├── docs/                        # Governance docs, protocols, schemas
├── goals/                       # Workflow task prompts
│   ├── manifest.md
│   ├── daily_financial_briefing.md
│   └── command_center_dashboard.md   # NEW — Kairo dashboard brief
├── launchd/                     # macOS daemon templates (keys as ${VAR} placeholders)
├── state/                       # Live state (Cortana-managed)
│   ├── Active_Projects.md
│   ├── Decision_Log.md
│   ├── Artifacts_Index.md
│   └── memory/
│       ├── MEMORY.md
│       └── logs/                # Daily logs (gitignored)
└── skills/
    └── ai-legal-claude/         # Submodule
```

### What Moves OUT to ClawCode
- `scripts/heartbeat.sh`
- `scripts/gateway-watchdog.sh`
- `scripts/check-gateway-keys.py`
- `scripts/fetch_dfb_market_data.py`
- `launchd/` templates (move to ClawCode/infra/)

### Config Updates Required
- `config/tools.yaml` — update script paths to point at `~/repos/ClawCode/scripts/`
- `goals/daily_financial_briefing.md` — update output paths to `~/repos/2Brain/`
- `openclaw.json` — remove Anthropic, update workspace paths to new home dir
- `config/workflows.yaml` — convert workflow definitions to OpenClaw Task Flow format (v2026.4.2+)

---

## 2.2 — ClawCode (Execution + Tools + Dashboard)

**Repo:** `github.com/MiloTheAssistant/ClawCode` (NEW — create on GitHub)
**Purpose:** Scripts, tools, automations, coding agent workspace, and the Command Center Dashboard.

### Structure
```
ClawCode/
├── README.md
├── CLAUDE.md                        # ClawCode-specific session guidance
├── scripts/
│   ├── ops/
│   │   ├── heartbeat.sh             # From OpenClawMaster/scripts/
│   │   ├── gateway-watchdog.sh      # From OpenClawMaster/scripts/
│   │   └── check-gateway-keys.py    # From OpenClawMaster/scripts/
│   ├── dfb/
│   │   └── fetch_dfb_market_data.py # From OpenClawMaster/scripts/
│   └── market/
│       └── signal_scanner.py        # Future: Market Signal Scanner
├── tools/
│   ├── sqlite/
│   │   ├── cost_tracker_schema.sql  # Cost tracking table definition
│   │   ├── memory_ops_schema.sql    # Memory ops log table definition
│   │   └── query.py                 # Direct SQLite query tool
│   ├── google/
│   │   └── gmail_mcp_setup.md       # Gmail MCP config docs
│   └── vercel/
│       └── deploy.sh                # Vercel deployment script
├── dashboard/                       # Command Center Dashboard (Kairo-built)
│   ├── app/                         # Next.js 16 App Router
│   ├── components/                  # shadcn/ui + custom
│   ├── lib/                         # Data fetching, SQLite queries, API routes
│   ├── public/
│   ├── package.json
│   ├── next.config.js
│   ├── tailwind.config.js
│   └── vercel.json
├── infra/
│   ├── launchd/
│   │   ├── install_daemons.sh       # Daemon registration script
│   │   └── templates/               # .plist templates (NO live keys)
│   └── hooks/
│       └── pre-commit               # Reject commits containing API key patterns
├── coding-agent/                    # Workspace for autonomous coding tasks
│   ├── README.md                    # Coding agent guidelines
│   └── workspace/                   # Scratch space for generated code
└── tests/
    ├── test_heartbeat.sh
    └── test_market_data.py
```

### Cross-Repo References
OpenClawMaster's `config/tools.yaml` points to ClawCode:
```yaml
dfb_market_data:
  type: script
  script_path: ~/repos/ClawCode/scripts/dfb/fetch_dfb_market_data.py

heartbeat:
  type: script
  script_path: ~/repos/ClawCode/scripts/ops/heartbeat.sh
```

---

## 2.3 — 2Brain (Second Brain Knowledge Base)

**Repo:** `github.com/MiloTheAssistant/Second-Brain-Skill-2Brain` (EXISTS)
**Purpose:** Karpathy-inspired flat-file knowledge base. Shared memory layer across all systems.

### Structure (from 2Brain PLAN.md)
```
2Brain/
├── CLAUDE.md                    # Schema + AI behavior rules
├── README.md
├── raw/                         # Source material (unprocessed)
│   ├── .gitkeep
│   └── _INTAKE.md               # Instructions for adding raw sources
├── wiki/                        # AI-maintained organized knowledge
│   ├── INDEX.md                 # Master index of all topics
│   └── .gitkeep
├── outputs/                     # Generated reports, answers, analyses
│   ├── .gitkeep
│   └── _TEMPLATE.md
├── scripts/                     # Prompt-as-script workflows
│   ├── compile-wiki.md          # Compile raw → wiki
│   ├── health-check.md          # Monthly maintenance
│   ├── ask-question.md          # Query the knowledge base
│   └── ingest-source.md         # Ingest a new source
├── integrations/                # Integration contracts
│   ├── openclaw.md              # How OpenClaw connects
│   ├── claw-code.md             # How ClawCode connects
│   └── dashboard.md             # How the dashboard reads stats
├── data/                        # NEW — structured data
│   ├── brain.sqlite             # Smart-memory DB (migrated from ~/.openclaw)
│   ├── cost_tracker.sqlite      # Agent cost tracking (or same DB, separate tables)
│   └── embeddings/              # nomic-embed-text vector index
└── briefings/                   # NEW — DFB historical archive
    ├── archive/                 # YYYY-MM-DD.json files
    └── templates/
        └── dfb_template.json
```

### Key Design Principles (from Karpathy)
- **Flat file structure** — no databases for knowledge, just markdown
- **Prompt-as-script** — workflow prompts are markdown files, not executable code
- **Compounding loop** — every interaction leaves the knowledge base better
- **SQLite for structured data only** — cost tracking, memory ops log, embeddings; knowledge stays in markdown

### Cross-Repo References
- OpenClawMaster's `openclaw.json` `memorySearch.dbPath` → `~/repos/2Brain/data/brain.sqlite`
- OpenClawMaster's `goals/daily_financial_briefing.md` output → `~/repos/2Brain/briefings/archive/`
- ClawCode's `dashboard/` reads from → `~/repos/2Brain/data/` for cost and memory stats

---

## 2.4 — Environment Variables for Cross-Repo Paths

Add to `~/.openclaw/.env`:
```bash
OPENCLAW_MASTER_ROOT=~/repos/OpenClawMaster
CLAWCODE_ROOT=~/repos/ClawCode
TWOBRAIN_ROOT=~/repos/2Brain
```

---

## Verification

- [ ] OpenClawMaster contains NO scripts (moved to ClawCode)
- [ ] ClawCode repo created on GitHub with structure above
- [ ] 2Brain repo cloned, data/ directory created with SQLite migration
- [ ] `config/tools.yaml` paths point to ClawCode
- [ ] `openclaw.json` memorySearch.dbPath points to 2Brain
- [ ] Environment variables set in .env
