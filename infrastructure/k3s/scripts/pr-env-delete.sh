#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${1:-example-pr-101}"

echo "Deleting namespace: ${NAMESPACE}"
helm uninstall "${NAMESPACE}" --namespace "${NAMESPACE}" || true
kubectl delete namespace "${NAMESPACE}" --ignore-not-found=true
