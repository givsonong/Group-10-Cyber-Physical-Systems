/*
 TEST 05: Webcam -> 144 brightness inputs -> Wekinator -> classifier -> GUI.
 No Arduino is used; keep motor disconnected.
 Wekinator input: /wek/inputs 6448, output /wek/outputs 12000.
 1 = empty, 2 = far, 3 = medium, 4 = near.
*/
import processing.video.*;
import oscP5.*;
import netP5.*;

Capture cam;
OscP5 osc;
NetAddress wekinator;
PImage mlPreview;
final int ML_WIDTH = 16, ML_HEIGHT = 9;
final int SEND_EVERY_MS = 125;
final int TIMEOUT_MS = 1000;

boolean cameraReady = false;
int lastCameraTime = 0, lastSendTime = 0, packetsSent = 0;
volatile int latestClass = 0, lastPredictionTime = 0, predictionSequence = 0;
int lastHandledPrediction = 0;
int candidateClass = 0, candidateCount = 0, confirmedClass = 1;

void setup() {
  size(960, 540);
  String[] cameras = Capture.list();
  println("Cameras:");
  printArray(cameras);
  if (cameras == null || cameras.length == 0) {
    println("ERROR: No camera available. Check camera permissions.");
    exit();
    return;
  }
  cam = new Capture(this, cameras[0]);
  cam.start();
  osc = new OscP5(this, 12000);  // Listen for Wekinator predictions.
  wekinator = new NetAddress("127.0.0.1", 6448);  // Send inputs.
}

void draw() {
  background(12);
  if (cam == null) return;
  if (cam.available()) {
    cam.read();
    lastCameraTime = millis();
    cameraReady = true;
  }
  if (cameraReady) image(cam, 0, 0, width, height);

  boolean cameraFresh = cameraReady && millis() - lastCameraTime < TIMEOUT_MS;
  if (cameraFresh && millis() - lastSendTime >= SEND_EVERY_MS) {
    sendInputs();
    lastSendTime = millis();
  }
  boolean predictionFresh = latestClass > 0 &&
    millis() - lastPredictionTime < TIMEOUT_MS;

  // Count each *incoming OSC prediction*, not each draw frame.
  int sequence = predictionSequence;
  if (predictionFresh && sequence != lastHandledPrediction) {
    lastHandledPrediction = sequence;
    int result = latestClass;
    if (result == candidateClass) candidateCount++;
    else { candidateClass = result; candidateCount = 1; }
    int needed = (result == 1) ? 2 : 3;
    if (candidateCount >= needed) confirmedClass = result;
  }
  if (!cameraFresh || !predictionFresh) {
    confirmedClass = 1;
    candidateClass = 0;
    candidateCount = 0;
  }

  String simulatedCommand = (!cameraFresh || !predictionFresh)
    ? "stop" : commandForClass(confirmedClass);
  drawStatus(cameraFresh, predictionFresh, simulatedCommand);
}

void sendInputs() {
  PImage small = cam.get();
  small.resize(ML_WIDTH, ML_HEIGHT);
  small.loadPixels();
  OscMessage msg = new OscMessage("/wek/inputs");
  for (int i = 0; i < small.pixels.length; i++) {
    color p = small.pixels[i];
    float brightness = (red(p) + green(p) + blue(p)) / (3.0f * 255.0f);
    msg.add(brightness);
    small.pixels[i] = color(brightness * 255.0f);
  }
  small.updatePixels();
  mlPreview = small;
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
  fill(0, 220);
  noStroke();
  rect(15, 15, 480, 216, 10);
  fill(255);
  textSize(19);
  text("TEST 05 — WEKINATOR CLASSIFICATION", 28, 43);
  textSize(15);
  text("Camera: " + (cameraFresh ? "FRESH" : "WAITING"), 28, 72);
  text("Wekinator predictions: " + (predictionFresh ? "FRESH" : "WAITING"), 28, 99);
  text("Latest class: " + (predictionFresh ? latestClass : "--"), 28, 126);
  text("Confirmed class: " + confirmedClass + " (" + className(confirmedClass) + ")", 28, 153);
  text("Simulated Arduino command: " + command, 28, 180);
  text("Sent 144-input packets: " + packetsSent, 28, 207);
  if (mlPreview != null) {
    fill(0, 220); rect(10, height - 125, 195, 115, 8);
    fill(255); textSize(12); text("16×9 grayscale input", 20, height - 106);
    image(mlPreview, 20, height - 97, 160, 90);
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
  lastPredictionTime = millis();
  predictionSequence++;
}
