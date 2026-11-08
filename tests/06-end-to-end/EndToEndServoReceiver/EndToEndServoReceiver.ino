// TEST 06: Servo receiver for the four-class Wekinator integration test.
// Independent regulated servo 5V supply with common GND is REQUIRED.
// "stop" commands 0 degrees, it does NOT disconnect power.
#include <Servo.h>
Servo motor;
String command = "";
int targetAngle = 0;
unsigned long lastValidAt = 0;
const unsigned long TIMEOUT_MS = 1000;

void setup() {
  Serial.begin(9600);
  pinMode(LED_BUILTIN, OUTPUT);
  motor.attach(9);
  motor.write(0);
  lastValidAt = millis();
  Serial.println("TEST 06 receiver ready");
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
        lastValidAt = millis();
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
  if (millis() - lastValidAt >= TIMEOUT_MS && targetAngle != 0) {
    targetAngle = 0;
    motor.write(0);
    digitalWrite(LED_BUILTIN, LOW);
  }
}
