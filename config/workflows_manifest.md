# Workflows Manifest

> One-line index of all defined workflows. Agents scan this for fast triage before parsing full YAML.
> Source of truth: `config/workflows.yaml`

| Workflow | Type | Schedule | Channels | Status |
|---|---|---|---|---|
| Daily_Financial_Briefing | recurring_publish | Cron, 7AM CT weekdays | Discord, Telegram | Active — standing approval granted (DEC-003) |
| Market_Signal_Scanner | intelligence | Every 2h during market hours | Internal only | Active — workflow spec complete |
| Content_Repurposing_Engine | campaign | On-demand | Discord, Telegram (X manual) | Paused — pending Milo standing approval |
