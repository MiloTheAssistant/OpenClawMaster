# GotchaFramework.md

## Mission Control Operating Framework

This system uses the **GOTCHA Framework** — a 6-layer architecture for governed multi-agent systems. Adapted from the general-purpose GOTCHA pattern to fit Mission Control's 16-agent, multi-model operating environment on OpenClaw.

---

## Why This Structure Exists

LLMs are probabilistic. Business logic is deterministic. When agents try to do everything themselves, errors compound fast — 90% accuracy per step is ~59% accuracy over 5 steps, and Mission Control regularly chains 6+ agents per workflow.

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

| Mission Control Mapping | Location |
|---|---|
| Workflow definitions | `config/workflows.yaml` |
| Router profiles (reusable formations) | `docs/Router_Profiles.md` |
| Task lifecycle stages | `docs/Task_Lifecycle.md` |
| Task-specific prompts | `/Volumes/BotCentral/Users/milo/Documents/agents/tasks/*.md` |

Goals define the objective, the agent sequence, which tools to invoke, expected outputs, and edge cases. In Mission Control, goals manifest as **workflow definitions** (DFB, Market Signal Scanner, Content Repurposing Engine) and **router profiles** (intelligence, campaign, engineering, executive, social_response, recurring_publish).

**Rules:**
- Check `config/workflows.yaml` and `docs/Router_Profiles.md` before starting any task
- If a workflow exists, follow it — don't improvise a new sequence
- Goals are living documents — update when better approaches or API constraints emerge
- Never modify workflow definitions without Milo approval
- If a goal file exceeds reasonable length, propose splitting into a primary goal + technical reference

---

### O — Orchestration (The Agent Layer)

**Who coordinates execution.**

In general GOTCHA, orchestration is a single AI manager. In Mission Control, orchestration is a **governed hierarchy**:

| Role | Agent | Responsibility |
|---|---|---|
| Executive Assistant | Milo | Intake, triage, caps, approvals, HALT authority, final delivery |
| First Principles Orchestrator | Elon | Task graphs, fan-out/fan-in, run clearance, executive packets |
| QA Gate | Sentinel | Evaluation only — never initiates, never speaks to John |
| State Engine | Cortana | Tracks state and telemetry — never decides policy |

**Orchestration rules:**
- Milo handles simple requests directly (complexity score < 2, no tool calls)
- Complex or cross-domain requests get briefed to Elon via `BRIEF_FOR_ELON`
- Elon applies first principles check before building any task graph
- Elon builds task graphs and dispatches to specialists — never compiles results for John
- Only Milo and Elon speak directly to John (plus THEMIS, CERBERUS, HERMES, KAIRO when explicitly invoked)
- Specialists return structured envelopes only — no side effects, no direct John messaging
- Elon owns fan-out and fan-in coordination
- Barriers must exist before final synthesis, distribution, and execution approval
- HALT is MILO's exclusively — ELON surfaces HALT_RECOMMENDATION and freezes, MILO decides

