# GotchaFramework.md

## Command Center Operating Framework

This system uses the **GOTCHA Framework** — a 6-layer architecture for governed multi-agent systems. Adapted from the general-purpose GOTCHA pattern to fit Command Center's multi-agent, multi-model operating environment on OpenClaw.

---

## Why This Structure Exists

LLMs are probabilistic. Business logic is deterministic. When agents try to do everything themselves, errors compound fast — 90% accuracy per step is ~59% accuracy over 5 steps, and Command Center regularly chains 6+ agents per workflow.

The solution:

- Push **reliability** into deterministic tools and structured handoffs
- Push **flexibility and reasoning** into LLM agents with defined roles
- Push **process clarity** into goals and workflow definitions
- Push **behavior settings** into args and runtime configs
- Push **domain knowledge** into context and state
- Push **governance** into approval gates and boundary rules

Agents make smart decisions. Tools execute perfectly. Nobody crosses lanes.

---

## The GOTCHA Layers

### G — Goals (Workflow Definitions)

**What needs to happen.**

| Command Center Mapping | Location |
|---|---|
| Workflow definitions | `config/workflows.yaml` |
| Router profiles (reusable formations) | `config/routing.yaml` |
| Task lifecycle stages | `docs/Task_Lifecycle.md` |
| Task-specific prompts | `agents/tasks/*.md` |

Goals define the objective, the agent sequence, which tools to invoke, expected outputs, and edge cases. In Command Center, goals manifest as **workflow definitions** (DFB, Market Signal Scanner, Content Repurposing Engine) and **router profiles** (intelligence, campaign, engineering, executive, social_response, recurring_publish).

**Rules:**
- Check `config/workflows.yaml` and `config/routing.yaml` before starting any task
- If a workflow exists, follow it — don't improvise a new sequence
- Goals are living documents — update when better approaches or API constraints emerge
- Never modify workflow definitions without Milo approval
- If a goal file exceeds reasonable length, propose splitting into a primary goal + technical reference

---

### O — Orchestration (The Agent Layer)

**Who coordinates execution.**

Phase 5: Milo is both the intake and the orchestrator. Elon retired — Milo absorbed his task-graph and dispatch responsibilities. The orchestration model is a **streamlined governed hierarchy**:

| Role | Agent | Responsibility |
|---|---|---|
| Executive Assistant & Orchestrator | Milo | Intake, dispatch, task sequencing, HALT authority, delivery to John |
| QA Gate | Sentinel | Output evaluation — never initiates, never speaks to John |
| State Engine | Cortana | Tracks state and telemetry — never decides policy |
| Research | Sagan | Deep research and synthesis authority |
| Engineering | Neo | Architecture and coding |
| Infra / Heavy Coding | Cornelius | Execution plans with rollback; runs solo (~48GB) |
| Communications | Hermes | All outbound comms — Discord, Telegram, email |

**Orchestration rules:**
- Milo handles simple requests directly (complexity < 2, no tool calls)
- Complex or multi-step requests: Milo dispatches sequentially via `sessions_spawn` with `agentId`
- Milo compiles each specialist's output before dispatching the next step
- Only Milo speaks to John; specialists return structured results
- Specialists return structured envelopes — no side effects, no direct user messaging
- Barriers must exist before final synthesis, distribution, and execution approval
- HALT is owned exclusively by Milo — specialists may flag `halt_recommended: true`, but only Milo stops work

**Model selection at orchestration time:**
- Milo reads `config/models.yaml` to resolve which model serves each specialist
- Primary model is used by default
- Escalation model is used when bias triggers fire (complexity, risk, conflicting outputs)
- Fallback model is used when primary is unavailable
- Approved providers: Ollama Local, Ollama Pro, NIM Direct, ChatGPT Plus (Codex), Perplexity Pro, Z.ai
- Anthropic API is not approved for OpenClaw harness use

---

### T — Tools (Execution Layer)

**Deterministic scripts and APIs that do the actual work.**

| Command Center Mapping | Location |
|---|---|
| Tool registry with implementations | `config/tools.yaml` |
| OpenClaw plugins | `@ollama/openclaw-web-search`, etc. |
| API integrations | Discord webhook, Telegram bot, X API (manual only) |
| Agent capabilities (LLM-native) | Marked as `agent_capability` in tool registry |

