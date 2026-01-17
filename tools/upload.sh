#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ENV_FILE:-$ROOT_DIR/tools/env.pico.sh}"
source "$ENV_FILE"


detect_port() {
  for p in /dev/ttyACM* /dev/ttyUSB*; do
    if [ -c "$p" ]; then echo "$p"; return 0; fi
  done
  return 1
}

if [ -z "${PORT}" ]; then
  PORT="$(detect_port || true)"
fi

if [ -z "${PORT}" ]; then
  echo "[upload] ERROR: No serial PORT set and none auto-detected."
  echo "         Set PORT in tools/env.sh or export PORT=/dev/ttyACM0"
  exit 1
fi

echo "[upload] FQBN=$FQBN"
echo "[upload] SKETCH=$SKETCH"
echo "[upload] PORT=$PORT"
arduino-cli upload --fqbn "$FQBN" -p "$PORT" "$ROOT_DIR/$SKETCH"
