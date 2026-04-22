# CLAUDE.md — OpenClaw Master Configuration

> Session guidance for any AI agent working in this repository.
> Derived from the **GOTCHA Framework** (`GotchaFramework.md`) and governance rules (`AGENTS.md`).

---

## What This Repo Is

The **OpenClawMaster** repository is the source of truth for a governed multi-agent system (Phase 5: 7 agents) running across multiple model providers. The architecture follows the **GOTCHA Framework** — a 6-layer pattern that separates Goals, Orchestration, Tools, Context, Hard Prompts, and Args into distinct concerns.

Key principle: LLMs are probabilistic, business logic is deterministic. Reliability lives in deterministic tools and structured handoffs. Flexibility lives in LLM agents with defined roles. Nobody crosses lanes.

## Operational Dashboards

This repo is the configuration source. Live operations run through these dashboards:

| Dashboard | URL | Purpose |
|---|---|---|
| **Mission Control** | `http://localhost:3100` | Task boards, approvals, activity feed, work orchestration |
| **OpenClaw Control UI** | `http://localhost:18789` (run `openclaw dashboard`) | Native agent/session/skill/cron monitoring |

**The legacy Command Center dashboard at `localhost:3000` has been retired.** Use Mission Control for work and OpenClaw Control UI for agent health. The 2Brain Viewer (`localhost:3200`) has also been decommissioned.

---

## Before You Start

1. **Read `GotchaFramework.md`** — the full operating framework
2. **Read `AGENTS.md`** — agent roster, authority chain, delegation flow
3. **Check `config/workflows.yaml`** — if a workflow exists for your task, follow it
4. **Check `config/routing.yaml`** — if a router profile fits, use it
5. **Check `config/tools_manifest.md`** — if a tool exists, use it — don't reinvent

Never build a custom task graph when a formation already exists.

---

## Agent Hierarchy (Phase 5: 7 agents)

```
John (USER)
 └─ MILO (Executive Assistant & Orchestrator) — intake, dispatch, HALT authority
     ├─ SAGAN     — deep research, web-grounded analysis
     ├─ NEO       — lead engineer, architecture, coding
     ├─ HERMES    — communications (Discord, Telegram, email)
     ├─ SENTINEL  — QA gate, output validation
     ├─ CORTANA   — state, memory, telemetry
     └─ CORNELIUS — infra planning, heavy coding (runs solo)
```

**Rules:**
- Milo is the only agent that speaks to John directly
- Milo absorbs Elon's role — no separate orchestrator (Elon retired in Phase 5)
- Milo dispatches via `sessions_spawn` with `agentId` — never spawns anonymous subagents
- Multi-step workflows: Milo orchestrates sequentially (dispatch → await → next dispatch)
- HALT authority belongs exclusively to Milo
- Specialists return structured results — no side effects unless explicitly allowed (Hermes for comms, Cornelius for infra)

---

## Key File Locations

| Category | Files |
|---|---|
| **Workflows** | `config/workflows.yaml`, `config/workflows_manifest.md` |
| **Routing** | `config/routing.yaml`, `docs/Router_Profiles.md` |
| **Tools** | `config/tools.yaml` (canonical), `config/tools_manifest.md` (index) |
| **Models** | `config/models.yaml`, `docs/Agent_Model_Routing_Matrix.md` |
| **Agent Prompts** | `agents/*.md` |
| **Governance** | `AGENTS.md`, `docs/QA_Gates.md`, `docs/Execution_Modes.md` |
| **State** | `state/Active_Projects.md`, `state/Decision_Log.md`, `state/Artifacts_Index.md` |
| **Memory** | `state/memory/MEMORY.md`, `state/memory/logs/YYYY-MM-DD.md` |
| **Protocols** | `docs/Handoff_Protocol.md`, `docs/State_Schema.md`, `docs/Task_Lifecycle.md` |
| **Parallelism** | `config/parallelism.yaml`, `docs/Parallel_Execution_Rules.md` |
| **Channels** | `config/channels.yaml` |
| **Mission Control** | `config/mission-control.yaml` — board IDs, custom fields, API base |
| **Scripts** | `tools/scripts/mc-push.sh`, `tools/scripts/sync-decisions.sh`, `tools/scripts/gateway-restart.sh`, `tools/scripts/sync-agents-models.sh`, `tools/scripts/model-health-check.sh` |

