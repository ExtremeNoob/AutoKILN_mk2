#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

usage() {
  cat <<'USAGE'
Usage: ./tools/cycle.sh [options]

Default (no options): build + upload.
Options:
  --build     Compile only
  --upload    Upload only
  --monitor   Open serial monitor after upload (with timestamped logging)
  --all       Build + upload + monitor
  --clean     Remove build directory
  -h, --help  Show help

Logs:
  Build log : logs/build.log
  Upload log: logs/upload.log
  Serial log: logs/serial/serial_YYYYMMDD_HHMMSS.log

Environment:
  Edit tools/env.sh or export:
    FQBN, SKETCH, BUILD_DIR, PORT, BAUD

Examples:
  ./tools/cycle.sh --all
  PORT=/dev/ttyACM0 ./tools/cycle.sh --all
USAGE
}

DO_BUILD=0; DO_UPLOAD=0; DO_MONITOR=0; DO_CLEAN=0

if [ $# -eq 0 ]; then
  DO_BUILD=1; DO_UPLOAD=1
else
  while [ $# -gt 0 ]; do
    case "$1" in
      --build) DO_BUILD=1 ;;
      --upload) DO_UPLOAD=1 ;;
      --monitor) DO_MONITOR=1 ;;
      --all) DO_BUILD=1; DO_UPLOAD=1; DO_MONITOR=1 ;;
      --clean) DO_CLEAN=1 ;;
      -h|--help) usage; exit 0 ;;
      *) echo "Unknown option: $1"; usage; exit 1 ;;
    esac
    shift
  done
fi

# Ensure logs dirs exist
mkdir -p "$ROOT_DIR/logs" "$ROOT_DIR/logs/serial"

BUILD_LOG="$ROOT_DIR/logs/build.log"
UPLOAD_LOG="$ROOT_DIR/logs/upload.log"

if [ "$DO_CLEAN" -eq 1 ]; then
  ENV_FILE="${ENV_FILE:-$ROOT_DIR/tools/env.pico.sh}"
	source "$ENV_FILE"

  echo "[clean] removing $ROOT_DIR/$BUILD_DIR"
  rm -rf "$ROOT_DIR/$BUILD_DIR"
fi

if [ "$DO_BUILD" -eq 1 ]; then
  echo "[cycle] build -> $BUILD_LOG"
  "$ROOT_DIR/tools/build.sh" 2>&1 | tee "$BUILD_LOG"
fi

if [ "$DO_UPLOAD" -eq 1 ]; then
  echo "[cycle] upload -> $UPLOAD_LOG"
  "$ROOT_DIR/tools/upload.sh" 2>&1 | tee "$UPLOAD_LOG"
fi

if [ "$DO_MONITOR" -eq 1 ]; then
  TS="$(date +%Y%m%d_%H%M%S)"
  export LOG_FILE="$ROOT_DIR/logs/serial/serial_${TS}.log"
  echo "[cycle] monitor -> $LOG_FILE"
  "$ROOT_DIR/tools/monitor.sh"
else
  echo "[hint] run: ./tools/monitor.sh  (or ./tools/cycle.sh --all)"
fi
