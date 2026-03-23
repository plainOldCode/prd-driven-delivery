# Local k3s Setup

## Purpose

This document outlines a simple flow for bringing up a test namespace for the example workspace on a local machine or a small server.

## Steps

1. Install k3s
2. Prepare a local or remote registry
3. Push the backend and frontend images
4. Deploy the Helm chart
5. Run the smoke tests

## Example

```bash
./setup/install-k3s.sh
./setup/install-registry.sh

helm upgrade --install example-dev ./helm/example-stack \
  --namespace example-dev \
  --create-namespace

kubectl get pods -n example-dev
```

## Local Preview Rehearsal

The same repo can rehearse a pull-request preview flow locally through `k3d`.

```bash
make pr-env-create-local PREVIEW_PR_NUMBER=204
make pr-env-test PREVIEW_PR_NUMBER=204
make pr-env-dashboard-open
make pr-env-delete PREVIEW_PR_NUMBER=204
```

This uses the same preview scripts as the GitHub Actions workflow, but exposes direct local URLs such as `http://pr-204.localhost:8088` and adds a local HTML dashboard for observing active previews.
