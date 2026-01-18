# AutoKILN Pin Map
Version: 0.1  
Date: 2026-01-15

This file is the **single source of truth** for electrical pin assignments.  
The FSD references **signal names** (e.g., `SSR_CTRL`) rather than raw GPIO numbers.

---

## Conventions
- Logic levels are **3.3V** unless explicitly stated.
- **Active=HIGH** means GPIO HIGH asserts the signal; **Active=LOW** means GPIO LOW asserts the signal.
- **Boot-safe** means the pin shall be driven to that state during BOOT (see FSD FR-001 / FR-003).
- If a value is **TBD**, it must be finalized before wiring/PCB and updated here.

---

## Pico 2W (Controller)

> Note: Pico “GPxx” are 3.3V only. Confirm external modules are 3.3V compatible or use level shifting.

| Signal | Purpose | Pico GPIO | Dir | Active | Pull | Boot-safe | Electrical notes |
|---|---|---:|:---:|:---:|:---:|:---:|---|
| `SSR_CTRL` | Heater SSR control | GP15 | OUT | HIGH *(assumed)* | — | OFF | OFF = LOW (if active-high). **Confirm SSR polarity** with your SSR module. |
| `I2C_SDA` | I2C data (SHT31 / RTC / FRAM) | GP4 *(suggested)* | I/O | — | UP | — | Shared bus. Use external pull-ups (e.g., 4.7k) if modules don’t provide them. |
| `I2C_SCL` | I2C clock (SHT31 / RTC / FRAM) | GP5 *(suggested)* | I/O | — | UP | — | Shared bus. Keep wiring short/twisted if noisy. |
| `DOOR_SW` | Door switch input | TBD | IN | LOW *(typical)* | UP | — | Reed switch often uses pull-up; closed→LOW. Debounce in software. |
| `HX711_DT` | Scale data | TBD | IN | — | — | — | Keep away from SSR/heater wiring (noise). |
| `HX711_SCK` | Scale clock | TBD | OUT | — | — | — | |
| `CURR_ADC` | Current probe analog out (ACS758, etc.) | GP26 / ADC0 *(suggested)* | IN | — | — | — | ADC range 0–3.3V. Cal in software. |
| `RS485_TX` | UART TX to RS485 transceiver | TBD | OUT | — | — | — | Choose a UART-capable pin pair. |
| `RS485_RX` | UART RX from RS485 transceiver | TBD | IN | — | — | — | |
| `RS485_DE` | RS485 Driver Enable | TBD | OUT | HIGH *(typical)* | — | OFF | Keep DE low when not transmitting (half-duplex). |

---

## ESP32-S3 (HMI) — placeholder

> Fill in once you lock down which UART/pins your Waveshare board exposes for RS-485 and any audio wiring.

| Signal | Purpose | ESP32 GPIO | Dir | Active | Pull | Boot-safe | Electrical notes |
|---|---|---:|:---:|:---:|:---:|:---:|---|
| `RS485_TX` | UART TX to RS485 transceiver | TBD | OUT | — | — | — | Dedicated UART recommended. |
| `RS485_RX` | UART RX from RS485 transceiver | TBD | IN | — | — | — | |
| `RS485_DE` | RS485 Driver Enable | TBD | OUT | HIGH *(typical)* | — | OFF | Some modules tie DE+RE together. |
| `AUDIO_EN` | Audio amp enable/mute | TBD | OUT | HIGH *(module-specific)* | — | OFF | Keep muted at boot to avoid pops. |
| `AUDIO_PWM/DAC` | Audio signal to amp | TBD | OUT | — | — | — | Depends on module (I2S/PWM/DAC). |

---

## Change log
- 0.1: Initial draft with suggested pins for SSR + I2C + ADC.
