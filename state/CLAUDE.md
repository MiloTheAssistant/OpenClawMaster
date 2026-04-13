# state/ — Durable State Layer

> Scoped context for any AI agent editing files in this directory.

## What Lives Here

| File | Purpose | Write Access |
|------|---------|-------------|
| `Active_Projects.md` | Current projects, status, owner, notes | Cortana only |
| `Decision_Log.md` | Append-only decision record | Cortana only |
| `Artifacts_Index.md` | Generated artifact tracking | Cortana only |
| `memory/MEMORY.md` | Memory index for cross-session recall | Cortana only |
| `memory/logs/*.md` | Daily memory operation logs | Cortana only |

## Rules

- **All durable state changes route through CORTANA.** No other agent writes to files in this directory.
- **Decision_Log.md is append-only.** Never modify or delete past entries. Each entry records: date, decision, who made it, context. This is the audit trail.
- **Policy-level state changes require Milo approval** before Cortana writes them. Facts and events Cortana writes automatically; policy decisions need explicit clearance.
- **Memory files follow the MEMORY.md index pattern.** Each memory is a separate file with frontmatter (name, description, type). The index in MEMORY.md is a one-line pointer per entry, kept under 200 lines.
- **Active_Projects.md uses markdown table format.** Parsed by the dashboard via `parseMarkdownTable()` in `ClawCode/dashboard/src/lib/state.ts`.
- **Never delete state files.** Mark outdated information with `[OUTDATED as of YYYY-MM-DD]` and add corrections below.
