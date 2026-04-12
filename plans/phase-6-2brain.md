# Phase 6: 2Brain — Second Brain Integration

## Context
2Brain is the shared memory layer connecting OpenClawMaster, ClawCode, and the Dashboard. Karpathy-inspired flat-file knowledge base with SQLite for structured data. Every interaction leaves the system smarter.

---

## 6.1 — Architecture

```
2Brain/
├── CLAUDE.md              # Schema + AI behavior rules (governs all AI interaction)
├── README.md
├── raw/                   # Source material — humans and agents drop files here
│   ├── _INTAKE.md         # Instructions for adding sources
│   └── (source files)
├── wiki/                  # AI-maintained knowledge — compiled from raw/
│   ├── INDEX.md           # Master topic index (auto-maintained)
│   └── (topic files)
├── outputs/               # Generated reports, answers, analyses
│   ├── _TEMPLATE.md       # Output format template
│   └── (dated outputs)
├── scripts/               # Prompt-as-script workflows (markdown, not code)
│   ├── compile-wiki.md    # Compile raw → wiki articles
│   ├── health-check.md    # Flag contradictions, gaps, unsourced claims
│   ├── ask-question.md    # Query knowledge base, save output, update wiki
│   └── ingest-source.md   # Process new source into raw/, update INDEX.md
├── integrations/          # Contracts for external systems
│   ├── openclaw.md        # How OpenClaw agents read/write 2Brain
│   ├── claw-code.md       # How ClawCode references knowledge
│   └── dashboard.md       # How the dashboard reads stats
├── data/                  # Structured data (SQLite, embeddings)
│   ├── brain.sqlite       # Smart-memory + cost tracker + memory ops log
│   └── embeddings/        # nomic-embed-text vector index
└── briefings/             # DFB and content archives
    ├── archive/           # YYYY-MM-DD.json historical briefings
    └── templates/
        └── dfb_template.json
```

---

## 6.2 — The Compounding Loop

Every interaction improves the knowledge base:

```
1. Agent produces output (research, briefing, analysis)
     ↓
2. Output saved to 2Brain/outputs/ (with date, sources, follow-ups)
     ↓
3. Relevant wiki articles updated with new insights
     ↓
4. INDEX.md regenerated
     ↓
5. Next agent query finds richer context
     ↓
6. Better output → back to step 1
```

---

## 6.3 — How Each System Connects

### OpenClaw → 2Brain

**Read path:** Cortana reads `wiki/` and `data/brain.sqlite` at workflow start for context.
```json
// openclaw.json
"memorySearch": {
  "enabled": true,
  "sources": ["memory", "sessions"],
  "provider": "ollama",
  "model": "nomic-embed-text",
  "dbPath": "~/repos/2Brain/data/brain.sqlite"
}
```

**Write path:** Cortana writes to:
- `data/brain.sqlite` — memory entries, cost tracking, memory ops log
- `wiki/` — updated articles when new facts are discovered (via compile-wiki prompt)
- `outputs/` — workflow outputs (DFB briefings, research reports)
- `briefings/archive/` — DFB JSON output

**Agent access:**
| Agent | 2Brain Access | What They Do |
|---|---|---|
| Cortana | Read + Write | State queries, memory ops, cost logging |
| Sagan | Read | Research context from wiki/ before synthesis |
| Pulse | Read | Check wiki/ for historical signal context |
| Hemingway | Read | Reference past briefing formats and tone |
| Hermes | Read | Check wiki/ for contact context, past threads |

### ClawCode → 2Brain

**Read path:** coding agent reads `wiki/` for technical context before implementing.
**Write path:** Architecture decisions and debugging notes feed back as `raw/` sources.

### Dashboard → 2Brain

**Read path:** Dashboard reads from `data/brain.sqlite`:
- `cost_tracker` table → cost panels
- `memory_ops_log` table → memory transparency panel
- Wiki article count, last modified → 2Brain stats panel

---

## 6.4 — Migration from Current Smart-Memory

