# Agent Model Routing Matrix

## Purpose
This matrix defines the role, user access, operating bias, routing behavior, and escalation posture for each agent in the OpenClaw Command Center.

**Source of truth for model assignments:** `config/models.yaml`
**Source of truth for agent roles:** `AGENTS.md`
**Phase:** 5 (streamlined 7-agent roster)

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
| Milo | Yes | Intake, dispatch, orchestration, HALT | Balanced | `codex/o4-mini` | `codex/gpt-5.4` | `zai/glm-5.1-turbo` | USER |

### Core Specialists

| Agent | User-facing | Primary Scope | Bias | Primary Model | Escalation | Fallback | Reports To |
|---|---|---|---|---|---|---|---|
| Sagan | No | Deep research, web-grounded synthesis | Accuracy | `perplexity/sonar-reasoning-pro` | `codex/gpt-5.4` | `zai/glm-5.1-turbo` | Milo |
| Neo | No | Engineering, architecture, coding | Accuracy | `nim/qwen/qwen3-coder-480b-a35b-instruct` | `codex/gpt-5.4` | `ollama_cloud/minimax-m2.7:cloud` | Milo |
| Hermes | No (invokable) | Communications — Discord, Telegram, email | Balanced | `ollama_cloud/glm-5.1:cloud` | `zai/glm-5.1-turbo` | `ollama_local/qwen3.5:4b` | Milo |
| Sentinel | No | QA gate, output validation, security checks | Accuracy | `ollama_cloud/glm-5.1:cloud` | `zai/glm-5.1-turbo` | `ollama_local/qwen3.5:4b` | Milo |
| Cortana | No | State, memory, telemetry, artifact tracking | Balanced | `ollama_local/qwen3.5:4b` | `ollama_cloud/glm-5.1:cloud` | — | Milo |
| Cornelius | No | Infra planning, execution plans, heavy coding | Balanced | `ollama_local/qwen3-coder-next:latest` | `ollama_cloud/minimax-m2.7:cloud` | — | Milo |

### Retired Agents

Elon, Pulse, Quant, Hemingway, Jonny, Kairo, Zuck, Themis, Cerberus, Sentinel-RT.
Available for reactivation when proven workflows need them — not in current runtime.

---

## Ollama Pro Cloud Slots (3 concurrent)

| Slot | Model | Serves |
|---|---|---|
| 1 | `glm-5.1:cloud` | Hermes (primary), Sentinel (primary) |
| 2 | `minimax-m2.7:cloud` | Neo (fallback), Cornelius (escalation) |
| 3 | reserved | overflow / research bursts |

> Milo now runs on `codex/o4-mini` (ChatGPT Pro) — not an Ollama slot.

## Local Model Roster

| Model | Size | Serves |
|---|---|---|
| `qwen3.5:4b` | ~3.2GB | Cortana (primary), Hermes/Sentinel (fallback) |
| `qwen3-coder-next:latest` | ~48.2GB | Cornelius (exclusive — unloads everything else) |
| `nomic-embed-text` | ~0.3GB | Embedding (2Brain memory-core) |

---

## Escalation Triggers

| Trigger | Action |
|---|---|
| Complexity >= 3 | Milo escalates to `codex/gpt-5.4` |
| Long context window | Milo escalates to `codex/gpt-5.4` |
| High-stakes output | Sentinel escalates to `zai/glm-5.1-turbo` |
| Conflicting outputs | Sentinel escalates to `zai/glm-5.1-turbo` |
| Research confidence below threshold | Sagan escalates to `codex/gpt-5.4` |
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
