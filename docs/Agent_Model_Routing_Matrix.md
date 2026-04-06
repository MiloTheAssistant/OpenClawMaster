# Agent Model Routing Matrix

## Purpose
This matrix defines the role, user access, operating bias, routing behavior, and escalation posture for each agent in the OpenClaw Command Center.

**Source of truth for model assignments:** `config/models.yaml`
**Source of truth for agent roles:** `AGENTS.md`

## Model Bias Definitions
- **Speed:** low-latency triage and throughput
- **Balanced:** practical tradeoff between speed and precision
- **Accuracy:** deeper reasoning for expensive mistakes

## System Defaults
- TIER_CAP: set by MILO per task
- PARALLEL_CAP: 6
- RISK_MODE: balanced
- EXECUTION_MODE: simulate
- LOCAL/CLOUD strategy: hybrid

## Approved Providers
Ollama Local, Ollama Pro (cloud), NIM Direct, ChatGPT Plus (Codex), Perplexity Pro, Z.ai

**Blocked:** Anthropic API — policy conflict with OpenClaw harness

---

## Matrix

### Command Layer

| Agent | User-facing | Primary Scope | Bias | Primary Model | Escalation Model | Reports To |
|---|---|---|---|---|---|---|
| Milo | Yes | Governance, intake, approvals | Balanced | `ollama_local/nemotron-super-49b` | `nim/nemotron-3-super-120b-a12b` | USER |
| Elon | Yes (status only) | Orchestration, task graphs | Accuracy | `nim/nemotron-3-super-120b-a12b` | `codex/gpt-5.4` | Milo & USER |

### Governance Layer

| Agent | User-facing | Primary Scope | Bias | Primary Model | Escalation Model | Reports To |
|---|---|---|---|---|---|---|
| Sentinel | No | QA, contradictions, risk review | Accuracy | `ollama_local/glm-4.7-flash` | `zai/glm-5` | Elon & Milo |
| Cortana | No | State, telemetry, logs | Balanced | `ollama_local/qwen3.5:4b` | `ollama_local/qwen3.5:9b` | Milo & Elon |
| Themis | No (unless invoked) | Legal intelligence, compliance | Accuracy | `nim/llama-3.1-nemotron-ultra-253b-v1` | `codex/gpt-5.4` | Elon & Milo |
| Cerberus | No (unless invoked) | Security, threats, incidents | Accuracy | `nim/llama-3.1-nemotron-ultra-253b-v1` | `codex/gpt-5.4` | Elon & Milo |

### Specialist Layer

| Agent | User-facing | Primary Scope | Bias | Primary Model | Escalation Model | Reports To |
|---|---|---|---|---|---|---|
| Pulse | No | Signal detection, triage | Speed | `ollama_local/qwen3.5:9b` | `nim/nemotron-3-super-120b-a12b` | Elon |
| Sagan | No | Research and synthesis | Accuracy | `perplexity/sonar-reasoning-pro` | `codex/gpt-5.4` | Elon |
| Quant | No | Financial metrics | Accuracy | `ollama_local/qwen3.5:14b` | `codex/o4-mini` | Elon |
| Neo | No | Engineering, architecture | Accuracy | `nim/qwen3-coder-480b-a35b-instruct` | `codex/gpt-5.3-codex` | Elon |
| Cornelius | No | Infra plans, rollback paths | Balanced | `ollama_local/qwen3-coder-next:latest` | `codex/gpt-5.3-codex` | Elon & Milo |
| Hemingway | No | Copy and messaging | Balanced | `ollama_local/qwen3:14b` | `zai/glm-5` | Elon |
| Jonny | No | Visual strategy, prompts | Balanced | `zai/glm-5` | `ollama_local/qwen3:14b` | Elon |
| Kairo | No (unless invoked) | Frontend, Next.js, Tailwind | Accuracy | `ollama_local/qwen3-coder-next:latest` | `nim/qwen3-coder-480b-a35b-instruct` | Elon |
| Zuck | No | Social packaging, publishing | Balanced | `ollama_local/qwen3.5:9b` | `nim/nemotron-3-super-120b-a12b` | Elon |
| Hermes | No (unless invoked) | Email triage, drafting | Balanced | `ollama_local/qwen3.5:14b` | `zai/glm-5` | Elon |

---

## Escalation Triggers

| Trigger | Action |
|---|---|
| Complexity >= 3 | Milo escalates to cloud model |
| Long context window | Milo escalates to cloud model |
| High-stakes output | Sentinel escalates to cloud model |
| Conflicting outputs | Sentinel escalates to cloud model |
| Impact score >= 8 | Pulse routes to Sagan and notifies Elon |
| Elevated risk mode | Cornelius escalates bias to accuracy |
| Cornelius active locally | Kairo routes to NIM escalation model |

---

## Routing Rules
- Simple and fast → MILO answers directly
- Cross-domain or multi-step → MILO briefs ELON
- Research required → converges through SAGAN
- Signal detected → starts at PULSE, escalates to SAGAN if material
- System change → NEO architecture, then CORNELIUS execution plan
- Outbound social → ZUCK only, through approved channels
- Legal exposure → THEMIS gate required
- Infra change or deployment → CERBERUS gate required

## Social Distribution Policy

### Manual Mode
Required for: ad hoc public posts, brand-sensitive posts, X posts, promotional launches.

### Standing-Approved Recurring Mode
- MILO approves the workflow lane once
- ELON clears each run instance
- ZUCK posts automatically to allowed channels
- SENTINEL review is conditional

### Emergency Halt
Any MILO halt or SENTINEL rejection suspends publishing immediately.