```bash
# Copy existing SQLite database
cp ~/.openclaw/workspace/smart-memory/main.sqlite ~/repos/2Brain/data/brain.sqlite

# Copy embeddings
cp -r ~/.openclaw/workspace/smart-memory/embeddings/ ~/repos/2Brain/data/embeddings/

# Run schema migrations (add new tables)
sqlite3 ~/repos/2Brain/data/brain.sqlite < ~/repos/ClawCode/tools/sqlite/cost_tracker_schema.sql
sqlite3 ~/repos/2Brain/data/brain.sqlite < ~/repos/ClawCode/tools/sqlite/memory_ops_schema.sql

# Update openclaw.json memorySearch path
# Old: ~/.openclaw/workspace/smart-memory/main.sqlite
# New: ~/repos/2Brain/data/brain.sqlite
```

---

## 6.5 — Transparent Memory Operations

Every memory read/write is logged to `memory_ops_log` in brain.sqlite. This gives John full visibility into what agents know, what they've learned, and what they've searched for.

**Query examples (via ClawCode/tools/sqlite/query.py):**
```bash
# What did agents read today?
python3 query.py "SELECT agent, operation, query FROM memory_ops_log WHERE date(timestamp) = date('now')"

# What has Cortana written this week?
python3 query.py "SELECT timestamp, content_preview FROM memory_ops_log WHERE agent='Cortana' AND operation='write' AND timestamp > datetime('now', '-7 days')"

# Cost breakdown by agent this month
python3 query.py "SELECT agent, SUM(tokens_in + tokens_out) as total_tokens, SUM(estimated_cost_usd) as total_cost FROM cost_tracker WHERE timestamp > datetime('now', 'start of month') GROUP BY agent ORDER BY total_cost DESC"
```

---

## 6.6 — OpenClaw Dreaming Integration (v2026.4.5)

OpenClaw now has built-in memory consolidation called "Dreaming" — light/deep/REM phases that promote short-term signals into durable MEMORY.md.

### How They Work Together

| Layer | What It Does | Where It Lives |
|---|---|---|
| **Dreaming** | Consolidates conversation signals → MEMORY.md | `~/.openclaw/workspace/MEMORY.md` + `DREAMS.md` |
| **2Brain** | Structured knowledge base — wiki, sources, outputs | `~/repos/2Brain/` |
| **Cortana** | State tracking — projects, decisions, artifacts, cost | `state/` in OpenClawMaster + brain.sqlite in 2Brain |

### Configuration
Enable Dreaming for Milo's workspace in `openclaw.json`:
```json
{
  "dreaming": {
    "enabled": true,
    "frequency": "nightly"
  }
}
```

### Feed Dreaming → 2Brain
After each Dreaming cycle, Cortana reads `DREAMS.md` and ingests notable insights into `2Brain/raw/` as source material:
- Dreaming handles "what did we talk about recently?"
- 2Brain handles "what do we know?"
- Dreams feed the wiki over time — compounding knowledge

### What NOT to Duplicate
- Don't duplicate MEMORY.md in 2Brain — let Dreaming own short-term → long-term promotion
- Don't replace Dreaming with Cortana's memory writes — they serve different purposes
- 2Brain's `wiki/` is curated knowledge; MEMORY.md is operational context

---

## 6.7 — Git LFS for Large Files

brain.sqlite will grow (currently ~974MB). Use Git LFS:
```bash
cd ~/repos/2Brain
git lfs install
git lfs track "data/*.sqlite"
git add .gitattributes
```

---

## 6.7 — Health Check Schedule

Run `scripts/health-check.md` monthly (via Elon scheduling):
- Flag contradictions between wiki articles
- Find topics mentioned but never explained
- List claims not backed by sources in `raw/`
- Suggest 3 new articles to fill gaps
- Check for compounding errors (outdated info propagated)

---

## Files to Update

- `openclaw.json` — update memorySearch.dbPath
- `config/tools.yaml` — add 2Brain read/write tools
- `goals/daily_financial_briefing.md` — output path → `~/repos/2Brain/briefings/archive/`
- `2Brain/integrations/openclaw.md` — write the integration contract
- `2Brain/integrations/claw-code.md` — write the integration contract
- `2Brain/integrations/dashboard.md` — write the integration contract

---

## Verification

- [ ] brain.sqlite migrated with existing data intact
- [ ] New tables (cost_tracker, memory_ops_log) created
- [ ] OpenClaw memorySearch works against new path
- [ ] Cortana can write a test memory entry
- [ ] Memory ops log captures the write
- [ ] DFB output lands in 2Brain/briefings/archive/
- [ ] Git LFS tracking .sqlite files
- [ ] Health check prompt runs without errors
