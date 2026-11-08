/*
  Webcam -> 16x9 greyscale -> Wekinator -> class 1..4 -> Processing GUI.
  OSC send /wek/inputs UDP 6448; receive /wek/outputs UDP 12000.
  The 144 brightness inputs must match the trained Wekinator model.
*/
import processing.video.*;
import oscP5.*;
import netP5.*;
import processing.serial.*;

Capture cam;
OscP5 osc;
NetAddress wekinator;
PImage preview;
final int ML_WIDTH = 16, ML_HEIGHT = 9;
final int SEND_EVERY_MS = 125, STALE_MS = 1000;
boolean cameraReady = false;
int lastCameraFrame = 0, lastInputSent = 0, packetsSent = 0;
volatile int latestClass = 0;
volatile int lastPredictionAt = 0;
volatile int predictionSequence = 0;
int handledSequence = 0;
int candidateClass = 0, candidateCount = 0, confirmedClass = 1;

Serial arduino;
final String ARDUINO_PORT = "/dev/cu.usbmodem11101"; // Check Serial.list().
int serialOpenedAt = 0;
int lastSerialSend = 0;
boolean serialReady = false;

void setup() {
  size(960, 540);
  String[] cameras = Capture.list();
  println("Available cameras:");
  printArray(cameras);
  if (cameras == null || cameras.length == 0) {
    println("No webcam available. Check permissions.");
    exit();
    return;
  }
  cam = new Capture(this, cameras[0]);
  cam.start();
  osc = new OscP5(this, 12000);
  wekinator = new NetAddress("127.0.0.1", 6448);

  println("Serial ports:");
  printArray(Serial.list());
  try {
    arduino = new Serial(this, ARDUINO_PORT, 9600);
    serialOpenedAt = millis();
    serialReady = true;
  } catch (Exception e) {
    println("Arduino port unavailable: " + e.getMessage());
  }
}

void draw() {
  background(18);
  if (cam == null) return;
  if (cam.available()) {
    cam.read();
    cameraReady = true;
    lastCameraFrame = millis();
  }
  if (cameraReady) image(cam, 0, 0, width, height);

  boolean cameraFresh = cameraReady && millis() - lastCameraFrame < STALE_MS;
  if (cameraFresh && millis() - lastInputSent >= SEND_EVERY_MS) {
    sendInputs();
    lastInputSent = millis();
  }

  boolean predictionFresh = latestClass > 0 &&
    millis() - lastPredictionAt < STALE_MS;

  // Confirm each distinct received OSC message, not each draw() frame.
  int sequence = predictionSequence;
  if (predictionFresh && sequence != handledSequence) {
    handledSequence = sequence;
    int result = latestClass;
    if (result == candidateClass) candidateCount++;
    else {
      candidateClass = result;
      candidateCount = 1;
    }
    int required = result == 1 ? 2 : 3;
    if (candidateCount >= required) confirmedClass = result;
  }

  if (!cameraFresh || !predictionFresh) {
    confirmedClass = 1;
    candidateClass = 0;
    candidateCount = 0;
  }

  String command = (!cameraFresh || !predictionFresh)
    ? "stop" : commandForClass(confirmedClass);

  // Heartbeat every 200 ms; fallback to rest on stale model/camera data.
  if (serialReady && millis() - serialOpenedAt >= 2500 &&
      millis() - lastSerialSend >= 200) {
    arduino.write(command + "\n");
    lastSerialSend = millis();
  }
  drawStatus(cameraFresh, predictionFresh, command);
}

void sendInputs() {
  PImage small = cam.get();
  small.resize(ML_WIDTH, ML_HEIGHT);
  small.loadPixels();
  OscMessage msg = new OscMessage("/wek/inputs");
  for (int i = 0; i < small.pixels.length; i++) {
    color pixelColour = small.pixels[i];
    float brightness = (red(pixelColour) + green(pixelColour) +
      blue(pixelColour)) / (3.0f * 255.0f);
    msg.add(brightness);
    small.pixels[i] = color(brightness * 255.0f);
  }
  small.updatePixels();
  preview = small;
  osc.send(msg, wekinator);
  packetsSent++;
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

void drawStatus(boolean cameraFresh, boolean predictionFresh, String command) {
  noStroke();
  fill(0, 220);
  rect(15, 15, 505, 245, 10);
  fill(255);
  textSize(18);
  text("TEST 06 - END-TO-END PIPELINE", 28, 45);
  textSize(15);
  text("Camera: " + (cameraFresh ? "FRESH" : "WAITING"), 28, 75);
  text("Wekinator: " + (predictionFresh ? "FRESH" : "WAITING"), 28, 102);
  text("Latest raw class: " + (predictionFresh ? str(latestClass) : "--"), 28, 129);
  text("Confirmed class: " + confirmedClass + " (" +
    className(confirmedClass) + ")", 28, 156);
  text("Serial command: " + command, 28, 183);
  text("Sent 144-input packets: " + packetsSent, 28, 210);

  text("Arduino serial: " + (serialReady ? "OPEN" : "UNAVAILABLE"), 28, 234);
  if (preview != null) {
    fill(0, 220);
    rect(10, height - 128, 200, 118, 8);
    fill(255);
    textSize(12);
    text("16x9 grayscale input", 20, height - 108);
    image(preview, 20, height - 100, 160, 90);
  }
}

void oscEvent(OscMessage message) {
  if (!message.checkAddrPattern("/wek/outputs")) return;
  String tags = message.typetag();
  if (tags.length() == 0) return;
  int result;
  if (tags.charAt(0) == 'f') result = round(message.get(0).floatValue());
  else if (tags.charAt(0) == 'i') result = message.get(0).intValue();
  else return;
  if (result < 1 || result > 4) return;
  if (result != latestClass) println("Wekinator raw class: " + result);
  latestClass = result;
  lastPredictionAt = millis();
  predictionSequence++;
}
