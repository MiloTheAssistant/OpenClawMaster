#!/usr/bin/env python3
"""
fetch_dfb_market_data.py
Fetches live market data for the Daily Financial Briefing.
Called by Cortana at the start of each DFB run.
Outputs a single JSON block to stdout — pipe into briefings context.

Sources (all free, no API key required):
  - Yahoo Finance: Strategy instruments (MSTR, STRC, STRD, STRK, STRF)
  - CoinGecko: BTC price, dominance, market cap, 24h change
  - Alternative.me: Fear & Greed Index
  - CoinGecko: Global crypto market data
"""

import json
import sys
import urllib.request
import urllib.error
from datetime import datetime, timezone
from typing import Optional

TIMEOUT = 10
HEADERS = {"User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"}


def fetch(url: str, label: str) -> Optional[dict]:
    try:
        req = urllib.request.Request(url, headers=HEADERS)
        with urllib.request.urlopen(req, timeout=TIMEOUT) as r:
            return json.loads(r.read())
    except Exception as e:
        log(f"WARNING: {label} fetch failed: {e}")
        return None


def log(msg: str):
    print(f"[fetch_dfb] {msg}", file=sys.stderr)


def fetch_yahoo(ticker: str) -> dict:
    """Fetch price + 24h change from Yahoo Finance."""
    url = f"https://query1.finance.yahoo.com/v8/finance/chart/{ticker}?interval=1d&range=1d"
    data = fetch(url, ticker)
    if not data:
        return {"ticker": ticker, "price": None, "change24h": None, "error": "fetch_failed"}
    try:
        meta = data["chart"]["result"][0]["meta"]
        price = meta.get("regularMarketPrice")
        prev  = meta.get("chartPreviousClose") or meta.get("previousClose")
        change = round(((price - prev) / prev) * 100, 2) if price and prev else None
        return {
            "ticker": ticker,
            "price": round(price, 2) if price else None,
            "change24h": change,
            "currency": meta.get("currency", "USD"),
            "marketState": meta.get("marketState", "unknown"),
        }
    except Exception as e:
        return {"ticker": ticker, "price": None, "change24h": None, "error": str(e)}


def fetch_btc() -> dict:
    """Fetch BTC from CoinGecko."""
    url = (
        "https://api.coingecko.com/api/v3/simple/price"
        "?ids=bitcoin&vs_currencies=usd"
        "&include_24hr_change=true&include_market_cap=true&include_24hr_vol=true"
    )
    data = fetch(url, "CoinGecko BTC")
    if not data:
        return {}
    btc = data.get("bitcoin", {})
    return {
        "price": btc.get("usd"),
        "change24h": round(btc.get("usd_24h_change", 0), 2),
        "marketCap": btc.get("usd_market_cap"),
        "volume24h": btc.get("usd_24h_vol"),
    }


def fetch_global_crypto() -> dict:
    """Fetch global market data from CoinGecko (dominance, total market cap)."""
    data = fetch("https://api.coingecko.com/api/v3/global", "CoinGecko Global")
    if not data:
        return {}
    d = data.get("data", {})
    return {
        "btcDominance": round(d.get("market_cap_percentage", {}).get("btc", 0), 1),
        "totalMarketCapUsd": d.get("total_market_cap", {}).get("usd"),
        "totalVolume24h": d.get("total_volume", {}).get("usd"),
        "marketCapChangePercent24h": round(d.get("market_cap_change_percentage_24h_usd", 0), 2),
    }


def fetch_fear_greed() -> dict:
    """Fetch Fear & Greed Index from Alternative.me."""
    data = fetch("https://api.alternative.me/fng/?limit=2", "Fear & Greed")
    if not data:
        return {}
    entries = data.get("data", [])
    today = entries[0] if entries else {}
    yesterday = entries[1] if len(entries) > 1 else {}
    return {
        "value": int(today.get("value", 0)),
        "label": today.get("value_classification", ""),
        "yesterday": int(yesterday.get("value", 0)) if yesterday else None,
        "trend": "rising" if int(today.get("value", 0)) > int(yesterday.get("value", 0)) else "falling"
                 if yesterday else "unknown",
    }


def fetch_mstr_btc_holdings() -> dict:
    """Estimate MSTR BTC holdings from public data via Yahoo Finance extended."""
    # MSTR doesn't publish real-time holdings — use last known public figure
    # Strategy updates this on their website; hardcode last known + flag for Pulse to verify
    return {
        "btcHoldings": 528185,
        "btcHoldingsNote": "Last public figure — Pulse should verify at strategy.com for any new purchases",
        "source": "strategy.com (last reported)",
    }


def compute_nav_premium(mstr_price: float, btc_price: float, btc_per_share: float = 0.00117) -> Optional[float]:
    """
    Estimate MSTR NAV premium.
    btc_per_share = BTC holdings / diluted shares outstanding (~451M shares)
    528,185 BTC / 451,000,000 shares ≈ 0.00117 BTC/share
    """
    if not mstr_price or not btc_price:
        return None
    nav_per_share = btc_per_share * btc_price
    premium = (mstr_price - nav_per_share) / nav_per_share
    return round(premium, 3)


