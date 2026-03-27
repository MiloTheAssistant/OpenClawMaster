# Tools Manifest

> One-line index of all registered tools. Agents scan this before writing new code.
> Source of truth: `config/tools.yaml`

| Tool | Type | Used By | One-Line Description |
|---|---|---|---|
| read_state | internal | Milo, Elon | Read-only access to Cortana state store |
| routing_controls | internal | Milo | Set TIER_CAP, PARALLEL_CAP, RISK_MODE, HALT |
| orchestration | internal | Elon | Build task graphs, fan-out/fan-in, clear run instances |
| state_log | internal | Cortana | Write state updates, log completions/failures (auto-write allowed) |
| artifact_registry | internal | Cortana | Register and retrieve generated artifacts |
| web_read | plugin | Pulse, Sagan | Search the web and extract readable content via OpenClaw |
| web_fetch | plugin | Sagan | Fetch specific URLs and extract content (no JS) |
| feeds | plugin | Pulse | Monitor RSS/API feeds for signal detection |
| docs_read | function | Sagan | Read local documents, PDFs, and knowledge base files |
| synthesis | capability | Sagan | Multi-source evidence aggregation (LLM-native, not a script) |
| code_read | function | Neo | Read and analyze code repositories and files |
| architecture | capability | Neo | Architecture briefs, dependency maps, tradeoff analysis (LLM-native) |
| plan_shell | capability | Cornelius | Generate shell execution plans — **never executes directly, Milo approval required** |
| plan_filesystem | capability | Cornelius | Generate filesystem change plans with rollback — **Milo approval required** |
| copy_formatting | capability | Hemingway | Format copy variants with audience/tone/CTA metadata (LLM-native) |
| visual_prompting | capability | Jonny | Generate visual direction briefs and image gen prompts (LLM-native) |
| discord_post | api | Zuck | Post to Discord channels via webhook — **requires standing approval** |
| telegram_post | api | Zuck | Post to Telegram via bot API — **requires standing approval** |
| x_post | api | Zuck | Post to X.com — **manual only, Milo approval per post, API pending** |
| read_only_review | internal | Sentinel | Read-only access to all agent outputs for QA evaluation |
