# Example Workspace

This is a simplified multi-project workspace inspired by the structure of `upbox-workspace`.

- `backend/`: Kotlin + Spring Boot API
- `frontend/`: Vue 3 + Vite web app
- `database/`: Local MariaDB setup and bootstrap schema
- `e2e-test/`: Playwright smoke tests
- `infrastructure/`: k3s test environment Helm chart, Dockerfiles, and ops scripts
- `docs/`: PRD and working documentation

This example is a skeleton meant to demonstrate how multiple repositories can be managed within a single workspace.
In a real project, each directory can be split into an independent Git repository or submodule.

## Objective

The main objective of this workspace is docs-first product development.

The idea is simple:

- write a Product Requirements Document in `docs/prd/`
- use that PRD as the source of truth for the feature
- generate or implement the related changes in `backend`, `frontend`, and `e2e-test`

This means the starting point for a new feature is not code. The starting point is a clear product document that explains what should happen, what is out of scope, and how the result should be validated.

If you are acting as the product side of the workflow, your job is to write the PRD. You do not begin by editing application code. You describe the feature well enough that the implementation and tests can be created from the document.

## How To Make A Feature

1. Create a new PRD file under `docs/prd/`, for example `docs/prd/user-profile.md`.
2. Describe the feature in product terms first: background, user problem, goals, and non-goals.
3. Define the expected backend behavior: endpoints, request and response shape, validation rules, and database impact if needed.
4. Define the expected frontend behavior: screens, states, empty/error/loading cases, and the API data it needs.
5. Define the expected `e2e-test` coverage: the main user flow, important API checks, and acceptance criteria.
6. Mark anything intentionally out of scope so the implementation stays focused.
7. Use the PRD as the handoff document for building the feature across `backend`, `frontend`, and `e2e-test`.

In short: this workspace exists so that one good PRD in `docs/` can drive one complete feature across multiple projects.

## Quick Start

```bash
cd ~/git/side-project/example-workspace

# 1) database
make db-up

# 2) backend
make backend-run

# 3) frontend
cd frontend
corepack pnpm install
corepack pnpm dev

# 4) e2e smoke
cd ../e2e-test
corepack pnpm install
corepack pnpm test
```

## Directory Map

| Path | Purpose |
|------|---------|
| `docs/prd/` | Requirement documents |
| `backend/src/main/` | API server |
| `frontend/src/` | User-facing web app |
| `database/dockerized/` | Local database runtime |
| `e2e-test/tests/` | UI and API smoke tests |
| `infrastructure/k3s/helm/example-stack/` | Helm chart for test environments |
| `infrastructure/k3s/scripts/` | PR environment create/delete scripts |

## Workspace Commands

```bash
make help
make db-up
make backend-run
make backend-logs
make backend-test
make frontend-dev
make e2e-test
make k3d-up
make helm-template
make helm-deploy-local
make helm-smoke-local
```

## Local k3d Validation

This workspace has been validated on an Apple Silicon Mac with Docker Desktop by running k3s through `k3d`.

```bash
# 1) create/switch the local cluster
make k3d-up

# 2) build/import local images and deploy the Helm release
make helm-deploy-local

# 3) check rollout status and probe ingress
make helm-smoke-local

# frontend + API through the k3d load balancer
open http://127.0.0.1:8088
curl -H "Host: example-workspace.local" http://127.0.0.1:8088/api/health
```

## Notes

- `backend`, `frontend`, and `e2e-test` are intentionally separated to mirror a real service workspace.
- The backend now runs against the MariaDB project by default and can be started either with Docker Compose or `./gradlew bootRun`.
- The backend targets Java 21; the Docker path avoids needing a host Gradle install and the `backend-test` target also runs inside Docker.
- `infrastructure/k3s` demonstrates how a dedicated test environment can exist separately from local Docker-based development, and the local `k3d` path has been verified end-to-end.
- This skeleton keeps CI, deployment, and secrets handling intentionally minimal because it is designed as a portfolio-ready example.
