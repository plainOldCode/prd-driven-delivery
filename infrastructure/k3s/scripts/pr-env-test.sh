#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${1:-example-pr-101}"

echo "Inspecting namespace: ${NAMESPACE}"
kubectl get all -n "${NAMESPACE}"
