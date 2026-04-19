# AGENTS.md
## OpenClaw — Agent Architecture & Operating Rules (Phase 5)

> **Source of truth for agent identity, authority, delegation, and execution policy.**
> See `config/models.yaml` for model assignments. See `config/routing.yaml` for routing profiles.
> See `docs/Agent_Model_Routing_Matrix.md` for escalation rules.
> See `GotchaFramework.md` for the full operating framework this document governs.

---

## User-Facing Access

John speaks directly with **MILO** only. All other agents operate behind the scenes.
John may explicitly invoke `hermes` for comms or `sentinel` for QA if needed.

---

## Agent Roster (Phase 5: Streamlined — 7 agents)

### Command Layer

| Agent | Role Type | Role | Primary Model |
|-------|-----------|------|---------------|
| **MILO** | `EXECUTIVE_ASSISTANT` | John's 1:1 interface — intake, dispatch, orchestration, HALT authority | `codex/o4-mini` |

### Core Specialists

| Agent | Role Type | Role | Primary Model |
|-------|-----------|------|---------------|
| **SAGAN** | `ANALYST` | Deep Research — evidence-backed synthesis, web-grounded analysis | `perplexity/sonar-reasoning-pro` |
| **NEO** | `BUILDER` | Lead Engineer — architecture, technical design, coding | `nim/qwen/qwen3-coder-480b-a35b-instruct` |
| **HERMES** | `COMMS` | Communications — Discord, Telegram, email, all outbound messaging | `ollama_cloud/glm-5.1:cloud` |
| **SENTINEL** | `GATE` | QA Gate — validate output quality, security checks, pre-delivery review | `ollama_cloud/glm-5.1:cloud` |
| **CORTANA** | `STATE` | State & Memory — memory writes, telemetry, artifact tracking, state updates | `ollama_local/qwen3.5:4b` |
| **CORNELIUS** | `BUILDER` | Infra & Planning — execution plans, infra changes, rollback paths, heavy coding | `ollama_local/qwen3-coder-next:latest` |

### Retired Agents (available for reactivation when proven workflows need them)

Elon, Pulse, Quant, Hemingway, Jonny, Kairo, Zuck, Themis, Cerberus, Sentinel-RT

**Approved providers:** Ollama Local, Ollama Pro (cloud), NIM Direct, ChatGPT Plus (Codex), Perplexity Pro, Z.ai
**Not approved:** Anthropic API (policy conflict with OpenClaw harness)

---

## Authority Chain

```
1. John (USER)
2. MILO — intake, dispatch, orchestration, HALT authority, delivery
3. SENTINEL / CORTANA — quality + state within their scopes
4. Specialists (SAGAN, NEO, HERMES, CORNELIUS) — within assigned tasks only
```

---

## Role Types

| ROLE_TYPE | Agents | Behavior |
|-----------|--------|----------|
| `EXECUTIVE_ASSISTANT` | MILO | John's 1:1 interface + orchestrator — intake, dispatch (via `sessions_spawn` with `agentId`), compile results, HALT authority, delivery. Owns HALT exclusively. |
| `GATE` | SENTINEL | Must-pass quality check — may surface `halt_recommended: true` to MILO |
| `STATE` | CORTANA | Always parallel-safe — stateless reads, structured writes, no policy decisions |
| `ANALYST` | SAGAN | Deep research and synthesis authority |
| `BUILDER` | NEO, CORNELIUS | Architecture (NEO) → execution plan + heavy coding (CORNELIUS). Sequential. |
| `COMMS` | HERMES | All outbound messaging — Discord, Telegram, email |

---

## HALT Authority

**HALT is owned exclusively by MILO.**

- Specialists (Sentinel, Sagan, Neo, Cornelius, Hermes) may return `halt_recommended: true` in their structured output
- Milo freezes the active dispatch chain and decides — proceed, modify, or stop
- On HALT: all active lanes freeze, CORTANA logs the event with reason, MILO reports to John

---

## Core Operating Rules

**Command**
- MILO is John's 1:1 interface — every request enters through Milo
- MILO handles trivial requests directly (score < 2, no tool calls); everything else gets dispatched
- MILO dispatches via `sessions_spawn` with `agentId` — never spawns anonymous subagents
- MILO orchestrates sequentially, compiling each specialist's output before dispatching the next step
- Specialists return structured envelopes — no side effects, no direct user messaging
- MILO is the only delivery path to John
- Milo is male — use he/him pronouns

