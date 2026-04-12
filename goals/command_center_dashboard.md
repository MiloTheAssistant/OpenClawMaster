# Command Center Dashboard — Kairo Task Prompt

**Workflow:** `kairo_build`
**Assigned to:** Kairo (frontend specialist)
**Repo:** `~/repos/ClawCode/dashboard/`
**Status:** Scaffolded — awaiting panel implementation

---

## Brief

Build the Command Center Dashboard — a Next.js 16 App Router app with 9 dark-mode panels showing live GOTCHA pipeline status, agent roster, cost tracking, 2Brain stats, memory ops, and system health.

## Scaffold (already done)
- Next.js 16 + Tailwind + shadcn/ui initialized
- API routes: `/api/agents`, `/api/costs`, `/api/memory`, `/api/health`
- Lib files: `sqlite.ts`, `gateway.ts`, `ollama.ts`, `config.ts`
- Main page with placeholder panel grid
- Dark mode (zinc-950 bg, indigo-500 accent)
- Geist Sans + Geist Mono fonts

## Panels to Implement
1. **Pipeline View** (hero) — horizontal GOTCHA flow with Framer Motion
2. **Agent Roster** — 16 agents, status, model, last invocation
3. **System Health** — Ollama, gateway, drive space
4. **Cost Tracker** — recharts bar/pie charts from brain.sqlite
5. **Workflow Monitor** — DFB schedule, last run, Sentinel verdict
6. **2Brain Stats** — wiki count, gaps, last health check
7. **Memory Ops** — scrollable feed, filterable by agent
8. **Decision Log** — from state/Decision_Log.md
9. **Channel Status** — Discord, Telegram, Email

## Design System
- Dark only (no light mode)
- shadcn/ui components (Card, Table, Badge, Tabs, ScrollArea)
- Framer Motion for agent transitions and panel loads
- Lucide React icons
- Recharts for cost visualization
- Responsive: 3-col (1440px), 2-col (768px), 1-col (375px)

## Data Sources
- OpenClaw Gateway: `http://localhost:18789` (agent status, health)
- Ollama: `http://localhost:11434` (model list, running models)
- brain.sqlite: `~/repos/2Brain/data/brain.sqlite` (costs, memory ops)
- Config files: `~/repos/OpenClawMaster/config/` (workflows, models)

## Delivery
Produce a `FRONTEND_PACKAGE` for Sentinel QA review. Must pass:
- All panels render (mock data OK for first pass)
- Responsive at all breakpoints
- No light mode leak
- `npm run build` succeeds