Tools fall into three categories:

**1. Real tools** — deterministic, executable, testable:
- `web_read` / `web_fetch` — OpenClaw web search plugin
- `discord_post` / `telegram_post` — API webhooks
- `state_log` / `artifact_registry` — Cortana's state store
- `docs_read` / `code_read` — filesystem access

**2. Agent capabilities** — LLM reasoning wrapped in a tool interface:
- `synthesis` (Sagan), `architecture` (Neo), `plan_shell` / `plan_filesystem` (Cornelius)
- These are not discrete scripts — they're the agent's core LLM capability driven by prompt
- They appear in the tool registry so the system can track permissions and restrictions uniformly

**3. Gated tools** — require approval to invoke:
- `plan_shell` / `plan_filesystem` — Cornelius designs plans, Milo approves execution
- `discord_post` / `telegram_post` — require standing approval or manual mode
- `x_post` — manual only, Milo approval per post
- `email_draft` — Hermes drafts, John sends (Hermes never sends on his own)

**Rules:**
- Check `config/tools.yaml` (canonical) or `config/tools_manifest.md` (index) before writing new code or scripts
- If a tool exists, use it — don't reinvent
- If you create a new tool, add it to the tool registry with type, implementation, and permissions
- When tools fail, fix and document — read the error, update the tool, add what you learned to the relevant workflow definition
- Never assume APIs support batch operations — check first
- Verify tool output format before chaining into another agent's handoff

---

### C — Context (Domain Knowledge + State)

**Reference material the system uses to reason.**

| Command Center Mapping | Location |
|---|---|
| Agent personas and boundaries | `agents/*.md` |
| Governance rules | `AGENTS.md` |
| Agent routing matrix | `docs/Agent_Model_Routing_Matrix.md` |
| QA trigger conditions | `docs/QA_Gates.md` |
| Execution mode definitions | `docs/Execution_Modes.md` |
| Active project state | `state/Active_Projects.md` |
| Decision history | `state/Decision_Log.md` |
| Artifact registry | `state/Artifacts_Index.md` |
| State schema | `docs/State_Schema.md` |

