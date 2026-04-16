# Parallel_Execution_Rules.md

## Default Parallel Cap
4 (reduced from 6 in Phase 5 — fewer agents, tighter coordination)

## Local Memory Budget
- **Hardware:** Mac Mini M4 Pro, 64GB unified memory
- **OS + services reserved:** ~8GB
- **Max concurrent local model footprint:** 45GB
- **Exclusive models:** Cornelius (`qwen3-coder-next:latest`, ~48.2GB) runs solo — no concurrent local models

When scheduling parallel work, Milo verifies the combined model footprint stays under the 45GB ceiling. If Cornelius is active, all other local agents must wait or route to cloud.

## Parallel-Safe Agents
The 7-agent roster runs mostly sequential, but these combinations are safe when dispatched concurrently:
- **CORTANA + HERMES** — state updates + outbound comms (different resources)
- **SAGAN + SENTINEL** — research + QA on a different output

CORTANA is always parallel-safe. She performs stateless reads and structured writes with no resource contention.

## Usually Sequential
These typically follow upstream work:
- **CORNELIUS after NEO** for system design work
- **HERMES after SAGAN** — distribute only when research is complete
- **SENTINEL before external publish** — QA clears before any outbound post

## Fan-Out / Fan-In Rules
- Milo dispatches sequentially by default
- Only independent subtasks may fan out — Milo decides case-by-case
- Milo owns fan-out and fan-in coordination (compiles each specialist's result before the next step)
- A barrier must exist before:
  - final delivery to John
  - external publishing
  - execution approval
  - any state change

## Timeouts
- Tolerance: moderate
- Retry once for transient failures when safe
- If model is unavailable, fall back to next model per `models.yaml`
- If a required step fails after retry, Milo either reroutes or marks the result partial
- If a non-required step fails, Milo proceeds with available results and notes the gap

## Cancellation Rules
- Milo HALT stops all downstream execution
- SENTINEL rejection blocks risky delivery or publishing
- Publishing lanes stop immediately on workflow-policy mismatch

## Failure Escalation
- First transient failure: silent retry
- Reroute or mark_partial: Milo logs via Cortana
- Required step failure in standing workflow: Milo decides
- Three or more failures in same workflow within 24h: Cortana surfaces a pattern summary to Milo
