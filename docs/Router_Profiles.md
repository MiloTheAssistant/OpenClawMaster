# Router_Profiles.md

## Purpose
Router Profiles are reusable formations that let Milo route tasks quickly without rebuilding logic from scratch. **Phase 5:** Milo absorbed the orchestrator role — there is no separate Elon. Milo dispatches specialists sequentially via `sessions_spawn` with `agentId`, compiling results between steps.

See `config/routing.yaml` for the machine-readable profile definitions.

---

## PROFILE: Intelligence
Use for market briefs, recurring intelligence, source-backed updates, any research that needs to ship out.

Flow:
```
Sagan (research + synthesize) → Hermes (distribute) → Cortana (log)
```

Notes:
- Sagan owns all research and synthesis — no separate scout/analyst split
- Hermes handles all outbound (Discord, Telegram, email)
- Milo compiles Sagan's output before handing to Hermes for distribution

---

## PROFILE: Engineering
Use for architecture, infra planning, automation rollouts, system changes.

Flow:
```
Neo (architecture) → Cornelius (execution plan) → Sentinel (QA gate) → Milo (approval) → Cortana (log)
```

Notes:
- Neo proposes architecture; Cornelius converts to an executable plan with rollback
- Cornelius runs solo — all other local models unload (48.2GB footprint)
- Sentinel clears before anything ships
- Milo owns final approval on execution

---

## PROFILE: Comms
Use for simple outbound messages, notifications, social posts.

Flow:
```
Hermes (draft + post) → Sentinel (conditional QA) → Cortana (log)
```

Notes:
- Milo dispatches directly to Hermes for one-off messages
- Sentinel review fires only on brand-sensitive content or new channels
- Email: Hermes drafts, John sends (always)

---

## PROFILE: Research
Use for pure research with no outbound distribution — output lands in 2Brain.

Flow:
```
Sagan (research) → Sentinel (conditional QA) → Cortana (log to 2Brain)
```

Notes:
- Sentinel triggers on confidence below threshold or source conflict
- Cortana writes findings to `2Brain/outputs/` or `2Brain/wiki/`
- No external distribution — Hermes not involved

---

## PROFILE: Governance
Use for pending items requiring quality review — security audit findings, approval items, policy checks.

Flow:
```
Sentinel (evaluate) → Cortana (log decision)
```

Notes:
- Gate profile — no distribution, no creative work
- Sentinel's evaluation feeds Mission Control's Approvals board when findings require Milo action

---

## Rules (all profiles)

- **Milo is the front door.** Nothing dispatches without him creating a brief
- **No parallel fan-out by default.** Milo orchestrates sequentially; fan-out only when the graph is genuinely independent
- **Standing-approved workflows** (DFB, Market Signal Scanner) may run without per-instance Milo approval once the standing policy is in place
- **HALT is Milo's exclusively** — any specialist may flag `halt_recommended: true`, but only Milo stops work
- **Cornelius exclusive window** — when Cornelius is active, all other local agents route to cloud
