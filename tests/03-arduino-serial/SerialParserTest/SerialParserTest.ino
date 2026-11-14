// TEST 03 — pure serial parser; servo disconnected.
// Type stop / far / medium / near, select "Newline" and 9600 baud.
String command = "";

void setup() {
  Serial.begin(9600);
  Serial.println("READY: send stop, far, medium, near (Newline)");
}

void loop() {
  while (Serial.available() > 0) {
    char incoming = Serial.read();
    if (incoming == '\r') continue;
    if (incoming == '\n') {
      command.trim();
      command.toLowerCase();
      int targetAngle = -1; // -1 means invalid command.
      if (command == "stop") targetAngle = 0;
      else if (command == "far") targetAngle = 10;
      else if (command == "medium") targetAngle = 20;
      else if (command == "near") targetAngle = 30;

      Serial.print("Received: ");
      Serial.println(command);
      if (targetAngle >= 0) {
        Serial.print("Target angle: ");
        Serial.println(targetAngle);
      } else {
        Serial.println("ERROR: Unknown command");
      }
      command = "";
    } else if (command.length() < 32) {
      command += incoming; // Bound buffer growth on malformed input.
    } else {
      command = "";
      Serial.println("ERROR: Command too long (discarded)");
    }
  }
}
