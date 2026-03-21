# Docs

This directory is the starting point for feature work in this workspace.

- `prd/`: product requirements and problem framing
- `spec/`: execution-facing specs, API contracts, validation rules, and acceptance criteria
- `ai-workflow.md`: how AI assistance is intended to fit into the delivery model

Expected workflow:

1. Write the product requirement in `prd/`.
2. Refine it into an implementation-facing spec in `spec/`.
3. Use those documents to drive `backend`, `frontend`, `e2e-test`, and `infrastructure` changes.
