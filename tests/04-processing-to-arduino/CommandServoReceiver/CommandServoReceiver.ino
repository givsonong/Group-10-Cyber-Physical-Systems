// TEST 04: USB serial text commands -> positional servo target.
// External regulated 5V motor power, shared GND and signal D9 required.
#include <Servo.h>
Servo motor;
String command = "";

void setup() {
  Serial.begin(9600);
  pinMode(LED_BUILTIN, OUTPUT);
  motor.attach(9);
  motor.write(0);
  Serial.println("Test 04 receiver ready");
}

void loop() {
  while (Serial.available() > 0) {
    char ch = Serial.read();
    if (ch == '\r') continue;
    if (ch == '\n') {
      command.trim();
      command.toLowerCase();
      int angle = -1;
      if (command == "stop") angle = 0;
      else if (command == "far") angle = 10;
      else if (command == "medium") angle = 20;
      else if (command == "near") angle = 30;
      if (angle >= 0) {
        motor.write(angle);
        digitalWrite(LED_BUILTIN, !digitalRead(LED_BUILTIN));
        Serial.print("ACK "); Serial.print(command);
        Serial.print(" target="); Serial.println(angle);
      } else {
        Serial.print("ERROR unknown command: "); Serial.println(command);
      }
      command = "";
    } else if (command.length() < 32) command += ch;
    else command = "";
  }
}
