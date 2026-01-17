#!/usr/bin/env bash
: "${TARGET:=esp32}"
: "${FQBN:=esp32:esp32:esp32doit-devkit-v1}"
: "${SKETCH:=src/AutoKILN_HMI/AutoKILN_HMI.ino}"
: "${BUILD_DIR:=build/esp32}"
: "${PORT:= /dev/ttyUSB0}"
: "${BAUD:=115200}"
