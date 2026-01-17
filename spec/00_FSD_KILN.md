# Kiln Controller — Functional Specification Document (FSD)
Version: 0.1 (mk2 starter)  
Date: 2026-01-15

This document defines **what the system must do**.  
Implementation details live in code; requirements live here.

---

## 1. Purpose and scope

### 1.1 Purpose
Provide a safe, reliable controller for a small wood kiln that:
- runs drying cycles (recipes / stages)
- drives a heater through an SSR (time-proportional)
- monitors temperature/humidity (SHT31)
- logs data and faults
- supports clean incremental development and testability

### 1.2 MVP scope (mk2 software-first)
MVP = a controllable loop that is safe, testable, and logged:
- state machine: BOOT / IDLE / RUN / FAULT
- temp/RH read (SHT31)
- heater SSR output (digital pin) with time window duty control
- serial command interface (temporary “fake HMI”)
- CSV logging to serial + optional file later
- basic faults: sensor fail, over-temp

---

## 2. Definitions
- **State**: Controller operating mode (BOOT/IDLE/RUN/FAULT).
- **Setpoint**: Target temperature in °C.
- **Duty**: Heater command percentage 0..100.
- **SSR Window**: Fixed time window where SSR is ON for duty% of the window.
- **Fault**: Abnormal condition. Critical faults force heater OFF.

---

## 3. System overview
- Controller MCU: Pico 2W
- Sensors: SHT31 temp/RH
- Output: SSR control pin (heater ON/OFF)
- Interface: Serial (USB) command + status

### 3.1 Hardware interface

#### Pin map (Pico 2W)

- SSR control output: GPIO __ (active: HIGH/LOW = __ )
- <!--(Optional) Status LED: GPIO __-->
- <!--(Optional) Door switch: GPIO __ (pull-up/down: __)-->
- <!--(Optional) Scale: GPIO __ (pull-up/down: __)-->
- <!--(Optional) UART_PINS: GPIO __ (pull-up/down: __)-->

#### Electrical / safety notes
- SSR output shall default OFF on boot (FR-001).
- SSR output polarity shall be defined (active-high vs active-low).

---

## 4. State machine

### 4.1 States
- **BOOT**: init; set outputs safe; print banner; go to IDLE
- **IDLE**: heater OFF; accept commands; show sensor readings
- **RUN**: heater control active; log; monitor faults
- **FAULT**: heater OFF; latch fault; require reset/clear action

### 4.2 Transitions
- BOOT → IDLE (if init ok)
- IDLE → RUN (command START)
- RUN → IDLE (command STOP)
- RUN → FAULT (critical fault)
- FAULT → IDLE (command RESET after fault cleared)

---

## 5. Functional requirements (FR)

### 5.1 Safety
- **FR-001** On boot, SSR output shall be set **OFF** before any other actions.
- **FR-002** In IDLE, SSR output shall remain **OFF**.
- **FR-003** In FAULT, SSR output shall be forced **OFF** immediately and remain OFF.

### 5.2 Telemetry / logging
- **FR-010** The system shall print a boot banner with firmware version.
- **FR-011** The system shall emit a 1 Hz heartbeat line (state + key readings).
- **FR-012** The system shall output CSV logs every `LOG_PERIOD_S` seconds (default 10s).
- **FR-013** CSV shall include: timestamp_ms, state, temp_C, rh_pct, setpoint_C, duty_pct, ssr_on, fault_code.

### 5.3 Sensor
- **FR-020** The controller shall read SHT31 at 1 Hz (configurable).
- **FR-021** If SHT31 read fails `SENSOR_FAIL_COUNT` consecutive times (default 5), trigger SENSOR_FAIL fault.

### 5.4 Control
- **FR-030** In RUN, controller shall compute `duty_pct` from (setpoint_C - temp_C).
- **FR-031** Controller shall apply duty via SSR Window `SSR_WINDOW_MS` (default 3000 ms) without blocking delays.
- **FR-032** Duty shall be clamped to 0..100%.

### 5.5 Faults
- **FR-040** Fault codes shall be stable and documented in this file.
- **FR-041** **OVER_TEMP** triggers if `temp_C > MAX_TEMP_C` for `OVER_TEMP_S` seconds (defaults: 80°C, 5s).
- **FR-042** Any critical fault shall transition RUN → FAULT and log the event immediately.

### 5.6 Commands (temporary serial “fake HMI”)
- **FR-050** The system shall accept simple commands over serial:
  - `start` → IDLE→RUN
  - `stop`  → RUN→IDLE
  - `set <tempC>` → setpoint change (IDLE or RUN)
  - `status` → print one status line
  - `fault` → force a fault (test helper)
  - `reset` → clear fault and go to IDLE (only in FAULT)

---

## 6. Fault table
| Code | Name         | Severity  | Latched | Action |
|------|--------------|-----------|---------|--------|
| F001 | SENSOR_FAIL  | CRITICAL  | Yes     | Heater OFF, FAULT |
| F002 | OVER_TEMP    | CRITICAL  | Yes     | Heater OFF, FAULT |

---

## 7. Configuration defaults
- `BAUD`: 115200
- `LOG_PERIOD_S`: 10
- `SENSOR_PERIOD_MS`: 1000
- `SSR_WINDOW_MS`: 3000
- `MAX_TEMP_C`: 80.0
- `OVER_TEMP_S`: 5
- `SENSOR_FAIL_COUNT`: 5
