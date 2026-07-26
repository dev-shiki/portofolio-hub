# Case Study 01: Universal Workflow & Approval Engine

**Domain**: Enterprise Operations — Procurement · HR · Maintenance · Capital Expenditure  
**Stack**: NestJS · Prisma ORM · PostgreSQL · TypeScript  
**Status**: Live operational core running in active multi-tenant service platform

---

## Problem Statement

Enterprise approval processes — purchasing requests, leave approvals, maintenance orders, capex sign-offs — are consistently handled through informal channels (WhatsApp, email, paper forms). This creates:

- No audit trail of who approved what and when
- No enforcement of step sequencing (e.g., supervisor must approve before finance)
- PII data (employee contacts, vendor details) stored in plaintext
- Zero tamper-evidence if a record is altered post-approval

---

## Solution Approach

A configurable **Business Process Engine (BPE)** built on a state machine model, where every approval step is a recorded transition with actor identity, timestamp, and full previous/new status. The domain is generic: the same engine handles purchasing, HR requests, or maintenance orders by changing only the `domain` field and `payload` schema.

---

## Architecture

```
Client / Portal
      │
      ▼
API Gateway + Auth (JWT + Role Check)
      │
      ▼
BPE State Machine Controller
      │
      ├──► PII Encryption Layer (AES-256-GCM before DB write)
      │
      ├──► PostgreSQL (encrypted ciphertext + HMAC blind index)
      │
      └──► ApprovalHistory (immutable step log)
```

### Key Architectural Decisions

**1. Application-layer PII encryption (AES-256-GCM)**  
PII fields (email, phone) are encrypted *before* reaching the database. Even a direct DB dump reveals only ciphertext. This matches GDPR/PDPA-class compliance requirements without relying on database-level encryption alone.

**2. HMAC-SHA256 Blind Indexing (`_bidx` columns)**  
Deterministic HMAC of the plaintext allows `WHERE email_bidx = ?` equality lookups without decryption. This is a standard pattern from Crunchy Data / CipherStash — uncommon in junior-level engineering but essential for compliant systems.

**3. JSON payload for form flexibility**  
Each domain's approval request carries a typed JSON `payload`, allowing the engine to serve procurement (with line items, vendor info) and HR (with dates, reason codes) using one unified model.

**4. Append-only ApprovalHistory**  
No step is ever updated or deleted. Every transition is inserted as a new record, providing a tamper-evident audit trail for compliance and dispute resolution.

---

## Core Schema

See [`schema.prisma`](./schema.prisma) for the full implementation.

Key models:

```prisma
// User with encrypted PII + HMAC blind index
model User {
  emailCiphertext  String  @map("email")       // 🔒 AES-256-GCM ciphertext
  emailBlindIndex  String  @unique @map("email_bidx") // 🔎 HMAC-SHA256 for lookups
}

// Configurable workflow request (any domain)
model WorkflowRequest {
  domain    String  // "procurement" | "hr" | "maintenance" | "capex"
  payload   Json    // domain-specific form data
  currentStatus WorkflowStatus @default(draft)
}

// Append-only step log — never updated, never deleted
model ApprovalHistory {
  previousStatus WorkflowStatus
  newStatus      WorkflowStatus
  executedAt     DateTime @default(now())
}
```

---

## Learnings

- Application-layer encryption is significantly harder to implement than DB-level encryption but is necessary when the database itself cannot be fully trusted (cloud providers, shared infrastructure).
- Blind indexing requires careful key management — the HMAC key must be separate from the encryption key and must never rotate without re-indexing.
- A state machine without an explicit step log is incomplete for enterprise use. The history *is* the product in audit-heavy domains.
