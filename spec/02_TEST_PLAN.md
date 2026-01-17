# AutoKILN — Acceptance Test Plan (mk2 starter)
Version: 0.1  
Date: 2026-01-15

Each Acceptance Test (AT) references Functional Requirements (FR) in `spec/00_FSD_KILN.md`.

---

## AT-001 Boot safety
**Covers:** FR-001, FR-010  
**Setup:** Pico connected over USB. SSR control pin connected to LED or test load.  
**Steps:**
1. Power cycle the Pico.
2. Watch serial output.
3. Observe SSR/LED output line.
**Expected:**
- SSR line goes OFF immediately at boot.
- Boot banner printed within ~2 seconds.

---

## AT-002 IDLE never heats
**Covers:** FR-002  
**Steps:**
1. Boot to IDLE.
2. Wait 30 seconds.
**Expected:**
- SSR output stays OFF.
- Heartbeat continues.

---

## AT-010 CSV format stable
**Covers:** FR-012, FR-013  
**Steps:**
1. Let system run in IDLE for > 20 seconds.
2. Capture logs.
**Expected:**
- Consistent column count per row.
- Columns include: timestamp_ms, state, temp_C, rh_pct, setpoint_C, duty_pct, ssr_on, fault_code.

---

## AT-020 Sensor failure triggers fault
**Covers:** FR-020, FR-021, FR-042, F001  
**Steps:**
1. Boot normally.
2. Disconnect SHT31 (or simulate failed reads in code).
3. Wait until consecutive failures exceed SENSOR_FAIL_COUNT.
**Expected:**
- Transition to FAULT.
- Heater OFF.
- Fault code F001 logged.

---

## AT-030 Over-temp triggers fault
**Covers:** FR-041, FR-042, F002  
**Steps:**
1. Set MAX_TEMP_C low temporarily (e.g., 25°C).
2. `start`
3. Let reading exceed MAX_TEMP_C for > OVER_TEMP_S.
**Expected:**
- Transition to FAULT.
- Heater OFF.
- Fault code F002 logged.

---

## AT-050 Commands work
**Covers:** FR-050  
**Steps:**
1. Send: `status`
2. Send: `set 40`
3. Send: `start`
4. Send: `stop`
**Expected:**
- Commands acknowledged.
- State transitions correct.