**Governance**
- SENTINEL evaluates outputs — never initiates, never speaks to John
- CORTANA tracks all state and memory — no policy decisions, no user interaction

**Specialists**
- SAGAN is the single research authority — all deep synthesis converges here
- NEO proposes architecture — CORNELIUS converts to execution plans — sequential, always
- CORNELIUS runs solo — heavy local model (~48.2GB); all other local agents route to cloud during his runs
- HERMES owns all outbound comms — Discord, Telegram, email. Drafts email; John sends. Always.

**State**
- All durable state changes route through CORTANA
- Facts and events: CORTANA writes automatically
- Policy-level changes: require MILO approval before CORTANA writes
- Decision_Log entries are append-only — never modify past entries

---

## Delegation Flow

```
John → MILO (intake, complexity score)
  ├── Trivial, no tools → MILO answers directly
  └── Dispatch-required →
      MILO → CORTANA (context pull when needed)
      MILO → [specialist] via sessions_spawn(agentId=...)
      MILO ← result
      MILO → [next specialist in sequence] if multi-step
      MILO → SENTINEL (QA — when output will ship or change state)
      MILO → John (delivery)
```

---

## Parallelism & Execution Policy

**Hardware budget:**
- Mac Mini M4 Pro, 64GB unified memory
- OS + services reserved: ~8GB
- Max concurrent local model footprint: 45GB
- CORNELIUS (`qwen3-coder-next:latest`, ~48.2GB) is exclusive — all other local models must be unloaded first

**Global defaults (set by MILO per request):**
- `PARALLEL_CAP`: 4 concurrent specialist lanes
- `TIER_CAP`: set per request
- `RISK_MODE`: balanced
- `EXECUTION_MODE`: simulate

**Parallel-safe groups:**

| Group | Agents |
|-------|--------|
| Always safe | CORTANA |
| State + comms | CORTANA, HERMES |
| Research + gate | SAGAN, SENTINEL |

**Sequential dependencies:**

| Sequence | Rule |
|----------|------|
| NEO → CORNELIUS | Architecture before execution plan |
| SAGAN → HERMES | Research complete before distribution |
| SENTINEL → outbound publish | QA clears before any external post |

---

## Agent Assignment Patterns (MILO reference)

| Task Type | Pattern |
|-----------|---------|
| Research + synthesis | Milo → Sagan → Sentinel (optional) → Cortana |
| Research + distribute | Milo → Sagan → Hermes → Sentinel (conditional) → Cortana |
| Engineering + infra | Milo → Neo → Cornelius → Sentinel → Milo (approval) → Cortana |
| Outbound comms | Milo → Hermes → Sentinel (conditional) → Cortana |
| Heavy coding | Milo → Cornelius → Sentinel → Milo (approval) |
| Email draft | Milo → Hermes (Hermes drafts, John sends) |
| Quality gate | Milo → Sentinel → Cortana |
| Autonomous coding | Escalate to Claude Code directly (outside harness) |

---

## Standing Workflow Approval

A standing-approved recurring workflow runs with reduced friction when:
- MILO approved the workflow policy on initial creation
- No blocking flags from SENTINEL
- HERMES posts only to channels listed in `config/channels.yaml`

---

## Failure Handling

Per `GotchaFramework.md`:
- **First failure**: silent retry with same model
- **Model unavailable**: retry with fallback from `config/models.yaml`
- **Second failure**: Milo reroutes or marks the step as partial
- **Required branch failure**: Milo decides
- **3 failures in 24h**: CORTANA generates a `GUARDRAIL_PROPOSAL` for MILO approval

---

## References

| Document | Purpose |
|----------|---------|
| `GotchaFramework.md` | Full operating framework — GOTCHA layers, operating procedures, guardrails |
| `config/models.yaml` | Provider and model configuration with fallback chains |
| `config/routing.yaml` | Routing profiles and rules |
| `config/channels.yaml` | Approved distribution channels and posting policy |
| `config/mission-control.yaml` | Mission Control board IDs, custom fields, API base |
| `docs/Agent_Model_Routing_Matrix.md` | Escalation rules, bias triggers, model tier selection |
| `docs/Router_Profiles.md` | Reusable dispatch formations |
| `docs/Handoff_Protocol.md` | Structured envelope schemas for all agent outputs |
| `docs/QA_Gates.md` | SENTINEL trigger conditions |
| `agents/*.md` | Individual agent personas and deliverable formats |
