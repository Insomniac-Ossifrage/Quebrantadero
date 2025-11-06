#!/usr/bin/env bash
set -euo pipefail

LATEST_VERSION=$(curl -sL https://api.github.com/repos/actions/runner/releases/latest \
  | grep -oP '"tag_name":\s*"\K(.*)(?=")' \
  | sed 's/^v//'
)

echo "$LATEST_VERSION"

