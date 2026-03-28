# Daily Financial Briefing — Task Prompt
**Workflow:** `recurring_publish`
**Schedule:** 8:45 AM America/Chicago, weekdays
**Destination:** Discord "Milo's World" → `#dfb` + DFB website JSON
**Cron Job ID:** `37a87d4f-05f5-4aad-9051-ed566a011b54`

---

## ORCHESTRATION CHAIN

```
Cortana (context gate)
  → [Pulse + Sagan] in parallel
      Sagan runs 4 tasks sequentially:
        Task 1 — BTC Creator Intel
        Task 2 — AI Industry Intelligence
        Task 3 — Retirement & Income Intelligence
        Task 4 — Health After 60 Intelligence
  → Quant (numerical analysis → FINANCIAL_ANALYSIS block)
  → Hemingway (format → Discord + JSON)
  → Sentinel (QA gate)
  → Zuck (post Discord #dfb + write JSON + trigger deploy)
  → Cortana (close + log)
```

**Do not compile results yourself. Do not speak to the user. Dispatch, collect, forward.**

---

## AGENT TASK ASSIGNMENTS

---

### CORTANA — OPEN
**Task:** Gate check + live market data fetch before dispatch.

**Step 1 — Fetch live market data (run first, always):**

Execute the market data fetcher and capture its JSON output:
```bash
python3 /Volumes/BotCentral/Users/milo/.openclaw/scripts/fetch_dfb_market_data.py
```

This returns a JSON block with live prices for BTC, MSTR, STRC, STRD, STRK, STRF, Fear & Greed Index, BTC dominance, and ETF flow placeholders. Parse it and hold as `MARKET_DATA` context.

**Inject `MARKET_DATA` into Pulse's task context** so Pulse begins with verified live prices rather than searching for them. Pulse should supplement with on-chain, ETF flows, and macro — not re-fetch prices the script already has.

The `MARKET_DATA` block will contain fields marked `null` (ETF flows, on-chain, macro DXY/10Y). Pulse must fill those via web search.

**Step 2 — Gate check:**
- Check for standing holds or overrides on DFB distribution
- Check prior briefing output (avoid duplicate lead stories)
- Check active Sentinel halt conditions

If no holds: confirm green and dispatch Pulse (with MARKET_DATA) + Sagan in parallel.
If hold found: abort and notify MILO.

---

### PULSE
**Task:** Market intelligence — supplement pre-fetched prices with on-chain, ETF flows, macro, institutional news.

**⚡ You receive MARKET_DATA from Cortana.** It contains verified live prices:
- BTC spot price, 24h change, dominance, market cap, Fear & Greed
- MSTR, STRC, STRD, STRK, STRF prices and 24h change
- MSTR NAV premium estimate (use this, do not recalculate)

**Use these numbers as-is. Do not re-fetch prices you already have.**
Fields marked `null` in MARKET_DATA are yours to fill via web search.

**Headline Market News (fetch first)**
Pull the top 4–5 market-moving stories from this morning across Bloomberg, Reuters, CNBC, and WSJ. Cover broad markets — equities, macro, crypto, earnings, geopolitical — not just crypto. This is the "what's moving the world this morning" section.

For each headline:
```
Headline: [title — tight, newswire style]
Source: [Bloomberg / Reuters / CNBC / WSJ]
Why it matters: [1 sentence — what does this move or signal]
```

Return as `marketHeadlines` array. Hemingway puts this at the top of the briefing, above Bitcoin.

---

**BTC Market Structure (supplement only)**
- 7-day trend direction (the script gives 24h — you add the weekly context)
- Funding rates across major perpetual exchanges (signal: bullish / neutral / bearish)
- ETF net flows: IBIT, FBTC, ARKB, and any notable movers — ranked by daily flow (fetch from farside.co.uk/bitcoin-etf/ or CoinDesk)

**On-Chain Metrics**
- Long-term holder (LTH) supply trend (accumulating / distributing)
- Exchange outflow/inflow net (coins leaving exchanges = bullish signal)
- Realized price vs. spot (above/below — indicates profit/loss on average coin)
- Any notable on-chain anomaly today

**Strategy (MSTR) Instruments — prices from MARKET_DATA, add context:**
- `$MSTR` — confirm NAV premium from MARKET_DATA; add any Strategy news/filings
- `$STRC` — any news or trading anomalies
- `$STRD`, `$STRK`, `$STRF` — calculate annualized yield from dividend/price (check strategy.com/investors)

