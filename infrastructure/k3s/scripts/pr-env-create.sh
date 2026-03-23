#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHART_DIR="${SCRIPT_DIR}/../helm/example-stack"

# shellcheck source=./lib/preview-env.sh
source "${SCRIPT_DIR}/lib/preview-env.sh"

PREVIEW_ID="$(preview_resolve_id "${1:-}")"
SOURCE_KIND="$(preview_source_kind "${1:-}")"
SOURCE_REF="$(preview_source_ref "${1:-}")"
NAMESPACE="$(preview_namespace "${PREVIEW_ID}")"
RELEASE="$(preview_release "${NAMESPACE}")"
HOST="$(preview_host "${PREVIEW_ID}")"
URL="$(preview_url "${HOST}")"

echo "Creating preview release: ${RELEASE}"
echo "Preview namespace: ${NAMESPACE}"
echo "Preview host: ${HOST}"

HELM_ARGS=(
  upgrade
  --install
  "${RELEASE}"
  "${CHART_DIR}"
  --namespace
  "${NAMESPACE}"
  --create-namespace
  --set-string
  "ingress.host=${HOST}"
  --set-string
  "ingress.className=${PREVIEW_INGRESS_CLASS:-traefik}"
)

if [[ -n "${PREVIEW_BACKEND_IMAGE:-}" ]]; then
  HELM_ARGS+=(--set-string "backend.image=${PREVIEW_BACKEND_IMAGE}")
fi

if [[ -n "${PREVIEW_FRONTEND_IMAGE:-}" ]]; then
  HELM_ARGS+=(--set-string "frontend.image=${PREVIEW_FRONTEND_IMAGE}")
fi

if [[ -n "${PREVIEW_DATABASE_IMAGE:-}" ]]; then
  HELM_ARGS+=(--set-string "database.image=${PREVIEW_DATABASE_IMAGE}")
fi

if [[ -n "${PREVIEW_BACKEND_IMAGE_PULL_POLICY:-}" ]]; then
  HELM_ARGS+=(--set-string "backend.imagePullPolicy=${PREVIEW_BACKEND_IMAGE_PULL_POLICY}")
fi

if [[ -n "${PREVIEW_FRONTEND_IMAGE_PULL_POLICY:-}" ]]; then
  HELM_ARGS+=(--set-string "frontend.imagePullPolicy=${PREVIEW_FRONTEND_IMAGE_PULL_POLICY}")
fi

if [[ -n "${PREVIEW_DATABASE_IMAGE_PULL_POLICY:-}" ]]; then
  HELM_ARGS+=(--set-string "database.imagePullPolicy=${PREVIEW_DATABASE_IMAGE_PULL_POLICY}")
fi

if [[ -n "${PREVIEW_NGINX_IMAGE_PULL_POLICY:-}" ]]; then
  HELM_ARGS+=(--set-string "nginx.imagePullPolicy=${PREVIEW_NGINX_IMAGE_PULL_POLICY}")
fi

if [[ -n "${PREVIEW_IMAGE_PULL_SECRET:-}" ]]; then
  HELM_ARGS+=(--set-string "imagePullSecrets[0].name=${PREVIEW_IMAGE_PULL_SECRET}")
fi

helm "${HELM_ARGS[@]}"

kubectl label namespace "${NAMESPACE}" \
  "prd-driven-delivery.io/preview=true" \
  "prd-driven-delivery.io/source=${SOURCE_KIND}" \
  --overwrite

kubectl annotate namespace "${NAMESPACE}" \
  "prd-driven-delivery.io/preview-id=${PREVIEW_ID}" \
  "prd-driven-delivery.io/source-ref=${SOURCE_REF}" \
  "prd-driven-delivery.io/release=${RELEASE}" \
  "prd-driven-delivery.io/host=${HOST}" \
  "prd-driven-delivery.io/url=${URL}" \
  --overwrite

echo "Preview URL: ${URL}"

preview_write_standard_outputs "${PREVIEW_ID}" "${NAMESPACE}" "${RELEASE}" "${HOST}" "${URL}"
