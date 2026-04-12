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
Ollama Local, Ollama Pro (cloud), NIM Direct, ChatGPT Pro (Codex), Perplexity Pro, Z.ai

**Blocked:** Anthropic API — policy conflict with OpenClaw harness

## Hardware Budget
- 64GB unified memory, ~8GB OS reserved
- 45GB max concurrent local models
- Cornelius exclusive: 51GB (all other local models unload)
- Ollama Pro: 3 concurrent cloud slots

---

## Matrix

### Command Layer

| Agent | User-facing | Primary Scope | Bias | Primary Model | Escalation Model | Fallback | Reports To |
|---|---|---|---|---|---|---|---|
| Milo | Yes | Governance, intake, approvals | Balanced | `ollama_cloud/gemma4:31b-cloud` | `nim/nemotron-super-49b-v1.5` | `ollama_local/nemotron-3-nano:4b` | USER |
| Elon | Yes (status only) | Orchestration, task graphs | Accuracy | `codex/gpt-5.4` | `nim/nemotron-ultra-253b` | `ollama_cloud/nemotron-super:cloud` | Milo & USER |

### Governance Layer

| Agent | User-facing | Primary Scope | Bias | Primary Model | Escalation Model | Fallback | Reports To |
|---|---|---|---|---|---|---|---|
| Sentinel | No | QA, contradictions, risk review | Accuracy | `ollama_local/glm-4.7-flash` | `zai/glm-5` | `ollama_local/gemma4:26b` | Elon & Milo |
| Cortana | No | State, telemetry, logs | Balanced | `ollama_local/nemotron-3-nano:4b` | `ollama_local/gemma4:26b` | — | Milo & Elon |
| Themis | No (unless invoked) | Legal intelligence, compliance | Accuracy | `nim/nemotron-ultra-253b` | `codex/gpt-5.4` | `zai/glm-5` | Elon & Milo |
| Cerberus | No (unless invoked) | Security, threats, incidents | Accuracy | `nim/nemotron-ultra-253b` | `codex/gpt-5.4` | `zai/glm-5` | Elon & Milo |

### Specialist Layer

| Agent | User-facing | Primary Scope | Bias | Primary Model | Escalation Model | Fallback | Reports To |
|---|---|---|---|---|---|---|---|
| Pulse | No | Signal detection, triage | Speed | `ollama_local/gemma4:26b` | `perplexity/sonar-pro` | `nim/nemotron-super-49b-v1.5` | Elon |
| Sagan | No | Research and synthesis | Accuracy | `perplexity/sonar-reasoning-pro` | `codex/gpt-5.4` | `zai/glm-5` | Elon |
| Quant | No | Financial metrics | Accuracy | `ollama_local/gemma4:26b` | `codex/o4-mini` | `nim/nemotron-super-49b-v1.5` | Elon |
| Neo | No | Engineering, architecture | Accuracy | `nim/qwen3-coder-480b` | `codex/gpt-5.4` | `ollama_cloud/qwen3-coder-next` | Elon |
| Cornelius | No | Infra plans, rollback paths | Balanced | `ollama_local/qwen3-coder-next:latest` | `codex/gpt-5.4` | — | Elon & Milo |
| Hemingway | No | Copy and messaging | Balanced | `ollama_local/gemma4:26b` | `zai/glm-5` | `nim/nemotron-super-49b-v1.5` | Elon |
| Jonny | No | Visual strategy, prompts | Balanced | `zai/glm-5` | `ollama_local/gemma4:26b` | — | Elon |
| Kairo | No (unless invoked) | Frontend, Next.js, Tailwind | Accuracy | `ollama_local/qwen3.5:35b-a3b-codingnvfp4` | `nim/qwen3-coder-480b` | `ollama_cloud/qwen3-coder-next` | Elon |
| Zuck | No | Social packaging, publishing | Balanced | `ollama_local/gemma4:26b` | `nim/nemotron-super-49b-v1.5` | — | Elon |
| Hermes | No (unless invoked) | Email triage, drafting | Balanced | `ollama_local/gemma4:26b` | `zai/glm-5` | `nim/nemotron-super-49b-v1.5` | Elon |

---

## Ollama Pro Cloud Slots (3 concurrent)

| Slot | Model | Serves |
|---|---|---|
| 1 | `gemma4:31b-cloud` | Milo (primary), general overflow |
| 2 | `qwen3-coder-next:cloud` | Kairo (when Cornelius holds local), Neo (fallback) |
| 3 | `minimax-m2.7:cloud` | ClawCode coding agent, overflow |

## Local Model Roster (~42GB concurrent)

| Model | Size | Serves |
|---|---|---|
| `nemotron-3-nano:4b` | ~2.5GB | Milo (fallback), Cortana |
| `gemma4:26b` | ~16GB | Pulse, Quant, Hemingway, Zuck, Hermes |
| `glm-4.7-flash` | ~5GB | Sentinel |
| `qwen3.5:35b-a3b-codingnvfp4` | ~18GB | Kairo |
| `nomic-embed-text` | ~0.3GB | Embedding (2Brain) |

---

## Escalation Triggers

| Trigger | Action |
|---|---|
| Complexity >= 3 | Milo escalates to NIM nemotron-super-49b |
| Long context window | Milo escalates to NIM |
| High-stakes output | Sentinel escalates to zai/glm-5 |
| Conflicting outputs | Sentinel escalates to zai/glm-5 |
| Impact score >= 8 | Pulse routes to Sagan and notifies Elon |
| Elevated risk mode | Cornelius escalates bias to accuracy |
| Cornelius active locally | Kairo routes to NIM qwen3-coder-480b |

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
