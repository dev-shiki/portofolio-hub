# ADR 0008: Two Order Aggregates — `commerce_orders` vs `commerce_order_requests`

- Status: Accepted
- Date: 2026-06-22
- Deciders: Novrana/Shiki architecture

## Context

Commerce currently has two tables that represent "an order" in everyday language:

| Table | Source | When created |
| --- | --- | --- |
| `commerce_orders` | Checkout session flow | After payment gateway confirms payment |
| `commerce_order_requests` | Direct order / inquiry cart flow | When buyer submits a storefront cart or inquiry |

Both emerged during the same implementation sprint (June 2026), but they were not planned
as a split — `commerce_order_requests` was added to support the **direct order** use case
for Indonesian SMB merchants who cannot immediately onboard a payment gateway and must
manually confirm and verify payment.

The absence of a boundary definition in the architecture means:

- Downstream domains (Relationship, Finance) cannot tell which table to consume from.
- The event catalog only had `commerce.order.*` — no events for `order_request` lifecycle.
- The manifest listed neither aggregate explicitly.

This ADR formalizes the split as a deliberate design decision.

## Decision

**These are two distinct aggregates with separate lifecycles. Both are permanent.**

### `commerce_orders` — The Confirmed Order Aggregate

- **Created when:** A checkout session completes and payment is confirmed by a payment gateway
  (Midtrans, Duitku, or future provider).
- **Lifecycle:** `pending → confirmed → processing → shipped → delivered` (or `cancelled`, `refunded`).
- **Payment state:** Payment is confirmed *before* the order record exists. The order is
  born in a paid/confirmed state.
- **Who manages it:** Automated — the payment webhook creates the order.
- **Event family:** `commerce.order.created`, `commerce.order.paid`, `commerce.order.cancelled`.
- **Modules required:** `commerce.checkout`, `commerce.orders`.
- **Consumer pattern:** Finance and Relationship can trust that `commerce.order.paid` means
  money has actually moved through a payment gateway.

### `commerce_order_requests` — The Manual-Confirmation Aggregate

- **Created when:** A buyer submits an inquiry cart or direct-order form on the storefront.
  No payment has been confirmed at creation time.
- **Lifecycle:** `new → contacted → confirmed → processing → shipped → completed` (or `cancelled`).
- **Payment state:** Tracked separately as `paymentStatus` (`unpaid → awaiting_confirmation → paid`).
  The seller manually marks payment as confirmed after reviewing a proof upload.
- **Who manages it:** Semi-automated — storefront creates it, seller manages state transitions
  via the Commerce admin dashboard.
- **Event family:** `commerce.order_request.created`, `commerce.order_request.confirmed`,
  `commerce.order_request.paid`, `commerce.order_request.cancelled`.
- **Modules required:** `commerce.direct_order_manual`, `commerce.inquiry_cart`.
- **Consumer pattern:** Finance and Relationship should treat `commerce.order_request.paid`
  as revenue-intent confirmed by a human seller, not by a payment gateway. They may choose
  to wait for a future Finance-domain invoice event for accounting purposes.

## Why Not Merge Them?

The two aggregates exist because the payment confirmation mechanism is fundamentally different:

- `commerce_orders`: payment gateway is the authority → order existence proves payment.
- `commerce_order_requests`: seller is the authority → `paymentStatus` field is the proof.

Merging them into a single table would require a nullable `checkoutSessionId`, complex
status branching, and unclear event semantics. Keeping them separate means each aggregate
is a pure model of its own business process.

## Consequences

- **Event catalog** now has both `commerce.order.*` and `commerce.order_request.*` families.
  Consumers must decide which family they care about (or both). See `contracts/events/event-catalog.yaml`.
- **Manifest** lists both table families under `owns`, grouped under their respective phases.
- **Finance domain** (when implemented) should define whether `order_request.paid` flows into
  an accounting entry directly or waits for an invoice issued by Finance itself.
- **Relationship domain** can consume both `order.paid` and `order_request.paid` to record
  purchase events against a contact, with appropriate source tagging.
- No SQL joins between the two tables are expected. If a merchant migrates from direct-order
  to checkout flow, that is a business event, not a data migration between tables.
- Future work: if order_request matures to the point where it maps to a Finance invoice
  automatically, that integration should go through the event contract, not a table join.
