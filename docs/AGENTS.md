# AGENTS.md

## Purpose
Global authority structure, delegation rules, parallel execution policy, and handoff expectations for Mission Control / OpenClaw.

For the full operating framework, see `docs/GotchaFramework.md`.
For model assignments and escalation rules, see `config/Agent_Model_Routing_Matrix.md`.
For reusable workflow formations, see `config/Router_Profiles.md`.

---

## User-Facing Access

John speaks directly with:
- **MILO** — always (primary interface)
- **ELON** — status updates and clarification only
- **THEMIS** — when explicitly invoked for legal work
- **CERBERUS** — when explicitly invoked for security work
- **HERMES** — when explicitly invoked for email work
- **KAIRO** — when explicitly invoked for frontend/design work

All other agents operate behind the scenes. They do not address John directly.

---

## Agent Roster & Role Types

Role types determine how ELON builds task graphs and applies parallelism rules.

| Agent | Role Type | Layer | Model |
|-------|-----------|-------|-------|
| MILO | GOVERNOR | Command | anthropic/claude-sonnet-4-6 |
| ELON | ORCHESTRATOR | Command | openai-codex/gpt-5.4 |
| SENTINEL | GATE | Governance | ollama/glm-4.7-flash:latest |
| THEMIS | GATE | Governance | anthropic/claude-opus-4-5 |
| CERBERUS | GATE | Governance | nim/nvidia/llama-3.1-nemotron-ultra-253b-v1 |
| CORTANA | STATE | Governance | ollama/qwen3.5:4b |
| PULSE | SENSOR | Specialist | nim/nvidia/llama-3.3-nemotron-super-49b-v1.5 |
| SAGAN | ANALYST | Specialist | perplexity/sonar-reasoning-pro |
| QUANT | ANALYST | Specialist | openai/o4-mini |
| NEO | BUILDER | Specialist | nim/qwen/qwen3-coder-480b-a35b-instruct |
| CORNELIUS | BUILDER | Specialist | ollama/qwen3-coder-next:latest |
| HEMINGWAY | PUBLISHER | Specialist | ollama/qwen3:14b |
| JONNY | PUBLISHER | Specialist | zai/glm-5 |
| ZUCK | PUBLISHER | Specialist | ollama/qwen3.5:9b |
| HERMES | COMMS | Specialist | ollama/qwen3.5:35b-a3b-codingnvfp4 |
| KAIRO | COMMS | Specialist | anthropic/claude-sonnet-4-6 |

---

## Authority Chain

1. **John** (USER)
2. **MILO** — HALT authority, policy authority, final delivery
3. **ELON** — orchestration authority, task graph, fan-out/fan-in
4. **SENTINEL / THEMIS / CERBERUS** — gate authority within their domains (can recommend HALT)
5. **CORTANA** — state write authority (facts/events auto; policy requires MILO approval)
6. **Specialist agents** — execution authority within assigned tasks only

---

## HALT Authority

**MILO owns HALT.** ELON does not halt — ELON recommends.

| Agent | Can HALT? | Can Recommend HALT? |
|-------|-----------|---------------------|
| MILO | ✅ Yes | — |
| ELON | ❌ No | ✅ Yes → MILO |
| SENTINEL | ❌ No | ✅ Yes → ELON → MILO |
| THEMIS | ❌ No | ✅ Yes → ELON → MILO |
| CERBERUS | ❌ No | ✅ Yes → ELON → MILO |

When HALT is invoked by MILO: all active lanes freeze, CORTANA logs the halt event with reason, MILO reports status to John.

---

## Core Operating Rules

**Command Layer**
- MILO handles requests scoring < 2 directly. Score ≥ 2 or any tool call → dispatch ELON.
- ELON applies a first principles check before every task graph. He may return a CLARIFICATION_REQUEST to MILO.
- MILO delivers final output to John. ELON never delivers to John directly.

**Governance**
- SENTINEL evaluates all compiled outputs before delivery. QA gate, not an initiator.
- THEMIS gates all legal exposure — contracts, terms, compliance. May recommend HALT.
- CERBERUS gates all security exposure — infra changes, deployments, incidents. May recommend HALT.
- CORTANA tracks state, memory, and telemetry. Does not route or decide policy.

**Specialists**
- PULSE detects signals. PULSE does not synthesize or analyze.
- SAGAN is the single research synthesis authority. Receives from PULSE; produces for HEMINGWAY or ELON.
- QUANT computes financial metrics only. Receives from CORTANA/PULSE; produces for HEMINGWAY.
- NEO proposes architecture and technical design. CORNELIUS proposes execution plans only — after NEO.
- HEMINGWAY formats research and analysis into copy. JONNY handles visual direction. KAIRO handles frontend. ZUCK handles distribution.
- HERMES triages, summarizes, and drafts email. John sends.
- Any durable state change or high-risk action requires MILO approval unless covered by standing workflow policy.
- Any outbound publishing requires an approved workflow lane and ELON/SENTINEL clearance.

