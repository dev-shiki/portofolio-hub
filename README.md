# Enterprise Systems & Digital Business Portfolio

> **Role**: Software Engineer — Business Systems & Automation  
> **Focus**: Enterprise Process Digitalization · Systems Architecture · Security · Applied AI

Software engineer with production experience building multi-tenant business platforms, configurable workflow engines, and security-first data systems. This portfolio documents architectural decisions, implementation patterns, and applied research from live systems.

---

## Featured Case Studies

| # | Title | Stack | Key Highlights |
| :--- | :--- | :--- | :--- |
| 01 | [Universal Workflow & Approval Engine](./case-studies/01-workflow-engine/README.md) | NestJS · Prisma · PostgreSQL | Multi-tenant BPE State Machine, AES-256-GCM PII Encryption, HMAC Blind Indexing |
| 02 | [Immutable Event & Audit Ledger](./case-studies/02-immutable-event-system/README.md) | Fastify · Drizzle ORM · PL/pgSQL | Database-enforced immutability trigger (`BEFORE UPDATE/DELETE`), Offline-first PWA |
| 03 | [B2B Document Approval Hub](./case-studies/03-b2b-approval-hub/README.md) | Next.js · Sanity · PDF Engine | Working drawing approval state machine, Automated contract generation |

---

## Architecture Decision Records (ADRs)

Formal engineering decision logs — written to document *why* a design was chosen, not just *what* was built.

| ADR | Title | Status |
| :--- | :--- | :--- |
| [0001](./research/adr-decision-log/0001-domain-map.md) | 10-Domain Bounded Context Map | Accepted |
| [0002](./research/adr-decision-log/0002-platform-vs-finance.md) | Platform vs Finance Domain Separation | Accepted |
| [0003](./research/adr-decision-log/0003-commerce-vs-operations.md) | Commerce vs Operations Boundary | Accepted |
| [0004](./research/adr-decision-log/0004-relationship-vs-operations.md) | Relationship vs Operations Boundary | Accepted |
| [0005](./research/adr-decision-log/0005-integration-vs-automation.md) | Integration vs Automation Boundary | Accepted |
| [0006](./research/adr-decision-log/0006-event-delivery-outbox-inbox.md) | Event Delivery via Transactional Outbox/Inbox | Accepted |
| [0007](./research/adr-decision-log/0007-platform-owns-module-entitlements.md) | Platform Owns Module Entitlements | Accepted |
| [0008](./research/adr-decision-log/0008-order-vs-order-request.md) | Order vs Order Request Distinction | Accepted |

---

## Applied AI Research

- [Automated AI Test Generation & Specification Bias Analysis](./research/ai-test-generation/README.md)  
  Undergraduate thesis investigating prompt engineering patterns, LLM reproducibility parameters, and specification bias in AI-generated test suites.

---

## Professional Background

### Production Engineering (Team)
Backend & system engineer on production enterprise platforms — built multi-branch organizational access control systems and automated cloud infrastructure provisioning with API gateway integrations.

### Independent Products & Ventures
- **Beresin OS** — Multi-tenant service operations platform with Business Process Engine, AES-256-GCM PII encryption, and multi-role RBAC. *(Live)*
- **Sentinel System** — Offline-first event traffic management platform with database-enforced immutable ledger. *(Live)*
- **B2B Platform** — Working drawing approval and automated contract generation for B2B fabrication workflows. *(Live)*

---

## Tech Stack

```
Backend       NestJS · Fastify · Hono · Express · Node.js
Frontend      Next.js (App Router) · Vue 3 / Nuxt · TailwindCSS
Database      PostgreSQL · Prisma ORM · Drizzle ORM · Redis
Architecture  DDD · ADRs · BPE State Machines · Outbox/Inbox Pattern
Security      AES-256-GCM · HMAC Blind Indexing · RBAC · PL/pgSQL Triggers
Cloud         Docker · Kong API Gateway · Nginx · Vercel · CI/CD
AI            RAG Pipelines · LLM Integration · AI Agent Design
```
