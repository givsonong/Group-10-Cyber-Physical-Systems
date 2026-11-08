// TEST 02: Low-range PWM pulse diagnostic; no camera or ML.
// Use external regulated servo 5V with common Arduino GND. Signal D9.
#include <Servo.h>
Servo motor;

void setup() {
  Serial.begin(9600);
  motor.attach(9);

  Serial.println("1500 microseconds, 3 sec");
  motor.writeMicroseconds(1500);
  delay(3000);

  Serial.println("1400 microseconds, 2 sec");
  motor.writeMicroseconds(1400);
  delay(2000);

  Serial.println("1500 microseconds, 3 sec");
  motor.writeMicroseconds(1500);
  delay(3000);

  Serial.println("1600 microseconds, 2 sec");
  motor.writeMicroseconds(1600);
  delay(2000);

  motor.writeMicroseconds(1500);
  Serial.println("TEST 02 finished at 1500 microseconds.");
}
void loop() {}
