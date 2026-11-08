// TEST 04: Processing keyboard sends newline-terminated text to Nano Every.
// Close Arduino Serial Monitor. Adjust port to match Serial.list().
import processing.serial.*;

Serial arduino;
final String ARDUINO_PORT = "/dev/cu.usbmodem11101";
final int STARTUP_WAIT_MS = 2500;
int openedAt = 0;
String status = "Not yet connected";

void setup() {
  size(700, 280);
  println("Available serial ports:");
  printArray(Serial.list());
  try {
    arduino = new Serial(this, ARDUINO_PORT, 9600);
    openedAt = millis();
    status = "Port opened. Wait 2.5 seconds before pressing keys.";
  } catch (Exception e) {
    status = "Unable to open port. See Processing Console.";
    println(e.getMessage());
  }
}

void draw() {
  background(30);
  fill(255);
  textSize(20);
  text("TEST 04: Processing to Arduino", 20, 55);
  textSize(16);
  text("0 = stop    1 = far    2 = medium    3 = near", 20, 110);
  text(status, 20, 160);
  text("Sending does not prove Arduino received the command.", 20, 210);
}

void keyPressed() {
  if (arduino == null) return;
  if (millis() - openedAt < STARTUP_WAIT_MS) {
    status = "Wait for the Arduino to finish USB startup.";
    return;
  }
  String command = "";
  if (key == '0') command = "stop";
  else if (key == '1') command = "far";
  else if (key == '2') command = "medium";
  else if (key == '3') command = "near";
  if (command.length() == 0) return;
  arduino.write(command + "\n");
  println("Sent: " + command);
  status = "Sent: " + command;
}
