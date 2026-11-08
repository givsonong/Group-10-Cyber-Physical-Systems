// TEST 03 — serial protocol only. Leave servo electrically disconnected.
String command = "";

void setup() {
  Serial.begin(9600);
  Serial.println("READY: send stop / far / medium / near (Newline, 9600 baud)");
}

void loop() {
  while (Serial.available() > 0) {
    char ch = Serial.read();
    if (ch == '\r') continue;

    if (ch == '\n') {
      command.trim();
      command.toLowerCase();
      int target = -1;
      if (command == "stop") target = 0;
      else if (command == "far") target = 10;
      else if (command == "medium") target = 20;
      else if (command == "near") target = 30;

      Serial.print("Received: ");
      Serial.println(command);
      if (target >= 0) {
        Serial.print("Target angle: ");
        Serial.println(target);
      } else {
        Serial.println("ERROR: Unknown command");
      }
      command = "";
    } else if (command.length() < 32) {
      command += ch;
    } else {
      command = "";
      Serial.println("ERROR: Input exceeds 32 chars");
    }
  }
}