def fetch_etf_flows() -> list:
    """
    ETF flow data — no free real-time API exists.
    Return placeholder structure for Pulse to fill via web search.
    Pulse should check: BitcoinTreasuries, Farside Investors, Bloomberg terminal data.
    """
    return [
        {"ticker": "IBIT", "issuer": "BlackRock",   "flowM": None, "note": "Pulse: check farside.co.uk or Bloomberg"},
        {"ticker": "FBTC", "issuer": "Fidelity",    "flowM": None, "note": "Pulse: check farside.co.uk"},
        {"ticker": "ARKB", "issuer": "ARK 21Shares", "flowM": None, "note": "Pulse: check farside.co.uk"},
        {"ticker": "BITB", "issuer": "Bitwise",     "flowM": None, "note": "Pulse: check farside.co.uk"},
    ]


def main():
    log("Starting DFB market data fetch...")
    fetched_at = datetime.now(timezone.utc).isoformat()

    # Fetch all sources
    log("Fetching Strategy instruments...")
    strategy_tickers = {}
    for ticker in ["MSTR", "STRC", "STRD", "STRK", "STRF"]:
        strategy_tickers[ticker.lower()] = fetch_yahoo(ticker)

    log("Fetching BTC price...")
    btc = fetch_btc()

    log("Fetching global crypto market...")
    global_crypto = fetch_global_crypto()

    log("Fetching Fear & Greed...")
    fg = fetch_fear_greed()

    log("Loading ETF flow placeholders...")
    etf_flows = fetch_etf_flows()

    mstr_price = strategy_tickers.get("mstr", {}).get("price")
    btc_price = btc.get("price")
    nav_premium = compute_nav_premium(mstr_price, btc_price) if mstr_price and btc_price else None

    # Compose yield context for preferred instruments
    # Benchmark: 5-year treasury ~4.2% (Pulse to verify current rate)
    benchmark_yield = 4.2  # Pulse should override with fresh 5Y rate

    result = {
        "fetchedAt": fetched_at,
        "dataFreshness": "live",
        "note": "Live data. Fields marked None require Pulse web search (ETF flows, on-chain, macro).",
        "bitcoin": {
            "price": btc_price,
            "change24h": btc.get("change24h"),
            "marketCapUsd": btc.get("marketCap"),
            "volume24hUsd": btc.get("volume24h"),
            "dominance": global_crypto.get("btcDominance"),
            "totalCryptoMarketCapUsd": global_crypto.get("totalMarketCapUsd"),
            "marketCapChange24h": global_crypto.get("marketCapChangePercent24h"),
            "fearGreed": fg,
        },
        "strategy": {
            "mstr": {
                **strategy_tickers.get("mstr", {}),
                "navPremiumEstimate": nav_premium,
                "navPremiumNote": "Estimated from ~0.00117 BTC/share (528,185 BTC / ~451M diluted shares). Verify at strategy.com.",
            },
            "strc": strategy_tickers.get("strc", {}),
            "strd": {
                **strategy_tickers.get("strd", {}),
                "estimatedYieldPct": None,
                "benchmarkYieldPct": benchmark_yield,
                "yieldNote": "Pulse: calculate yield from dividend/price. Check strategy.com/investors.",
            },
            "strk": {
                **strategy_tickers.get("strk", {}),
                "estimatedYieldPct": None,
                "benchmarkYieldPct": benchmark_yield,
                "yieldNote": "Pulse: calculate yield from dividend/price.",
            },
            "strf": {
                **strategy_tickers.get("strf", {}),
                "estimatedYieldPct": None,
                "benchmarkYieldPct": benchmark_yield,
                "yieldNote": "Pulse: calculate yield from dividend/price.",
            },
            "btcHoldings": fetch_mstr_btc_holdings(),
        },
        "etfFlows": etf_flows,
        "etfFlowNote": "No free real-time ETF flow API. Pulse must fetch from farside.co.uk/bitcoin-etf/ or coindesk.com.",
        "onChain": {
            "note": "Pulse: fetch from glassnode.com, lookintobitcoin.com, or cryptoquant.com",
            "lthTrend": None,
            "exchangeFlow": None,
            "realizedPriceVsSpot": None,
        },
        "macro": {
            "note": "Pulse: fetch DXY, 10Y yield, and any Fed news from Bloomberg/Reuters/CNBC",
            "dxy": None,
            "tenYearYield": None,
            "fedEvent": None,
        },
    }

    # Print clean JSON to stdout
    print(json.dumps(result, indent=2))
    log(f"Done. BTC=${btc_price:,.0f} MSTR=${mstr_price} F&G={fg.get('value')} ({fg.get('label')})")


if __name__ == "__main__":
    main()
