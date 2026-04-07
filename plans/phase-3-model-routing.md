# Phase 3: Model Routing — 2026 Optimal Configuration

## Context
Assign the best 2026 models to each of the 16 agents. Balance local performance (45GB budget), Ollama Pro cloud (3 concurrent), and external APIs (NIM, Codex, Perplexity, Z.ai). Milo must never be blocked.

---

## 3.1 — Hardware Budget

| Resource | Value |
|---|---|
| Total memory | 64GB unified |
| OS + services reserved | ~8GB |
| Max concurrent local models | 45GB |
| Cornelius exclusive | 51GB (all other local models unload) |
| Ollama Pro concurrent slots | 3 cloud models |

---

## 3.2 — Local Model Roster (under 45GB concurrent)

| Model | Size | Agents Served | Notes |
|---|---|---|---|
| `nemotron-3-nano:4b` | ~2.5GB | Milo (always-on), Cortana | Tiny, fast, always loaded. Milo's instant-answer model. |
| `gemma4:27b` | ~16GB | Pulse, Quant, Hemingway, Zuck, Hermes | Replaces 3 separate qwen variants. Strong reasoning, multimodal, 256K context. |
| `glm-4.7-flash` | ~5GB | Sentinel | Proven QA gate. Keep as-is. |
| `qwen3.5:35b-a3b-codingnvfp4` | ~18GB | Kairo | Quantized for M4 Pro. Frontend coding. |
| `nomic-embed-text` | ~0.3GB | Embedding (2Brain) | Always loaded. |
| **Total concurrent** | **~42GB** | | Fits in 45GB budget |

### Cornelius Exclusive Mode
When Cornelius activates: Ollama unloads all models except nomic-embed-text → loads `qwen3-coder-next:latest` (51GB) → runs task → restores standard set.

---

## 3.3 — Ollama Pro Cloud Strategy (3 concurrent)

| Slot | Model | Agents Served | Rationale |
|---|---|---|---|
| 1 | `nemotron-super-49b:cloud` | Milo (escalated), Elon | Milo's escalation model. Too large for concurrent local. |
| 2 | `qwen3-coder-next:cloud` | Kairo (when Cornelius holds local), Neo (fallback) | Cloud coding when local is full. |
| 3 | `minimax-m2.7:cloud` | ClawCode coding agent, overflow | Agentic coding tasks. SWE-Pro 56.22%. |

---

## 3.4 — External API Routing

| Provider | Models | Agents | Cost Model |
|---|---|---|---|
| **NIM Direct** | Nemotron Ultra 253B, Nemotron Super 49B v1.5, Qwen3-Coder 480B | Themis, Cerberus, Neo, Elon (escalation) | Free tier → per-token |
| **ChatGPT Plus / Codex** | GPT-5.4, o4-mini, gpt-5.3-codex | Elon (primary), Quant (escalation), Sagan (escalation) | Included in subscription via OAuth |
| **Z.ai** | GLM-5 | Jonny (primary), Sentinel (escalation) | Paid account |
| **Perplexity Pro** | Sonar Reasoning Pro | Sagan (primary) | Included in Pro subscription |

---

## 3.5 — Per-Agent Model Assignments

### Command Layer
| Agent | Primary | Escalation | Fallback |
|---|---|---|---|
| **Milo** | `ollama_local/nemotron-3-nano:4b` | `ollama_cloud/nemotron-super-49b` | `nim/nemotron-super-49b-v1.5` |
| **Elon** | `codex/gpt-5.4` | `nim/nemotron-ultra-253b` | `ollama_cloud/nemotron-super-49b` |

### Governance Layer
| Agent | Primary | Escalation | Fallback |
|---|---|---|---|
| **Sentinel** | `ollama_local/glm-4.7-flash` | `zai/glm-5` | `ollama_local/gemma4:27b` |
| **Cortana** | `ollama_local/nemotron-3-nano:4b` | `ollama_local/gemma4:27b` | — |
| **Themis** | `nim/nemotron-ultra-253b` | `codex/gpt-5.4` | `zai/glm-5` |
| **Cerberus** | `nim/nemotron-ultra-253b` | `codex/gpt-5.4` | `zai/glm-5` |

