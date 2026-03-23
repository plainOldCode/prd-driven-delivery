#!/usr/bin/env bash

preview_trim_name() {
  printf '%s' "$1" | cut -c1-63 | sed 's/-$//'
}

preview_slugify() {
  local value
  value="$(printf '%s' "${1:-}" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g; s/-\{2,\}/-/g; s/^-//; s/-$//')"
  if [[ -z "${value}" ]]; then
    value="preview"
  fi
  printf '%s' "${value}" | cut -c1-40 | sed 's/-$//'
}

preview_resolve_id() {
  local explicit_key="${1:-}"

  if [[ -n "${PREVIEW_PR_NUMBER:-}" ]]; then
    printf 'pr-%s' "${PREVIEW_PR_NUMBER}"
    return
  fi

  if [[ -n "${PREVIEW_BRANCH_NAME:-}" ]]; then
    preview_slugify "${PREVIEW_BRANCH_NAME}"
    return
  fi

  if [[ -n "${explicit_key}" ]]; then
    preview_slugify "${explicit_key}"
    return
  fi

  printf 'preview'
}

preview_source_kind() {
  local explicit_key="${1:-}"

  if [[ -n "${PREVIEW_PR_NUMBER:-}" ]]; then
    printf 'pull-request'
    return
  fi

  if [[ -n "${PREVIEW_BRANCH_NAME:-}" ]]; then
    printf 'branch'
    return
  fi

  if [[ -n "${explicit_key}" ]]; then
    printf 'manual'
    return
  fi

  printf 'manual'
}

preview_source_ref() {
  local explicit_key="${1:-}"

  if [[ -n "${PREVIEW_PR_NUMBER:-}" ]]; then
    printf '%s' "${PREVIEW_PR_NUMBER}"
    return
  fi

  if [[ -n "${PREVIEW_BRANCH_NAME:-}" ]]; then
    printf '%s' "${PREVIEW_BRANCH_NAME}"
    return
  fi

  if [[ -n "${explicit_key}" ]]; then
    printf '%s' "${explicit_key}"
    return
  fi

  printf 'preview'
}

preview_namespace() {
  local preview_id="$1"
  local prefix="${PREVIEW_NAMESPACE_PREFIX:-example-preview}"
  preview_trim_name "${PREVIEW_NAMESPACE:-${prefix}-${preview_id}}"
}

preview_release() {
  local namespace="$1"
  preview_trim_name "${PREVIEW_RELEASE:-${namespace}}"
}

preview_host() {
  local preview_id="$1"

  if [[ -n "${PREVIEW_HOST:-}" ]]; then
    printf '%s' "${PREVIEW_HOST}"
    return
  fi

  printf '%s.%s' "${preview_id}" "${PREVIEW_BASE_DOMAIN:-previews.prd-driven-delivery.local}"
}

preview_url() {
  local host="$1"
  local scheme="${PREVIEW_URL_SCHEME:-https}"
  local port="${PREVIEW_PUBLIC_PORT:-}"
  local default_port=""

  if [[ "${scheme}" == "http" ]]; then
    default_port="80"
  elif [[ "${scheme}" == "https" ]]; then
    default_port="443"
  fi

  if [[ -n "${port}" && "${port}" != "${default_port}" ]]; then
    printf '%s://%s:%s' "${scheme}" "${host}" "${port}"
    return
  fi

  printf '%s://%s' "${scheme}" "${host}"
}

preview_write_output() {
  local key="$1"
  local value="$2"

  if [[ -n "${PREVIEW_OUTPUT_FILE:-}" ]]; then
    printf '%s=%s\n' "${key}" "${value}" >> "${PREVIEW_OUTPUT_FILE}"
  fi
}

preview_write_standard_outputs() {
  local preview_id="$1"
  local namespace="$2"
  local release="$3"
  local host="$4"
  local url="$5"

  preview_write_output preview_id "${preview_id}"
  preview_write_output preview_namespace "${namespace}"
  preview_write_output preview_release "${release}"
  preview_write_output preview_host "${host}"
  preview_write_output preview_url "${url}"
}
