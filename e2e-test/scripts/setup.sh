#!/usr/bin/env bash
set -euo pipefail

pnpm install
pnpm exec playwright install --with-deps
