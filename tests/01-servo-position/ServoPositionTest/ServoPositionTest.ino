// TEST 01: Positional servo independently of all computer/ML software.
// SAFETY: Servo uses a separate regulated 5V supply + common Arduino GND.
// Signal is D9. Remove load and verify 60 to 120 degrees is unobstructed.
#include <Servo.h>
Servo motor;

void setup() {
  Serial.begin(9600);
  motor.attach(9);

  Serial.println("TEST 01: target 90 degrees; hold 5 seconds");
  motor.write(90);
  delay(5000);

  Serial.println("TEST 01: target 60 degrees; hold 5 seconds");
  motor.write(60);
  delay(5000);

  Serial.println("TEST 01: target 90 degrees; hold 5 seconds");
  motor.write(90);
  delay(5000);

  Serial.println("TEST 01: target 120 degrees; hold 5 seconds");
  motor.write(120);
  delay(5000);

  Serial.println("TEST 01 complete. Commands do not measure shaft angle.");
}
void loop() {
  // Run once: setup() is not repeated.
}
