---
name: dispatch-elon
description: Create a BRIEF_FOR_ELON and dispatch a task to the orchestrator — used when complexity score >= 2 or any tool call is needed
---

# Dispatch Task to ELON

## When to Use
When Milo scores a request at complexity >= 2, or the task requires any tool call. Milo does not execute multi-step or cross-domain tasks inline — he dispatches to ELON.

## Complexity Scoring

| Signal | Points |
|--------|--------|
| Requires external service or API | +2 |
| Requires validation across multiple targets | +2 |
| Requires research or synthesis from multiple sources | +3 |
| Involves a system or infrastructure change | +3 |
| Touches 2+ agent scopes | +2 |
| Output requires copy, visuals, or publishing | +1 |
| Simple factual answer from memory or single-step reasoning | 0 |
| Single tool call with no synthesis | 0 |

**Score < 2 → Milo answers directly.**
**Score >= 2 → Dispatch ELON. No exceptions.**

## Brief Format

```
BRIEF_FOR_ELON:
REQUEST: <what John asked for, in his words>
GOAL: <the outcome, not the process>
CONTEXT: <relevant background — active projects, prior decisions, constraints>
CONSTRAINTS: <budget, timeline, risk tolerance, provider restrictions>
ASSUMPTIONS: <what you're assuming is true — flag anything uncertain>
COMPLEXITY_SCORE: <number>
COMPLEXITY_LEVEL: <low | medium | high | critical>
TIER_CAP: <max agent tier to involve — 1=command, 2=governance, 3=specialist>
PARALLEL_CAP: <max concurrent lanes — default 6>
RISK_MODE: <balanced | accuracy | speed>
SUGGESTED_AGENTS: <comma-separated list of agents likely needed>
```

## Steps

1. **Score the request** using the table above. Sum the applicable signals.

2. **Set routing controls:**
   - TIER_CAP: how deep into the agent hierarchy this task should go
   - PARALLEL_CAP: how many concurrent specialist lanes (default 6, max 6)
   - RISK_MODE: balanced (default), accuracy (for high-stakes), speed (for time-sensitive)

3. **Write the BRIEF_FOR_ELON** using the format above. Be specific in REQUEST and GOAL — ELON works from this brief, not from the original user message.

4. **Hand off** using the `orchestration` tool. Do not attempt to execute the task yourself.

5. **Wait** for EXECUTIVE_PACKET from ELON.

6. **Deliver** the final result to John — clean, no scaffolding, no agent jargon.
