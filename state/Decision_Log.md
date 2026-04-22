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
| DEC-006 | 2026-04-22 | Phase 5.1 — Kat content specialist added, dispatch architecture pivoted from `sessions_spawn(runtime:"acp")` to cron-based isolated dispatch; confabulation bug fixed | John | Option A (ACP) attempted but `acpx` plugin requires per-agent external spawn commands (designed for external ACP agents like Claude Code CLI, not internal in-process routing). Pivoted to Option C (cron-isolated dispatch): `cron add --agent <specialist> --session isolated --no-deliver --delete-after-run`. Canary results: (1) direct cron dispatch to Sagan creates `agent:sagan:cron:*` on `sonar-reasoning-pro` ✅; (2) parallel Sagan+Kat confirmed (Kat 14k/128k gpt-5.4 real processing) ✅; (3) Milo dispatch via isolated cron correctly reports failures instead of confabulating ✅. Known open bugs (not blockers): (a) Perplexity adapter rejects cron agentTurn message format with `400 Tool parameters must be a JSON object` — affects Sagan specifically; (b) isolated Milo sessions may have different tool surface than persistent main — `cron` tool discoverability needs verification. Kat's model stack validated: gpt-5.4 primary (1M ctx, multimodal), gemma4:31b-cloud fallback. Sentinel moved to openai/o4-mini. 8-agent roster: main, sagan, neo, kat, hermes, sentinel, cortana, cornelius. |
