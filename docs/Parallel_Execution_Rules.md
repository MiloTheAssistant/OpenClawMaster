# Parallel_Execution_Rules.md

## Default Parallel Cap
6

## Local Memory Budget
- **Hardware:** Mac Mini M4 Pro, 64GB unified memory
- **OS + services reserved:** ~8GB
- **Max concurrent local model footprint:** 45GB
- **Exclusive models:** Cornelius (`qwen3-coder-next:latest`, 51GB) runs solo — no concurrent local models

When scheduling parallel local agents, Elon must verify the combined model footprint stays under the 45GB ceiling. If Cornelius is active, all other local agents must wait or route to cloud.

## Parallel-Safe Agents
These commonly run in parallel when fed the same upstream brief:
- PULSE, HEMINGWAY, JONNY — creative pipeline
- NEO, CORTANA — engineering + state
- CORTANA, PULSE, SAGAN — research pipeline
- HEMINGWAY, JONNY, ZUCK — distribution packaging

CORTANA is always parallel-safe. She performs stateless reads and structured writes with no resource contention.

## Usually Sequential
These typically follow upstream work:
- SAGAN after PULSE or raw source gathering
- CORNELIUS after NEO for system design work
- ZUCK after ELON clearance
- SENTINEL after ELON fan-in or anomaly trigger

## Fan-Out / Fan-In Rules
- Only independent subtasks may fan out.
- ELON owns fan-out and fan-in coordination.
- A barrier must exist before:
  - final synthesis
  - external publishing
  - execution approval

## Timeouts
- Tolerance: moderate
- Retry once for transient failures when safe.
- If model is unavailable, fall back to next model per models.yaml.
- If a required branch fails after retry, ELON either reroutes or marks the packet partial.
- If a non-required branch fails, ELON proceeds with available results and notes the gap.

## Cancellation Rules
- MILO halt stops all downstream execution.
- SENTINEL rejection blocks risky delivery or publishing.
- Publishing lanes stop immediately on workflow-policy mismatch.

## Failure Escalation
- First transient failure: silent retry.
- Reroute or mark_partial: Elon logs, Cortana records.
- Required branch failure in standing workflow: Milo notified.
- Three or more failures in same workflow within 24h: Milo notified with pattern summary.
