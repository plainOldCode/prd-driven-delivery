#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${1:-example-pr-101}"
RELEASE="${2:-${NAMESPACE}}"

echo "Waiting for core workloads in namespace: ${NAMESPACE}"
kubectl rollout status deployment/"${RELEASE}"-backend -n "${NAMESPACE}" --timeout=180s
kubectl rollout status deployment/"${RELEASE}"-frontend -n "${NAMESPACE}" --timeout=180s
kubectl rollout status deployment/"${RELEASE}"-nginx -n "${NAMESPACE}" --timeout=180s
kubectl wait --for=condition=ready pod/"${RELEASE}"-database-0 -n "${NAMESPACE}" --timeout=180s

echo "Inspecting namespace: ${NAMESPACE}"
kubectl get all,ingress -n "${NAMESPACE}"
