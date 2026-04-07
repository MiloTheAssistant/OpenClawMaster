# Phase 5: Skills & Tools Integration

## Context
Wire up the tools and skills the Command Center needs: Composio MCP (500+ apps), SQLite, GitHub, Google Workspace, Vercel, and select community skills. Prefer single integrations that cover multiple needs.

---

## 5.1 — Composio MCP (The Big One)

Composio's single MCP server connects OpenClaw to 500+ apps with managed authentication. This covers several requirements in one install.

### What It Replaces / Consolidates

| Requirement | Without Composio | With Composio |
|---|---|---|
| GitHub | `gh` CLI + GITHUB_TOKEN | Composio GitHub adapter (auth managed) |
| Google Workspace | 2 separate Gmail MCP servers | Composio Google adapter (Gmail, Calendar, Docs, Sheets, Drive) |
| Vercel | `vercel` CLI + manual auth | Composio Vercel adapter |
| Discord | Custom webhook in tools.yaml | Composio Discord adapter |
| Slack | Not configured | Composio Slack adapter (free addition) |

### Install

```bash
# Method 1: OpenClaw plugin (recommended — tracks upgrades)
npx skills add https://github.com/composiohq/skills --skill composio --yes

# Method 2: Manual MCP config
# Get consumer key from dashboard.composio.dev
# Add to openclaw.json MCP servers section
```

### openclaw.json MCP Entry
```json
{
  "mcpServers": {
    "composio": {
      "command": "npx",
      "args": ["@composio/mcp-server"],
      "env": {
        "COMPOSIO_API_KEY": "${COMPOSIO_API_KEY}"
      }
    }
  }
}
```

### Apps to Activate in Composio Dashboard
1. **GitHub** — repo management, PRs, issues (replaces `gh` CLI dependency)
2. **Gmail** — inbox triage, draft creation (replaces 2 Gmail MCP servers)
3. **Google Calendar** — scheduling awareness for Milo
4. **Google Sheets** — data export for Quant/financial workflows
5. **Google Drive** — document storage for 2Brain raw sources
6. **Vercel** — deployment for Kairo's dashboard and DFB website
7. **Discord** — DFB delivery, notifications (replaces custom webhook)
8. **Telegram** — alerts, Milo DMs (replaces custom bot setup)

### Environment Variable
Add to `~/.openclaw/.env`:
```bash
COMPOSIO_API_KEY=your_key_here
```

---

## 5.2 — SQLite (2Brain Data Layer)

SQLite handles structured data in 2Brain — cost tracking, memory operations log, and smart-memory embeddings. No Postgres dependency.

### Tables

**brain.sqlite** (migrated from `~/.openclaw/workspace/smart-memory/`):
- Existing smart-memory tables (preserve as-is during migration)

**New tables to add:**

```sql
-- Cost tracking (Cortana writes on every API call)
CREATE TABLE cost_tracker (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  timestamp TEXT NOT NULL DEFAULT (datetime('now')),
  agent TEXT NOT NULL,
  provider TEXT NOT NULL,
  model TEXT NOT NULL,
  tokens_in INTEGER DEFAULT 0,
  tokens_out INTEGER DEFAULT 0,
  estimated_cost_usd REAL DEFAULT 0.0,
  workflow TEXT,
  session_id TEXT
);

-- Memory operations transparency log
CREATE TABLE memory_ops_log (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  timestamp TEXT NOT NULL DEFAULT (datetime('now')),
  agent TEXT NOT NULL,
  operation TEXT NOT NULL,  -- 'read', 'write', 'search', 'embed'
  query TEXT,
  result_count INTEGER,
  content_preview TEXT,     -- first 200 chars
  session_id TEXT
);

-- Indexes for dashboard queries
CREATE INDEX idx_cost_timestamp ON cost_tracker(timestamp);
CREATE INDEX idx_cost_agent ON cost_tracker(agent);
CREATE INDEX idx_memops_timestamp ON memory_ops_log(timestamp);
CREATE INDEX idx_memops_agent ON memory_ops_log(agent);
```

### Schema Files Location
```
ClawCode/tools/sqlite/
├── cost_tracker_schema.sql
├── memory_ops_schema.sql
└── query.py                # CLI tool for direct queries
```

---

## 5.3 — Select Awesome-Claude-Skills

From `github.com/ComposioHQ/awesome-claude-skills`, install these for the base config:

| Skill | Why | Install |
|---|---|---|
| **google-workspace-skills** | Full Google suite integration (Gmail, Calendar, Docs, Sheets) | `npx skills add ... --skill google-workspace-skills` |
| **deep-research** | Autonomous multi-step research using Gemini — complements Sagan | `npx skills add ... --skill deep-research` |
| **tapestry** | Interlinks and summarizes related documents — perfect for 2Brain wiki compilation | `npx skills add ... --skill tapestry` |
| **subagent-driven-development** | Dispatches independent subagents for tasks — aligns with Elon's fan-out pattern | `npx skills add ... --skill subagent-driven-development` |
| **youtube-transcript** | Fetches video transcripts — useful for 2Brain raw source ingestion | `npx skills add ... --skill youtube-transcript` |
| **article-extractor** | Extracts full article text from URLs — feeds 2Brain raw/ | `npx skills add ... --skill article-extractor` |

### Skills to Evaluate Later (not base config)
- **postgres** — if we ever need relational data beyond SQLite
- **computer-forensics** — useful for Cerberus security investigations
- **n8n-skills** — if workflow automation needs grow beyond GOTCHA
- **Playwright Browser Automation** — if Kairo needs automated UI testing

---

## 5.4 — GitHub CLI (Keep as Backup)

Even with Composio, keep `gh` CLI installed for direct terminal use:
```bash
brew install gh
gh auth login
```

---

## 5.5 — Vercel CLI (Keep as Backup)

For manual deployments outside Composio:
```bash
npm install -g vercel
cd ~/repos/ClawCode/dashboard && vercel link
```

---

## 5.6 — Gmail MCP Servers (Deprecate After Composio)

The current 2 Gmail MCP servers (ports 3333 and 3335) can be deprecated once Composio's Google adapter is verified working. Keep the config docs in ClawCode for reference but remove from `openclaw.json` MCP servers.

---

## Files to Update

- `openclaw.json` — add Composio MCP server, remove Gmail MCP servers (after verification)
- `~/.openclaw/.env` — add COMPOSIO_API_KEY
- `config/tools.yaml` — add Composio-backed tools
- `config/tools_manifest.md` — update index
- `2Brain/data/brain.sqlite` — run schema migrations for new tables

---

## Verification

- [ ] Composio MCP server responds in OpenClaw
- [ ] GitHub operations work via Composio (test: list repos)
- [ ] Gmail operations work via Composio (test: list inbox)
- [ ] Vercel deployment works via Composio
- [ ] SQLite tables created in 2Brain/data/brain.sqlite
- [ ] All 6 community skills installed and functional
- [ ] Cost tracker logs a test entry
- [ ] Memory ops log captures a test read/write
