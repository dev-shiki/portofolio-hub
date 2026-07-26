# Case Study 02: Immutable Event & Audit Ledger

**Domain**: Event Operations — Ticketing · Digital Wallet · Traffic Management  
**Stack**: Fastify · Drizzle ORM · PostgreSQL · PL/pgSQL · Offline PWA (Vite)  
**Status**: Live — deployed for active event traffic management operations

---

## Problem Statement

Event-scale digital wallet and ticketing systems handle transactions under conditions where:

- Connectivity is unreliable (venue dead zones, peak-hour saturation)
- Concurrent sync from multiple offline scanners creates race conditions
- Financial records must be forensically tamper-evident for operator accountability
- A single corrupted or silently modified ledger row can cause real financial loss

The naive approach — application-level locks and soft-delete flags — is insufficient. An attacker (or a bug) with direct DB access can bypass any application-layer guard.

---

## Solution Approach

Two complementary guarantees:

1. **Offline-first sync** — scanners operate independently, storing state locally, then batch-sync idempotent transactions when connectivity returns.
2. **Database-enforced immutability** — a PL/pgSQL trigger fires `BEFORE UPDATE OR DELETE` on the ledger table and raises a PostgreSQL-level exception, making modification impossible regardless of which application or database user issues the query.

---

## Architecture

```
[Scanner PWA 1] ──┐
[Scanner PWA 2] ──┤  (offline queue, local IndexedDB)
[Scanner PWA N] ──┘
        │
        │  batch idempotent sync on reconnect
        ▼
   Fastify API Server
        │
        │  Drizzle ORM transaction
        ▼
  PostgreSQL — event_wallet_ledger
        │
        │  BEFORE UPDATE / BEFORE DELETE
        ▼
  PL/pgSQL Trigger (enforce_ledger_immutability)
        │
        ▼
  RAISE EXCEPTION — operation blocked at engine level
```

### Key Architectural Decisions

**1. Why database-level, not application-level, immutability?**  
Application-level guards (e.g., `if (operation === 'delete') throw`) are only enforced if the request goes through the application. A compromised API key, a direct `psql` session, or a future migration script can bypass them silently. The PL/pgSQL trigger fires inside the PostgreSQL transaction engine itself — it cannot be bypassed without dropping the trigger, which requires elevated privileges and is itself a logged DDL event.

**2. Idempotency keys for offline sync**  
Each scanner transaction carries a client-generated UUID. The server checks for duplicates before inserting, ensuring that network retries from intermittent connectivity do not double-count transactions.

**3. Separate ERRCODE for monitoring**  
The trigger raises `restrict_violation` (SQLSTATE `23001`), allowing infrastructure monitoring to alert specifically on ledger tamper attempts vs. ordinary application errors.

---

## Core Implementation

See [`immutability_trigger.sql`](./immutability_trigger.sql) for the full trigger.

```sql
CREATE OR REPLACE FUNCTION enforce_ledger_immutability()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'UPDATE' THEN
        RAISE EXCEPTION
            'SECURITY: Ledger entry % cannot be updated after commit', OLD.id
            USING ERRCODE = 'restrict_violation';
    ELSIF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION
            'SECURITY: Ledger entry % cannot be deleted', OLD.id
            USING ERRCODE = 'restrict_violation';
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_ledger_immutability
BEFORE UPDATE OR DELETE ON event_wallet_ledger
FOR EACH ROW EXECUTE FUNCTION enforce_ledger_immutability();
```

---

## Learnings

- Database-level immutability is underused in most codebases. It adds negligible overhead (trigger fires only on UPDATE/DELETE, which should be zero on a ledger) while eliminating an entire category of data integrity risk.
- Offline-first PWA sync requires thinking in terms of *idempotent operations*, not *stateful sessions*. Every mutation must be safe to replay.
- Raising a typed SQLSTATE code (not a generic exception) is the difference between a monitorable security alert and a noisy generic error log.
