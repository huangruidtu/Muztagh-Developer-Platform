#!/usr/bin/env bash

set -euo pipefail

version="1.19.1"
install_dir="${RUNNER_TEMP:-/tmp}/muztagh-kyverno"
archive="${RUNNER_TEMP:-/tmp}/kyverno-cli-linux-x86_64.tar.gz"
mkdir -p "$install_dir"

curl --fail --location --silent --show-error \
  --proto '=https' --tlsv1.2 \
  --output "$archive" \
  "https://github.com/kyverno/kyverno/releases/download/v${version}/kyverno-cli_v${version}_linux_x86_64.tar.gz"
printf '%s  %s\n' \
  "b38228f367fc0fdc2b08f4c83ea50ac5f16c60ff8d62d76a66157c33c47b70ae" \
  "$archive" | sha256sum --check --status
tar --extract --gzip --file "$archive" --directory "$install_dir" kyverno
chmod 0755 "$install_dir/kyverno"

if [[ -n "${GITHUB_PATH:-}" ]]; then
  printf '%s\n' "$install_dir" >> "$GITHUB_PATH"
else
  printf 'Add %s to PATH before running Kyverno.\n' "$install_dir"
fi
