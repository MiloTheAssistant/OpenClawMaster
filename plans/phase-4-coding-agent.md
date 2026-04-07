# Phase 4: Coding Agent Strategy

## Context
With Anthropic banned from the OpenClaw harness, we need a non-Anthropic coding agent for routine autonomous tasks. Claude Code (the human's direct tool) handles critical/complex work. The ClawCode coding agent handles routine automation within OpenClaw's orchestration.

---

## 4.1 — Tiered Coding Strategy

| Tier | When | Tool | Model |
|---|---|---|---|
| **Critical** | Architecture decisions, security-sensitive code, production deploys, complex debugging | **Claude Code** (direct with John) | Claude Opus/Sonnet |
| **Routine** | Script generation, config changes, file operations, test writing, boilerplate | **ClawCode coding agent** (via OpenClaw) | MiniMax M2.7 (cloud) or GPT-OSS 120B (cloud) |
| **Fast/simple** | Linting, formatting, small fixes, one-liners | **ClawCode coding agent** (local) | GPT-OSS 20B (local Ollama) |

---

## 4.2 — Why MiniMax M2.7 for Routine Coding

- **SWE-Pro score: 56.22%** — top of class for agentic coding benchmarks
- **Terminal Bench 2: 57.0%** — strong at shell/terminal tasks
- **Built for agentic tasks** — native tool calling, multi-step execution
- **Available on Ollama Cloud** — fits Ollama Pro subscription (slot 3)
- **Keeps existing agent roles clean** — Cornelius plans, Neo architects, the coding agent *implements*

---

## 4.3 — Coding Agent Role Definition

This is NOT a new persona in `agents/*.md`. It's a **tool** in `config/tools.yaml` that Cornelius and Neo can invoke through Elon:

```yaml
code_execute:
  type: agent_capability
  description: "Execute coding tasks — write scripts, modify files, run tests"
  implementation: clawcode_coding_agent
  model_primary: ollama_cloud/minimax-m2.7
  model_local: ollama_local/gpt-oss:20b
  permissions: [read, write]
  restrictions:
    - "MILO approval required for filesystem changes outside ClawCode/coding-agent/workspace/"
    - "Never modify OpenClawMaster files directly"
    - "Never execute shell commands without plan approval"
  workspace: ~/repos/ClawCode/coding-agent/workspace/
```

### Workflow
```
Neo designs architecture (ENGINEERING_BRIEF)
  → Cornelius creates execution plan (EXEC_PLAN)
    → Milo approves
      → code_execute tool implements in ClawCode workspace
        → Sentinel reviews output
          → Milo delivers or approves deployment
```

---

## 4.4 — GPT-OSS as Local Fallback

When Ollama Pro cloud is unavailable or all 3 slots are in use:

- **GPT-OSS 20B** (~12GB) — fits alongside Gemma4 and other models in the 45GB budget
- **GPT-OSS 120B** — available via NIM or Ollama cloud for heavier tasks
- Apache 2.0 license, MoE architecture, configurable reasoning levels (low/medium/high)

```bash
# Pull locally
ollama pull gpt-oss:20b
```

---

## 4.5 — What the Coding Agent Does NOT Do

- Does NOT replace Claude Code for critical work
- Does NOT have direct shell execution (plans only — Milo approves)
- Does NOT modify OpenClawMaster governance files
- Does NOT deploy to production (Zuck handles deployment)
- Does NOT make architectural decisions (Neo's job)

---

## 4.6 — ClawCode Workspace Structure

```
ClawCode/coding-agent/
├── README.md          # Guidelines and restrictions
├── workspace/         # Scratch space — generated code lands here
│   ├── .gitkeep
│   └── (generated files)
└── approved/          # Milo-approved code promoted from workspace
    └── (promoted files moved to appropriate ClawCode directories)
```

---

## Files to Update

- `config/tools.yaml` — add `code_execute` tool entry
- `config/tools_manifest.md` — add to index
- Create `ClawCode/coding-agent/README.md` — guidelines

---

## Verification

- [ ] MiniMax M2.7 responds via Ollama Pro cloud
- [ ] GPT-OSS 20B loads locally and handles basic coding prompts
- [ ] code_execute tool registered in tools.yaml
- [ ] Workspace directory exists at ClawCode/coding-agent/workspace/
- [ ] Test: Elon dispatches a simple script-writing task → coding agent produces output → Sentinel reviews
