/*
  TEST 04 — Keyboard-controlled Processing -> Arduino serial messages.
  No webcam or Wekinator. 9600 baud and newline-terminated commands.
  Important: send the selected mode every 200 ms because the Arduino
  sketch stops sweeping after 1000 ms without a valid command.
*/

import processing.serial.*;

Serial arduino;
final String ARDUINO_PORT = "/dev/cu.usbmodem11101"; // Verify Serial.list()!
final int BAUD = 9600;
final int STARTUP_WAIT_MS = 2500;
final int HEARTBEAT_MS = 200;

int openedAt = 0;
int lastSentAt = 0;
String selectedCommand = "stop";
String connectionStatus = "Not connected";
String latestReply = "No reply yet";

void setup() {
  size(740, 300);
  println("Available serial ports:");
  printArray(Serial.list());

  try {
    arduino = new Serial(this, ARDUINO_PORT, BAUD);
    arduino.bufferUntil('\n');
    openedAt = millis();
    connectionStatus = "Port open; waiting 2.5 seconds for Nano startup";
  } catch (Exception e) {
    connectionStatus = "PORT ERROR: see Processing Console";
    println("Could not open Arduino: " + e.getMessage());
  }
}

void draw() {
  background(25);
  fill(255);
  textSize(20);
  text("TEST 04 - PROCESSING TO ARDUINO", 20, 45);
  textSize(16);
  text("0 = stop   1 = far   2 = medium   3 = near", 20, 90);

  boolean ready = arduino != null && millis() - openedAt >= STARTUP_WAIT_MS;
  if (ready) {
    connectionStatus = "Serial port open (not proof of motor movement)";
    if (millis() - lastSentAt >= HEARTBEAT_MS) {
      arduino.write(selectedCommand + "\n");
      lastSentAt = millis();
    }
  }

  text("Selected command: " + selectedCommand, 20, 138);
  text("Status: " + connectionStatus, 20, 172);
  text("Latest Arduino message: " + latestReply, 20, 206);
  text("Every 200 ms Processing resends the selected command.", 20, 247);
}

void keyPressed() {
  if (key == '0') selectedCommand = "stop";
  else if (key == '1') selectedCommand = "far";
  else if (key == '2') selectedCommand = "medium";
  else if (key == '3') selectedCommand = "near";
  else return;
  println("Selected: " + selectedCommand);
}

void serialEvent(Serial port) {
  String incoming = port.readStringUntil('\n');
  if (incoming == null) return;
  latestReply = trim(incoming);
  println("Arduino: " + latestReply);
}