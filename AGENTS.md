# AGENTS.md - PRD-Driven Delivery Workspace

This workspace is a docs-first delivery workspace with backend, frontend, QA, and preview-environment touchpoints.

## Structure

| Directory | Role |
|-----------|------|
| `docs/` | PRD, spec, and preview-flow documents |
| `backend/` | Kotlin Spring Boot API |
| `frontend/` | Vue 3 web app |
| `database/` | MariaDB and bootstrap SQL |
| `e2e-test/` | Playwright smoke tests |
| `infrastructure/` | k3s/k3d templates, preview scripts, and Helm chart |

## Working Principles

1. Inspect the root structure first, then move into the target directory.
2. Treat `backend`, `frontend`, `database`, and `e2e-test` as independent projects.
3. Feature work should start in `docs/prd/` and `docs/spec/` before code changes.
4. When the API changes, also review `frontend/src/api/` and `e2e-test/tests/`.
5. When the test environment changes, update `infrastructure/k3s/helm/example-stack` and `infrastructure/k3s/scripts` together.
6. On macOS with Docker Desktop, prefer validating the k3s flow through `k3d` unless the user explicitly wants Docker Desktop Kubernetes.
7. Preview changes should update the PRD/spec package, GitHub workflows, Helm values/templates, and preview scripts together.
8. Treat preview as part of the delivery flow: branch or PR input, live URL, smoke check, approval/merge, then cleanup.

## Common Commands

```bash
make help
make db-up
make backend-run
make frontend-dev
make e2e-test
make k3d-up
make helm-deploy-local
make helm-smoke-local
make helm-template
make pr-env-create-local PREVIEW_PR_NUMBER=204
make pr-env-test PREVIEW_PR_NUMBER=204
make pr-env-dashboard
make pr-env-dashboard-open
make pr-env-delete PREVIEW_PR_NUMBER=204
```

## Goal

Keep the workspace minimal and readable while making the PRD -> SPEC -> CODE -> QA -> preview flow visible enough to evaluate.
