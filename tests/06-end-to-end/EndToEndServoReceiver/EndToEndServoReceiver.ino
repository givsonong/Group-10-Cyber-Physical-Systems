// TEST 06 — Arduino receiver for complete Wekinator-to-servo pipeline.
// 0/10/20/30 degree target. Failsafe: 1s serial message timeout -> 0.
// External regulated 5 V servo power with common GND REQUIRED.
#include <Servo.h>
Servo motor;
String command = "";
unsigned long lastValidCommandAt = 0;
const unsigned long TIMEOUT_MS = 1000;
int targetAngle = 0;

void setup() {
  Serial.begin(9600);
  pinMode(LED_BUILTIN, OUTPUT);
  motor.attach(9);
  motor.write(0);
  lastValidCommandAt = millis();
  Serial.println("Test 06 servo receiver ready");
}

void loop() {
  while (Serial.available() > 0) {
    char ch = Serial.read();
    if (ch == '\r') continue;
    if (ch == '\n') {
      command.trim();
      command.toLowerCase();
      int nextAngle = -1;
      if (command == "stop") nextAngle = 0;
      else if (command == "far") nextAngle = 10;
      else if (command == "medium") nextAngle = 20;
      else if (command == "near") nextAngle = 30;
      if (nextAngle >= 0) {
        lastValidCommandAt = millis();
        if (nextAngle != targetAngle) {
          targetAngle = nextAngle;
          motor.write(targetAngle);
          digitalWrite(LED_BUILTIN, !digitalRead(LED_BUILTIN));
        }
      }
      command = "";
    } else if (command.length() < 32) command += ch;
    else command = "";
  }
  // A timeout returns toward the software-defined rest ANGLE;
  // it does not remove electrical power.
  if (millis() - lastValidCommandAt >= TIMEOUT_MS && targetAngle != 0) {
    targetAngle = 0;
    motor.write(targetAngle);
    digitalWrite(LED_BUILTIN, LOW);
  }
}
