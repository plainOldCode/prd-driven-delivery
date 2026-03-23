#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=./lib/preview-env.sh
source "${SCRIPT_DIR}/lib/preview-env.sh"

PREVIEW_ID="$(preview_resolve_id "${1:-}")"
NAMESPACE="${2:-$(preview_namespace "${PREVIEW_ID}")}"
RELEASE="${3:-$(preview_release "${NAMESPACE}")}"
HOST="$(preview_host "${PREVIEW_ID}")"
URL="$(preview_url "${HOST}")"

echo "Waiting for core workloads in namespace: ${NAMESPACE}"
kubectl rollout status deployment/"${RELEASE}"-backend -n "${NAMESPACE}" --timeout=180s
kubectl rollout status deployment/"${RELEASE}"-frontend -n "${NAMESPACE}" --timeout=180s
kubectl rollout status deployment/"${RELEASE}"-nginx -n "${NAMESPACE}" --timeout=180s
kubectl wait --for=condition=ready pod/"${RELEASE}"-database-0 -n "${NAMESPACE}" --timeout=180s

echo "Inspecting namespace: ${NAMESPACE}"
kubectl get all,ingress -n "${NAMESPACE}"

if [[ "${PREVIEW_DIRECT_URL:-false}" == "true" ]]; then
  echo "Running direct smoke checks against ${URL}"
  curl --retry 20 --retry-delay 1 --retry-all-errors -sf "${URL}/api/health"
  printf '\n'
  curl --retry 20 --retry-delay 1 --retry-all-errors -sf "${URL}/api/tasks"
  printf '\n'
elif [[ -n "${PREVIEW_GATEWAY_URL:-}" ]]; then
  GATEWAY_URL="${PREVIEW_GATEWAY_URL%/}"
  echo "Running gateway smoke checks through ${GATEWAY_URL} with host header ${HOST}"
  curl --retry 20 --retry-delay 1 --retry-all-errors -sf -H "Host: ${HOST}" "${GATEWAY_URL}/api/health"
  printf '\n'
  curl --retry 20 --retry-delay 1 --retry-all-errors -sf -H "Host: ${HOST}" "${GATEWAY_URL}/api/tasks"
  printf '\n'
else
  echo "Skipping HTTP smoke checks. Set PREVIEW_GATEWAY_URL to probe the preview ingress directly."
fi
