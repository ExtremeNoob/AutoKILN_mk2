# AutoKILN_mk2

Spec-driven firmware development for a small wood kiln controller.

## What’s in this repo (starter)
- `spec/00_FSD_KILN.md` — functional spec (source of truth)
- `spec/02_TEST_PLAN.md` — acceptance tests / scenarios
- `agents.md` — “agent contract” (rules + project memory)
- `tools/` — one-command build / upload / monitor (`cycle.sh`)

## Quick start (Pico / arduino-cli)
1. Edit `tools/env.sh` (or export env vars) with your board + port if needed.
2. Run:
   ```bash
   ./tools/cycle.sh --all
   ```
   or build+upload only:
   ```bash
   ./tools/cycle.sh
   ```

## Notes
- `cycle.sh` standardizes the exact CLI calls so you and an AI agent can run the same loop.
- If monitoring fails (port busy), unplug/replug the Pico or close other serial monitors.
