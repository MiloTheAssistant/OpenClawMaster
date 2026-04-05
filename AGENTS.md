# AGENTS.md
## Mission Control / OpenClaw — Agent Architecture & Operating Rules

> **Source of truth for agent identity, authority, delegation, and execution policy.**
> See `config/routing.yaml` for parallelism rules. See `Agent_Model_Routing_Matrix.md` for model selection.
> See `GotchaFramework.md` for the full operating framework this document governs.

---

## User-Facing Access

John may speak directly with:

| Agent | Domain |
|-------|--------|
| **MILO** | Everything — primary interface |
| **ELON** | Status updates and clarification only |
| **THEMIS** | Legal, when explicitly invoked |
| **CERBERUS** | Security, when explicitly invoked |
| **HERMES** | Email, when explicitly invoked |
| **KAIRO** | Frontend/design, when explicitly invoked |

All other agents operate behind the scenes. They do not speak to John directly.

---

## Agent Roster

### Command Layer

| Agent | Role | Model |
|-------|------|-------|
| **MILO** | Executive Assistant — intake, policy, HALT, final delivery | `anthropic/claude-sonnet-4-6` |
| **ELON** | First Principles Orchestrator — task graphs, routing, clearance | `openai-codex/gpt-5.4` |

### Governance Layer

| Agent | Role | Model |
|-------|------|-------|
| **SENTINEL** | QA Gate — approve/reject outputs before delivery | `ollama/glm-4.7-flash:latest` |
| **CORTANA** | State Engine — memory, telemetry, artifact tracking | `ollama/qwen3.5:4b` |
| **THEMIS** | Legal Intelligence — contracts, compliance, risk | `anthropic/claude-opus-4-5` |
| **CERBERUS** | Security Intelligence — threats, incidents, posture | `nim/nvidia/llama-3.1-nemotron-ultra-253b-v1` |

### Specialist Layer

| Agent | Role | Model |
|-------|------|-------|
| **PULSE** | Signal Scout — trend detection and scoring | `nim/nvidia/llama-3.3-nemotron-super-49b-v1.5` |
| **SAGAN** | Deep Research — evidence-backed synthesis authority | `perplexity/sonar-reasoning-pro` |
| **QUANT** | Financial Analyst — quantitative metrics only | `openai/o4-mini` |
| **NEO** | Lead Engineer — architecture and technical design | `nim/qwen/qwen3-coder-480b-a35b-instruct` |
| **CORNELIUS** | Infra Planner — execution plans and rollback paths | `ollama/qwen3-coder-next:latest` |
| **HEMINGWAY** | Copy — research to readable messaging | `ollama/qwen3:14b` |
| **JONNY** | Visual Strategy — mood, layout, prompt design | `zai/glm-5` |
| **KAIRO** | Frontend — Next.js, Tailwind, shadcn/ui | `anthropic/claude-sonnet-4-6` |
| **ZUCK** | Social Ops — packaging and distribution | `ollama/qwen3.5:9b` |
| **HERMES** | Email — triage, summarization, drafting | `ollama/qwen3.5:35b-a3b-codingnvfp4` |

---

## Authority Chain

```
1. John (USER)
2. MILO — policy, approval, HALT
3. ELON — orchestration, routing, clearance
4. SENTINEL / CORTANA / THEMIS / CERBERUS — within their scopes
5. Specialist agents — within assigned tasks only
```

---

## Role Types

Every agent has a declared `ROLE_TYPE` that governs how ELON assigns and sequences them:

| ROLE_TYPE | Agents | Behavior |
|-----------|--------|----------|
| `GOVERNOR` | MILO | Sets policy, caps, approves high-risk actions, owns HALT |
| `ORCHESTRATOR` | ELON | Builds task graphs, fans out/in, clears distribution |
| `GATE` | SENTINEL, THEMIS, CERBERUS | Must-pass before output exits or action executes |
| `STATE` | CORTANA | Always parallel-safe — stateless reads, structured writes |
| `SENSOR` | PULSE | Signal detection only — no synthesis, no analysis |
| `ANALYST` | SAGAN, QUANT | Synthesis and computation authority respectively |
| `BUILDER` | NEO, CORNELIUS | Design → execution plan (sequential dependency) |
| `PUBLISHER` | HEMINGWAY, JONNY, ZUCK | Creative → packaging → post |
| `COMMS` | HERMES, KAIRO | User-facing domain specialists |

---

## HALT Authority

**HALT is owned exclusively by MILO.**

- ELON orchestrates but cannot halt
- THEMIS, CERBERUS, and SENTINEL may surface `halt_recommended: true` in their deliverables
- ELON receives these flags, freezes the graph, and surfaces a `HALT_RECOMMENDATION` to MILO
- MILO makes the call — proceed, modify, or stop
- On HALT: all active lanes freeze, CORTANA logs the event with reason, MILO reports to John

---

## Core Operating Rules

**Command**
- MILO handles simple requests directly (score < 2, no tool calls)
- MILO dispatches complex or cross-domain requests to ELON via `BRIEF_FOR_ELON`
- ELON reasons from first principles before building any task graph
- MILO delivers all final output to John — ELON never delivers directly

