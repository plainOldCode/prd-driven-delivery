# E2E Test

This directory contains Playwright smoke tests for the example workspace.

## Structure

- `tests/ui/`: frontend rendering checks
- `tests/smoke/`: API smoke tests

## Run

```bash
cd e2e-test
pnpm install
pnpm test
```

Environment variables:

- `E2E_FRONTEND_BASE_URL` default: `http://127.0.0.1:5173`
- `E2E_API_BASE_URL` default: `http://127.0.0.1:8080`
