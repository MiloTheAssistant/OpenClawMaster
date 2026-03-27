# Execution_Modes.md

## draft
Plans only. No execution, no posting, no durable changes.

## simulate
Default mode. Produce the expected behavior, outputs, and impact without executing external side effects unless explicitly covered by standing policy.

## execute
Perform real actions only when:
- the mode is explicitly elevated
- required approvals exist
- policy gates are satisfied

## Standing Policy Exception
Standing-approved recurring publishing workflows may execute distribution actions in simulate-default systems because the workflow itself has already been authorized by MILO and the run is cleared by ELON.
