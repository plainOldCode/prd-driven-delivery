# AGENTS.md - Example Workspace

This workspace is a simplified example for a multi-project development setup.

## Structure

| Directory | Role |
|-----------|------|
| `docs/` | PRD and working notes |
| `backend/` | Kotlin Spring Boot API |
| `frontend/` | Vue 3 web app |
| `database/` | MariaDB and bootstrap SQL |
| `e2e-test/` | Playwright smoke tests |
| `infrastructure/` | k3s test environment templates |

## Working Principles

1. Inspect the root structure first, then move into the target directory.
2. Treat `backend`, `frontend`, `database`, and `e2e-test` as independent projects.
3. When the API changes, also review `frontend/src/api/` and `e2e-test/tests/`.
4. When the test environment changes, update `infrastructure/k3s/helm/example-stack` and `infrastructure/k3s/scripts` together.

## Common Commands

```bash
make help
make db-up
make backend-run
make frontend-dev
make e2e-test
make helm-template
```

## Goal

Keep the skeleton minimal and readable instead of copying a full production workspace, while preserving visible dependencies and operational touchpoints.
