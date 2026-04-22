# Agent Model Routing Matrix

## Purpose
This matrix defines the role, user access, operating bias, routing behavior, and escalation posture for each agent in the OpenClaw Command Center.

**Source of truth for model assignments:** `config/models.yaml` + `~/.openclaw/openclaw.json`
**Source of truth for agent roles:** `AGENTS.md`
**Phase:** 5.1 (8-agent roster — Kat added for content)

## Model Bias Definitions
- **Speed:** low-latency triage and throughput
- **Balanced:** practical tradeoff between speed and precision
- **Accuracy:** deeper reasoning for expensive mistakes

## System Defaults
- `TIER_CAP`: set by Milo per task
- `PARALLEL_CAP`: 4
- `RISK_MODE`: balanced
- `EXECUTION_MODE`: simulate
- LOCAL/CLOUD strategy: hybrid

## Approved Providers
Ollama Local, Ollama Pro (cloud), NIM Direct, ChatGPT Pro (Codex), Perplexity Pro, Z.ai

**Blocked:** Anthropic API — policy conflict with OpenClaw harness

## Hardware Budget
- 64GB unified memory, ~8GB OS reserved
- 45GB max concurrent local models
- Cornelius exclusive: 48.2GB (all other local models unload)
- Ollama Pro: 3 concurrent cloud slots

---

## Matrix

### Command Layer

| Agent | User-facing | Primary Scope | Bias | Primary Model | Escalation | Fallback | Reports To |
|---|---|---|---|---|---|---|---|
| Milo | Yes | Intake, dispatch, orchestration, HALT | Balanced | `ollama/minimax-m2.7:cloud` | `openai/gpt-5.4` (long-context orchestration) | `zai/glm-5.1-turbo` | USER |

### Core Specialists

| Agent | User-facing | Primary Scope | Bias | Primary Model | Escalation | Fallback | Reports To |
|---|---|---|---|---|---|---|---|
| Sagan | No | Deep research, web-grounded synthesis | Accuracy | `perplexity/sonar-reasoning-pro` | `openai/gpt-5.4` (long-doc lane) | `nim/nvidia/llama-3.1-nemotron-ultra-253b-v1` | Milo |
| Neo | No | Engineering, architecture, coding | Accuracy | `nim/qwen/qwen3-coder-480b-a35b-instruct` | `openai/gpt-5.4` | `ollama/qwen3.6:35b-a3b-q4_K_M` (local) | Milo |
| Kat | No | Content creation — website copy, policy, blog, marketing | Balanced | `openai/gpt-5.4` (1M context) | — | `ollama/gemma4:31b-cloud` | Milo |
| Hermes | No (invokable) | Communications — Discord, Telegram, email | Balanced | `ollama/glm-5.1:cloud` | `zai/glm-5.1-turbo` | `ollama/qwen3.5:4b` | Milo |
| Sentinel | No | QA gate, output validation, security checks | Accuracy | `openai/o4-mini` (reasoning QA) | `zai/glm-5.1-turbo` | `ollama/glm-5.1:cloud` | Milo |
| Cortana | No | State, memory, telemetry, artifact tracking | Balanced | `ollama/qwen3.5:4b` | `ollama/glm-5.1:cloud` | — | Milo |
| Cornelius | No | Infra planning, execution plans, heavy coding | Balanced | `ollama/qwen3-coder-next:latest` | `ollama/minimax-m2.7:cloud` | — | Milo |

### Retired Agents

Elon, Pulse, Quant, Hemingway, Jonny, Kairo, Zuck, Themis, Cerberus, Sentinel-RT.
Available for reactivation when proven workflows need them — not in current runtime.

---

## Ollama Pro Cloud Slots (3 concurrent)

| Slot | Model | Serves |
|---|---|---|
| 1 | `minimax-m2.7:cloud` | Milo (primary) |
| 2 | `glm-5.1:cloud` | Hermes (primary), Cortana fallback |
| 3 | `gemma4:31b-cloud` | Kat (fallback), multimodal overflow |

> Sentinel moved to `openai/o4-mini` (Codex) for reasoning QA — frees a shared slot.
> Kat runs on `openai/gpt-5.4` (Codex) primary — 1M context for content work, falls back to slot 3.

## Local Model Roster

| Model | Size | Serves |
|---|---|---|
| `qwen3.5:4b` | ~3.4GB | Cortana (primary) |
| `qwen3.6:35b-a3b-q4_K_M` | ~23GB | Neo local fallback |
| `qwen3-coder-next:latest` | ~51GB | Cornelius (exclusive — unloads everything else) |
| `nemotron-cascade-2:latest` | ~24GB | Evaluation candidate (MoE 3B active — potential Cortana upgrade) |
| `nomic-embed-text` | ~0.3GB | Embedding (memory-core) |

---

## Escalation Triggers

| Trigger | Action |
|---|---|
| Planning 5+ phase workflow | Milo escalates to `openai/gpt-5.4` (1M context for phase state) |
| Orchestrating 4+ parallel specialist dispatches | Milo escalates to `openai/gpt-5.4` |
| Reviewing output across multiple specialist results | Milo escalates to `openai/gpt-5.4` |
| Milo session context ≥ 85% | Auto-swap to `openai/gpt-5.4` for that turn |
| High-stakes output | Sentinel escalates to `zai/glm-5.1-turbo` |
| Conflicting outputs | Sentinel escalates to `zai/glm-5.1-turbo` |
| Research confidence below threshold | Sagan escalates to `openai/gpt-5.4` (long-doc lane) |
| Research requires massive corpus ingestion | Sagan switches to `openai/gpt-5.4` (1M context) |
| Cornelius active locally | All other local agents route to cloud |
| Primary provider 5xx | Gateway falls through to escalation → fallback chain |

---

## Routing Rules

- **Trivial, no tools** → Milo answers directly
- **Cross-domain or multi-step** → Milo dispatches sequentially (Sagan → Hermes → ...)
- **Research required** → converges through Sagan
- **Outbound comms** → Hermes (Discord, Telegram, email)
- **System change** → Neo architecture, then Cornelius execution plan, Sentinel gate
- **Heavy local coding** → Cornelius (exclusive, all other local models unload)
- **Critical/complex coding** → escalate to Claude Code directly (outside harness)
- **Output quality check** → Sentinel
- **State change or artifact** → Cortana

## Distribution Policy

### Manual Mode
Required for: ad-hoc public posts, brand-sensitive posts, X posts, promotional launches.

### Standing-Approved Recurring Mode
- Milo approves the workflow lane once
- Hermes posts automatically to allowed channels
- Sentinel review is conditional

### Emergency Halt
Any Milo halt or Sentinel rejection suspends publishing immediately.
