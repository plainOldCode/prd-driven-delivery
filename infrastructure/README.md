# Infrastructure

This directory is a skeleton for the test environment infrastructure that lives alongside the application code.

## Included

- `k3s/dockerfiles/`: image build baselines for backend, frontend, nginx, and e2e
- `k3s/helm/example-stack/`: Helm chart for test environments
- `k3s/scripts/`: scripts for creating and deleting PR namespaces
- `k3s/setup/`: setup-oriented helper scripts
- `k3s/manifests/`: shared cluster manifest examples
