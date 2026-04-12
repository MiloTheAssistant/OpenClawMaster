# CLAUDE.md — OpenClaw Command Center

> Session guidance for any AI agent working in this repository.
> Derived from the **GOTCHA Framework** (`GotchaFramework.md`) and governance rules (`AGENTS.md`).

---

## What This Repo Is

OpenClaw Command Center is a **governed multi-agent system** running 16 specialized AI agents across multiple model providers. The architecture follows the **GOTCHA Framework** — a 6-layer pattern that separates Goals, Orchestration, Tools, Context, Hard Prompts, and Args into distinct concerns.

Key principle: LLMs are probabilistic, business logic is deterministic. Reliability lives in deterministic tools and structured handoffs. Flexibility lives in LLM agents with defined roles. Nobody crosses lanes.

---

## Before You Start

1. **Read `GotchaFramework.md`** — the full operating framework
2. **Read `AGENTS.md`** — agent roster, authority chain, delegation flow
3. **Check `config/workflows.yaml`** — if a workflow exists for your task, follow it
4. **Check `config/routing.yaml`** — if a router profile fits, use it
5. **Check `config/tools_manifest.md`** — if a tool exists, use it — don't reinvent

Never build a custom task graph when a formation already exists.

---

## Agent Hierarchy

```
John (USER)
 └─ MILO (Governor) — intake, policy, HALT, final delivery
     └─ ELON (Orchestrator) — task graphs, fan-out/fan-in, clearance
         ├─ CORTANA (State) — memory, telemetry, artifact tracking
         ├─ SENTINEL (QA Gate) — approve/reject before output exits
         ├─ THEMIS (Legal Gate) — compliance, contracts, risk
         ├─ CERBERUS (Security Gate) — threats, incidents, posture
         └─ Specialists: PULSE, SAGAN, QUANT, NEO, CORNELIUS,
            HEMINGWAY, JONNY, KAIRO, ZUCK, HERMES
```

**Rules:**
- Only MILO delivers to John (ELON never delivers directly)
- HALT authority belongs exclusively to MILO
- Specialists return structured envelopes — no side effects, no direct user messaging
- SENTINEL is always last before output exits

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

---

## Development Rules

### Check before you build
- Check `config/workflows.yaml` and `config/routing.yaml` before starting any task
- Check `config/tools_manifest.md` before writing new code or scripts
- Read the full workflow definition — don't skim

### When modifying agents
- Agent prompts (`agents/*.md`) are fixed instructions — modify only with Milo approval
- Every agent must have a defined deliverable format compatible with Elon's fan-in
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
3. **Cornelius runs solo.** At 51GB, `qwen3-coder-next:latest` cannot share local memory with other models. Schedule as exclusive sequential step.
4. **No automatic shell execution.** Cornelius designs plans. Milo approves execution.
5. **Anthropic API is not approved** for OpenClaw harness use. Use only: Ollama Local, Ollama Pro, NIM Direct, ChatGPT Plus (Codex), Perplexity Pro, Z.ai.
6. **Pulse detects signals — Pulse does not analyze.** Deep analysis routes to Sagan.
7. **Elon never compiles or delivers to John.** He routes and clears only. Milo delivers.
8. **Run `docs/Init_Checklist.md`** after any crash or fresh start before accepting tasks.

---

## Failure Handling

Every failure generates a `FAILURE_ENVELOPE` per `docs/Handoff_Protocol.md`:

1. **First failure** — silent retry with same model
2. **Model unavailable** — retry with fallback from `config/models.yaml`
3. **Second failure** — Elon reroutes or marks branch as partial
4. **Required branch failure** — Milo is notified
5. **3 failures in 24h** — Cortana surfaces pattern and generates `GUARDRAIL_PROPOSAL`

When tools fail: read the error, fix the tool, document what you learned in the relevant workflow definition, log the failure through Cortana.

---

## Runtime Defaults

| Setting | Default | Notes |
|---|---|---|
| `PARALLEL_CAP` | 6 | Max concurrent specialist lanes |
| `RISK_MODE` | balanced | Can be elevated to `accuracy` |
| `EXECUTION_MODE` | simulate | Execute only when explicitly elevated |
| `max_concurrent_local_model_gb` | 45 | Memory ceiling for parallel local models |

Hardware: Mac Mini M4 Pro, 64GB unified memory (~8GB reserved for OS + services).

---

## Continuous Improvement

Every failure strengthens the system: Identify → Fix → Test → Document → Log → Auto-detect → Propose → Approve → Codify. Cortana monitors for recurring patterns (3+ failures in 24h) and generates guardrail proposals for Milo to approve.
