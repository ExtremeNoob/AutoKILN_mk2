#!/usr/bin/env bash
: "${TARGET:=pico}"
: "${FQBN:=rp2040:rp2040:rpipico2w}"
: "${SKETCH:=src/AutoKILN_Pico/AutoKILN_Pico.ino}"
: "${BUILD_DIR:=build/pico}"
: "${PORT:=/dev/ttyACM0}"
: "${BAUD:=115200}"