**Institutional & Regulatory (no ETF flow table — that's in Bitcoin)**
- BlackRock: any news beyond IBIT flows (crypto policy, products, statements)
- Fidelity: any news beyond FBTC flows
- TradFi headlines: JPMorgan, Goldman, Citadel, or any major institution making crypto/macro headlines
- Sovereign / nation-state BTC news
- Legislative/Regulatory Radar: SEC, Congress, or foreign regulatory item today (or "None today")

**Macro Snapshot**
- BTC correlation to equities today (risk-on / risk-off)
- DXY direction, 10-year yield direction
- Any macro event today touching crypto (Fed speaker, CPI, etc.)

Return all as structured raw data. Hemingway formats. Do not editorialize.

---

### SAGAN
**Task:** Deep research across four content areas. Run all four sequentially.

---

#### SAGAN TASK 1 — BTC Creator Intel

Search YouTube and major crypto media for the **5 most-watched or most-discussed Bitcoin videos published in the last 48 hours** from top-tier creators.

Target creators (prioritize): Michael Saylor, Anthony Pompliano, Lyn Alden, Preston Pysh, Greg Foss, Dan Held, Dylan LeClair, Willy Woo, PlanB, Matthew Kratter, Peter McCormack, Natalie Brunell, Bitcoin Archive, Bitcoin Magazine.

For each video:
```
Title: [full title]
Creator: [channel name]
URL: [direct YouTube link]
Published: [date/time]
Summary: [3–5 sentences on key claims, price targets, thesis]
Why it matters: [1 sentence on relevance to today's market]
```

After all videos: provide a **Narrative Sentiment Reading** — overall tone across the 5 videos:
Bullish / Cautiously Bullish / Neutral / Cautious / Bearish
One sentence on what's driving the dominant narrative today.

---

#### SAGAN TASK 2 — AI Industry Intelligence (daily fast-scan)

**This Week's Moves** — 3–5 headlines from the last 7 days that shift the competitive picture:
```
Headline: [news item]
Company: [affected player]
Why it matters: [1–2 sentences on competitive impact]
```

**Structural Snapshot** — brief current-state bullets (update only if materially changed):
- Software: OpenAI, Anthropic, Google DeepMind, Meta AI, xAI, Mistral, Perplexity
- Hardware: NVIDIA, AMD, Broadcom, TSMC, Cerebras/Groq, AWS Trainium/Google TPU/Maia

**Durable Moat Deep Dive** (rotate daily: OpenAI → Anthropic → NVIDIA → Google → Meta → Broadcom → TSMC):
- Today's player: [rotating]
- 2–3 sentences on why this player is or isn't defensible long-term

*Full 5–10 year outlook runs Fridays only, not daily.*

---

#### SAGAN TASK 3 — Retirement & Income Intelligence

**Rate Watch** (pull fresh):
```
Fed Funds (effective):  X.XX%   Next FOMC: [date]   Market path: [hawkish/neutral/dovish]
T-Bills (3mo):          X.XX%
T-Notes (2Y):           X.XX%
T-Notes (10Y):          X.XX%
I-Bonds (current):      X.XX%
HY Savings (top):       X.XX%
CDs (1Y top):           X.XX%
TIPS (10Y real):        X.XX%
```

**Income ETF Watchlist** (yield + notable flow changes):
$SCHD, $VYM, $JEPI, $JEPQ, $XYLD, $QYLD, $RYLD

**What 60+ Investors Are Doing Right Now**
Synthesize from recent articles, Bogleheads, r/retirement, advisor commentary:
- Rebalancing moves in progress
- Equity exposure changes
- Sequence-of-returns risk debate
- Any opportunity or concern unique to this market moment

**Key Planning Points**
- Social Security: any current optimization or timing discussion
- RMDs / SECURE Act 2.0: any relevant near-retiree item
- Tax/legislative: any change affecting retirement accounts

**Reader Action Item**
One concrete, specific thing a near-retiree should consider acting on this week.
Tied to actual data in this briefing — not generic advice.

---

#### SAGAN TASK 4 — Health After 60

Research current evidence and news on longevity, cardiovascular health, and healthy aging for adults 60+.

**Heart Health Signal**
One evidence-based item this week: new study, guideline update, or notable clinical finding for cardiovascular health in adults 60+. Include source/journal.

**Longevity Supplement Stack** (2–3 per day, rotating through the pool)
For each:
- Name, typical dosing range, what the evidence actually shows
- Evidence tier: 🟢 Strong (multiple RCTs) | 🟡 Emerging (early trials/observational) | 🔴 Unproven (anecdotal/theoretical)
- Any notable new research this week

Supplement pool (rotate): NMN/NR, Berberine, Magnesium Glycinate, Omega-3/EPA/DHA, Creatine, Taurine, Vitamin D3+K2, CoQ10, Spermidine, Rapamycin (clinical discussion only), Metformin (off-label longevity discussion).

**Red Light Therapy / Photobiomodulation**
- Latest research note or protocol update
- Practical protocol: wavelength, duration, frequency, distance — what current evidence supports
- Any notable device news or study this week

**Sauna & Heat Therapy**
- Current evidence summary on cardiovascular benefit (cite Rhonda Patrick / Huberman / peer-reviewed)
- Optimal protocol: temperature, duration, frequency, timing
- Any new finding this week

**Study of the Week**
One peer-reviewed finding from the last 7–14 days relevant to healthy aging 60+:
```
Study: [title / journal]
Finding: [2 sentences]
Relevance: [why a 60+ reader should care — 1 sentence]
```

**Practitioner Take**
One paragraph: what a longevity-focused physician would say about this week's combined health data.
Grounded, not hype. Flag anything that contradicts mainstream guidelines.

---

### QUANT
**Task:** Receive `MARKET_DATA` from Cortana and structured intel from Pulse. Produce a `FINANCIAL_ANALYSIS` block for Hemingway to write against. Do not format for Discord. Numbers only.

**Inputs:**
- `MARKET_DATA` block from Cortana (prices, fear/greed, BTC dominance)
- Pulse output (ETF flows, on-chain, macro signals)

**Compute:**
- Day-over-day and 7-day % changes for BTC, MSTR instruments
- BTC dominance delta (pp change)
- ETF net flow totals and direction trend
- MSTR instrument spreads and NAV premium estimates (where data available)
- Macro correlation note (DXY/10Y vs BTC movement)
- Anomaly flags: any metric >2σ from recent average, or notable divergences

**Rules:**
- Mark unavailable fields as `null` with a brief reason
- Do not editorialize — "BTC fell 4.2%" not "BTC had a rough day"
- Pass the completed `FINANCIAL_ANALYSIS` block to Hemingway

---

### HEMINGWAY
**Task:** Compile all Pulse + Sagan + Quant outputs into a Daily Financial Briefing.

Produce **TWO outputs**:
1. Discord-formatted briefing (for Zuck to post)
2. Structured JSON block labeled `dfb-json` (for Zuck to write to disk)

**Audience:** One person. Morning coffee read. Financially sophisticated. No hand-holding. No hype. Occasionally dry.

---

#### DISCORD BRIEFING STRUCTURE

```
🌅 DAILY FINANCIAL BRIEFING — [WEEKDAY, MONTH DD, YYYY]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Delivered by Mission Control | 8:45 AM CST
```

**SECTION 0: 📰 MARKET HEADLINES**
- **[Headline]** — *[Source]* — [why it matters]
- **[Headline]** — *[Source]* — [why it matters]
- **[Headline]** — *[Source]* — [why it matters]
- **[Headline]** — *[Source]* — [why it matters]
*(4–5 headlines, broad markets — equities, macro, crypto, earnings, geopolitical)*

---

**SECTION 1: ₿ BITCOIN & CRYPTO MARKETS**
```
BTC     $XX,XXX  |  +/-X.X%  24h
Dom     XX.X%    |  Mkt Cap  $X.XT
F&G     XX — [Label]
```
- ETF Flows: [IBIT +/-$XM | FBTC +/-$XM | ARKB +/-$XM | Net: +/-$XM] — ranked
- Funding: [signal + brief note]
- On-Chain: LTH [accumulating/distributing] | Exchange [net out/in] | Realized price [above/below spot]
- [2–3 bullets: most important BTC news today]

---

**SECTION 2: 🏦 STRATEGY (MSTR) INSTRUMENTS**
```
$MSTR   $XXX.XX  |  +/-X.X%  |  NAV premium: +/-XX%
$STRC   $XXX.XX  |  +/-X.X%
$STRD   $XX.XX   |  +/-X.X%  |  Yield: X.X% (vs X.X% comp)
$STRK   $XX.XX   |  +/-X.X%  |  Yield: X.X% (vs X.X% comp)
$STRF   $XX.XX   |  +/-X.X%  |  Yield: X.X% (vs X.X% comp)
```
- BTC holdings: [current if available]
- [Any Saylor commentary, capital raise, or SEC filing news]

---

**SECTION 3: 🏛️ INSTITUTIONAL & REGULATORY**
- **BlackRock:** [news beyond IBIT flows — policy, products, statements]
- **Fidelity:** [news beyond FBTC flows]
- **TradFi:** [JPMorgan / Goldman / Citadel / other institution headline, or "None today"]
- **Regulatory Radar:** [SEC / Congress / foreign item, or "None today"]
- **Sovereign:** [nation-state BTC news, or "None today"]

---

**SECTION 4: 🎬 BTC CREATOR INTEL**
**Narrative: [Bullish/Cautiously Bullish/Neutral/Cautious/Bearish]** — [one sentence on dominant theme]

> 🎥 **[Title]** — [Creator]
> [3–4 sentence summary]
> [Why it matters]
> 🔗 [URL]

*(repeat for up to 5 videos)*

---

**SECTION 5: 🤖 THE AI RACE**
**This Week's Moves**
- [Headline] — [Company] — [why it matters]
- [Headline] — [Company] — [why it matters]

**Today's Deep Dive: [Company]**
[2–3 sentences on moat/position/risk]

**Snapshot**
- OpenAI: [1 line] | Anthropic: [1 line] | Google: [1 line]
- Meta: [1 line] | xAI: [1 line] | NVIDIA: [1 line]

---

**SECTION 6: 💰 RETIREMENT & INCOME**
```
Fed Funds: X.XX%  |  Next FOMC: [date]  |  Path: [hawkish/neutral/dovish]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
T-Bills (3mo) X.XX%  |  T-Notes (2Y) X.XX%  |  T-Notes (10Y) X.XX%
I-Bonds X.XX%        |  HY Savings  X.XX%   |  CDs (1Y)      X.XX%
TIPS (10Y real) X.XX%
```
Income ETFs: $SCHD X.X% | $VYM X.X% | $JEPI X.X% | $JEPQ X.X% | $XYLD X.X% | $QYLD X.X%

**What 60+ Investors Are Doing**
- [2–3 bullets on current behavior/strategy shifts]

**Key Planning Points**
- [Social Security / RMD / tax item]

🎯 **Action Item:** [specific, concrete, tied to today's data]

---

**SECTION 7: 🫀 HEALTH AFTER 60**
**❤️ Heart Health:** [one evidence-based finding — source noted]

**💊 Supplement Spotlight**
- **[Name]** [dose] — [evidence summary] — [🟢/🟡/🔴]
- **[Name]** [dose] — [evidence summary] — [🟢/🟡/🔴]
- **[Name]** [dose] — [evidence summary] — [🟢/🟡/🔴]

**🔴 Red Light/PBM:** [protocol note or research update]

**🧖 Sauna:** [protocol + finding if any]

**📄 Study of the Week**
> [Study / journal]
> [Finding — 2 sentences]
> [Relevance to 60+]

**🩺 Practitioner Take:** [one paragraph — grounded, not hype]

---

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🤖 Mission Control | Pulse • Sagan • Hemingway • Sentinel
[ISO timestamp] | Confidence: [High/Medium/Low] | Sources: [count]
```

---

#### JSON OUTPUT (dfb-json block)

After the Discord briefing, output the following JSON block exactly. Zuck extracts it by label.

```dfb-json
{
  "date": "YYYY-MM-DD",
  "weekday": "Monday",
  "generatedAt": "ISO-8601",
  "confidence": "high",
  "sourcesCount": 0,
  "sections": {
    "marketHeadlines": [
      { "headline": "", "source": "Bloomberg", "whyItMatters": "" }
    ],
    "bitcoin": {
      "price": 0,
      "change24h": 0,
      "dominance": 0,
      "marketCap": "",
      "fearGreed": { "value": 0, "label": "" },
      "etfFlows": [{ "ticker": "IBIT", "issuer": "BlackRock", "flowM": 0 }],
      "fundingSignal": "neutral",
      "onChain": {
        "lthTrend": "accumulating",
        "exchangeFlow": "outflow",
        "realizedPriceVsSpot": "below"
      },
      "headlines": []
    },
    "strategy": {
      "mstr": { "price": 0, "change24h": 0, "navPremium": 0 },
      "strc": { "price": 0, "change24h": 0 },
      "strd": { "price": 0, "change24h": 0, "yield": 0, "compBondYield": 0 },
      "strk": { "price": 0, "change24h": 0, "yield": 0, "compBondYield": 0 },
      "strf": { "price": 0, "change24h": 0, "yield": 0, "compBondYield": 0 },
      "btcHoldings": "",
      "news": []
    },
    "institutional": {
      "blackrock": "",
      "fidelity": "",
      "tradfi": "",
      "regulatoryRadar": "",
      "sovereign": ""
    },
    "creatorIntel": {
      "sentimentReading": "Neutral",
      "sentimentNote": "",
      "videos": [
        { "title": "", "creator": "", "url": "", "published": "", "summary": "", "whyItMatters": "" }
      ]
    },
    "aiRace": {
      "weeklyMoves": [{ "headline": "", "company": "", "whyItMatters": "" }],
      "deepDiveCompany": "",
      "deepDiveSummary": "",
      "snapshot": {
        "openai": "", "anthropic": "", "google": "",
        "meta": "", "xai": "", "nvidia": "", "tsmc": ""
      }
    },
    "retirement": {
      "rateWatch": {
        "fedFunds": 0, "nextFomc": "", "marketPath": "neutral",
        "tBills3m": 0, "tNotes2y": 0, "tNotes10y": 0,
        "iBonds": 0, "hySavings": 0, "cds1y": 0, "tips10yReal": 0
      },
      "incomeEtfs": {
        "schd": 0, "vym": 0, "jepi": 0, "jepq": 0,
        "xyld": 0, "qyld": 0, "ryld": 0
      },
      "investorBehavior": [],
      "planningPoints": [],
      "actionItem": ""
    },
    "health": {
      "heartSignal": { "finding": "", "source": "" },
      "supplements": [
        { "name": "", "dose": "", "evidence": "", "tier": "emerging" }
      ],
      "redLight": { "protocol": "", "researchNote": "" },
      "sauna": { "protocol": "", "finding": "" },
      "studyOfWeek": { "title": "", "journal": "", "finding": "", "relevance": "" },
      "practitionerTake": ""
    }
  }
}
```

**JSON rules:**
- All numeric fields must be numbers (not strings)
- Use `null` for unavailable data — never invent values
- Valid JSON only — no trailing commas, no comments inside the block
- The `dfb-json` label is required so Zuck can extract it

---

### SENTINEL
**Task:** QA gate before distribution.

- [ ] No invented prices or fabricated data → auto-reject
- [ ] No more than 3 `null` values across numeric fields → flag if exceeded
- [ ] Tone: executive, grounded — no hype or speculation presented as fact
- [ ] Discord formatting intact
- [ ] JSON block present, labeled `dfb-json`, and valid JSON
- [ ] No duplicate lead stories from prior briefing
- [ ] Section 7 health claims have evidence tier labels — no unqualified health claims

Pass → forward Discord text + JSON to Zuck.
Fail → return to Hemingway with specific notes. One retry. Second failure → distribute with `[SENTINEL FLAG]` and alert MILO.

---

### ZUCK
**Task:** Four deliverables, in order:

**1. Write JSON to disk**
Extract the `dfb-json` block. Write to:
```
/Volumes/BotCentral/Users/milo/.openclaw/workspace/website/public/briefings/YYYY-MM-DD.json
```
Also write/overwrite:
```
/Volumes/BotCentral/Users/milo/.openclaw/workspace/website/public/briefings/latest.json
```

**2. Trigger Vercel redeploy**
```bash
cd /Volumes/BotCentral/Users/milo/.openclaw/workspace/website && vercel deploy --prod --yes 2>&1
```

**3. Post to Discord #dfb**
Channel ID: `1485800271421640854`
Split at section boundaries if any section exceeds 2,000 characters.
Post sequentially. No commentary. No summary. Post as delivered.

**4. Confirm and log to Cortana**
JSON written ✓ | Deploy triggered ✓ | Discord posts sent (count) ✓

---

### CORTANA — CLOSE
After Zuck confirms:
- Log: timestamp, null fields count, Sentinel flags, Discord message count, round-trip time
- Update `Active_Projects.md` DFB entry with last run date and status
