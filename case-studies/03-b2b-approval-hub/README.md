# Case Study 03: B2B Working Drawing & Document Approval Hub

**Domain**: B2B Commerce — Custom Fabrication · Furniture Manufacturing · Contract Management  
**Stack**: Next.js (App Router) · TypeScript · Sanity CMS · PDF Generation  
**Status**: Live — powering active B2B fabrication and contract workflows

---

## Problem Statement

Custom fabrication businesses (furniture, metalwork, fit-out) face a specific class of approval problem: **technical drawings must be validated by multiple parties before production begins**, but the current process is almost always:

- WhatsApp image threads with no version control
- Email chains where the latest revision is ambiguous
- Verbal "OK, proceed" approvals with no written record
- Production starting before final sign-off, causing costly rework

The consequences are real: wrong specifications reach the factory floor, disputes over what was agreed are unresolvable, and invoice reconciliation is messy because the agreed spec and the produced item diverge.

---

## Solution Approach

A structured approval state machine where:

1. The client uploads a working drawing (PDF/image) with structured spec data
2. The system routes it through required reviewers in sequence
3. Every review action (approve, request revision, reject) is timestamped and attributed
4. Only upon full approval does the system auto-generate a legally-structured contract PDF
5. That contract references the exact spec version that was approved — no ambiguity

---

## Architecture

```
Client / Designer
      │
      │  Upload drawing + structured spec (JSON form)
      ▼
Next.js B2B Platform (App Router)
      │
      ├── Sanity CMS: stores drawing assets, spec history, versioned revisions
      │
      ├── Approval State Machine:
      │     draft → client_submitted → internal_review
      │         → revision_requested → client_resubmitted
      │         → approved → contract_generated
      │
      └── PDF Generation Engine:
            Approved spec JSON → structured PDF contract
            (spec version, party identities, timestamp, approver signatures)
```

### Key Architectural Decisions

**1. Structured spec data alongside the drawing**  
Uploading a drawing image alone is insufficient. The system captures structured fields (dimensions, materials, finishes, quantities) separately. This is what powers the automated PDF generation — the contract is generated from data, not from human-typed text.

**2. Explicit versioning of revisions**  
Every revision cycle (client resubmits after revision request) creates a new spec version. The approval history tracks which version was reviewed at each step, making it unambiguous what was finally approved.

**3. Contract PDF locked to approved spec version**  
The generated PDF embeds the spec version ID and a cryptographic hash of the approved spec payload. Any post-approval modification is detectable.

---

## State Machine

```
draft
  └─► client_submitted
            └─► internal_review
                      ├─► revision_requested
                      │         └─► client_resubmitted → (back to internal_review)
                      ├─► rejected (terminal)
                      └─► approved
                                └─► contract_generated (terminal, triggers PDF)
```

---

## Learnings

- The hardest part of this system was not the technology — it was capturing the right fields in the spec form. "What dimensions does a custom furniture piece need?" requires domain knowledge, not engineering knowledge.
- State machines are dramatically more maintainable than `if/else` status checks scattered across codebase. Defining all valid transitions in one place makes invalid transitions impossible to express in code.
- PDF generation from structured JSON is underused. Most teams write PDFs manually or use Word templates. A code-generated PDF from validated data is both more accurate and fully automatable.
