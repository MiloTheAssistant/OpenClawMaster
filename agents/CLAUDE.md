# agents/ — Agent Identity Prompts

> Scoped context for any AI agent editing files in this directory.

## What Lives Here

Each `.md` file is an agent identity prompt with YAML frontmatter (`name`, `model`, `color`, `description`) followed by the agent's full operating instructions.

## Rules

- **Milo approval required** for any modification to agent prompts. These are fixed identity instructions, not casual docs.
- **Frontmatter `model` field must match `config/models.yaml`** — the agent's primary model assignment. When you update one, update the other.
- **Every agent must have a defined deliverable format** compatible with Milo's sequential dispatch (structured envelopes, not free-form text).
- **Task-specific prompts are separate from identity prompts.** Don't add task-specific instructions to these files — those go in workflow definitions or BRIEF_FOR_ELON blocks.
- **No side effects, no direct user messaging.** Specialist agents return structured envelopes. Only Milo delivers to John. Only agents listed in `AGENTS.md` User-Facing Access may speak to John directly.
- **Milo is male** — use he/him pronouns when referencing Milo in any documentation or code.

## Agent Hierarchy (Phase 5: 7 agents)

```
John (USER)
 └─ MILO (Executive Assistant & Orchestrator) — intake, dispatch, HALT authority
     ├─ SAGAN     — deep research, web-grounded analysis
     ├─ NEO       — lead engineer, architecture, coding
     ├─ HERMES    — communications (Discord, Telegram, email)
     ├─ SENTINEL  — QA gate, output validation
     ├─ CORTANA   — state, memory, telemetry
     └─ CORNELIUS — infra planning, heavy coding (runs solo)
```

Elon is retired. Milo dispatches directly to specialists via `sessions_spawn(agentId=...)`. There is no intermediate orchestrator.

## Adding a New Agent

Use the skill: `/add-agent` — or follow these steps manually:

1. Create `agents/<name>.md` with frontmatter and identity prompt
2. Add to the Agent Roster table in `AGENTS.md`
3. Add model assignment in `config/models.yaml`
4. Add routing rules in `config/routing.yaml` if applicable
5. Update `config/parallelism.yaml` if the agent has local model constraints