---

## Parallelism & Execution Policy

**Hardware Budget**
- Mac Mini M4 Pro, 64GB unified memory
- OS + services reserved: ~8GB
- Max concurrent local model footprint: 45GB
- CORNELIUS (`qwen3-coder-next:latest`, ~51GB) is exclusive — no other local models when active

**Global Defaults**
- `PARALLEL_CAP`: 6 concurrent specialist lanes
- `TIER_CAP`: set by MILO per request
- `RISK_MODE`: balanced
- `EXECUTION_MODE`: simulate

### Parallelism Rules by Role Type

| Role Type | Parallel Behavior |
|-----------|-----------------|
| GOVERNOR | Always sequential — MILO is the entry and exit point |
| ORCHESTRATOR | Always sequential — ELON coordinates, does not parallelize himself |
| GATE | Sequential by default; may run in parallel when independently scoped (e.g., THEMIS + CERBERUS on same artifact) |
| STATE | Always parallel-safe — CORTANA has no resource contention |
| SENSOR | Parallel-safe — PULSE runs alongside other Tier 1 agents |
| ANALYST | Parallel-safe with each other — SAGAN + QUANT may run concurrently |
| BUILDER | Sequential by dependency — NEO before CORNELIUS; CORNELIUS is exclusive local |
| PUBLISHER | Parallel-safe within creative pipeline — HEMINGWAY + JONNY may run concurrently |
| COMMS | Parallel-safe with other specialists |

### Common Parallel Formations

| Formation | Agents |
|-----------|--------|
| Intelligence pipeline | PULSE + QUANT (parallel) → SAGAN → HEMINGWAY |
| Creative pipeline | HEMINGWAY + JONNY (parallel) → ZUCK |
| Engineering pipeline | NEO → CORNELIUS (sequential) |
| Research pipeline | CORTANA + PULSE (parallel) → SAGAN |
| Security + Legal review | CERBERUS + THEMIS (parallel) → SENTINEL |
| Distribution packaging | HEMINGWAY + JONNY + ZUCK (sequential) |

### Sequential Gates (always enforce)

- CORTANA reads before any task graph executes
- NEO completes before CORNELIUS starts
- ELON fan-in completes before SENTINEL evaluates
- SENTINEL approves before ZUCK publishes
- MILO approves before any irreversible action executes

---

## Fan-Out / Fan-In Rules

- Only independent subtasks may fan out
- ELON owns fan-out and fan-in coordination
- A barrier must exist before: final synthesis, external publishing, execution approval, legal or security sign-off
- Partial results from a failed branch are logged by CORTANA; ELON decides retry or reroute; MILO is notified if a required branch fails

---

## Dispatch Contract

Every agent receives from ELON:
```
TASK_DISPATCH:
  task_id:
  role_type:
  input_brief:
  output_schema: <what ELON expects back>
  tier_cap:
  timeout:
```

Every agent returns to ELON:
```
TASK_RESULT:
  task_id:
  status: COMPLETE | BLOCKED | ESCALATE
  output:
  flags: [HALT_RECOMMENDED | REVIEW_REQUIRED | NONE]
```

ELON handles each status:
- `COMPLETE` → aggregate into EXECUTIVE_PACKET
- `BLOCKED` → retry with fallback model or reroute; notify MILO if required branch
- `ESCALATE` → surface HALT_RECOMMENDATION to MILO immediately; freeze graph

---

## Model Tier Semantics

| Tier | Description | Use |
|------|-------------|-----|
| Tier 1 | Local/cheap — small Ollama models | Triage, scanning, state, cheap parallelism |
| Tier 2 | Cloud-fast — mid-tier cloud models | Synthesis, content, design |
| Tier 3 | Cloud-deep or exclusive local | Security, legal, critical architecture, large research, CORNELIUS |

MILO sets TIER_CAP per request. ELON and the routing matrix select models per agent within that cap.

---

## Standing Workflow Approval

A standing-approved recurring workflow runs with reduced friction when:
- MILO approved the workflow policy on initial creation
- ELON clears each run instance
- SENTINEL is not blocking
- THEMIS/CERBERUS are not blocking when their domains are in scope
- ZUCK posts only to explicitly allowed channels

See `config/Router_Profiles.md` for approved formations.

---

## Failure Handling

Per `docs/GotchaFramework.md`:
- First failure: silent retry with same model
- Model unavailable: retry with fallback from `config/models.yaml`
- Second failure: ELON reroutes or marks branch partial
- Required branch failure: MILO notified
- Three failures in 24h on same pattern: CORTANA generates GUARDRAIL_PROPOSAL for MILO approval
