# Phase 7: Command Center Dashboard — Kairo Builds

## Context
Kairo builds a custom Command Center Dashboard — a Next.js app deployed to Vercel and running locally. Dark mode, real-time, beautiful. Loads in the macOS Companion App Canvas for always-on visibility.

---

## 7.1 — Deployment Strategy

| Environment | URL | Purpose |
|---|---|---|
| **Local** | `http://localhost:3000` | Development + Companion App Canvas |
| **Vercel** | `https://command-center-xxx.vercel.app` | Remote access (phone, iPad, anywhere) |
| **Custom domain** | TBD (purchase later) | Production — e.g. `command.openclaw.dev` |

Both environments read from the same data sources — the local OpenClaw gateway and 2Brain SQLite.

**Vercel note:** For remote access, the dashboard needs an API layer that's publicly reachable, OR the Vercel deployment shows cached/snapshot data refreshed periodically. Live WebSocket to the local gateway only works when on the same network (or via Tailscale).

---

## 7.2 — Dashboard Panels

### Pipeline View (Hero Panel)
Live GOTCHA flow visualization:
- Horizontal pipeline: Cortana → [Specialists] → Sentinel → Milo → Delivery
- Active agents glow with indigo accent (#6366f1)
- Completed stages show green checkmark
- Failed stages show red with failure reason on hover
- Framer Motion animations for agent transitions

### Agent Roster
| Column | Data |
|---|---|
| Agent name + icon | From agents/*.md |
| Status | idle / active / error / exclusive |
| Current model | From models.yaml + live gateway data |
| Last invocation | Timestamp |
| Provider | Local / NIM / Codex / Perplexity / Z.ai |

### Workflow Monitor
| Column | Data |
|---|---|
| Workflow name | DFB, Signal Scanner, Content Engine |
| Schedule | From workflows.yaml |
| Last run | Timestamp + pass/fail |
| Next run | Calculated from schedule |
| Sentinel verdict | approved / conditional / rejected |
| Output link | → 2Brain briefings archive |

### Cost Tracker
- Per-agent token usage (bar chart, daily/weekly/monthly toggle)
- Per-provider cost breakdown (pie chart)
- Running total with trend line
- Data from: `2Brain/data/brain.sqlite → cost_tracker`

### 2Brain Stats
- Wiki article count + recent additions
- Last health check date + results summary
- Knowledge gaps flagged
- Raw source count
- Data from: `2Brain/wiki/INDEX.md` + file system stats

### Memory Ops Log (Transparency Panel)
- Scrollable feed of every agent read/write/search
- Filterable by agent, operation type, date
- Shows content preview for writes
- Data from: `2Brain/data/brain.sqlite → memory_ops_log`

### Decision Log
- Recent decisions from `state/Decision_Log.md`
- Filterable by authority (Milo, Elon)
- Links to context

### System Health
- Ollama status (running/stopped, models loaded, memory usage)
- Gateway status (connected/disconnected, uptime)
- Drive space on 4TB volume
- Last heartbeat result
- Data from: Ollama API (`http://localhost:11434`), gateway health endpoint, heartbeat.sh

### Channel Status
- Discord: last post, channel, delivery status
- Telegram: last message, recipient
- Email: pending drafts
- Standing approvals active
- Data from: `config/channels.yaml` + Cortana logs

---

## 7.3 — Design Spec (Kairo's Brief)

```
Design System:
  framework: Next.js 16 App Router
  styling: Tailwind CSS + shadcn/ui
  typography: Geist Sans (UI) + Geist Mono (metrics/code)
  motion: Framer Motion (agent transitions, panel loads)
  color: 
    background: zinc-950
    surface: zinc-900
    accent: #6366f1 (indigo)
    success: emerald-500
    error: rose-500
    warning: amber-500
  icons: Lucide React
  mode: Dark only (no light mode toggle — this is a command center)

Layout:
  desktop (1440px): 3-column grid — pipeline hero spans full width top,
                     panels in responsive grid below
  tablet (768px): 2-column, pipeline stacks vertically
  mobile (375px): Single column, panels as collapsible cards

Real-time:
  - WebSocket to OpenClaw gateway for live agent status
  - Poll 2Brain SQLite every 30s for cost/memory data
  - Framer Motion for smooth data transitions (no jarring refreshes)
```

---

## 7.4 — Tech Stack

```
ClawCode/dashboard/
├── app/
│   ├── layout.tsx           # Root layout — dark theme, fonts
│   ├── page.tsx             # Main dashboard grid
│   ├── api/
│   │   ├── agents/route.ts  # Agent status from gateway
│   │   ├── costs/route.ts   # Cost data from brain.sqlite
│   │   ├── memory/route.ts  # Memory ops from brain.sqlite
│   │   ├── health/route.ts  # System health aggregation
│   │   └── workflows/route.ts  # Workflow status
│   └── (panel pages for drill-down)
├── components/
│   ├── pipeline-view.tsx    # Hero GOTCHA flow visualization
│   ├── agent-roster.tsx     # Agent grid with status
│   ├── workflow-monitor.tsx # Workflow cards
│   ├── cost-tracker.tsx     # Charts (recharts or tremor)
│   ├── brain-stats.tsx      # 2Brain knowledge metrics
│   ├── memory-feed.tsx      # Scrollable memory ops log
│   ├── decision-log.tsx     # Decision history
│   ├── system-health.tsx    # Ollama/gateway/drive status
│   └── channel-status.tsx   # Distribution channel status
├── lib/
│   ├── sqlite.ts            # better-sqlite3 queries to brain.sqlite
│   ├── gateway.ts           # WebSocket client to OpenClaw gateway
│   ├── ollama.ts            # Ollama API client
│   └── config.ts            # Paths, env vars
├── public/
│   └── favicon.ico
├── package.json
├── next.config.js
├── tailwind.config.js
└── vercel.json
```

### Key Dependencies
```json
{
  "dependencies": {
    "next": "^16",
    "react": "^19",
    "tailwindcss": "^4",
    "@shadcn/ui": "latest",
    "framer-motion": "^12",
    "lucide-react": "latest",
    "better-sqlite3": "^11",
    "recharts": "^3",
    "geist": "latest"
  }
}
```

---

## 7.5 — Vercel Deployment

```bash
cd ~/repos/ClawCode/dashboard

# Install dependencies
npm install

# Link to Vercel
vercel link

# Deploy (non-custom domain)
vercel deploy --prod

# Result: https://command-center-xxx.vercel.app
```

### vercel.json
```json
{
  "buildCommand": "next build",
  "outputDirectory": ".next",
  "framework": "nextjs",
  "regions": ["iad1"]
}
```

### Vercel Environment Variables
Set in Vercel dashboard:
- `TWOBRAIN_SQLITE_PATH` — for serverless: use Vercel KV or snapshot strategy
- `GATEWAY_URL` — `http://localhost:18789` (local only; Vercel needs Tailscale or snapshot)

**Note:** Full real-time on Vercel requires either:
1. **Tailscale** — tunnel gateway to the internet (enable in openclaw.json)
2. **Snapshot mode** — ClawCode cron job exports state snapshots to Vercel KV every 5 minutes
3. **Hybrid** — local runs live WebSocket, Vercel runs cached data with manual refresh

Recommend: **Start with local + snapshot mode for Vercel.** Add Tailscale when ready for full remote real-time.

---

## 7.6 — Companion App Canvas Integration

The macOS Companion App's Canvas feature loads any URL. Point it at the local dashboard:

```
Canvas URL: http://localhost:3000
```

This gives always-on dashboard visibility from the menu bar — click the OpenClaw menu bar icon → Canvas panel shows the full Command Center Dashboard with live data.

---

## 7.7 — GOTCHA Workflow to Build It

```
John → Milo ("Build the Command Center Dashboard")
  Milo → Elon (BRIEF_FOR_ELON, complexity 4)
    Elon → Cortana (pull current state, active projects)
    Elon → Jonny (VISUAL_BRIEF — mood board, color system, layout hierarchy)
    Elon → Kairo (receives Jonny's brief + goals/command_center_dashboard.md)
      Kairo → produces FRONTEND_PACKAGE
    Elon → Sentinel (QA review — no placeholder UI, responsive, dark mode)
    Elon → Milo (EXECUTIVE_PACKET with preview URL)
  Milo → John (preview at localhost:3000)
  John approves
    Milo → Zuck (deploy to Vercel)
    Cortana → logs artifact in Artifacts_Index.md
```

---

## Files to Create

- `goals/command_center_dashboard.md` — Kairo's task prompt with all specs above
- `ClawCode/dashboard/` — entire Next.js project
- `ClawCode/dashboard/vercel.json` — Vercel config

## Files to Update

- `config/tools.yaml` — add dashboard deployment tool
- `state/Active_Projects.md` — add Command Center Dashboard project

---

## Verification

- [ ] `npm run dev` works at localhost:3000
- [ ] All 9 panels render with mock data
- [ ] WebSocket connects to local gateway
- [ ] SQLite queries return cost/memory data from brain.sqlite
- [ ] Responsive at 375px, 768px, 1440px
- [ ] Deployed to Vercel — loads at public URL
- [ ] Canvas in Companion App shows dashboard
- [ ] Framer Motion animations work on agent transitions
- [ ] Dark mode — no light mode leak
