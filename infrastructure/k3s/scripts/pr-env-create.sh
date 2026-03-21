#!/usr/bin/env bash
set -euo pipefail

PR_NUMBER="${1:-101}"
NAMESPACE="${2:-example-pr-${PR_NUMBER}}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHART_DIR="${SCRIPT_DIR}/../helm/example-stack"

echo "Creating namespace: ${NAMESPACE}"
helm upgrade --install "${NAMESPACE}" "${CHART_DIR}" \
  --namespace "${NAMESPACE}" \
  --create-namespace \
  --set ingress.host="${NAMESPACE}.local"
