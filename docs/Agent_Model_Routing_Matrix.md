# Agent_Model_Routing_Matrix.md

## Purpose
This matrix defines the role, user access, operating bias, routing behavior, and escalation posture for each agent.

## Model Bias Definitions
- Speed: low-latency triage and throughput
- Balanced: practical tradeoff between speed and precision
- Accuracy: deeper reasoning for expensive mistakes

## System Defaults
- TIER_CAP set by MILO
- PARALLEL_CAP default: 6
- RISK_MODE default: balanced
- EXECUTION_MODE default: simulate
- LOCAL/CLOUD strategy: hybrid

## Matrix

| Agent | User-facing | Primary Scope | Operating Bias | Typical Use | Escalation Trigger | Reports To |
|---|---|---:|---|---|---|---|
| Milo | Yes | Governance, intake, approvals | Balanced | Quick answers, caps, final gate | Complexity >= 3 or high risk | USER |
| Elon | Yes | Orchestration, task graphs, synthesis | Accuracy | Multi-step plans, routing, executive packets | Large cross-domain workflows | Milo & USER |
| Sentinel | No | QA, contradictions, risk review | Accuracy | Risk checks, validation, blocking decisions | High-stakes or conflicting outputs | Elon & Milo |
| Cortana | No | State, telemetry, logs | Balanced | State briefs, artifact registry, recurring patterns | Multi-project state views | Milo & Elon |
| Pulse | No | Signal detection and triage | Speed | Scanning, urgency scoring, clustering | impact_score >= 8 routes onward | Elon |
| Sagan | No | Research and synthesis authority | Accuracy | Evidence-backed briefs, source synthesis | Large source sets, high stakes | Elon |
| Neo | No | Engineering and architecture | Accuracy | Architecture, tradeoffs, dependencies | Critical system design | Elon |
| Cornelius | No | Infrastructure and automation plans | Balanced | Exec plans, verification, rollback | Escalate to accuracy under elevated risk | Elon & Milo |
| Hemingway | No | Copy and messaging | Balanced | Copy variants, summaries, packaged language | Brand-critical launches | Elon |
| Jonny | No | Visual strategy and prompts | Balanced | Visual briefs, prompt blocks, creative systems | Large campaign systems | Elon |
| Zuck | No | Social packaging and publishing | Balanced | Platform-native packages, cadence, recurring posting | Public launch / new channel / policy change | Elon |

## Routing Rules
- If the request is simple and answerable within ~15 seconds, MILO answers directly.
- If the request spans multiple domains or dependencies, MILO briefs ELON.
- Research questions converge through SAGAN before external distribution.
- Signals start at PULSE and escalate to SAGAN if material.
- Engineering architecture starts at NEO; system-change execution plans follow through CORNELIUS.
- Outbound social distribution runs through ZUCK only.

## Social Distribution Policy
### Manual Mode
- Required for ad hoc public posts, brand-sensitive posts, X posts, and promotional launches.

### Standing-Approved Recurring Mode
- MILO approves the workflow lane once.
- ELON clears each run instance.
- ZUCK posts automatically to allowed channels.
- SENTINEL review is conditional.

### Emergency Halt
- Any MILO halt or SENTINEL rejection suspends publishing immediately.
