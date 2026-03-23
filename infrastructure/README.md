# Infrastructure

This directory is a skeleton for the test environment infrastructure that lives alongside the application code.

## Included

- `k3s/dockerfiles/`: image build baselines for backend, frontend, nginx, and e2e
- `k3s/helm/example-stack/`: Helm chart for test environments
- `k3s/scripts/`: scripts for creating, testing, and deleting branch or PR preview namespaces
- `k3s/setup/`: setup-oriented helper scripts
- `k3s/manifests/`: shared cluster manifest examples

The preview slice in this repo is intentionally review-oriented:

- derive a deterministic preview from a branch or pull request
- deploy that preview with the Helm chart
- validate workload readiness
- surface a URL that non-engineering reviewers can open with human eyes
- keep a lightweight dashboard for active preview observation
- allow approval-driven merge behavior when the repository explicitly enables it
