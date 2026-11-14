/*
  PROJECT: Proximity Servo Control — four-class prototype
  SOFTWARE: Processing (Java mode)

  1. Capture and preview webcam at requested 1280 x 720.
  2. Send 144 grayscale brightness values to Wekinator.
  3. Receive four-class proximity predictions from Wekinator.
  4. Wait for repeat predictions to reduce unwanted speed changes.
  5. Send stop / far / medium / near to Arduino Nano Every via USB.

  CLASSES: 1 = empty, 2 = far, 3 = medium, 4 = near
  WEKINATOR: OSC inputs /wek/inputs at UDP 6448
             OSC outputs /wek/outputs at UDP 12000
  ARDUINO: 9600 baud, text commands ending in newline

  EMERGENCY KEY: X = force STOP. S = resume automatic control.

  HARDWARE SAFETY:
  Don't power the SG90 from USB through the Nano's 5V pin,
  especially if your Mac has shown a USB overcurrent warning.
*/

import processing.video.*;
import processing.serial.*;
import oscP5.*;
import netP5.*;

Capture cam;
Serial arduino;
OscP5 osc;
NetAddress wekinator;
PImage mlPreview;

// Check Processing's console output if the serial port changes.
final String ARDUINO_PORT = "/dev/cu.usbmodem1101";

final int ML_WIDTH = 16;
final int ML_HEIGHT = 9;  // 16 x 9 = 144 inputs
final int CAMERA_SEND_MS = 125;
final int ARDUINO_SEND_MS = 200; // Arduino watchdog needs regular commands
final int STALE_MS = 1000;

boolean cameraReady = false;
boolean arduinoConnected = false;
boolean paused = false;
int lastCameraTime = 0;
int lastCameraSend = 0;
int lastArduinoSend = 0;
int serialOpenedAt = 0;
int packetsSent = 0;
String lastCommand = "none";

// OSC may call oscEvent() from another thread, so it only stores new data.
volatile int latestClass = 0;
volatile int latestClassTime = 0;
volatile int predictionSequence = 0;
int lastHandledPrediction = 0;

// Predictions are filtered once per newly received OSC message.
int candidateClass = 0;
int candidateCount = 0;
int confirmedClass = 1;  // Default to safely stopped.

void setup() {
  size(960, 540);

  String[] cameras = Capture.list();
  println("CAMERAS:");
  printArray(cameras);
  if (cameras.length == 0) {
    println("ERROR: No webcam detected.");
    exit();
    return;
  }

  // Use the same Capture constructor as your working camera sketch.
  cam = new Capture(this, 1280, 720, cameras[0]);
  cam.start();

  // Receive Wekinator predictions at 12000; send frames to 6448.
  osc = new OscP5(this, 12000);
  wekinator = new NetAddress("127.0.0.1", 6448);

  // Serial ports are listed so you can correct ARDUINO_PORT if needed.
  String[] ports = Serial.list();
  println("SERIAL PORTS:");
  printArray(ports);
  boolean found = false;
  for (String port : ports) {
    if (port.equals(ARDUINO_PORT)) found = true;
  }
  if (found) {
    try {
      arduino = new Serial(this, ARDUINO_PORT, 9600);
      serialOpenedAt = millis();
      arduinoConnected = true;
      println("Arduino connected on " + ARDUINO_PORT);
    } catch (Exception e) {
      println("Could not open Arduino: " + e.getMessage());
    }
  } else {
    println("Arduino not found; camera and Wekinator can still run.");
  }
}

