/*
  PROTOTYPE 2: Webcam -> Wekinator (4 proximity classes)
  SOFTWARE: Processing (Java mode)

  WHAT THIS SKETCH DOES:
  1. Shows a high-resolution webcam preview.
  2. Makes a small 16 x 9 grayscale copy of each frame.
  3. Sends 144 brightness numbers to Wekinator via OSC.
  4. Displays Wekinator's classification when the model is running.

  CLASS 1 = NO PERSON
  CLASS 2 = FAR
  CLASS 3 = MEDIUM
  CLASS 4 = NEAR

  WEKINATOR PROJECT SETTINGS:
    144 inputs, OSC address /wek/inputs, receiving port 6448
    1 classifier output, 4 classes, OSC address /wek/outputs
    Send outputs to localhost, port 12000

  NOTE: This sketch does NOT connect to Arduino or the servo.
*/

// Import libraries: Video for webcam; oscP5/netP5 for Wekinator.
import processing.video.*;
import oscP5.*;
import netP5.*;

Capture cam;            // Our webcam
OscP5 osc;              // Sends and receives OSC messages
NetAddress wekinator;   // Destination for camera data
PImage mlPreview;       // Tiny grayscale image shown in the corner

// 16 * 9 = 144 inputs: must match Wekinator's project settings.
final int ML_WIDTH = 16;
final int ML_HEIGHT = 9;

// Send a webcam sample every 125 ms (approximately 8 times/second).
final int SEND_INTERVAL_MS = 125;

// If no new camera frame/prediction has arrived for this long,
// we treat that source as unavailable.
final int STALE_AFTER_MS = 1000;

boolean cameraReady = false;
int lastCameraFrameTime = 0;
int lastSendTime = 0;
int sentPackets = 0;

int predictedClass = 0;       // 0 means no valid prediction yet
int lastPredictionTime = 0;   // Time of most recent prediction

void setup() {
  // High-resolution capture is displayed in a smaller window.
  size(960, 540);

  String[] cameras = Capture.list();
  println("Available cameras:");
  printArray(cameras);

  if (cameras.length == 0) {
    println("ERROR: No webcam found. Check camera permissions.");
    exit();
    return;
  }

  // This matches your previously working webcam test.
  // If your previous sketch needed a different camera entry,
  // use that same entry/constructor here.
  cam = new Capture(this, 1280, 720, cameras[0]);
  cam.start();

  // Processing listens for Wekinator's predictions on port 12000.
  osc = new OscP5(this, 12000);

  // Wekinator listens for camera features on port 6448.
  // 127.0.0.1 means Wekinator runs on this same computer.
  wekinator = new NetAddress("127.0.0.1", 6448);

  println("Sending 144 camera inputs to Wekinator at /wek/inputs.");
  println("Listening for /wek/outputs on port 12000.");
}

void draw() {
  background(0);

  // Read a new camera frame when one is available.
  if (cam.available()) {
    cam.read();
    cameraReady = true;
    lastCameraFrameTime = millis();
  }

  // Keep the webcam display clear and high-resolution.
  if (cameraReady) {
    image(cam, 0, 0, width, height);
  }

  boolean cameraFresh = cameraReady &&
    millis() - lastCameraFrameTime < STALE_AFTER_MS;

  // Send image features periodically, while the camera is active.
  if (cameraFresh && millis() - lastSendTime >= SEND_INTERVAL_MS) {
    sendWebcamInputs();
    lastSendTime = millis();
  }

  boolean predictionFresh = lastPredictionTime > 0 &&
    millis() - lastPredictionTime < STALE_AFTER_MS;

  // Draw a readable status panel over the live video.
  noStroke();
  fill(0, 195);
  rect(15, 15, 390, 145, 10);

  textSize(21);
  fill(255);

  if (!cameraFresh) {
    text("WAITING FOR CAMERA", 30, 50);
  } else if (!predictionFresh) {
    text("WAITING FOR WEKINATOR", 30, 50);
  } else {
    // Display the name of the current class.
    if (predictedClass == 1) {
      fill(255, 200, 100);
      text("CLASS 1: NO PERSON", 30, 50);
    } else if (predictedClass == 2) {
      fill(130, 210, 255);
      text("CLASS 2: FAR", 30, 50);
    } else if (predictedClass == 3) {
      fill(130, 255, 195);
      text("CLASS 3: MEDIUM", 30, 50);
    } else if (predictedClass == 4) {
      fill(100, 255, 130);
      text("CLASS 4: NEAR", 30, 50);
    }
  }

  fill(255);
  textSize(14);
  text("OSC input: 144 grayscale values -> port 6448", 30, 84);
  text("Packets sent: " + sentPackets, 30, 110);
  text("Predicted class: " + (predictionFresh ? str(predictedClass) : "--"),
       30, 136);

  // Small preview of the actual 16 x 9 grayscale image sent to Wekinator.
  if (mlPreview != null) {
    fill(0, 190);
    rect(10, height - 125, 190, 115, 8);
    fill(255);
    textSize(12);
    text("What Wekinator sees", 20, height - 103);
    image(mlPreview, 20, height - 98, 160, 90);
  }
}

void sendWebcamInputs() {
  // Copy the frame so the original preview stays high-resolution.
  PImage small = cam.get();

  // Downsample to 16 x 9 = 144 pixels.
  small.resize(ML_WIDTH, ML_HEIGHT);
  small.loadPixels();

  // Wekinator expects 144 float values at this OSC address.
  OscMessage message = new OscMessage("/wek/inputs");

  for (int i = 0; i < small.pixels.length; i++) {
    color c = small.pixels[i];

    // Convert red, green, blue into one normalized brightness value.
    // Black = 0.0; white = 1.0.
    float brightness = (red(c) + green(c) + blue(c)) / (3.0f * 255.0f);

    message.add(brightness);

    // Also build an exact grayscale image for our small preview.
    small.pixels[i] = color(brightness * 255.0f);
  }

  small.updatePixels();
  mlPreview = small;

  // Send all 144 brightness values to Wekinator.
  osc.send(message, wekinator);
  sentPackets++;
}

// Wekinator sends an OSC message when its trained model is running.
// This is NOT called during ordinary input-only training.
void oscEvent(OscMessage message) {
  if (!message.checkAddrPattern("/wek/outputs")) {
    return;
  }

  String type = message.typetag();
  if (type.length() == 0) {
    return;
  }

  int result;

  // Accept a classifier output sent as either a float or an integer.
  if (type.charAt(0) == 'f') {
    result = round(message.get(0).floatValue());
  } else if (type.charAt(0) == 'i') {
    result = message.get(0).intValue();
  } else {
    return;
  }

  // Only accept the four classes configured in Wekinator.
  if (result < 1 || result > 4) {
    return;
  }

  if (result != predictedClass) {
    println("Wekinator prediction: Class " + result);
  }

  predictedClass = result;
  lastPredictionTime = millis();
}