// TEST 02 — 1400 / 1500 / 1600 microsecond pulse diagnostic.
// Positional servo should move to finite positions and hold; a 360-degree
// continuous servo might use these pulses for speed/direction instead.
// IMPORTANT: external regulated servo supply, shared GND, unloaded horn.
#include <Servo.h>
Servo motor;

void setup() {
  Serial.begin(9600);
  motor.attach(9);

  Serial.println("1500 us: observe response, 3 seconds");
  motor.writeMicroseconds(1500);
  delay(3000);

  Serial.println("1400 us: observe response, 2 seconds");
  motor.writeMicroseconds(1400);
  delay(2000);

  Serial.println("1500 us: observe response, 3 seconds");
  motor.writeMicroseconds(1500);
  delay(3000);

  Serial.println("1600 us: observe response, 2 seconds");
  motor.writeMicroseconds(1600);
  delay(2000);

  motor.writeMicroseconds(1500);
  Serial.println("Test 02 finished: holding 1500 us");
}
void loop() {}
