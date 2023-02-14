#!/usr/bin/env bash

set -euo pipefail

KUSTOMIZE_VERSION=4.5.3
KUSTOMIZE_REPO_COMMIT=d2e59002aeb1faa724c6fa6e8218df2ad12631f8
KUSTOMIZE_INSTALL_SCRIPT_URL="https://raw.githubusercontent.com/kubernetes-sigs/kustomize/$KUSTOMIZE_REPO_COMMIT/hack/install_kustomize.sh"

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ALL_YAML="$SCRIPT_DIR/_all.yaml"
KUSTOMIZE_INSTALL_DIR="$(mktemp -d)"

on_exit()
{
  test -e "$ALL_YAML" && rm "$ALL_YAML"
}

trap on_exit EXIT

curl -s "$KUSTOMIZE_INSTALL_SCRIPT_URL" | bash /dev/stdin "$KUSTOMIZE_VERSION" "$KUSTOMIZE_INSTALL_DIR" > /dev/null

cd "$SCRIPT_DIR"

cat <&0 > "$ALL_YAML"

"$KUSTOMIZE_INSTALL_DIR/kustomize" build --reorder none .