### Specialist Layer
| Agent | Primary | Escalation | Fallback |
|---|---|---|---|
| **Pulse** | `ollama_local/gemma4:27b` | `perplexity/sonar-pro` | `nim/nemotron-super-49b-v1.5` |
| **Sagan** | `perplexity/sonar-reasoning-pro` | `codex/gpt-5.4` | `zai/glm-5` |
| **Quant** | `ollama_local/gemma4:27b` | `codex/o4-mini` | `nim/nemotron-super-49b-v1.5` |
| **Neo** | `nim/qwen3-coder-480b` | `codex/gpt-5.4` | `ollama_cloud/qwen3-coder-next` |
| **Cornelius** | `ollama_local/qwen3-coder-next` | `codex/gpt-5.4` | — |
| **Hemingway** | `ollama_local/gemma4:27b` | `zai/glm-5` | `nim/nemotron-super-49b-v1.5` |
| **Jonny** | `zai/glm-5` | `ollama_local/gemma4:27b` | — |
| **Kairo** | `ollama_local/qwen3.5:35b-a3b-codingnvfp4` | `nim/qwen3-coder-480b` | `ollama_cloud/qwen3-coder-next` |
| **Zuck** | `ollama_local/gemma4:27b` | `nim/nemotron-super-49b-v1.5` | — |
| **Hermes** | `ollama_local/gemma4:27b` | `zai/glm-5` | `nim/nemotron-super-49b-v1.5` |

---

## 3.6 — Key Changes from Current Config

| Change | Rationale |
|---|---|
| Milo: nemotron-super-49b → nemotron-3-nano:4b (local) | Milo must never block. 4B stays loaded permanently. Escalates to cloud for complex tasks. |
| Gemma4:27b replaces qwen3:14b, qwen3.5:9b, qwen3.5:14b | One stronger model serves 6 agents. Reduces model management. |
| Elon: NIM → Codex GPT-5.4 as primary | Frontier reasoning for orchestration. NIM becomes escalation. |
| Cortana: qwen3.5:4b → nemotron-3-nano:4b | Shares Milo's always-loaded model. Zero overhead. |
| GPT-OSS 20B available for local coding | Pulled but not assigned to an agent — used by ClawCode coding agent (see Phase 4). |

---

## 3.7 — New 2026 Models — Status

| Model | Status | Use Case |
|---|---|---|
| **Gemma4 27B** | ADOPT — primary local for 6 agents | Text generation, reasoning, signal detection |
| **GPT-5.4** | ADOPT — Elon primary via Codex | Frontier orchestration |
| **GPT-OSS 20B/120B** | ADOPT — local coding agent | Routine autonomous coding in ClawCode |
| **MiniMax M2.7** | ADOPT — Ollama Pro cloud | Agentic coding tasks, tool calling |
| **GLM-5** | KEEP — Jonny primary, Sentinel escalation | Visual strategy, creative |
| **GLM-OCR** | EVALUATE — add as tool, not agent model | Document understanding for Hermes/Sagan |
| **Microsoft MAI** | DEFER — Azure-only, not LLM reasoning | Speech/voice/image. Revisit when multimodal workflows emerge. |

---

## Files to Update

- `config/models.yaml` — rewrite with new assignments
- `docs/Agent_Model_Routing_Matrix.md` — update tables
- `openclaw.json` → `models` section — update provider and agent model entries
- Each `agents/*.md` — update model field in frontmatter

---

## Verification

- [ ] `ollama list` shows all local models pulled
- [ ] Milo responds instantly on nemotron-3-nano:4b (test via Telegram)
- [ ] Gemma4:27b loads and serves Pulse/Hemingway/Zuck prompts correctly
- [ ] Cornelius exclusive mode works (other models unload, qwen3-coder-next loads)
- [ ] Ollama Pro cloud slots respond (test nemotron-super-49b, qwen3-coder-next, minimax-m2.7)
- [ ] NIM API responds for Themis/Cerberus/Neo
- [ ] Codex OAuth works for Elon/GPT-5.4
- [ ] Perplexity responds for Sagan
- [ ] Z.ai responds for Jonny
