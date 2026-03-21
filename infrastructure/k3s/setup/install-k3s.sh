#!/usr/bin/env bash
set -euo pipefail

echo "Installing k3s..."
curl -sfL https://get.k3s.io | sh -
echo "k3s installation completed"
