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

## Quick Start

```bash
cd ~/git/side-project/example-workspace

# 1) database
make db-up

# 2) backend
make backend-run

# 3) frontend
cd frontend
pnpm install
pnpm dev

# 4) e2e smoke
cd ../e2e-test
pnpm install
pnpm test
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
make helm-template
```

## Notes

- `backend`, `frontend`, and `e2e-test` are intentionally separated to mirror a real service workspace.
- The backend now runs against the MariaDB project by default and can be started either with Docker Compose or `./gradlew bootRun`.
- The backend targets Java 21; the Docker path avoids needing a host Gradle install and the `backend-test` target also runs inside Docker.
- `infrastructure/k3s` demonstrates how a dedicated test environment can exist separately from local Docker-based development.
- This skeleton keeps CI, deployment, and secrets handling intentionally minimal because it is designed as a portfolio-ready example.
