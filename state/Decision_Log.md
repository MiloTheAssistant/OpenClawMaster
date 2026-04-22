# Decision Log

> Append-only. Never modify past entries.
> Maintained by CORTANA with MILO approval for policy-level entries.

| ID | Date | Decision | Made By | Context |
|---|---|---|---|---|
| DEC-001 | — | Established GOTCHA Framework as operating architecture | Milo | Initial system design |
| DEC-002 | — | Anthropic API blocked for OpenClaw harness use | Milo | Provider policy |
| DEC-003 | — | DFB standing approval granted | Milo | Recurring workflow approval |
| DEC-004 | — | X posting set to manual-only pending API setup | Milo | Channel policy |
| DEC-005 | 2026-04-22 | Specialist dispatch diagnosed as broken; Milo has been confabulating Sagan/Neo/Sentinel/Cortana dispatches | John | `sessions_spawn` defaults to `runtime="subagent"` which spawns anonymous children of `main` (no specialist identity, runs on Milo's subagent default model). `runtime="acp"` honors `agentId` but requires `acp.defaultAgent` config and removal of `tools.deny:["*"]` on Sagan + Cortana. Pattern known and documented in gateway log since 2026-04-13; lost from working memory. Path forward: Option A (proper ACP) under active discussion for parallel specialist work. Options B (role-brief subagents) and C (cron-isolated dispatch) documented as alternatives. |