Context is what agents read to understand the world they're operating in. It's not process (that's goals) and it's not behavior settings (that's args). It's **what is true right now**.

**Cortana's role:** Cortana is the state engine — she maintains `state/Active_Projects.md`, `state/Artifacts_Index.md`, and `state/Decision_Log.md` as living state. Other agents read from Cortana's state; only Cortana writes to it (with the exception of durable policy changes, which require Milo approval).

**Rules:**
- Agents must read relevant context before starting work
- State updates happen through Cortana, not ad hoc file edits
- Decision_Log entries are append-only — never modify past entries
- Context shapes quality and judgment — it doesn't define process or behavior

---

### H — Hard Prompts (Agent System Prompts)

**Fixed instructions that define agent identity and behavior.**

| Command Center Mapping | Location |
|---|---|
| Agent system prompts | `agents/*.md` |
| Task-specific prompts | `agents/tasks/*.md` |
| Handoff envelope schema | `docs/Handoff_Protocol.md` |
| Output contracts | Each agent's `.md` defines deliverable format |

Hard prompts are the fixed instructions that tell each agent **who it is**, **what it can do**, **what it must never do**, and **what format to return**. They're not context (that changes) and they're not goals (that define workflows). They're the agent's operating identity.

Each agent prompt defines:
- Identity and role
- ROLE_TYPE
- User-facing status (yes/no)
- Operating bias (speed / balanced / accuracy)
- Responsibilities and restrictions
- Deliverable format (structured envelope)

**Rules:**
- Hard prompts are fixed instructions — modify only with explicit Milo permission
- Every agent must have a defined deliverable format
- The deliverable format must be compatible with Milo's sequential dispatch + compile pattern
- Task-specific prompts are separate from identity prompts

---

### A — Args (Runtime Behavior Settings)

**Configuration that shapes how the system behaves right now.**

| Command Center Mapping | Location |
|---|---|
| Model selection and provider routing | `config/models.yaml` |
| Parallelism caps and memory constraints | `config/parallelism.yaml` |
| Channel permissions and distribution policy | `config/channels.yaml` |
| Routing profiles and sequencing | `config/routing.yaml` |

**Key args in Command Center:**
- `TIER_CAP` — set by Milo per task, controls maximum model tier
- `PARALLEL_CAP` — default 4, maximum concurrent agent branches
- `RISK_MODE` — balanced by default, can be elevated to accuracy
- `EXECUTION_MODE` — simulate by default, execute only when explicitly elevated
- `max_concurrent_local_model_gb: 45` — memory ceiling for parallel local models
- `exclusive_models` — Cornelius runs solo (~48.2GB footprint)

**Rules:**
- Milo reads args before dispatching any workflow
- Changing args changes behavior immediately — no code changes needed
- Args never override governance rules (Milo's approval authority, Sentinel's QA gates)
- Model fallback chains are defined in args, not in agent prompts

---

## Operating Procedures

### 1. Check for existing workflows first

Before starting any task, check `config/workflows.yaml` and `config/routing.yaml`. If a workflow exists, follow it. If a router profile fits, use it. Don't build a custom task graph when a formation already exists.

### 2. Check for existing tools

Before writing new code, read `config/tools_manifest.md`. If a tool exists, use it. If you create a new tool, add it to the tool registry with:
- `type` (internal / openclaw_plugin / api)
- `description` (one sentence)
- `implementation` (what it actually calls)
- `permissions` (read / write / dispatch)
- `restrictions` (if gated)

### 3. When tools fail, fix and document

1. Read the error and stack trace carefully
2. Update the tool to handle the issue
3. Add what you learned to the relevant workflow definition
4. Log the failure through Cortana as a `recent_failures` state entry
5. If the same failure recurs 3+ times in 24h, Cortana flags the pattern to Milo

### 4. Treat workflows as living documentation

- Update only when better approaches or API constraints emerge
- Never modify workflows without Milo approval
- Workflows are the instruction manual for the entire system

### 5. Communicate clearly when stuck

If an agent can't complete a task with existing tools and workflows:
- State what's missing
- State what's needed
- Do not guess or invent capabilities
- Route the blocker back to Milo

### 6. Failure handling

Every failure generates a `FAILURE_ENVELOPE` per `docs/Handoff_Protocol.md`:
- First failure: silent retry with same model
- Model unavailable: retry with fallback from `config/models.yaml`
- Second failure: Milo reroutes or marks the step as partial
- Required branch failure: Milo is notified and decides
- Three failures in 24h: Cortana surfaces pattern summary

### 7. Context window management

Long agent chains accumulate tokens fast.

**Proactive hygiene:**
- Monitor context usage — if responses degrade, the window is filling
- When approaching limits, summarize current state and write to Cortana
- Prefer targeted tool calls over broad ones
- Don't re-read files already in context
- When a sub-task is complete, close it mentally — don't keep referencing old tool outputs
- Preserve intermediate outputs before retrying failed workflows

### 8. State protocol

**On workflow start:**
- Cortana reads `state/memory/MEMORY.md` for persistent facts and preferences
- Cortana reads today's daily log and yesterday's log for session continuity
- Cortana reads `state/Active_Projects.md` for current project state
- Cortana reads `state/Decision_Log.md` for relevant past decisions
- Milo reads `config/models.yaml` and `config/routing.yaml` for runtime configuration

**During workflow:**
- Cortana logs events, artifacts, and failures automatically
- Cortana appends notable events to today's daily log (`state/memory/logs/YYYY-MM-DD.md`)
- Cortana writes newly discovered facts to `state/memory/MEMORY.md`
- Policy-level updates require Milo approval before Cortana writes
- Decision_Log entries are append-only

**On workflow completion:**
- Cortana updates project status in `state/Active_Projects.md`
- Cortana registers new artifacts in `state/Artifacts_Index.md`
- Cortana logs the workflow run record per `docs/State_Schema.md`

### 9. Memory protocol

**`state/memory/MEMORY.md`** — Curated long-term facts: user preferences, key technical facts, learned behaviors, current projects, technical context. Source of truth across session boundaries.

**`state/memory/logs/YYYY-MM-DD.md`** — Daily session logs. Cortana appends events during workflows.

**Memory update rules:**
- Facts and events: Cortana writes automatically
- Policy-level updates: require Milo approval
- Memory entries should include: content, entry_type (fact/preference/event/insight/task), importance (1-10), source_agent

### 10. Initialization protocol

On fresh start, after crash, or when environment integrity is uncertain, run `docs/Init_Checklist.md` before accepting tasks.

The checklist verifies:
1. **Infrastructure services** — Docker, Ollama, OpenClaw running
2. **External volume** — `/Volumes/BotCentral/Users/milo` mounted
3. **Environment variables** — all required API keys set
4. **Local models** — key Ollama models pulled
5. **State files** — all state and config files exist and are parseable
6. **Memory** — daily log created, `MEMORY.md` exists

If any check fails, resolve before accepting tasks. Log infrastructure failures through Cortana with `failure_type: infrastructure`.

---

## Guardrails — Learned Behaviors

Document system-level mistakes here. Script bugs go in tool documentation. Agent-specific behaviors go in agent prompts.

1. **Always check `config/tools_manifest.md` before writing a new script.** If it exists, use it.
2. **Verify tool output format before chaining into another agent's handoff.** Format mismatches are silent failures.
3. **Don't assume APIs support batch operations.** Check first.
4. **When a workflow fails mid-execution, preserve intermediate outputs before retrying.** Cortana logs; Milo decides retry strategy.
5. **Read the full workflow definition before starting a task.** Don't skim.
6. **Never expose API keys or tokens in chat, logs, or handoff packets.** Store via `~/.openclaw/secrets.json` (SecretRef). If a token is exposed, rotate immediately.
7. **Path casing matters.** Username is lowercase `milo`, not `Milo`. Mismatches have caused repeated failures.
8. **External volume paths are required.** Home directory lives at `/Volumes/BotCentral/Users/milo/`. LaunchAgents must be copied to `/Users/milo/Library/LaunchAgents/` on the system drive.
9. **Cornelius runs solo.** At ~48.2GB, `qwen3-coder-next:latest` cannot share local memory with other models. When Cornelius is active, all other local agents route to cloud.
10. **Milo is the only path to John.** Specialists never deliver directly — they return structured results to Milo who compiles and delivers.
11. **Milo dispatches via `sessions_spawn` with `agentId`.** Never spawn anonymous subagents — they have no tool access.
12. **No automatic shell execution.** Cornelius designs plans. Milo approves execution.
13. **Run Init_Checklist.md after any crash or fresh start.** Don't accept tasks on an unverified environment.
14. **Check `config/routing.yaml` before building a custom dispatch.** If a router profile already exists, use it.
15. **Anthropic API is not approved for OpenClaw harness use.** Route all agents to approved providers: Ollama Local, Ollama Pro, NIM Direct, ChatGPT Plus (Codex), Perplexity Pro, Z.ai.
16. **HALT is Milo's exclusively.** Any specialist may flag `halt_recommended: true`, but only Milo stops work.
17. **Milo is male.** Use he/him pronouns in code comments and documentation.

*(Add new guardrails as mistakes happen. Keep this list under 20 items. When Cortana detects 3+ instances of the same failure pattern within 24h, she generates a GUARDRAIL_PROPOSAL for Milo to approve and append here.)*

---

## The Continuous Improvement Loop

Every failure strengthens the system:

1. **Identify** what broke and why
2. **Fix** the tool, prompt, or workflow definition
3. **Test** until it works reliably
4. **Document** the fix — update the goal, add a guardrail, log the decision
5. **Log** through Cortana so the pattern is tracked
6. **Auto-detect** — Cortana monitors for recurring patterns (3+ failures in 24h)
7. **Propose** — Cortana generates a `GUARDRAIL_PROPOSAL` when a pattern is detected
8. **Approve** — Milo reviews and approves the proposed guardrail
9. **Codify** — approved guardrail is appended to this section
10. Next time → automatic success

---

## Your Job in One Sentence

Read the workflow, check the tools, apply the args, use the context, delegate through the hierarchy, handle failures, log everything through Cortana, and strengthen the system with each run.
