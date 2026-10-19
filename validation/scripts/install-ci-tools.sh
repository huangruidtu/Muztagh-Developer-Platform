#!/usr/bin/env bash

set -euo pipefail

install_dir="${RUNNER_TEMP:-/tmp}/muztagh-ci-tools"
download_dir="${RUNNER_TEMP:-/tmp}/muztagh-ci-downloads"
mkdir -p "$install_dir" "$download_dir"

download_and_verify() {
  local url="$1"
  local destination="$2"
  local checksum="$3"

  curl --fail --location --silent --show-error \
    --proto '=https' --tlsv1.2 \
    --output "$destination" "$url"
  printf '%s  %s\n' "$checksum" "$destination" | sha256sum --check --status
}

kubeconform_version="0.8.0"
kubeconform_archive="$download_dir/kubeconform-linux-amd64.tar.gz"
download_and_verify \
  "https://github.com/yannh/kubeconform/releases/download/v${kubeconform_version}/kubeconform-linux-amd64.tar.gz" \
  "$kubeconform_archive" \
  "9bc2bffbf71f261128533edaf912153948b7ff238f9a531ae6d34466ec287883"
tar --extract --gzip --file "$kubeconform_archive" --directory "$install_dir" kubeconform

actionlint_version="1.7.12"
actionlint_archive="$download_dir/actionlint-linux-amd64.tar.gz"
download_and_verify \
  "https://github.com/rhysd/actionlint/releases/download/v${actionlint_version}/actionlint_${actionlint_version}_linux_amd64.tar.gz" \
  "$actionlint_archive" \
  "8aca8db96f1b94770f1b0d72b6dddcb1ebb8123cb3712530b08cc387b349a3d8"
tar --extract --gzip --file "$actionlint_archive" --directory "$install_dir" actionlint

prometheus_version="3.15.0"
prometheus_archive="$download_dir/prometheus-linux-amd64.tar.gz"
download_and_verify \
  "https://github.com/prometheus/prometheus/releases/download/v${prometheus_version}/prometheus-${prometheus_version}.linux-amd64.tar.gz" \
  "$prometheus_archive" \
  "2a542df32eac02ee17b9d844fb2aa1de00dafa5476579ba8a3ba862e9d572ea0"
tar --extract --gzip --file "$prometheus_archive" --directory "$download_dir"
install -m 0755 \
  "$download_dir/prometheus-${prometheus_version}.linux-amd64/promtool" \
  "$install_dir/promtool"

python3 -m venv "$download_dir/yamllint"
"$download_dir/yamllint/bin/pip" install \
  --disable-pip-version-check \
  "yamllint==1.38.0"
ln -sf "$download_dir/yamllint/bin/yamllint" "$install_dir/yamllint"

if [[ -n "${GITHUB_PATH:-}" ]]; then
  printf '%s\n' "$install_dir" >> "$GITHUB_PATH"
else
  printf 'Add %s to PATH before running the installed tools.\n' "$install_dir"
fi