---

## Development Rules

### Check before you build
- Check `config/workflows.yaml` and `config/routing.yaml` before starting any task
- Check `config/tools_manifest.md` before writing new code or scripts
- Read the full workflow definition — don't skim

### When modifying agents
- Agent prompts (`agents/*.md`) are fixed instructions — modify only with Milo approval
- Every agent must have a defined deliverable format compatible with Milo's sequential dispatch
- Task-specific prompts are separate from identity prompts

### When modifying tools
- Add new tools to the tool registry with: type, description, implementation, permissions, restrictions
- Verify tool output format before chaining into another agent's handoff — format mismatches are silent failures
- Never assume APIs support batch operations — check first

### When modifying workflows
- Workflows are living documents — update when better approaches or API constraints emerge
- Never modify workflow definitions without Milo approval

### State changes
- All durable state changes route through CORTANA
- Facts and events: CORTANA writes automatically
- Policy-level changes: require MILO approval before CORTANA writes
- `Decision_Log` entries are append-only — never modify past entries

---

## Guardrails

Hard-won rules from production failures. Violating these has caused real issues.

1. **Never expose API keys or tokens** in chat, logs, or handoff packets. If a token is exposed, rotate immediately.
2. **Path casing matters.** Username is lowercase `milo`, not `Milo`.
3. **Milo is male.** Use he/him pronouns in code comments and documentation.
4. **Cornelius runs solo.** At 48.2GB, `qwen3-coder-next:latest` cannot share local memory with other models. Schedule as exclusive sequential step.
5. **No automatic shell execution.** Cornelius designs plans. Milo approves execution.
6. **Anthropic API is not approved** for OpenClaw harness use. Use only: Ollama Local, Ollama Pro, NIM Direct, ChatGPT Plus (Codex), Perplexity Pro, Z.ai.
7. **Milo dispatches via `sessions_spawn` with `agentId`.** Never spawn anonymous subagents — they have no tool access.
8. **Mission Control is the work dashboard.** Push tasks via `tools/scripts/mc-push.sh` — never duplicate state in the retired Command Center.
9. **Run `docs/Init_Checklist.md`** after any crash or fresh start before accepting tasks.

---

## Failure Handling

Every failure generates a `FAILURE_ENVELOPE` per `docs/Handoff_Protocol.md`:

1. **First failure** — silent retry with same model
2. **Model unavailable** — retry with fallback from `config/models.yaml`
3. **Second failure** — Milo reroutes or marks step as partial
4. **Required branch failure** — Milo is notified
5. **3 failures in 24h** — Cortana surfaces pattern and generates `GUARDRAIL_PROPOSAL`

When tools fail: read the error, fix the tool, document what you learned in the relevant workflow definition, log the failure through Cortana.

---

## Runtime Defaults

| Setting | Default | Notes |
|---|---|---|
| `PARALLEL_CAP` | 4 | Max concurrent specialist lanes (reduced from 6 in Phase 5) |
| `RISK_MODE` | balanced | Can be elevated to `accuracy` |
| `EXECUTION_MODE` | simulate | Execute only when explicitly elevated |
| `max_concurrent_local_model_gb` | 45 | Memory ceiling for parallel local models |

**Hardware:** Mac Mini M4 Pro, 64GB unified memory (~8GB reserved for OS + services).

**LLM providers:**
- Local (Ollama): `qwen3.5:4b`, `qwen3.5:9b`, `qwen3-coder-next:latest`, `glm-4.7-flash`, `gemma4:26b`, `nomic-embed-text`
- Cloud (Ollama Pro): `glm-5.1:cloud`, `minimax-m2.7:cloud`, `gemma4:31b-cloud`, `gpt-oss:120b-cloud`
- Codex (ChatGPT Pro): `gpt-5.4`, `o4-mini`
- NIM: `qwen/qwen3-coder-480b-a35b-instruct`, `nvidia/llama-3.1-nemotron-ultra-253b-v1`
- Perplexity: `sonar-reasoning-pro`, `sonar-pro`
- Z.ai: `glm-5.1-turbo`, `glm-5.1v-turbo`

---

## Continuous Improvement

Every failure strengthens the system: Identify → Fix → Test → Document → Log → Auto-detect → Propose → Approve → Codify. Cortana monitors for recurring patterns (3+ failures in 24h) and generates guardrail proposals for Milo to approve.
