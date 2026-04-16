# Task_Lifecycle.md

## Canonical Stages (Phase 5)
1. Intake
2. Triage
3. Dispatch
4. Specialist Work
5. Compile
6. QA
7. Approval
8. Delivery
9. State Update

## Definitions

### Intake
Milo identifies the actual goal and missing critical context.

### Triage
Milo classifies complexity, risk, and whether the task is direct-answer or dispatch-worthy.

### Dispatch
Milo selects a Router Profile from `config/routing.yaml` (or builds a custom sequence). He dispatches each step to a named specialist via `sessions_spawn` with `agentId`. Multi-step tasks loop back through Milo between steps.

### Specialist Work
Named agents (Sagan, Neo, Hermes, Sentinel, Cortana, Cornelius) return structured envelopes — no side effects, no direct user messaging.

### Compile
Milo aggregates each specialist's output and decides the next step: another dispatch, QA, delivery, or halt.

### QA
Sentinel reviews when required by policy or anomaly triggers (brand-sensitive content, source conflict, confidence below threshold, new channel).

### Approval
Milo approves high-risk actions (infra changes, new channels) and standing workflow policies. Recurring workflows with `standing_approval_granted: true` in `config/workflows.yaml` run without per-instance approval.

### Delivery
Milo communicates with John. Hermes handles outbound comms (Discord, Telegram, email drafts — John sends email).

### State Update
Cortana records state, artifacts, failures, and completion notes under policy.
