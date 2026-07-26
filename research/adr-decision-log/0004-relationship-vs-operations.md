# ADR 0004: Relationship as a Domain Separate from Operations

- Status: Accepted
- Date: 2026-06-18

## Context

Customer/contact data could be folded into Operations (since POS and Booking touch
customers) or into Commerce (since orders have customers). But customer/relationship data
is used by many domains: Commerce, Operations (POS/Booking), Content, Intelligence, and
Support. Embedding it in any one of them forces the others to reach across boundaries.

## Decision

**Relationship** is its own domain. It owns contact/lead/CRM/timeline/loyalty/support:
`relationship_contacts`, `relationship_leads`, `relationship_deals`,
`relationship_customer_timelines`, `relationship_segments`, `relationship_loyalty_profiles`,
`relationship_support_requests`.

Other domains reference contacts by ID and consume relationship events; they do not own
contact master data.

## Consequences

- A single customer timeline can unify online (`commerce.order.paid`) and in-store
  (`operations.pos_order.paid`) history.
- Intelligence scores leads and emits `intelligence.lead.scored`; Relationship consumes it.
- "Business segment" (CRM concept) lives in Relationship; "analytics segment" (metric
  cohort) lives in Analytics. They are not merged.
- Support requests have one home, not scattered per product.
