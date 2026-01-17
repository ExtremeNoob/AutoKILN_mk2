// AutoKILN.ino (mk2 starter skeleton)
// Grows slice-by-slice from spec/00_FSD_KILN.md

#include <Arduino.h>

static const char* FW_VERSION = "mk2-0.1";

// TODO: set to your actual GPIO for SSR control
static const int PIN_SSR = 15;

static uint32_t lastHeartbeatMs = 0;

void setup() {
  // FR-001: SSR OFF before anything else
  pinMode(PIN_SSR, OUTPUT);
  digitalWrite(PIN_SSR, LOW);

  Serial.begin(115200);
  while (!Serial && millis() < 1500) {}

  // FR-010: boot banner
  Serial.println();
  Serial.print("[boot] AutoKILN ");
  Serial.println(FW_VERSION);
  Serial.println("[boot] state=IDLE");
}

void loop() {
  // FR-011: 1 Hz heartbeat
  const uint32_t now = millis();
  if (now - lastHeartbeatMs >= 1000) {
    lastHeartbeatMs = now;
    Serial.print("[hb] ms=");
    Serial.print(now);
    Serial.println(" state=IDLE ssr=0");
  }
}
