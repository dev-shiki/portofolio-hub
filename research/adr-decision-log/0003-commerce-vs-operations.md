# ADR 0003: Commerce Order vs Operations POS Order

- Status: Accepted
- Date: 2026-06-18

## Context

"Order" is ambiguous. An online storefront order and an in-store POS transaction look
similar but have different lifecycles, channels, and operational concerns. Forcing them
into one table couples online checkout with register/shift/cash-drawer mechanics.

## Decision

- **Commerce** owns the online selling channel: `commerce_orders`, `commerce_carts`,
  `commerce_checkout_sessions`, catalog, storefront.
- **Operations** owns in-store/operational transactions: `operations_pos_orders`,
  `operations_shifts`, `operations_registers`, `operations_stock_movements`.

They are distinct aggregates. Both can emit a "paid" event
(`commerce.order.paid`, `operations.pos_order.paid`) that downstream domains consume
uniformly.

## Consequences

- Inventory/fulfillment in Operations can react to `commerce.order.paid` to decrement stock,
  without Commerce owning stock.
- Relationship and Finance consume both paid events to unify customer history and accounting.
- Reporting can aggregate both channels via Analytics.
- No single "orders" table tries to serve both online and POS semantics.
