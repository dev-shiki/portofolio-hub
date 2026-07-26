# ADR 0001: The 10-Domain Map

- Status: Accepted
- Date: 2026-06-18
- Deciders: Novrana/Shiki architecture

## Context

The system spans many products (commerce, POS, CRM, AI, invoicing, etc.). Without explicit
boundaries, all of this tends to collapse into one super-app (Novrana Hub) or fragment into
ad-hoc tables with no owner. We need a bounded-context map that is large enough to scale
and small enough to stay legible.

Options considered:

- ~6 broad domains: too coarse; Commerce, Operations, and Relationship get conflated.
- ~20 fine domains: too much overhead; ownership and CI/versioning cost outweighs benefit.
- 10 domains: balances scale and legibility.

## Decision

Adopt **10 domains**: Platform, Commerce, Relationship, Operations, Content, Intelligence,
Automation, Analytics, Finance, Integration.

Each domain owns its model, data, rules, API, events, permissions, and lifecycle. The set
is closed — adding or removing a domain requires a new ADR.

## Consequences

- A clear home for every business record.
- Apps map to exactly one primary domain (see ADR-linked app catalog).
- Cross-domain collaboration must go through events/APIs, not shared tables.
- Some judgment calls on boundaries are needed; recorded in ADRs 0002–0005.
- Platform stays a trust layer, not a super-monolith.
