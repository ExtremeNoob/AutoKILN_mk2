# agents.md — AutoKILN_mk2 “Agent Contract” + Project Memory

This file is here so an AI coding agent (or future-you) has stable rules for working in this repo.

## 1) Project targets
- Controller: **Raspberry Pi Pico 2W** (Arduino-Pico core / RP2040)
- Later HMI: **ESP32-S3 7" Waveshare touch** (LVGL)
- Primary loop: **spec → code → build/upload → test → update spec**

## 2) Non-negotiable rules
1. **Spec is source of truth**
   - If behavior is unclear, update `spec/00_FSD_KILN.md` first (add/adjust FR/AT IDs).
2. **Small slices only**
   - One feature per commit. Each feature references FR/AT IDs.
3. **Safety first**
   - On boot and on fault: **heater SSR output must be OFF**.
4. **No long blocking delays** in the control loop
   - Use non-blocking timing (millis()).
5. **Never silently change log formats**
   - If a log field changes, bump a `LOG_VERSION` and update the spec.

## 3) Repo boundaries
- Allowed to edit:
  - `src/controller/**`, `spec/**`, `tools/**`, `README.md`, `.gitignore`
- Avoid editing:
  - vendor libraries under `refs/` unless explicitly requested.

## 4) Build/run commands (must use)
Use scripts under `tools/`:
- Build: `./tools/build.sh`
- Upload: `./tools/upload.sh`
- Monitor: `./tools/monitor.sh`
- All-in-one: `./tools/cycle.sh`

If a command fails, capture the error output and update the spec (or code) accordingly.

## 5) Current “known-good” defaults (edit as needed)
- BAUD: 115200
- Default port: `/dev/ttyACM0` (auto-detected if possible)
- Board FQBN (example): `rp2040:rp2040:rpipico`
  - Replace with your exact Pico 2W FQBN if different.

## 6) Workflow mantra
> If something fails: **spec first**, then patch code to match the spec.
