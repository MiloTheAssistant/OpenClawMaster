# Tools Manifest

> Quick-scan index of all registered tools. Check here before writing new code.
> **Canonical definitions live in `config/tools.yaml`** — this file is a summary index only.
> Phase 5 roster: Milo, Sagan, Neo, Hermes, Sentinel, Cortana, Cornelius.

| Tool | Type | Used By | One-Line Description |
|---|---|---|---|
| read_state | internal | Milo | Read-only access to Cortana state store |
| routing_controls | internal | Milo | Set TIER_CAP, PARALLEL_CAP, RISK_MODE, HALT |
| sessions_spawn | internal | Milo | Dispatch to a named specialist via `agentId` |
| state_log | internal | Cortana | Write state updates, log completions/failures (auto-write allowed) |
| artifact_registry | internal | Cortana | Register and retrieve generated artifacts |
| cost_log | internal | Cortana | Log API cost to 2Brain/data/brain.sqlite |
| web_read | plugin | Sagan | Search the web and extract readable content via OpenClaw |
| web_fetch | plugin | Sagan | Fetch specific URLs and extract content (no JS) |
| docs_read | function | Sagan | Read local documents, PDFs, and 2Brain wiki/briefings |
| synthesis | capability | Sagan | Multi-source evidence aggregation (LLM-native, not a script) |
| code_read | function | Neo | Read and analyze code repositories and files |
| architecture | capability | Neo | Architecture briefs, dependency maps, tradeoff analysis (LLM-native) |
| plan_shell | capability | Cornelius | Generate shell execution plans — **never executes directly, Milo approval required** |
| plan_filesystem | capability | Cornelius | Generate filesystem change plans with rollback — **Milo approval required** |
| code_execute | capability | Cornelius | Execute coding tasks in Cornelius workspace — **Milo approval required for fs changes** |
| discord_post | api | Hermes | Post to Discord channels via webhook — **requires standing approval** |
| telegram_post | api | Hermes | Post to Telegram via bot API — **requires standing approval** |
| email_draft | api | Hermes | Draft email via Gmail MCP — **John sends, Hermes never sends on his own** |
| twobrain_read | filesystem | Cortana, Sagan, Hermes | Read from 2Brain wiki, outputs, briefings |
| twobrain_write | filesystem | Cortana | Write to 2Brain raw/ or outputs/ — **Cortana only** |
| mc_push | script | Milo, Cortana | Push tasks/comments to Mission Control via REST (`tools/scripts/mc-push.sh`) |
| read_only_review | internal | Sentinel | Read-only access to all agent outputs for QA evaluation |
