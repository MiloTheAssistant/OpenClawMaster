---
name: add-agent
description: Add a new agent to the OpenClaw Command Center — create identity prompt, update all config files, verify sync
---

# Add a New Agent

## When to Use
When a new specialist, gate, or utility agent needs to be added to the Command Center roster.

## Prerequisites
- Agent name, role type, and domain decided
- Primary model selected (check `config/models.yaml` providers for available options)
- Escalation and fallback models selected (follow dual-cloud resilience: Ollama Cloud + Z.ai on different layers)

## Steps

1. **Create the identity prompt** at `agents/<name>.md`:
   ```yaml
   ---
   name: <AgentName>
   model: <provider/model-id>
   color: "#hexcolor"
   description: "<Role Type> — one-line description"
   ---
   ```
   Follow existing agent prompts for structure: Identity, Operating Bias, Core Responsibilities, Key Rules, deliverable format.

2. **Update `AGENTS.md`** — add the agent to the appropriate layer table (Command / Governance / Specialist) with role type, role description, and primary model.

3. **Update `config/models.yaml`** — add the agent's model configuration:
   ```yaml
   <AgentName>:
     bias: <balanced | accuracy | speed>
     preference: <local-first | cloud-preferred | hybrid>
     primary_model: <provider/model>
     escalation_model: <different-provider/model>
     fallback_model: <third-provider/model>
   ```
   Ensure escalation and fallback use different providers.

4. **Update `config/routing.yaml`** if the agent has routing rules (e.g., triggered by specific request types or complexity signals).

5. **Update `config/parallelism.yaml`** if the agent has local model constraints or needs exclusive scheduling (like Cornelius).

6. **Restart the gateway** to pick up the new agent:
   ```bash
   tools/scripts/gateway-restart.sh
   ```

7. **Verify** the agent appears in gateway health:
   ```bash
   openclaw gateway call health --json
   ```

## Checklist
- [ ] `agents/<name>.md` created with frontmatter + identity prompt
- [ ] `AGENTS.md` Agent Roster table updated
- [ ] `config/models.yaml` entry added with dual-cloud failover
- [ ] `config/routing.yaml` updated (if applicable)
- [ ] `config/parallelism.yaml` updated (if applicable)
- [ ] Gateway restarted and agent visible in health check
