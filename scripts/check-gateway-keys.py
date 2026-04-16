#!/usr/bin/env python3
"""
check-gateway-keys.py

Checks the OpenClaw gateway LaunchAgent plist for required API keys.
If any are missing, re-injects them from openclaw.json and sends a
Telegram notification prompting for gateway restart approval.

Also checks that dist/control-ui/ assets are present after a brew upgrade.
If missing, restores them from the previous day's npm package tarball.

Called by:
  - launchd WatchPaths agent (on openclaw package update)
  - MC recurring cron task (every 30 min)
  - Manually: python3 check-gateway-keys.py
"""

import json
import plistlib
import time
import sys
import os
import shutil
import subprocess
import tarfile
import tempfile
import urllib.request
import urllib.parse
import urllib.error
from datetime import date, timedelta
from pathlib import Path

PLIST_PATH      = Path('/Volumes/BotCentral/Users/milo/Library/LaunchAgents/ai.openclaw.gateway.plist')
CONFIG_PATH     = Path('/Volumes/BotCentral/Users/milo/.openclaw/openclaw.json')
LOG_PATH        = Path('/Volumes/BotCentral/Users/milo/.openclaw/logs/key-injector.log')
OPENCLAW_DIST   = Path('/opt/homebrew/lib/node_modules/openclaw/dist')
CONTROL_UI_DIR  = OPENCLAW_DIST / 'control-ui'
PKG_JSON_PATH   = Path('/opt/homebrew/lib/node_modules/openclaw/package.json')

# Telegram target: Milo's user ID (from openclaw.json allowFrom)
TELEGRAM_TARGET_ID  = 7758623844
DISCORD_SYSADMIN_ID = 1486019891218874369


def log(msg: str):
    ts = time.strftime('%Y-%m-%dT%H:%M:%S')
    line = f"{ts} [key-injector] {msg}"
    print(line, flush=True)
    LOG_PATH.parent.mkdir(parents=True, exist_ok=True)
    with open(LOG_PATH, 'a') as f:
        f.write(line + '\n')


def load_config():
    with open(CONFIG_PATH) as f:
        return json.load(f)


def extract_keys(cfg: dict) -> dict:
    providers = cfg.get('models', {}).get('providers', {})
    channels  = cfg.get('channels', {})
    return {
        'NVIDIA_NIM_API_KEY': providers.get('nim', {}).get('apiKey', ''),
        'ANTHROPIC_API_KEY':  providers.get('anthropic', {}).get('apiKey', ''),
        'PERPLEXITY_API_KEY': providers.get('perplexity', {}).get('apiKey', ''),
        'DISCORD_BOT_TOKEN':  channels.get('discord', {}).get('token', ''),
        'TELEGRAM_BOT_TOKEN': channels.get('telegram', {}).get('botToken', ''),
    }


def check_and_inject() -> dict:
    """
    Returns: {injected: bool, missing_before: list, bot_token: str}
    """
    if not PLIST_PATH.exists():
        log(f"WARNING: plist not found at {PLIST_PATH}")
        return {'injected': False, 'missing_before': [], 'bot_token': ''}

    cfg = load_config()
    keys = extract_keys(cfg)
    bot_token = keys.get('TELEGRAM_BOT_TOKEN', '')

    with open(PLIST_PATH, 'rb') as f:
        plist = plistlib.load(f)

    env = plist.setdefault('EnvironmentVariables', {})

    missing = [k for k, v in keys.items() if v and not env.get(k)]

    if not missing:
        log("All API keys present — no action needed.")
        return {'injected': False, 'missing_before': [], 'bot_token': bot_token}

    log(f"Missing keys detected: {missing}")
    for k, v in keys.items():
        if v:
            env[k] = v
    with open(PLIST_PATH, 'wb') as f:
        plistlib.dump(plist, f)

    log(f"Re-injected {len([v for v in keys.values() if v])} keys into plist.")
    return {'injected': True, 'missing_before': missing, 'bot_token': bot_token}


def get_installed_version() -> str:
    """Read the currently installed openclaw version from package.json."""
    try:
        with open(PKG_JSON_PATH) as f:
            return json.load(f).get('version', '')
    except Exception:
        return ''


def check_and_restore_control_ui() -> dict:
    """
    Returns: {restored: bool, version_used: str, error: str}
    Checks if dist/control-ui/ is present and functional.
    If missing, fetches from a recent prior npm tarball and restores it.
    """
    sentinel = CONTROL_UI_DIR / 'index.html'
    if sentinel.exists():
        log("control-ui assets present — no restore needed.")
        return {'restored': False, 'version_used': '', 'error': ''}

    log("WARNING: dist/control-ui/ is missing — attempting restore from npm.")

    current_version = get_installed_version()
    log(f"Installed openclaw version: {current_version or 'unknown'}")

    # Try up to 14 prior daily build versions (YYYY.M.D format)
    candidates = _candidate_versions(current_version)

    for version in candidates:
        log(f"Trying restore from openclaw@{version}...")
        result = _restore_from_tarball(version)
        if result['ok']:
            log(f"control-ui restored from openclaw@{version}")
            return {'restored': True, 'version_used': version, 'error': ''}
        log(f"  {version} failed: {result['error']}")

    msg = "Exhausted all candidate versions — manual restore required."
    log(f"ERROR: {msg}")
    return {'restored': False, 'version_used': '', 'error': msg}


