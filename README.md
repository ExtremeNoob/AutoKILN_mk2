# AutoKILN_mk2

Spec-driven firmware development for a small wood kiln controller.

## What’s in this repo (starter)
- `spec/00_FSD_KILN.md` — functional spec (source of truth)
- `spec/02_TEST_PLAN.md` — acceptance tests / scenarios
- `agents.md` — “agent contract” (rules + project memory)
- `tools/` — one-command build / upload / monitor (`cycle.sh`)

## Build / Upload / Monitor (multi-target)

This repo supports multiple firmware targets (e.g., Pico controller now, ESP32 HMI later)
using the same scripts in `tools/` and per-target environment files.

### Targets (env files)
- Pico 2W controller: `tools/env.pico.sh`
- ESP32 HMI (later): `tools/env.esp32.sh`

### How to run (recommended)
Select a target by setting `ENV_FILE`:

#### Pico (build + upload)
```bash
cd /home/admin/Arduino/AutoKILN_mk2
ENV_FILE=tools/env.pico.sh ./tools/cycle.sh
```

#### Pico (build + upload + monitor + serial logging)

```bash
cd /home/admin/Arduino/AutoKILN_mk2
ENV_FILE=tools/env.pico.sh ./tools/cycle.sh --all
```

#### ESP32 (build only)

```bash
cd /home/admin/Arduino/AutoKILN_mk2
ENV_FILE=tools/env.esp32.sh ./tools/cycle.sh --build
```



## Codex Example Prompt

1. A typical instruction you’d give Codex:

   - ```bash
     “Implement FR-020..FR-021 in src/AutoKILN_Pico. Then run ENV_FILE=tools/env.pico.sh ./tools/cycle.sh. Fix any compile errors until it builds cleanly. Don’t change log format unless I bump LOG_VERSION and update the FSD.”
     ```

   This is spec-driven design in action: spec → code → build loop → update spec when reality disagrees.

   

## Notes
- `cycle.sh` standardizes the exact CLI calls so you and an AI agent can run the same loop.
- If monitoring fails (port busy), unplug/replug the Pico or close other serial monitors.
