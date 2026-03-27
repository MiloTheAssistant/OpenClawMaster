# State_Schema.md

## Owner
CORTANA

## Allowed State Types
- active_projects
- pending_items
- recent_failures
- blockers
- resource_notes
- decision_log_entries
- artifact_registry_entries
- workflow_run_records
- memory_entries
- guardrail_proposals

## Update Rules
- Controlled automatic state updates are allowed.
- Durable policy changes require MILO approval.
- CORTANA may log run completions, failures, and artifact references automatically.
- CORTANA may write to `state/memory/MEMORY.md` for facts and events automatically.
- Policy-level memory updates (user preferences, system policy) require MILO approval.
- CORTANA generates `GUARDRAIL_PROPOSAL` when 3+ instances of the same failure pattern occur within 24h.
- Guardrail proposals require MILO approval before being added to `GotchaFramework.md`.

## File Locations
- `state/Active_Projects.md` — project tracking
- `state/Artifacts_Index.md` — artifact registry
- `state/Decision_Log.md` — decision history (append-only)
- `state/memory/MEMORY.md` — persistent cross-session facts
- `state/memory/logs/YYYY-MM-DD.md` — daily session logs

## Decision Log Fields
- decision
- context
- authority
- outcome
- confidence
- timestamp
- rollback_notes

## Artifact Registry Fields
- artifact_name
- workflow
- location
- created_by
- timestamp
- retention

## Memory Entry Fields
- content
- entry_type: fact | preference | event | insight | task
- importance: 1-10
- timestamp
- source_agent

## Guardrail Proposal Fields
- pattern (what keeps failing)
- failure_count
- timeframe
- proposed_guardrail (text of the new guardrail)
- severity: low | medium | high
- approval_required: Milo
- status: proposed | approved | rejected

## Failure Pattern Detection Rules
Cortana tracks all `recent_failures` entries and groups by:
- `failure_type` (timeout, malformed_output, model_unavailable, etc.)
- `failed_agent`
- `workflow` (if applicable)

When any grouping reaches 3+ occurrences within a rolling 24h window:
1. Cortana generates a `GUARDRAIL_PROPOSAL`
2. The proposal is logged in `state/Decision_Log.md` as a pending decision
3. Milo is notified for review
4. If approved, the guardrail is appended to `GotchaFramework.md#guardrails--learned-behaviors`
