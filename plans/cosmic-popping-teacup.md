# Super Command Center Plan — Master Index

## Context

Re-architect the OpenClaw Command Center from scratch on a fresh Mac Mini M4 Pro (64GB) with 4TB external home drive. Three repos (OpenClawMaster, ClawCode, 2Brain), no Anthropic models in the harness, 2026 model routing, custom Kairo-built dashboard, and Karpathy-inspired Second Brain as shared memory layer.

## Phase Files

| Phase | File | Summary |
|---|---|---|
| 0 | `phase-0-backup-teardown.md` | Back up identity/memory/state, stop services, preserve Ollama models, wipe OpenClaw |
| 1 | `phase-1-fresh-install.md` | 4TB drive setup, Ollama install, OpenClaw install, directory structure |
| 2 | `phase-2-three-repos.md` | OpenClawMaster (governance), ClawCode (execution), 2Brain (knowledge) — what lives where |
| 3 | `phase-3-model-routing.md` | 2026 model assignments, local budget, Ollama Pro cloud slots, provider routing |
| 4 | `phase-4-coding-agent.md` | ClawCode coding agent strategy — MiniMax M2.7 / GPT-OSS for routine, Claude Code for critical |
| 5 | `phase-5-skills-tools.md` | Composio MCP, SQLite, GitHub, Google Workspace, Vercel, select awesome-claude-skills |
| 6 | `phase-6-2brain.md` | Second Brain integration — flat-file knowledge base, memory ops, compounding loop |
| 7 | `phase-7-dashboard.md` | Kairo-built Command Center Dashboard — Next.js + Vercel + local, pipeline view, cost tracker |
| 8 | `phase-8-wiring-verification.md` | Cross-repo wiring, config updates, Init Checklist, end-to-end verification |

## Decisions Made During Planning

- **PaperClip: DROPPED** — GOTCHA governance is stronger; dashboard gap filled by Kairo-built custom UI
- **Claw Code (the OSS project): NOT USED** — ClawCode is our own repo for scripts/tools/coding agent
- **Anthropic in harness: BANNED** — Claude Code (me) handles critical work directly, outside the harness
- **Microsoft MAI models: DEFERRED** — speech/voice/image via Azure, not core agent routing; revisit when needed
- **Dashboard: Vercel + local** — deployed to Vercel (non-custom domain initially), also runs locally at localhost:3000, loadable in Companion App Canvas
