# AutoKILN — Pico ↔ ESP32 Communication Protocol

Version: 0.1 (initial draft)  
Date: 2026-01-15  
Applies to: AutoKILN_mk2 (Pico 2W controller + ESP32-S3 HMI)

This document defines the **wire contract** between:

- **Pico (Controller)** — source of truth for safety + control
- **ESP32 (HMI)** — UI + user commands

> The FSD (`spec/00_FSD_KILN.md`) defines **what must happen**.  
> This file defines **how messages are exchanged**.

---

## 1. Goals and non-goals

### 1.1 Goals

- Reliable exchange of **status**, **commands**, and **fault events**
- Detect corrupted frames (CRC)
- Avoid lockups: no blocking waits required
- Maintain **safety** if comms are lost (policy defined here + referenced by FSD)

### 1.2 Non-goals (for v0.1)

- Encryption/authentication
- File transfer (assets)
- Remote/cloud communication

---

## 2. Physical / link layer

### 2.1 Transport

- Link: **UART over RS-485** (half-duplex)
- Default baud: **115200 8N1**
- Wiring: A/B differential pair + GND reference
- Termination: 120Ω at each end if cable length requires (recommend if > ~1m or noisy environment)
- Direction control: RS-485 transceiver **DE/RE** pins controlled by MCU GPIO

### 2.2 Roles

- Pico is **authoritative** for:
  - heater enable/disable
  - fault detection and latching
  - state machine
- ESP32 is **authoritative** for:
  - user input
  - display content

---

## 3. Safety policy on comms loss

### 3.1 Timeout

- **COMM_TIMEOUT_MS = 3000** (default)

### 3.2 Policy (choose ONE as project standard)

**Policy A (recommended): Continue running safely**

- If link is lost while RUNNING, Pico **continues** control but:
  - raises `COMM_LOST` warning
  - disables setpoint/recipe changes until link returns
- Heater remains under Pico control.

**Policy B (more conservative): Pause heating**

- If link is lost while RUNNING, Pico transitions to PAUSED/IDLE and heater OFF.

**Default for v0.1:** Policy A.

---

## 4. Versioning and compatibility

- **PROTOCOL_VERSION = 1**
- Each STATUS message includes protocol version.
- If versions mismatch:
  - HMI displays “PROTOCOL MISMATCH”
  - Pico continues in safe operation and may ignore commands.

---

## 5. Frame format (binary)

### 5.1 Overview

All messages are framed to allow resync and corruption detection.

**Endianness:** little-endian for multi-byte integers.

```
+--------+--------+--------+--------+--------+--------+-----------+--------+--------+
|  SOF1  |  SOF2  |  VER   |  TYPE  | FLAGS  |  LEN   | SEQ (u16) | PAYLOAD| CRC16 |
+--------+--------+--------+--------+--------+--------+-----------+--------+--------+
  0xAA     0x55     u8       u8       u8       u8        u16        LEN B   u16
```

- **SOF1/SOF2**: constant 0xAA 0x55
- **VER**: protocol version (u8), currently 1
- **TYPE**: message type (u8)
- **FLAGS**: bitfield (u8)
- **LEN**: payload length in bytes (u8), 0..255
- **SEQ**: sequence number (u16), increments per message per sender
- **PAYLOAD**: message-specific bytes
- **CRC16**: CRC of bytes from VER through end of PAYLOAD (not including SOF)

### 5.2 CRC

- Algorithm: **CRC-16/CCITT-FALSE**
  - poly 0x1021
  - init 0xFFFF
  - xorout 0x0000
  - reflect in/out: false
- CRC is appended little-endian (LSB first).

### 5.3 FLAGS bits (v0.1)

- bit0: **ACK_REQ** (sender requests an ACK)
- bit1: **ACK** (this frame is an ACK)
- bit2: **ERROR** (negative ack / error report)
- bit3..7: reserved (0)

---

## 6. Message types

### 6.1 Type list

Pico → HMI:

- `0x10` **STATUS**
- `0x11` **FAULT_EVENT**
- `0x12` **LOG_LINE** (optional; text chunk)

HMI → Pico:

- `0x20` **CMD**
- `0x21` **ACK** (generic ACK/NAK)

### 6.2 Common field conventions

To keep payloads compact and deterministic:

- Temperatures are **centi-degrees C** (°C × 100) stored as **i16**
  - example: 23.45°C → 2345
- Humidity is **centi-%RH** (% × 100) stored as **u16**
  - example: 55.12% → 5512
- Duty is **percent × 100** stored as **u16**
  - example: 12.34% → 1234
