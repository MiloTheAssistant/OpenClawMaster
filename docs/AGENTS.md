# AGENTS.md (summary)

> **Source of truth:** `../AGENTS.md` at the repo root.
> This file is a quick-scan summary; the root file is canonical.

## Purpose
Global communication rules, operating rules, authority structure, and handoff expectations for the OpenClaw deployment. **Phase 5** (streamlined 7-agent roster).

## User-Facing Access
The USER speaks directly with **MILO** only. Hermes (comms) or Sentinel (QA) may be explicitly invoked by name.

## Layers

### Command Layer
- MILO (intake + orchestrator)

### Governance Layer
- SENTINEL (QA gate)
- CORTANA (state + memory)

### Specialist Layer
- SAGAN (research)
- NEO (engineering)
- CORNELIUS (infra + heavy coding; runs solo)
- HERMES (outbound comms)

## Authority
1. USER
2. MILO (intake, dispatch, HALT, delivery)
3. SENTINEL / CORTANA within their scopes
4. Specialist agents within assigned tasks only

## Core Operating Rules
- SAGAN is the single research authority for evidence-backed synthesis
- HERMES handles all outbound comms (Discord, Telegram, email drafts)
- CORNELIUS proposes execution plans and rollback paths; runs solo (~48.2GB)
- SENTINEL evaluates outputs, risks, and contradictions only
- CORTANA tracks structured state and telemetry only
- MILO is the only direct interface to the USER
- Any durable state change or high-risk action requires MILO approval unless covered by standing workflow policy
- Any outbound publishing requires approved workflow policy

## Standing Workflow Approval
A standing-approved recurring workflow runs with reduced friction when:
- MILO approved the workflow policy on creation
- SENTINEL is not blocking when review is triggered
- HERMES posts only to explicitly allowed channels (`config/channels.yaml`)

## Router Profiles
See `./Router_Profiles.md` for reusable formations (intelligence, engineering, comms, research, governance).

## Model and Routing Policy
See `./Agent_Model_Routing_Matrix.md` for agent bias, escalation rules, and task routing.
