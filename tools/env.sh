#!/usr/bin/env bash
# tools/env.sh - environment defaults for AutoKILN builds
# Edit this file OR override via exported env vars.

: "${FQBN:=rp2040:rp2040:rpipico2w}"
: "${SKETCH:=src/AutoKILN/AutoKILN.ino}"
: "${BUILD_DIR:=build}"
: "${PORT:=}"
: "${BAUD:=115200}"
