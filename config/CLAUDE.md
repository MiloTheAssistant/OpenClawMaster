# config/ — Configuration Layer

> Scoped context for any AI agent editing files in this directory.

## What Lives Here

| File | Purpose | Format |
|------|---------|--------|
| `models.yaml` | Agent-to-model assignments, provider config, failover chains | YAML |
| `routing.yaml` | Router profiles, complexity thresholds, agent selection rules | YAML |
| `workflows.yaml` | Workflow definitions — step sequences, formations, triggers | YAML |
| `tools.yaml` | Tool registry — type, description, implementation, permissions | YAML |
| `tools_manifest.md` | Human-readable tool index (generated from tools.yaml) | Markdown |
| `parallelism.yaml` | Parallel execution caps, memory budgets, exclusivity rules | YAML |
| `channels.yaml` | Channel definitions — Telegram, Discord, email, etc. | YAML |

## Rules

- **Check before you build.** Before creating a new tool, workflow, or routing rule, check if one already exists in the relevant file above.
- **models.yaml and AGENTS.md must stay in sync.** When you change a model assignment here, update the Agent Roster table in `AGENTS.md` to match. Run `tools/scripts/sync-agents-models.sh` to verify.
- **Dual-cloud resilience pattern.** Every agent should have escalation and fallback on different providers (Ollama Cloud vs Z.ai). Never put two adjacent failover layers on the same provider.
- **Format mismatches are silent failures.** When chaining tools or modifying handoff formats, verify the output format of one step matches the expected input of the next.
- **Never assume batch support.** Check API documentation before assuming any external service supports batch operations.
- **Workflow definitions are living documents.** Update when better approaches or API constraints emerge, but require Milo approval before modifying.
- **Local model memory budget:** 45GB concurrent max. Cornelius is exclusive at 48.2GB — all other local models unload when he runs.