def _candidate_versions(current: str) -> list:
    """
    Generate candidate previous versions to try.
    OpenClaw uses YYYY.M.D versioning (e.g. 2026.3.22).
    Walk back up to 14 days from today (or from current version date).
    """
    candidates = []

    # Try to parse current version date
    ref_date = None
    if current:
        parts = current.split('.')
        if len(parts) == 3:
            try:
                ref_date = date(int(parts[0]), int(parts[1]), int(parts[2]))
            except ValueError:
                pass

    if ref_date is None:
        ref_date = date.today()

    for i in range(1, 15):
        d = ref_date - timedelta(days=i)
        candidates.append(f"{d.year}.{d.month}.{d.day}")

    return candidates


def _restore_from_tarball(version: str) -> dict:
    """
    Fetch openclaw@<version> tarball from npm registry and extract dist/control-ui/.
    Returns: {ok: bool, error: str}
    """
    tarball_url = f"https://registry.npmjs.org/openclaw/-/openclaw-{version}.tgz"

    try:
        with tempfile.TemporaryDirectory() as tmpdir:
            tgz_path = os.path.join(tmpdir, f"openclaw-{version}.tgz")

            # Download tarball
            req = urllib.request.Request(tarball_url, headers={'User-Agent': 'openclaw-key-injector/1.0'})
            with urllib.request.urlopen(req, timeout=30) as resp:
                if resp.status != 200:
                    return {'ok': False, 'error': f"HTTP {resp.status}"}
                with open(tgz_path, 'wb') as f:
                    shutil.copyfileobj(resp, f)

            # Extract dist/control-ui from tarball (npm tarballs have package/ prefix)
            extract_dir = os.path.join(tmpdir, 'extracted')
            os.makedirs(extract_dir)
            with tarfile.open(tgz_path, 'r:gz') as tar:
                members = [m for m in tar.getmembers()
                           if m.name.startswith('package/dist/control-ui/')]
                if not members:
                    return {'ok': False, 'error': 'dist/control-ui/ not found in tarball'}
                tar.extractall(extract_dir, members=members)

            src = Path(extract_dir) / 'package' / 'dist' / 'control-ui'
            if not (src / 'index.html').exists():
                return {'ok': False, 'error': 'index.html not found after extraction'}

            # Copy into place (remove stale dir first if partial)
            if CONTROL_UI_DIR.exists():
                shutil.rmtree(CONTROL_UI_DIR)
            shutil.copytree(src, CONTROL_UI_DIR)
            return {'ok': True, 'error': ''}

    except urllib.error.HTTPError as e:
        return {'ok': False, 'error': f"HTTP {e.code}"}
    except Exception as e:
        return {'ok': False, 'error': str(e)}


def send_telegram(bot_token: str, chat_id: int, text: str):
    url = f"https://api.telegram.org/bot{bot_token}/sendMessage"
    payload = json.dumps({'chat_id': chat_id, 'text': text, 'parse_mode': 'Markdown'}).encode()
    req = urllib.request.Request(url, data=payload,
                                  headers={'Content-Type': 'application/json'})
    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            log(f"Telegram notification sent (status {resp.status})")
    except urllib.error.URLError as e:
        log(f"WARNING: Telegram notification failed: {e}")


def send_discord(channel_id: int, text: str):
    """Post to a Discord channel via the openclaw CLI (errors only)."""
    try:
        result = subprocess.run(
            ['openclaw', 'message', 'send',
             '--channel', 'discord',
             '--target', str(channel_id),
             '--message', text],
            capture_output=True, text=True, timeout=15
        )
        if result.returncode == 0:
            log(f"Discord notification sent to {channel_id}")
        else:
            log(f"WARNING: Discord notification failed: {result.stderr.strip()}")
    except Exception as e:
        log(f"WARNING: Discord notification error: {e}")


def main():
    log("Starting health check...")

    key_result = check_and_inject()
    ui_result  = check_and_restore_control_ui()

    cfg = load_config()
    bot_token = extract_keys(cfg).get('TELEGRAM_BOT_TOKEN', '')

    # Build notification if anything changed
    sections = []

    if key_result['injected']:
        sections.append(
            "🔑 *Keys Re-injected*\n"
            f"Restored: `{'`, `'.join(key_result['missing_before'])}`\n"
            "Reply *`restart gateway`* to apply."
        )

    if ui_result['restored']:
        sections.append(
            f"🖥 *Control UI Restored*\n"
            f"Assets recovered from openclaw@{ui_result['version_used']}.\n"
            "Reply *`restart gateway`* if the UI is still unreachable."
        )
    elif ui_result['error']:
        sections.append(
            f"⚠️ *Control UI Restore Failed*\n"
            f"{ui_result['error']}\n"
            "Manual restore needed: extract dist/control-ui from a prior npm tarball."
        )

    if sections:
        telegram_msg = "⚠️ *OpenClaw Gateway — Health Check*\n\n" + "\n\n".join(sections)
        discord_msg  = "⚠️ OpenClaw Gateway — Health Check\n\n" + "\n\n".join(
            s.replace('*', '**').replace('`', '`') for s in sections
        )

        if bot_token:
            send_telegram(bot_token, TELEGRAM_TARGET_ID, telegram_msg)
        else:
            log("Changes detected but no bot token — skipping Telegram.")

        send_discord(DISCORD_SYSADMIN_ID, discord_msg)

    # Exit codes: 0 = all good, 2 = something changed (keys or UI)
    changed = key_result['injected'] or ui_result['restored'] or bool(ui_result['error'])
    sys.exit(0 if not changed else 2)


if __name__ == '__main__':
    main()