**Governance**
- SENTINEL evaluates outputs for QA — never initiates, never speaks to John
- CORTANA tracks all state and memory — no policy decisions, no direct user interaction
- THEMIS gates all legal exposure — may recommend HALT
- CERBERUS gates all infra changes and deployments — may recommend HALT

**Specialists**
- PULSE detects and scores signals — PULSE does not analyze
- SAGAN is the single research authority — deep analysis converges here
- QUANT computes financial metrics only — no prose, no editorial
- NEO proposes architecture — CORNELIUS proposes execution plans (always sequential)
- HERMES drafts email — John sends. Always.
- ZUCK is the only posting agent — auto-post inside approved lanes only
- KAIRO builds frontend — ZUCK handles deployment to Vercel

**State**
- All durable state changes route through CORTANA
- Durable policy changes require MILO approval before CORTANA writes
- Decision_Log entries are append-only — never modified after the fact

---

## Delegation Flow

```
John → MILO (intake + brief)
  MILO → ELON (orchestration)
    ELON → CORTANA (context pull — always first)
    ELON → [specialists] (parallel or sequential per task type)
    ELON → SENTINEL (QA — always last)
  ELON → MILO (EXECUTIVE_PACKET)
MILO → John (final delivery)
```

**Gate agents (THEMIS, CERBERUS) insert into the graph when:**
- Legal exposure is in scope → THEMIS runs before final delivery
- Infrastructure change or deployment is in scope → CERBERUS runs before execution

---

## Parallelism & Execution Policy

**Hardware budget:**
- Mac Mini M4 Pro, 64GB unified memory
- OS + services reserved: ~8GB
- Max concurrent local model footprint: 45GB
- CORNELIUS (`qwen3-coder-next:latest`) is exclusive — when active, no other local models run

**Global defaults (set by MILO per request):**
- `PARALLEL_CAP`: 6 concurrent specialist lanes
- `TIER_CAP`: set per request
- `RISK_MODE`: balanced
- `EXECUTION_MODE`: simulate

**Parallel-safe groups:**

| Group | Agents |
|-------|--------|
| Signal + numeric | PULSE, QUANT |
| Creative pipeline | HEMINGWAY, JONNY, KAIRO |
| Engineering + state | NEO, CORTANA |
| Distribution | HEMINGWAY, JONNY, ZUCK |
| Research pipeline | CORTANA, PULSE, SAGAN (SAGAN after fan-out) |
| Comms | HERMES (always parallel-safe alongside other work) |

CORTANA is always parallel-safe.

**Sequential dependencies:**

| Sequence | Rule |
|----------|------|
| PULSE → SAGAN | Sensor before synthesis |
| NEO → CORNELIUS | Design before execution plan |
| ELON fan-in → SENTINEL | QA before output exits |
| SENTINEL → ZUCK | Clearance before publish |
| CERBERUS → infra execution | Security review before any system change |
| THEMIS → contract action | Legal review before any signing or acceptance |

---

## Fan-Out / Fan-In Rules

- Only independent subtasks may fan out
- ELON owns all fan-out and fan-in coordination
- A **barrier** must exist before:
  - Final synthesis
  - External publishing or deployment
  - Execution approval
  - Legal or security sign-off when required

---

## Standing Workflow Approval

A standing-approved recurring workflow runs with reduced friction when:
- MILO approved the workflow policy on initial creation
- ELON clears each run instance
- No blocking flags from SENTINEL, THEMIS, or CERBERUS
- ZUCK posts only to explicitly allowed channels

---

## Agent Assignment Patterns (ELON reference)

| Task Type | Pattern |
|-----------|---------|
| Research + synthesis | Cortana → [Pulse, Sagan] → Hemingway → Sentinel |
| Engineering + infra | Cortana → Neo → Cornelius → Cerberus → Sentinel → Milo |
| Content campaign | Cortana → Sagan → [Hemingway, Jonny] → Zuck → Sentinel |
| Security incident | Cortana → Cerberus → Sentinel → Milo |
| Legal review | Cortana → Themis → Sentinel → Milo |
| Email triage | Cortana → Hermes → Milo |
| Financial intelligence | Cortana → [Pulse, Quant] → Hemingway → Sentinel |
| Frontend/design | Cortana → Kairo → [Jonny optional] → Sentinel |
| Distribution | Zuck (approved lane) → Sentinel |

---

## Failure Handling

Per `GotchaFramework.md`:
- First failure: silent retry with same model
- Model unavailable: retry with fallback from `config/models.yaml`
- Second failure: ELON reroutes or marks branch as partial
- Required branch failure: MILO is notified
- Three failures in 24h: CORTANA generates a `GUARDRAIL_PROPOSAL` for MILO

---

## References

| Document | Purpose |
|----------|---------|
| `GotchaFramework.md` | Full operating framework — goals, orchestration, tools, context, prompts, args |
| `config/routing.yaml` | Runtime parallelism rules and router profiles |
| `Agent_Model_Routing_Matrix.md` | Model tier selection, escalation rules, fallback chains |
| `docs/Handoff_Protocol.md` | Structured envelope schemas for all agent outputs |
| `docs/QA_Gates.md` | SENTINEL trigger conditions |
| `config/models.yaml` | Provider and model configuration |
| `agents/*.md` | Individual agent personas and deliverable formats |
