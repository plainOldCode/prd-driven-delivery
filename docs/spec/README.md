# Spec

This directory turns product intent into execution detail.

Each spec should answer the questions that a PRD alone should not carry:

- what API shape changes are required
- what validation and business rules must be enforced
- what frontend states must exist
- what `e2e-test` must prove
- what rollout or environment assumptions matter

Recommended structure for a feature spec:

1. Scope summary
2. Backend contract
3. Validation and business rules
4. Frontend behavior
5. E2E acceptance criteria
6. Rollout and non-goals
