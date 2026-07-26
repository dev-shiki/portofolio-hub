# ADR 0006: Event Delivery via Transactional Outbox + Inbox

- Status: Accepted
- Date: 2026-06-18
- Deciders: Novrana/Shiki architecture

## Context

The architecture says domains collaborate through events and never through shared tables
(`domain-rules.md` §6, `event-rules.md`). Commerce is the first domain after Platform to
emit and consume cross-domain events (`commerce.order.paid` fans out to seven domains), so
we must decide *how events are physically delivered* before that code is written —
otherwise each domain invents its own mechanism and we get drift.

Constraints of the current stack:

- Database is Turso/libSQL (SQLite dialect), single database for now.
- Runtime is Hono on Cloudflare Workers (short-lived, can die mid-request).
- No message broker is deployed, and standing up Kafka/NATS now is unjustified overhead
  for current scale.

Options:

1. **In-process emit** (call consumers directly / in-memory queue). Simplest, but loses
   events if the worker dies after the DB commit but before consumers run. Unacceptable
   for money-adjacent events (receipts, metrics, stock).
2. **Broker now** (Kafka/NATS/Redis Streams). Durable, but heavy operational cost and a
   premature commitment at current scale.
3. **Transactional outbox + inbox on the existing DB.** Durable, no new infrastructure,
   and broker-ready later without a rewrite.

## Decision

Adopt the **transactional outbox + inbox** pattern, standardized across all domains:

- Every emitting domain owns `{domain}_outbox`. The outbox row is written **in the same
  DB transaction** as the state change. A relay publishes `pending` rows with backoff and
  a terminal `failed` state.
- Every consuming domain owns `{domain}_inbox`, keyed by `event.id`. The handler effect
  and the inbox insert happen **in one transaction**, making consumption idempotent
  (exactly-once in effect) over at-least-once delivery.
- Row shapes are fixed in `@shikitoka/domain-contracts` (`OutboxRecord`, `InboxRecord`).
- Full rules in `governance/event-delivery-rules.md`.

The envelope (`DomainEvent`) gains `envelopeVersion`, `payloadVersion`, `correlationId`,
`causationId`, and `traceparent` so versioning and tracing never require a breaking change
later (`observability-rules.md`).

## Consequences

- No event is lost on crash; no event is processed twice. This holds from the first
  Commerce event, not after an incident.
- No new infrastructure: outbox/inbox are ordinary libSQL tables.
- A real broker can be introduced later **between** the relay and the inbox; the outbox
  and inbox tables stay. That introduction is its own ADR, not a rewrite.
- Every domain pays a small, uniform cost (two tables + relay + dedupe), which is the
  price of durable decoupling and is identical everywhere.
- Mirrors the proven Platform webhook-retry model (durable, replayable, never silently
  dropped), keeping operational behavior consistent across the system.
