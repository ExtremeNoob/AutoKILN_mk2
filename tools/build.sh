#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ENV_FILE:-$ROOT_DIR/tools/env.pico.sh}"
source "$ENV_FILE"


mkdir -p "$ROOT_DIR/$BUILD_DIR"

echo "[build] FQBN=$FQBN"
echo "[build] SKETCH=$SKETCH"
arduino-cli compile --fqbn "$FQBN" --build-path "$ROOT_DIR/$BUILD_DIR" "$ROOT_DIR/$SKETCH"
