# ADR 0007: Platform Owns Commerce Module Entitlements

- Status: Accepted
- Date: 2026-06-22
- Deciders: Novrana/Shiki architecture

## Context

Commerce implements a module-gating system to control which Commerce features a user can
access based on their plan (e.g. `brand-site`, `direct-order`, `pro`, `enterprise`).
Thirteen modules are defined:

```
commerce.brand_site         commerce.catalog            commerce.custom_domain
commerce.inquiry            commerce.direct_order_manual commerce.inquiry_cart
commerce.manual_payment     commerce.manual_shipping    commerce.payment_link
commerce.shipping_api       commerce.checkout           commerce.orders
commerce.analytics
```

When implementing this, two tables were created to store module state:

- `platform_module_plan_entitlements` — maps (projectId, planId, moduleKey) → enabled/limits
- `platform_module_user_overrides` — maps (userId, projectId, moduleKey) → enabled override

The question is: which domain **owns** these tables?

### Option A — Commerce owns them

The modules are Commerce-specific concepts. Commerce code writes and reads these tables
directly. Prefix them `commerce_module_*`.

### Option B — Platform owns them

Module entitlements are a **platform-level governance concern**: who can access what feature
in which product, based on their subscription plan. This is the same concern Platform already
manages for billing, subscriptions, and access control (via `platform_subscriptions`,
`platform_access_grants`, etc.). The `platform_` prefix signals that other products beyond
Commerce could register their own modules in the same mechanism without creating a new
entitlement system.

## Decision

**Platform owns the module entitlement tables.** The `platform_` prefix is correct and
intentional. Rationale:

1. **Consistency with Platform's existing responsibility surface.** Platform already owns
   subscription truth (`platform_subscriptions`) and access grants. Module entitlements are
   a natural extension: "given your subscription plan, which modules are you allowed to use?"
   This is a Platform-level question, not a Commerce-specific one.

2. **Future-proofing.** If Operations, Relationship, or another domain implements its own
   module gating, they should reuse the same mechanism rather than inventing `operations_module_*`
   tables. The shared tables with a `platform_` prefix make this obvious.

3. **Separation of concerns.** Commerce *defines* what its modules are and *checks* module
   access at runtime (`hasModuleAccess`). Platform *stores* the entitlement state and
   *interprets* it via plan/override rules. The read/write split is clean: Commerce calls
   `ModuleEntitlementsService` (which reads Platform tables); it does not write those tables
   itself except via the entitlement service API.

4. **Precedent in the schema.** The tables already use `platform_module_` prefix in the
   runtime implementation (`packages/database/src/schema/modules.ts`), which belongs to
   the `platform` schema file group, not the `commerce/` subdirectory.

## Consequences

- `platform_module_plan_entitlements` and `platform_module_user_overrides` are declared
  as **Platform-owned** in `domains/platform/manifest.yaml` (to be updated when Platform
  manifest is written out in full).
- Commerce manifest (`domains/commerce/manifest.yaml`) lists these tables under
  `notes.platform_owned_tables` — they are **used by** Commerce but **not owned by** it.
- Any future domain that adds module gating should register its modules in the same
  `platform_module_*` tables and expose a service API analogous to `ModuleEntitlementsService`.
- No table rename or migration is required; the `platform_` prefix was used from the start.
- The module catalog for Commerce (keys, labels, descriptions, and plan mappings) is
  documented separately in `app-catalog/commerce.module-catalog.md`.
