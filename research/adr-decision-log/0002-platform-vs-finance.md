# ADR 0002: Platform Billing vs Finance Domain

- Status: Accepted
- Date: 2026-06-18

## Context

Two very different "money" concepts exist:

1. The client pays **Novrana** for platform access (subscriptions, checkout, entitlement).
2. The client runs their **own** business finance (invoices to their customers, receipts,
   settlements, tax, accounting).

If both live in one place, billing logic and the client's accounting get entangled, and the
trust layer (Platform) becomes a general-purpose accounting engine.

## Decision

- **Platform** owns platform billing: `payments`, `subscriptions`, `plans`,
  `provider_prices`, `entitlements`, provider webhooks for Novrana checkout. This is the
  client paying Novrana.
- **Finance** owns the client's own business money: `finance_invoices`,
  `finance_receipts`, `finance_settlements`, `finance_tax_lines`,
  `finance_accounting_events`, `finance_payouts`.

A Novrana subscription is **Platform**, never Finance.

## Consequences

- Provider billing webhooks (Lemon/Paddle/Midtrans/Duitku/Xendit) stay Platform-owned.
- Finance consumes business events (`commerce.order.paid`, `operations.pos_order.paid`,
  `relationship.deal.won`) to build invoices/receipts — it never reads Platform's `payments`.
- Clear support story: "could not access product" is a Platform question; "my invoice to my
  customer is wrong" is a Finance question.
