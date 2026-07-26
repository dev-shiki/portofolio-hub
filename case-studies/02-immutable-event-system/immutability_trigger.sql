-- Immutable Ledger Trigger — Enterprise Event Wallet System
--
-- Purpose:
--   Enforce append-only semantics on the event_wallet_ledger table at the
--   PostgreSQL engine level. No application code, API key, or DB user can
--   UPDATE or DELETE a committed ledger row, regardless of permissions.
--
-- Design rationale:
--   Application-layer guards (throw on delete) are bypassable via direct DB
--   access, migration scripts, or compromised credentials. This trigger fires
--   inside the PostgreSQL transaction engine itself, making bypass impossible
--   without a DROP TRIGGER DDL statement (which requires superuser and is a
--   logged DDL event).
--
-- ERRCODE 'restrict_violation' (SQLSTATE 23001) is used intentionally so
--   infrastructure monitoring can alert specifically on tamper attempts vs
--   ordinary application errors.
--
-- Attach this trigger once after table creation. No maintenance required.

CREATE OR REPLACE FUNCTION enforce_ledger_immutability()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'UPDATE' THEN
        RAISE EXCEPTION
            'SECURITY VIOLATION: Ledger entry % cannot be modified after commit. ' ||
            'Attempted UPDATE on event_wallet_ledger by session user "%".',
            OLD.id, session_user
            USING ERRCODE = 'restrict_violation';

    ELSIF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION
            'SECURITY VIOLATION: Ledger entry % cannot be deleted. ' ||
            'Attempted DELETE on event_wallet_ledger by session user "%".',
            OLD.id, session_user
            USING ERRCODE = 'restrict_violation';
    END IF;

    RETURN NULL; -- BEFORE trigger: returning NULL cancels the operation
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER  -- runs with definer privileges, not caller
   SET search_path = public;

-- Drop existing trigger first (idempotent deployment)
DROP TRIGGER IF EXISTS trg_ledger_immutability ON event_wallet_ledger;

-- Attach: fires BEFORE every row-level UPDATE or DELETE
CREATE TRIGGER trg_ledger_immutability
    BEFORE UPDATE OR DELETE
    ON event_wallet_ledger
    FOR EACH ROW
    EXECUTE FUNCTION enforce_ledger_immutability();

-- Verification: confirm trigger is registered
-- SELECT trigger_name, event_manipulation, action_timing
-- FROM information_schema.triggers
-- WHERE event_object_table = 'event_wallet_ledger';
