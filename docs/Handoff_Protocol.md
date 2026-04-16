# Handoff_Protocol.md

## Purpose
Every inter-agent handoff should be explicit, structured, and easy to audit.

## Required Fields
- TASK_ID
- PARENT_TASK_ID
- REQUEST
- GOAL
- INPUTS
- CONSTRAINTS
- ASSUMPTIONS
- EXPECTED_OUTPUT
- DEPENDENCIES
- CONFIDENCE
- NEXT_RECOMMENDED_AGENT

## Rules
- Specialists return structured envelopes only.
- No side effects inside handoff content.
- No direct USER messaging from non-user-facing agents.
- Include blocking dependencies when fan-in is required.
- Include confidence and unresolved contradictions when present.

## Recommended Envelope Example
HANDOFF_PACKET:
  TASK_ID:
  PARENT_TASK_ID:
  REQUEST:
  GOAL:
  INPUTS:
  CONSTRAINTS:
  ASSUMPTIONS:
  EXPECTED_OUTPUT:
  DEPENDENCIES:
  CONFIDENCE:
  NEXT_RECOMMENDED_AGENT:

---

## Failure Handling

### Failure Types
- **timeout** — agent did not return within tolerance window
- **malformed_output** — response does not match expected envelope schema
- **confidence_below_threshold** — agent returned a result but confidence is too low to proceed
- **model_unavailable** — assigned model is down, rate-limited, or unreachable
- **context_overflow** — input exceeds model's context window

### Failure Envelope
When an agent fails, Elon (or the dispatching agent) generates a failure envelope:

FAILURE_ENVELOPE:
  TASK_ID:
  PARENT_TASK_ID:
  FAILED_AGENT:
  FAILURE_TYPE: timeout | malformed_output | confidence_below_threshold | model_unavailable | context_overflow
  RETRY_COUNT:
  MAX_RETRIES: 1  # per parallelism.yaml retry_policy
  FALLBACK_ACTION: retry | reroute | mark_partial | escalate_to_milo
  FALLBACK_MODEL:  # if model_unavailable, specify fallback from models.yaml
  ERROR_DETAIL:
  LAST_GOOD_STATE_REF:  # Cortana state key for rollback reference
  TIMESTAMP:

### Failure Resolution Rules
1. **First failure (transient):** Retry once with same model. If model_unavailable, retry with fallback_model from models.yaml.
2. **Second failure (same task):** Elon reroutes to an alternative agent or marks the branch as partial.
3. **Required branch failure:** If the failed branch is required for fan-in (e.g., Sagan in DFB), Elon marks the entire packet as partial and notifies Milo.
4. **Non-required branch failure:** Elon proceeds with available results and notes the gap in the executive packet.
5. **Milo escalation:** Any failure that blocks a standing-approved workflow or involves high-risk output triggers Milo notification.

### Cortana Logging on Failure
Cortana automatically logs every failure envelope as a `recent_failures` state entry with:
- failed_agent
- failure_type
- workflow (if applicable)
- timestamp
- resolution (retry_succeeded | rerouted | marked_partial | escalated)

### Notification Rules
- **First transient failure:** No notification (silent retry).
- **Reroute or mark_partial:** Elon logs and proceeds. Cortana records.
- **Required branch failure in standing workflow:** Milo is notified.
- **Three or more failures in same workflow within 24h:** Milo is notified with pattern summary from Cortana.
