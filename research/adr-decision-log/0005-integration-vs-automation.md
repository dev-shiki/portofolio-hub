# ADR 0005: Integration vs Automation

- Status: Accepted
- Date: 2026-06-18

## Context

Both Integration and Automation can be described as "doing something when something
happens," so they risk overlapping. We need a crisp rule for what belongs where.

## Decision

- **Integration** = connect and sync external systems. Connectors, external accounts, sync
  jobs, external mappings, webhook subscriptions, import/export jobs.
  `integration_connectors`, `integration_sync_jobs`, `integration_external_mappings`, etc.
- **Automation** = rules and workflows inside the platform. Triggers, conditions, actions,
  approvals, retries, schedules. `automation_workflows`, `automation_triggers`,
  `automation_actions`, etc.

Heuristic:

```text
"Sync orders to the marketplace every 15 minutes"        -> Integration
"When order is paid, if total > X, request approval"      -> Automation
```

## Consequences

- An automation workflow may invoke an integration sync as one of its actions (via the
  Integration API), but it does not own connector state.
- Integration emits `integration.sync.failed`; Automation may consume it to trigger a
  recovery workflow.
- Provider billing webhooks for Novrana checkout remain **Platform**-owned, not Integration
  (those are trust-layer payment evidence, not external business connectors).
