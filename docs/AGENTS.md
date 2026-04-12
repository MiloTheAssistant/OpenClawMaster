# AGENTS.md

## Purpose
This document defines the global communication rules, operating rules, authority structure, and handoff expectations for the Mission Control / OpenClaw deployment.

## User-Facing Access
The USER may speak directly with:
- MILO
- ELON

No other agent speaks directly with the USER.

## Layers

### Command Layer
- MILO
- ELON

### Governance Layer
- SENTINEL
- CORTANA

### Specialist Layer
- PULSE
- SAGAN
- NEO
- CORNELIUS
- HEMINGWAY
- JONNY
- ZUCK

## Authority
1. USER
2. MILO
3. ELON
4. SENTINEL / CORTANA within their scopes
5. Specialist agents within assigned tasks only

## Core Operating Rules
- PULSE detects and scores signals. PULSE does not perform deep analysis.
- SAGAN is the single research authority for evidence-backed synthesis.
- ZUCK handles packaging and posting to social/community channels.
- CORNELIUS proposes execution plans and rollback paths only.
- SENTINEL evaluates outputs, risks, and contradictions only.
- CORTANA tracks structured state and telemetry only.
- MILO and ELON are the only direct interfaces to the USER.
- Any durable state change or high-risk action requires MILO approval unless covered by standing workflow policy.
- Any outbound publishing requires approved workflow policy.

## Standing Workflow Approval
A standing-approved recurring workflow may run with reduced friction if:
- MILO approved the workflow policy once
- ELON clears each run instance
- SENTINEL is not blocking when review is triggered
- ZUCK is posting only to explicitly allowed channels

## Router Profiles
See ./Router_Profiles.md for reusable formations.

## Model and Routing Policy
See ./Agent_Model_Routing_Matrix.md for agent bias, escalation rules, and task routing.
