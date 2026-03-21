# AI-Assisted Workflow

This workspace is not trying to prove that AI can replace product, engineering, or QA.

It is trying to prove something narrower and more useful:

AI assistance becomes much more reliable when the workflow is anchored in explicit artifacts.

## Intended Use

The expected order is:

1. Product intent is written in `docs/prd/`
2. Execution detail is written in `docs/spec/`
3. Backend, frontend, and e2e changes are derived from those docs
4. Local validation happens through tests, Docker, and k3d

## Where AI Helps

- expanding rough product notes into a structured PRD
- turning a PRD into a tighter implementation-facing spec
- identifying backend/frontend/e2e touchpoints from the spec
- drafting acceptance criteria and validation cases
- keeping multi-project changes aligned

## Where AI Should Not Lead

- inventing product rules that are not in the PRD
- changing API behavior without updating the spec
- skipping validation just because generated code compiles
- replacing test intent with vague smoke coverage

## Practical Rule

In this workspace, AI should accelerate translation between layers:

- PRD
- spec
- implementation
- verification

It should not become an unreviewed source of truth.
