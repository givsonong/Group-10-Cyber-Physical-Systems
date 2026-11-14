// TEST 01 — position commands for a conventional positional servo.
// Power servo from separate regulated 5 V supply; connect common GND.
// Signal D9. Ensure 60°–120° is mechanically unobstructed.
#include <Servo.h>
Servo motor;

void setup() {
  Serial.begin(9600);
  motor.attach(9);
  Serial.println("Test 01 started: unloaded servo, external power required");

  Serial.println("Target 90 degrees — observe move then hold for 5 seconds");
  motor.write(90);
  delay(5000);

  Serial.println("Target 60 degrees — observe move then hold for 5 seconds");
  motor.write(60);
  delay(5000);

  Serial.println("Target 90 degrees — observe move then hold for 5 seconds");
  motor.write(90);
  delay(5000);

  Serial.println("Target 120 degrees — observe move then hold for 5 seconds");
  motor.write(120);
  delay(5000);

  Serial.println("Test 01 finished: last commanded position = 120 degrees");
}

void loop() {
  // Run the staged test once only.
}
