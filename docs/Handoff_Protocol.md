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
When an agent fails, Milo (the dispatching agent) generates a failure envelope:

FAILURE_ENVELOPE:
  TASK_ID:
  PARENT_TASK_ID:
  FAILED_AGENT:
  FAILURE_TYPE: timeout | malformed_output | confidence_below_threshold | model_unavailable | context_overflow
  RETRY_COUNT:
  MAX_RETRIES: 1  # per parallelism.yaml retry_policy
  FALLBACK_ACTION: retry | reroute | mark_partial | approval_task_to_mc
  FALLBACK_MODEL:  # if model_unavailable, specify fallback from models.yaml
  ERROR_DETAIL:
  LAST_GOOD_STATE_REF:  # Cortana state key for rollback reference
  TIMESTAMP:

### Failure Resolution Rules
1. **First failure (transient):** Retry once with same model. If model_unavailable, retry with fallback_model from models.yaml.
2. **Second failure (same task):** Milo reroutes to an alternative agent or marks the step as partial.
3. **Required step failure:** If the failed step is required for the workflow (e.g., Sagan in DFB), Milo marks the entire dispatch as partial and decides next action.
4. **Non-required step failure:** Milo proceeds with available results and notes the gap in the final compile.
5. **Standing workflow failure:** Any failure that blocks a standing-approved workflow triggers an approval task in Mission Control's Approvals board.

### Cortana Logging on Failure
Cortana automatically logs every failure envelope as a `recent_failures` state entry with:
- failed_agent
- failure_type
- workflow (if applicable)
- timestamp
- resolution (retry_succeeded | rerouted | marked_partial | escalated)

### Notification Rules
- **First transient failure:** No notification (silent retry).
- **Reroute or mark_partial:** Milo logs via Cortana and proceeds.
- **Required step failure in standing workflow:** Mission Control Approvals task is created via `mc-push`.
- **Three or more failures in same workflow within 24h:** Cortana surfaces a pattern summary to Milo.