- Millis timestamps are **u32** (from Pico `millis()`)

---

## 7. Payload definitions

## 7.1 STATUS (0x10) Pico → HMI

Sent periodically (e.g., 2–5 Hz) while system is powered.

Payload layout:

```
u32  uptime_ms
u8   controller_state
u8   fault_active (0/1)
u8   fault_code_major   (e.g., 1 for F001)
u8   fault_code_minor   (e.g., 0 for now)
i16  temp_c_x100
u16  rh_x100
i16  setpoint_c_x100
u16  duty_x100
u8   ssr_on (0/1)
u8   protocol_version   (duplicate for UI sanity)
```

Controller states (v0.1):

- 0 = BOOT
- 1 = IDLE
- 2 = RUN
- 3 = PAUSED
- 4 = FAULT

Fault code example mapping:

- F001 SENSOR_FAIL → major=1
- F002 OVER_TEMP → major=2

---

## 7.2 FAULT_EVENT (0x11) Pico → HMI

Sent immediately when a fault is raised/cleared. Usually set ACK_REQ.

Payload:

```
u32 uptime_ms
u8  event_kind     (1=RAISED, 2=CLEARED)
u8  fault_major    (1..255)
u8  fault_minor    (0)
u8  severity       (1=WARNING,2=ALARM,3=CRITICAL)
```

---

## 7.3 LOG_LINE (0x12) Pico → HMI (optional)

Used if you want the HMI to display raw logs.
Payload:

- UTF-8 bytes, no null terminator, max 255 bytes.
- Can be chunked across multiple frames.

---

## 7.4 CMD (0x20) HMI → Pico

A single command per message.

Payload:

```
u8  cmd_id
u8  reserved0
u16 reserved1
i16 param_i16_0
i16 param_i16_1
u32 param_u32_0
```

Command IDs:

- 1 = START
- 2 = STOP
- 3 = PAUSE
- 4 = RESUME
- 5 = SET_SETPOINT (param_i16_0 = setpoint_c_x100)
- 6 = ACK_FAULT   (param_i16_0 = fault_major)
- 7 = SET_TIME    (param_u32_0 = unix_time_seconds) *(optional, later with RTC)*

Rules:

- Pico should ACK all valid commands (ACK frame or ACK flag) when ACK_REQ is set.
- Pico ignores commands that violate safety (e.g., START while in FAULT).

---

## 7.5 ACK (0x21) Either direction

Used as response when FLAGS.ACK is set OR as explicit ACK frame.

Payload:

```
u16 ack_seq        (sequence number being acknowledged)
u8  status_code    (0=OK, 1=BAD_CRC, 2=BAD_LEN, 3=UNKNOWN_TYPE, 4=INVALID_CMD, 5=BUSY)
u8  detail         (optional extra info)
```

---

## 8. Timing and rates (recommended defaults)

- STATUS rate:
  - IDLE: 2 Hz
  - RUN: 5 Hz
- FAULT_EVENT: immediate
- ACK timeout for command retries (HMI side): 200 ms initial, retry up to 3 times
- COMM_TIMEOUT_MS: 3000 ms (loss detection)

---

## 9. Error handling and resynchronization

Receiver must:

1. Scan for SOF1/SOF2 (0xAA,0x55)
2. Read fixed header (VER..SEQ)
3. Validate LEN (0..255)
4. Read PAYLOAD + CRC16
5. Validate CRC16
6. If invalid:
   - discard one byte and rescan OR discard frame and resync at next SOF
   - optionally emit NAK (ACK with ERROR flag) if link is stable

---

## 10. Worked examples (conceptual)

### 10.1 SET_SETPOINT to 40.00°C

- cmd_id = 5
- param_i16_0 = 4000

HMI sends CMD with ACK_REQ.
Pico responds with ACK status_code=0 (OK) and updates setpoint.

### 10.2 Status line shows SSR duty and state

Pico sends STATUS at 5 Hz during RUN with:

- duty_x100 = 2500 → 25.00%
- ssr_on toggles according to SSR window logic

---

## 11. Planned extensions (v0.2+)

- Recipe/stage transfer (chunked messages)
- Bitmask of active faults instead of single fault
- Current sensor data (A × 100)
- Weight data (g)
- Door state + debounced transitions
- Time sync and RTC health reporting

---

## Appendix A — Constants summary

- SOF: 0xAA 0x55
- PROTOCOL_VERSION: 1
- CRC: CRC-16/CCITT-FALSE
- COMM_TIMEOUT_MS: 3000