#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=./lib/preview-env.sh
source "${SCRIPT_DIR}/lib/preview-env.sh"

PREVIEW_ID="$(preview_resolve_id "${1:-}")"
NAMESPACE="$(preview_namespace "${PREVIEW_ID}")"
RELEASE="$(preview_release "${NAMESPACE}")"

echo "Deleting preview release: ${RELEASE}"
echo "Deleting namespace: ${NAMESPACE}"
helm uninstall "${RELEASE}" --namespace "${NAMESPACE}" || true
kubectl delete namespace "${NAMESPACE}" --ignore-not-found=true
