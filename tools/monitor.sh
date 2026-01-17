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

# Auto-detect port if not provided
if [ -z "${PORT}" ]; then
  PORT="$(detect_port || true)"
fi

if [ -z "${PORT}" ]; then
  echo "[monitor] ERROR: No serial PORT set and none auto-detected."
  echo "          Set PORT in tools/env.sh or export PORT=/dev/ttyACM0"
  exit 1
fi

# Ensure serial log directory exists
SERIAL_DIR="$ROOT_DIR/logs/serial"
mkdir -p "$SERIAL_DIR"

# Allow caller to set LOG_FILE; otherwise create timestamped
if [ -z "${LOG_FILE:-}" ]; then
  TS="$(date +%Y%m%d_%H%M%S)"
  LOG_FILE="$SERIAL_DIR/serial_${TS}.log"
fi

echo "[monitor] PORT=$PORT BAUD=$BAUD"
echo "[monitor] LOG_FILE=$LOG_FILE"

# Choose monitor tool: minicom preferred, else screen
if command -v minicom >/dev/null 2>&1; then
  # -C captures to file
  exec minicom -D "$PORT" -b "$BAUD" -C "$LOG_FILE"
elif command -v screen >/dev/null 2>&1; then
  echo "[monitor] minicom not found; using screen."
  # -L enables logging, -Logfile selects file
  exec screen -L -Logfile "$LOG_FILE" "$PORT" "$BAUD"
else
  echo "[monitor] ERROR: install minicom or screen."
  echo "          sudo apt-get install -y minicom"
  exit 1
fi
