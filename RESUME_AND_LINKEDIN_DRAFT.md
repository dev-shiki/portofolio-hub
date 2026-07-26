# Resume & LinkedIn Profile Guide

---

## LinkedIn Headline

```
Software Engineer — Business Systems & Automation | Enterprise Process Digitalization | Architecture & Integration
```

*Note: Add "Ex-[Company Name]" if your previous employer is well-known in your target market. Keep it if the name adds signal; omit it if it doesn't.*

---

## LinkedIn About Section

```
Software engineer with hands-on production experience building multi-tenant business platforms, configurable workflow automation, and security-first data systems.

My work focuses on the boundary between business operations and technical implementation: designing systems that reflect how organizations actually approve, track, and audit work — not just CRUD applications.

Technical foundation:
• Backend: Node.js (NestJS, Fastify, Hono), PostgreSQL, Prisma ORM, Drizzle ORM, Redis
• Frontend: Next.js (App Router), Vue 3 / Nuxt, TypeScript, TailwindCSS
• Architecture: Domain-Driven Design, Architecture Decision Records (ADRs), State Machine design, Outbox/Inbox event patterns
• Security: AES-256-GCM application-layer encryption, HMAC blind indexing, RBAC, PL/pgSQL immutability triggers
• Cloud & Integration: Docker, Kong API Gateway, Nginx, Webhook infrastructure, CI/CD

Independent products I've designed and shipped:
• A multi-tenant service operations platform with a configurable Business Process Engine and GDPR-class PII encryption
• An offline-first event scanning platform with database-enforced immutable transaction ledger
• A B2B approval and contract generation platform for custom fabrication workflows
```

---

## Resume Structure

### Header
```
[Full Name]
[City, Country] · [email] · [LinkedIn URL] · [GitHub URL]
```

### Summary (3–4 lines max)
```
Software engineer specializing in business systems architecture and enterprise process digitalization.
Production experience building multi-tenant workflow platforms, applying application-layer security
(AES-256-GCM PII encryption, database immutability triggers), and designing systems with formal
Architecture Decision Records. Background includes team production work and independent product development.
```

### Skills
```
Languages      TypeScript · JavaScript · Python · SQL (PL/pgSQL)
Backend        NestJS · Fastify · Hono · Express · Node.js
Frontend       Next.js · Vue 3 · Nuxt · TailwindCSS · React
Databases      PostgreSQL · Prisma ORM · Drizzle ORM · Redis · SQLite
Architecture   Domain-Driven Design · State Machine Design · ADRs · Outbox/Inbox Pattern
Security       AES-256-GCM · HMAC Blind Indexing · RBAC · Row-Level Security
DevOps/Cloud   Docker · Kong API Gateway · Nginx · Vercel · CI/CD
AI             RAG Pipelines · LLM Integration · AI Agent Architecture
```

### Professional Experience

**[Previous Company Name] — Software Engineer**  
*[Month Year] – [Month Year]*
- Developed multi-tenant organizational access control system managing complex branch hierarchies and permission isolation across business units.
- Built automated cloud infrastructure provisioning service and API gateway request routing layer for VM lifecycle management.
- Worked in cross-functional engineering team delivering production systems under Agile/Scrum methodology.

*How to describe this without publishing code: these bullet points describe what you built and the technical domain — they don't reference any internal project names or show any code. That's the right level of detail.*

---

**Independent Digital Ventures — Product Systems Engineer**  
*[Month Year] – Present*
- Designed and shipped **Beresin OS**, a multi-tenant service operations platform with a configurable Business Process Engine (BPE), AES-256-GCM application-layer PII encryption, and HMAC blind indexing for compliant data storage.
- Built **Sentinel System**, an offline-first event scanning and digital wallet platform with PL/pgSQL immutability triggers enforcing tamper-proof transaction records at the database engine level.
- Developed **B2B Fabrication Platform**, automating technical drawing approval workflows and contract PDF generation for custom manufacturing clients.

### Education

**Bachelor of [Computer Science / Information Technology]**  
*[University Name], [Year]*  
Thesis: *Automated AI Test Generation & Specification Bias Analysis*  
— Empirical study measuring happy-path bias and edge-case coverage gaps in LLM-generated test suites.

---

## Interview Answer Templates

### "Walk me through one of your projects."

> "One of the more technically interesting systems I built was a configurable workflow engine for multi-step approvals — things like procurement requests, maintenance orders, HR approvals. The core challenge was that different domains have completely different approval structures, so rather than hardcoding a 'purchasing flow' and a 'leave request flow', I built it as a state machine where the domain and payload schema are configuration. Every step is append-only in an audit log — you can reconstruct the full approval history at any point. The security layer was the most involved part: contact data is AES-256-GCM encrypted at the application level before it touches the database, and we use HMAC blind indexing so you can still do equality lookups without decryption."

### "What's the hardest technical decision you've made?"

> "Choosing database-level immutability over application-level guards for a financial ledger. Application-level protection is bypassable — a direct database session, a migration script, a compromised key can all get around it. So I implemented a PL/pgSQL trigger that fires before any UPDATE or DELETE on the ledger table and raises a PostgreSQL-level exception with a specific SQLSTATE code. It can't be bypassed without a DROP TRIGGER DDL statement, which itself is a logged event. The tradeoff was that it made the system slightly harder to test, because you have to think carefully about test database cleanup — but for a financial audit trail, that tradeoff is clearly worth it."

### "Tell me about your experience with team production work."

> "In my previous role I worked on enterprise production systems — one was an access control system that managed hierarchical permissions across multiple business branches, where the organizational structure itself was a tree that had to be queried efficiently for authorization decisions. Another was a cloud infrastructure service that automated VM provisioning and routed API requests through a gateway. Both were team environments with code review, branch management, and coordination across multiple engineers."
