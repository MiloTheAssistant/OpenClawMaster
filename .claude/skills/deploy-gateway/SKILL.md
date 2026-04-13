---
name: deploy-gateway
description: Restart or reload the OpenClaw Gateway — handles launchctl lifecycle, verifies health, checks for MCP server failures
---

# Deploy / Restart Gateway

## When to Use
After modifying `openclaw.json`, `config/models.yaml`, agent prompts, or MCP server configuration. The gateway does not hot-reload most config changes — a restart is required.

## Quick Restart

Run the helper script:
```bash
tools/scripts/gateway-restart.sh
```

## Manual Steps (if script fails)

1. **Unload the gateway:**
   ```bash
   launchctl unload -F ~/Library/LaunchAgents/ai.openclaw.gateway.plist
   ```

2. **Wait 2 seconds** for clean shutdown.

3. **Reload the gateway:**
   ```bash
   launchctl load -F ~/Library/LaunchAgents/ai.openclaw.gateway.plist
   ```

4. **Wait 4 seconds** for startup + MCP server initialization.

5. **Verify health:**
   ```bash
   openclaw gateway call health --json
   ```
   Expected: `"ok": true` with all agents listed.

6. **Check for MCP failures** in the gateway log:
   ```bash
   tail -20 ~/.openclaw/logs/gateway.err.log | grep "failed to start"
   ```
   Common failures:
   - `Connection closed` on npx-based servers (composio, context7) — cold start timeout, usually resolves on retry
   - `Connection closed` on gmail-mcp — check if credentials are expired, re-auth with `gmail-mcp auth`
   - Port conflicts — check `lsof -i :<port>`

## Plist Location
```
~/Library/LaunchAgents/ai.openclaw.gateway.plist
```

## Gateway Logs
```
~/.openclaw/logs/gateway.log      # stdout
~/.openclaw/logs/gateway.err.log  # stderr
```

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `launchctl load` fails with I/O error | Use `launchctl unload -F` first, then `load -F` |
| Gateway crashes on SIGHUP | Don't use `kill -HUP` — do full unload/load cycle |
| Agent count wrong in health | Check `~/.openclaw/openclaw.json` agent definitions |
| MCP server won't connect | Check if process is running: `pgrep -f <server-name>` |
| `KeepAlive` not restarting | `launchctl unload -F` then `load -F` to re-register |
