# QA_Gates.md

## Always Trigger SENTINEL
- High-risk infrastructure plans
- Conflicting specialist outputs
- Financial or legal-sensitive recommendations with low confidence
- Any workflow flagged by MILO as locked or elevated risk

## Conditional Trigger
- Recurring approved briefs with source conflicts
- Confidence below threshold
- Missing required sections
- New channel addition
- Workflow template drift
- Unusually large market event

## Not Required By Default
- Routine recurring approved publish runs that match template, pass confidence checks, and show no source conflict

## QA Decision Outcomes
- approved
- conditional
- rejected
