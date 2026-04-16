# Goals Manifest

> Index of all goal workflows. Check here before creating new goals.

---

## Active Goals

| Goal | File | Description |
|---|---|---|
| Daily Financial Briefing | `goals/daily_financial_briefing.md` | Full 7-section DFB chain: Cortana → Pulse + Sagan → Hemingway → Sentinel → Zuck. Runs 7AM CT weekdays. Publishes to Discord #dfb + DFB website. |

## Scripts

| Script | File | Description |
|---|---|---|
| DFB Market Data Fetcher | `scripts/fetch_dfb_market_data.py` | Fetches live BTC, MSTR/Strategy instruments, Fear & Greed, dominance via Yahoo Finance + CoinGecko + Alternative.me. Called by Cortana at DFB open. Outputs JSON to stdout. |

## Retired

| Goal | File | Notes |
|---|---|---|
| Daily Market Brief (old) | `goals/daily_market_brief.RETIRED.md` | Superseded by `daily_financial_briefing.md` — 69-line stub, pre-7-section redesign |