void draw() {
  background(0);

  if (cam.available()) {
    cam.read();
    cameraReady = true;
    lastCameraTime = millis();
  }
  if (cameraReady) image(cam, 0, 0, width, height);

  boolean cameraFresh = cameraReady && millis() - lastCameraTime < STALE_MS;
  boolean predictionFresh = latestClassTime > 0 &&
                            millis() - latestClassTime < STALE_MS;

  // Send 144 grayscale values every 125 ms.
  if (cameraFresh && millis() - lastCameraSend >= CAMERA_SEND_MS) {
    sendWebcamInputs();
    lastCameraSend = millis();
  }

  // Apply smoothing only when a NEW prediction is received.
  int sequence = predictionSequence;
  if (sequence != lastHandledPrediction) {
    lastHandledPrediction = sequence;
    int result = latestClass;

    if (result == candidateClass) candidateCount++;
    else {
      candidateClass = result;
      candidateCount = 1;
    }

    // Stop after two empty predictions; otherwise require three.
    int required = result == 1 ? 2 : 3;
    if (candidateCount >= required) confirmedClass = result;
  }

  // Never keep motion enabled with a missing camera/ML connection.
  if (!cameraFresh || !predictionFresh) {
    confirmedClass = 1;
    candidateClass = 0;
    candidateCount = 0;
  }

  int activeClass = (cameraFresh && predictionFresh && !paused)
                    ? confirmedClass : 1;
  String command = commandForClass(activeClass);

  // Send a command repeatedly for the Arduino's 1-second watchdog.
  // Opening the serial port can reset the Nano, so allow 2.5 seconds.
  boolean serialReady = arduinoConnected &&
                        millis() - serialOpenedAt >= 2500;
  if (serialReady && millis() - lastArduinoSend >= ARDUINO_SEND_MS) {
    arduino.write(command + "\n");
    if (!command.equals(lastCommand)) {
      println("Arduino command: " + command);
    }
    lastCommand = command;
    lastArduinoSend = millis();
  }

  // On-screen status (no extra Processing libraries required).
  noStroke();
  fill(0, 205);
  rect(15, 15, 455, 186, 10);
  fill(255);
  textSize(20);
  if (paused) text("MANUAL STOP (press S to resume)", 30, 48);
  else if (!cameraFresh) text("WAITING FOR CAMERA", 30, 48);
  else if (!predictionFresh) text("WAITING FOR WEKINATOR", 30, 48);
  else text("PROXIMITY: " + className(activeClass), 30, 48);

  textSize(14);
  text("Latest Wekinator class: " +
       (predictionFresh ? str(latestClass) : "--"), 30, 81);
  text("Confirmed class: " + confirmedClass, 30, 107);
  text("Command: " + command + "     Packets: " + packetsSent, 30, 133);
  text("Arduino: " + (serialReady ? "CONNECTED" : "NOT READY"), 30, 159);
  text("X = force stop       S = resume", 30, 185);

  // Miniature image containing the actual features sent to Wekinator.
  if (mlPreview != null) {
    fill(0, 195);
    rect(10, height - 125, 190, 115, 8);
    fill(255);
    textSize(12);
    text("144-pixel ML preview", 20, height - 103);
    image(mlPreview, 20, height - 98, 160, 90);
  }
}

String commandForClass(int c) {
  if (c == 2) return "far";
  if (c == 3) return "medium";
  if (c == 4) return "near";
  return "stop";
}

String className(int c) {
  if (c == 2) return "FAR";
  if (c == 3) return "MEDIUM";
  if (c == 4) return "NEAR";
  return "NO PERSON";
}

void sendWebcamInputs() {
  PImage small = cam.get();
  small.resize(ML_WIDTH, ML_HEIGHT);
  small.loadPixels();
  OscMessage msg = new OscMessage("/wek/inputs");

  for (int i = 0; i < small.pixels.length; i++) {
    color c = small.pixels[i];
    float brightness = (red(c) + green(c) + blue(c)) / (3.0f * 255.0f);
    msg.add(brightness);
    small.pixels[i] = color(brightness * 255.0f);
  }
  small.updatePixels();
  mlPreview = small;
  osc.send(msg, wekinator);
  packetsSent++;
}

// Called whenever a Wekinator output arrives over OSC.
void oscEvent(OscMessage msg) {
  if (!msg.checkAddrPattern("/wek/outputs")) return;
  String tags = msg.typetag();
  if (tags.length() == 0) return;
  int result;
  if (tags.charAt(0) == 'f') result = round(msg.get(0).floatValue());
  else if (tags.charAt(0) == 'i') result = msg.get(0).intValue();
  else return;
  if (result < 1 || result > 4) return;

  latestClass = result;
  latestClassTime = millis();
  predictionSequence++;
}

void keyPressed() {
  if (key == 'x' || key == 'X') {
    paused = true;
    confirmedClass = 1;
    candidateClass = 0;
    candidateCount = 0;
    // Send STOP immediately as well as on the next serial heartbeat.
    if (arduinoConnected) arduino.write("stop\n");
  } else if (key == 's' || key == 'S') {
    paused = false;
    confirmedClass = 1;  // Require fresh confirmation after resuming.
    candidateClass = 0;
    candidateCount = 0;
  }
}