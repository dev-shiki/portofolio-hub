# Automated AI Test Generation & Specification Bias Analysis

**Type**: Undergraduate Thesis (Skripsi) — Empirical Research  
**Domain**: Software Engineering · AI/ML · Test Automation  
**Methodology**: Empirical study with reproducibility testing and statistical bias analysis

---

## Research Question

Apakah AI dapat meningkatkan kualitas pengujian perangkat lunak secara signifikan? Dan jika bisa, *di mana batasnya*?

Lebih spesifik:

> *Do LLM-generated test suites exhibit systematic specification bias — consistently covering happy-path scenarios while under-generating edge cases, boundary values, and negative test paths?*

---

## Methodology

### Phase 1: Test Generation
- Selected a corpus of business logic functions with formal natural-language specifications.
- Used LLM prompting (varying temperature, prompt structure, context window size) to generate test suites for each function.
- Collected generated suites for comparative analysis.

### Phase 2: Coverage & Bias Analysis
- Measured **branch coverage**, **condition coverage**, and **negative path coverage** against human-authored ground-truth test suites.
- Categorized systematically under-covered test types: boundary values, error states, concurrent access, and input validation failures.

### Phase 3: Reproducibility Testing
- Re-ran identical prompts across multiple sessions.
- Evaluated whether deterministic sampling (`temperature=0`) produces consistent quality — or merely *consistently biased* output.

---

## Key Findings

The research demonstrated measurable, systematic bias in LLM-generated test suites:

- **Happy-path bias confirmed**: AI-generated suites covered a high proportion of specification-described behaviours but significantly fewer unlisted edge cases.
- **Prompt engineering helps, but doesn't eliminate the gap**: Explicit instructions to "also test failure cases and boundaries" improved edge-case coverage, but still fell short of human-authored suites.
- **Deterministic ≠ Unbiased**: `temperature=0` produces *reproducible bias* — the same coverage gaps appear every run. This is useful for tooling but should not be confused with correctness.
- **Specification quality is the dominant variable**: Functions with ambiguous or incomplete specifications produced the worst AI test coverage, regardless of the model used. This reframes where investment should go: better specifications, not better prompts.

---

## Research Contributions

1. **Empirical bias taxonomy** — A categorized framework of which test categories AI systematically under-generates.
2. **Prompt strategy comparison** — Measured effectiveness of different prompting approaches for improving coverage.
3. **Reproducibility framework** — Methodology for measuring non-determinism in AI-generated test suites across sessions.

---

## Practical Implications

- AI test generation is most effective as a **first-pass** tool — not as a complete solution.
- Engineering teams using AI test tools should maintain a **bias checklist** covering: boundary values, null/invalid inputs, error states, concurrent access.
- Investing in **structured specification formats** (Gherkin, OpenAPI schemas, formal type definitions) improves AI test quality more than prompt engineering alone.
- The bottleneck is often specification clarity, not model capability.

---

## Research Artifacts

- Python analysis scripts and reproducibility testing notebooks (`radios/skripsi-ai-test-generation/`)
- Statistical analysis results and bias categorization data