**Model selection at orchestration time:**
- Elon reads `config/models.yaml` to resolve which model serves each agent
- Primary model is used by default
- Escalation model is used when bias triggers fire (complexity, risk, conflicting outputs)
- Fallback model is used when primary is unavailable
- Allowed providers: ollama_local, ollama_cloud, openai, perplexity, zai, nvidia_nim
- BLOCKED: anthropic/* — policy blocked with OpenClaw harness

---

### T — Tools (Execution Layer)

**Deterministic scripts and APIs that do the actual work.**

| Mission Control Mapping | Location |
|---|---|
| Tool registry with implementations | `config/tools.yaml` |
| OpenClaw plugins | `@ollama/openclaw-web-search`, etc. |
| API integrations | Discord webhook, Telegram bot, X API (pending) |
| Agent capabilities (LLM-native) | Marked as `agent_capability` in tool_registry |

Tools fall into three categories:

**1. Real tools** — deterministic, executable, testable:
- `web_read` / `web_fetch` — OpenClaw web search plugin
- `discord_post` / `telegram_post` — API webhooks
- `state_log` / `artifact_registry` — Cortana's state store
- `docs_read` / `code_read` — filesystem access

**2. Agent capabilities** — LLM reasoning wrapped in a tool interface:
- `synthesis` (Sagan), `architecture` (Neo), `copy_formatting` (Hemingway), `visual_prompting` (Jonny), `plan_shell` / `plan_filesystem` (Cornelius)
- These are not discrete scripts — they're the agent's core LLM capability driven by prompt
- They appear in the tool registry so the system can track permissions and restrictions uniformly

**3. Gated tools** — require approval to invoke:
- `plan_shell` / `plan_filesystem` — Cornelius designs plans, Milo approves execution
- `discord_post` / `telegram_post` — require standing approval or manual mode
- `x_post` — manual only, Milo approval per post

**Rules:**
- Check `config/tools.yaml` before writing new code or scripts
- If a tool exists, use it — don't reinvent
- If you create a new tool, add it to the tool_registry with type, implementation, and permissions
- When tools fail, fix and document: read the error, update the tool, add what you learned to the relevant workflow definition
- Never assume APIs support batch operations — check first
- Verify tool output format before chaining into another agent's handoff

---

### C — Context (Domain Knowledge + State)

**Reference material the system uses to reason.**

| Mission Control Mapping | Location |
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
- Agents must read relevant context before starting work — don't skim, read the full goal and context
- State updates happen through Cortana, not ad hoc file edits
- Decision_Log entries are append-only — never modify past entries
- Context shapes quality and judgment — it doesn't define process or behavior

---

### H — Hard Prompts (Agent System Prompts)

**Reusable instruction templates that define agent identity and behavior.**

| Mission Control Mapping | Location |
|---|---|
| Agent system prompts | `agents/*.md` |
| Task-specific prompts | `/Volumes/BotCentral/Users/milo/Documents/agents/tasks/*.md` |
| Handoff envelope schema | `docs/Handoff_Protocol.md` |
| Failure envelope schema | `docs/Handoff_Protocol.md` (failure handling section) |
| Output contracts | Each agent's `.md` file defines deliverable format |

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
- The deliverable format must be compatible with Elon's fan-in aggregation
- Task-specific prompts (like the DFB task prompt) are separate from identity prompts

---

### A — Args (Runtime Behavior Settings)

**Configuration that shapes how the system behaves right now.**

| Mission Control Mapping | Location |
|---|---|
| Model selection and provider routing | `config/models.yaml` |
| Parallelism caps and memory constraints | `config/parallelism.yaml` |
| Channel permissions and distribution policy | `config/channels.yaml` |
| Routing profiles and sequencing | `config/routing.yaml` |

Args control runtime behavior without changing goals or tools. Changing `config/models.yaml` changes which LLMs serve which agents. Changing `config/parallelism.yaml` changes how many agents can run concurrently. Changing `config/channels.yaml` changes where content gets distributed.

**Key args in Mission Control:**
- `TIER_CAP` — set by Milo per task, controls maximum model tier
- `PARALLEL_CAP` — default 6, maximum concurrent agent branches
- `RISK_MODE` — balanced by default, can be elevated to accuracy
- `EXECUTION_MODE` — simulate by default, execute only when explicitly elevated
- `max_concurrent_local_model_gb: 45` — memory ceiling for parallel local models
- `exclusive_models` — Cornelius runs solo (51GB footprint)

**Rules:**
- Elon reads args before running any workflow
- Changing args changes behavior immediately — no code changes needed
- Args never override governance rules (Milo's approval authority, Sentinel's QA gates)
- Model fallback chains are defined in args, not in agent prompts

---

## Operating Procedures

### 1. Check for existing workflows first

Before starting any task, check `config/workflows.yaml` and `docs/Router_Profiles.md`. If a workflow exists, follow it. If a router profile fits, use it. Don't build a custom task graph when a formation already exists.

### 2. Check for existing tools

Before writing new code, read `config/tools.yaml`. If a tool exists, use it. If you create a new tool, add it to the tool_registry with:
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
- Route the blocker through Elon to Milo

### 6. Failure handling

Every failure generates a `FAILURE_ENVELOPE` per `docs/Handoff_Protocol.md`:
- First failure: silent retry with same model
- Model unavailable: retry with fallback from `config/models.yaml`
- Second failure: Elon reroutes or marks branch as partial
- Required branch failure: Milo is notified
- Three failures in 24h: Cortana surfaces pattern summary

### 7. Context window management

Long agent chains accumulate tokens fast. Every handoff, tool call, and result adds up.

**Proactive hygiene:**
- Monitor context usage — if responses degrade, the window is filling
- When approaching limits, summarize current state and write to Cortana
- Prefer targeted tool calls over broad ones (specific queries, specific file sections)
- Don't re-read files already in context
- When a sub-task is complete, close it mentally — don't keep referencing old tool outputs
- Preserve intermediate outputs before retrying failed workflows

### 8. State protocol

**On workflow start:**
- Cortana reads `state/memory/MEMORY.md` for persistent facts and preferences
- Cortana reads today's daily log and yesterday's log for session continuity
- Cortana reads `state/Active_Projects.md` for current project state
- Cortana reads `state/Decision_Log.md` for relevant past decisions
- Elon reads `config/models.yaml` and `config/routing.yaml` for runtime configuration

**During workflow:**
- Cortana logs events, artifacts, and failures automatically
- Cortana appends notable events to today's daily log (`state/memory/logs/YYYY-MM-DD.md`)
- Cortana writes newly discovered facts to `state/memory/MEMORY.md` (automatic for facts/events; policy-level updates require Milo approval)
- Durable policy changes require Milo approval before Cortana writes them
- Decision_Log entries are append-only

**On workflow completion:**
- Cortana updates project status in `state/Active_Projects.md`
- Cortana registers any new artifacts in `state/Artifacts_Index.md`
- Cortana logs the workflow run record per `docs/State_Schema.md`

### 9. Memory protocol

Cortana maintains persistent memory across sessions in `state/memory/`.

**`state/memory/MEMORY.md`** — Curated long-term facts: user preferences, key technical facts, learned behaviors, current projects, technical context. This is the source of truth that survives session boundaries. Cortana reads it at startup, writes to it when new persistent information is discovered.

**`state/memory/logs/YYYY-MM-DD.md`** — Daily session logs. Cortana appends events during workflows. At session start, Cortana reads today's and yesterday's logs for continuity.

**Memory update rules:**
- Facts and events: Cortana writes automatically
- Policy-level updates (user preferences, system rules): require Milo approval
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
4. **When a workflow fails mid-execution, preserve intermediate outputs before retrying.** Cortana logs, Elon decides retry strategy.
5. **Read the full workflow definition before starting a task.** Don't skim.
6. **Never expose API keys or tokens in chat, logs, or handoff packets.** Set via `~/.zshrc` or `.env`. If a token is exposed, rotate immediately.
7. **Path casing matters.** Username is lowercase `milo`, not `Milo`. Mismatches have caused repeated failures.
8. **External volume paths are required.** Home directory lives at `/Volumes/BotCentral/Users/milo/`. LaunchAgents must be copied to `/Users/milo/Library/LaunchAgents/` on the system drive.
9. **Cornelius runs solo.** At 51GB, `qwen3-coder-next:latest` cannot share local memory with other models. ELON must schedule as an exclusive sequential step.
10. **Elon never compiles or delivers to John.** He routes and clears only. Milo delivers.
11. **Pulse detects signals — Pulse does not analyze.** Deep analysis routes to Sagan.
12. **No automatic shell execution.** Cornelius designs plans. Milo approves execution.
13. **Run Init_Checklist.md after any crash or fresh start.** Don't accept tasks on an unverified environment.
14. **Check `config/workflows_manifest.md` before building a custom task graph.** If a workflow or router profile already exists, use it.
15. **Anthropic models are blocked in the OpenClaw harness.** Do not assign anthropic/* to any agent. Use ollama_local, ollama_cloud, openai, perplexity, zai, or nvidia_nim only.
16. **HALT is Milo's exclusively.** ELON surfaces HALT_RECOMMENDATION and freezes the graph. Milo makes the call. Agents that return halt_recommended: true route through ELON — they do not contact Milo directly.

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
