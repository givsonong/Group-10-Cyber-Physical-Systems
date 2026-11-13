
/*
  PROJECT: Four-Class Proximity Control
  SOFTWARE: Processing (Java mode)

  PURPOSE
  -------
  1. Capture webcam images at 1280 x 720.
  2. Convert each image into 144 grayscale values.
  3. Send these values to Wekinator.
  4. Receive one of four proximity classifications.
  5. Confirm repeated predictions for stability.
  6. Send the corresponding command to Arduino.

  WEKINATOR CLASSES
  -----------------
    Class 1 = EMPTY  -> "stop"   -> 0 degrees
    Class 2 = FAR    -> "far"    -> 5 degrees
    Class 3 = MEDIUM -> "medium" -> 15 degrees
    Class 4 = NEAR   -> "near"   -> 30 degrees

  NOTE:
  Arduino determines the servo's actual
  target angle. Processing only sends
  the text command.

  COMMUNICATION
  -------------
  Wekinator input:
    /wek/inputs on UDP port 6448

  Wekinator output:
    /wek/outputs on UDP port 12000

  Arduino:
    USB serial at 9600 baud

  RESPONSIVENESS IMPROVEMENT
  --------------------------
  When the confirmed proximity class changes,
  Processing immediately sends the new command
  to Arduino instead of waiting for the next
  scheduled 200 ms transmission.

  Processing still resends the current command
  every 200 ms to prevent Arduino's 1-second
  communication timeout.

  MANUAL CONTROLS
  ---------------
    X = Stop automatic servo control
    S = Resume automatic servo control

  IMPORTANT:
  X is a software STOP command.
  It does not physically disconnect motor power.
*/


// ============================================
// SECTION 1: IMPORT LIBRARIES
// ============================================

// Capture webcam images.
import processing.video.*;

// Communicate with Arduino over USB serial.
import processing.serial.*;

// Send and receive OSC messages.
import oscP5.*;
import netP5.*;


// ============================================
// SECTION 2: CREATE OBJECT VARIABLES
// ============================================

Capture cam;
Serial arduino;
OscP5 osc;
NetAddress wekinator;
PImage mlPreview;


// ============================================
// SECTION 3: COMMUNICATION SETTINGS
// ============================================

// Arduino's USB serial port.
// Check Processing Console if this changes.
final String ARDUINO_PORT =
  "/dev/cu.usbmodem11401";

// Wekinator receives a 16 x 9 image,
// giving us 144 grayscale input values.
final int ML_WIDTH = 16;
final int ML_HEIGHT = 9;

// Send updated webcam inputs every 125 ms.
final int CAMERA_SEND_MS = 125;

// Resend Arduino commands every 200 ms.
// This prevents Arduino's communication
// timeout during normal operation.
final int ARDUINO_SEND_MS = 200;

// Treat camera or Wekinator information
// as outdated after 1000 milliseconds.
final int STALE_MS = 1000;


// ============================================
// SECTION 4: CAMERA AND SERIAL VARIABLES
// ============================================

boolean cameraReady = false;
boolean arduinoConnected = false;

// When true, automatic control is paused.
boolean paused = false;

// Record when the latest camera frame arrived.
int lastCameraTime = 0;

// Record when camera inputs were last sent.
int lastCameraSend = 0;

// Record when Arduino was last sent a command.
int lastArduinoSend = 0;

// Record when the USB serial port was opened.
int serialOpenedAt = 0;

// Count webcam input packets sent to Wekinator.
int packetsSent = 0;

// Remember the most recent command sent
// to Arduino so changes can be detected.
String lastCommand = "none";


// ============================================
// SECTION 5: WEKINATOR PREDICTION VARIABLES
// ============================================

// Store the latest class received from Wekinator.
//
// volatile helps when oscEvent() updates these
// values from a different thread.
volatile int latestClass = 0;

// Time of the most recent Wekinator prediction.
volatile int latestClassTime = 0;

// Incremented whenever a new prediction arrives.
volatile int predictionSequence = 0;

// Remember which prediction was last processed.
int lastHandledPrediction = 0;

// Track consecutive predictions of the same class.
int candidateClass = 0;
int candidateCount = 0;

// Start safely at class 1 (EMPTY).
int confirmedClass = 1;


// ============================================
// SECTION 6: SETUP
// ============================================

// setup() runs once when Processing starts.
void setup() {

  // Create the Processing display window.
  size(960, 540);

  // List available cameras for debugging.
  String[] cameras = Capture.list();

  println("CAMERAS:");
  printArray(cameras);

  // Stop if no webcam is available.
  if (cameras.length == 0) {
    println("ERROR: No webcam detected.");
    exit();
    return;
  }

  // Open the first detected webcam.
  cam = new Capture(this, 1280, 720, cameras[0]);

  // Start capturing images.
  cam.start();

  // Listen for Wekinator predictions
  // arriving on UDP port 12000.
  osc = new OscP5(this, 12000);

  // Send camera inputs to Wekinator
  // on UDP port 6448.
  wekinator =
    new NetAddress("127.0.0.1", 6448);

  // Find available USB serial ports.
  String[] ports = Serial.list();

  println("SERIAL PORTS:");
  printArray(ports);

  // Check whether our specified Arduino
  // port appears in the available port list.
  boolean found = false;

  for (String port : ports) {
    if (port.equals(ARDUINO_PORT)) {
      found = true;
    }
  }

  // Attempt to open the Arduino connection.
  if (found) {

    try {

      // Open serial communication at 9600 baud.
      arduino = new Serial(
        this,
        ARDUINO_PORT,
        9600
      );

      // Opening serial can reset Arduino.
      // Remember when the connection opened.
      serialOpenedAt = millis();

      arduinoConnected = true;

      println(
        "Arduino connected on " + ARDUINO_PORT
      );

    } catch (Exception e) {

      println(
        "Could not open Arduino: " +
        e.getMessage()
      );
    }

  } else {

    // Camera and Wekinator can still work
    // even when Arduino is unavailable.
    println(
      "Arduino not found; camera and Wekinator can still run."
    );
  }
}


// ============================================
// SECTION 7: MAIN PROCESSING LOOP
// ============================================

// draw() runs repeatedly while Processing
// is operating.
void draw() {

  background(0);


  // ------------------------------------------
  // TASK 1: CAPTURE CAMERA IMAGE
  // ------------------------------------------

  // Check whether a new camera frame exists.
  if (cam.available()) {

    // Read the latest frame.
    cam.read();

    cameraReady = true;

    // Remember when the frame arrived.
    lastCameraTime = millis();
  }

  // Display the webcam image.
  if (cameraReady) {
    image(cam, 0, 0, width, height);
  }


  // ------------------------------------------
  // TASK 2: CHECK DATA FRESHNESS
  // ------------------------------------------

  // A camera frame is fresh if it arrived
  // within the past 1000 milliseconds.
  boolean cameraFresh =
    cameraReady &&
    millis() - lastCameraTime < STALE_MS;

  // A Wekinator prediction is fresh if
  // it arrived within the past 1000 ms.
  boolean predictionFresh =
    latestClassTime > 0 &&
    millis() - latestClassTime < STALE_MS;


  // ------------------------------------------
  // TASK 3: SEND INPUTS TO WEKINATOR
  // ------------------------------------------

  // Send a new set of 144 grayscale values
  // approximately every 125 milliseconds.
  if (cameraFresh &&
      millis() - lastCameraSend >= CAMERA_SEND_MS) {

    sendWebcamInputs();

    lastCameraSend = millis();
  }


  // ------------------------------------------
  // TASK 4: CONFIRM PROXIMITY CLASSIFICATION
  // ------------------------------------------

  // Only process each newly received
  // Wekinator prediction once.
  int sequence = predictionSequence;

  if (sequence != lastHandledPrediction) {

    lastHandledPrediction = sequence;

    int result = latestClass;

    // If the predicted class matches the
    // previous candidate, increase the count.
    if (result == candidateClass) {
      candidateCount++;
    }

    // Otherwise, begin counting a new class.
    else {
      candidateClass = result;
      candidateCount = 1;
    }

    // Class 1 (EMPTY) requires 2 consecutive
    // predictions before confirmation.
    //
    // FAR, MEDIUM and NEAR require 3.
    //
    // This reduces unwanted changes caused
    // by brief classification fluctuations.
    int required = result == 1 ? 2 : 3;

    if (candidateCount >= required) {
      confirmedClass = result;
    }
  }


  // ------------------------------------------
  // TASK 5: HANDLE MISSING CAMERA OR ML DATA
  // ------------------------------------------

  // If camera frames or Wekinator predictions
  // stop arriving, return to Class 1 (EMPTY).
  //
  // This prevents continued movement based
  // on outdated classification information.
  if (!cameraFresh || !predictionFresh) {

    confirmedClass = 1;
    candidateClass = 0;
    candidateCount = 0;
  }


  // ------------------------------------------
  // TASK 6: SELECT ARDUINO COMMAND
  // ------------------------------------------

  // Use the confirmed proximity class when
  // camera and ML data are fresh and the
  // system is not manually paused.
  //
  // Otherwise, select Class 1 (EMPTY).
  int activeClass =
    (cameraFresh && predictionFresh && !paused)
    ? confirmedClass : 1;

  // Convert the class number into a
  // command understood by Arduino.
  String command = commandForClass(activeClass);


  // ------------------------------------------
  // TASK 7: SEND COMMAND TO ARDUINO
  // UPDATED: IMMEDIATE RESPONSE TO MODE CHANGES
  // ------------------------------------------

  // Opening a USB serial connection may
  // reset the Arduino Nano Every.
  //
  // Wait at least 2.5 seconds after opening
  // the port before sending regular commands.
  boolean serialReady =
    arduinoConnected &&
    millis() - serialOpenedAt >= 2500;

  // NEW:
  // Check whether the selected command
  // differs from the last command sent.
  //
  // For example:
  // Previous command = "far"
  // Current command  = "near"
  //
  // In that case, we should send "near"
  // immediately rather than waiting.
  boolean commandChanged =
    !command.equals(lastCommand);

  // Check whether 200 milliseconds have
  // passed since the previous transmission.
  //
  // Even when the proximity class is unchanged,
  // Arduino needs regular valid commands.
  //
  // Otherwise, its 1-second timeout causes
  // the servo to return to 0 degrees.
  boolean heartbeatDue =
    millis() - lastArduinoSend >= ARDUINO_SEND_MS;

  // UPDATED:
  // Send a command when Arduino is ready AND:
  //
  // 1. The command has changed, OR
  // 2. The 200 ms resend interval has elapsed.
  //
  // This makes confirmed proximity changes
  // reach Arduino more quickly without
  // weakening the prediction filter.
  if (serialReady &&
      (commandChanged || heartbeatDue)) {

    // Send the current command followed
    // by a newline character.
    arduino.write(command + "\n");

    // Only print a debugging message when
    // the selected command changes.
    //
    // This avoids printing the same command
    // five times every second.
    if (commandChanged) {
      println("Arduino command: " + command);
    }

    // Remember which command was sent.
    lastCommand = command;

    // Record the transmission time so
    // the next resend can be scheduled.
    lastArduinoSend = millis();
  }


  // ------------------------------------------
  // TASK 8: DISPLAY STATUS INFORMATION
  // ------------------------------------------

  // Draw a semi-transparent panel over
  // the webcam image.
  noStroke();
  fill(0, 205);
  rect(15, 15, 455, 186, 10);

  fill(255);
  textSize(20);

  // Display the most relevant system status.
  if (paused) {
    text(
      "MANUAL STOP (press S to resume)",
      30, 48
    );
  }
  else if (!cameraFresh) {
    text("WAITING FOR CAMERA", 30, 48);
  }
  else if (!predictionFresh) {
    text("WAITING FOR WEKINATOR", 30, 48);
  }
  else {
    text(
      "PROXIMITY: " + className(activeClass),
      30, 48
    );
  }

  textSize(14);

  // Show the latest class received from ML.
  text(
    "Latest Wekinator class: " +
    (predictionFresh ? str(latestClass) : "--"),
    30, 81
  );

  // Show the class accepted by the filter.
  text(
    "Confirmed class: " + confirmedClass,
    30, 107
  );

  // Show the selected serial command
  // and number of camera packets sent.
  text(
    "Command: " + command +
    "     Packets: " + packetsSent,
    30, 133
  );

  // CONNECTED means the serial port
  // opened and the startup wait finished.
  //
  // It does not prove the servo moved.
  text(
    "Arduino: " +
    (serialReady ? "CONNECTED" : "NOT READY"),
    30, 159
  );

  text(
    "X = force stop       S = resume",
    30, 185
  );


  // ------------------------------------------
  // TASK 9: DISPLAY ML INPUT PREVIEW
  // ------------------------------------------

  // Display the reduced 16 x 9 image
  // that is sent to Wekinator.
  if (mlPreview != null) {

    fill(0, 195);
    rect(10, height - 125, 190, 115, 8);

    fill(255);
    textSize(12);

    text(
      "144-pixel ML preview",
      20, height - 103
    );

    image(
      mlPreview,
      20, height - 98,
      160, 90
    );
  }
}


// ============================================
// SECTION 8: CONVERT CLASS TO COMMAND
// ============================================

// Translate Wekinator's numeric output
// into a serial command for Arduino.
//
// The Arduino controller determines
// which angle corresponds to each command.
String commandForClass(int c) {

  if (c == 2) return "far";
  if (c == 3) return "medium";
  if (c == 4) return "near";

  return "stop";
}


// ============================================
// SECTION 9: CLASS NAMES
// ============================================

// Convert class numbers into readable
// names for the Processing display.
String className(int c) {

  if (c == 2) return "FAR";
  if (c == 3) return "MEDIUM";
  if (c == 4) return "NEAR";

  return "NO PERSON";
}


// ============================================
// SECTION 10: PREPARE WEKINATOR INPUTS
// ============================================

// Convert the webcam image into 144
// grayscale brightness values.
//
// The values range from 0.0 to 1.0.
void sendWebcamInputs() {

  // Copy the current camera frame.
  PImage small = cam.get();

  // Reduce it to 16 x 9 pixels.
  small.resize(ML_WIDTH, ML_HEIGHT);

  // Make its pixels available for reading.
  small.loadPixels();

  // Create an OSC message using the
  // input address expected by Wekinator.
  OscMessage msg =
    new OscMessage("/wek/inputs");

  // Process every pixel in the reduced image.
  for (int i = 0; i < small.pixels.length; i++) {

    color c = small.pixels[i];

    // Calculate approximate grayscale
    // brightness from red, green and blue.
    //
    // Divide by 255 to normalise the
    // value between 0 and 1.
    float brightness =
      (red(c) + green(c) + blue(c)) /
      (3.0f * 255.0f);

    // Add this brightness value to the
    // OSC message for Wekinator.
    msg.add(brightness);

    // Convert the preview image to grayscale.
    small.pixels[i] =
      color(brightness * 255.0f);
  }

  // Update the grayscale preview.
  small.updatePixels();
  mlPreview = small;

  // Send the 144 inputs to Wekinator.
  osc.send(msg, wekinator);

  // Count outgoing camera-input packets.
  packetsSent++;
}


// ============================================
// SECTION 11: RECEIVE WEKINATOR OUTPUTS
// ============================================

// oscEvent() runs when an OSC message arrives.
//
// We only accept messages from Wekinator's
// expected output address.
void oscEvent(OscMessage msg) {

  if (!msg.checkAddrPattern("/wek/outputs")) {
    return;
  }

  // Check what data type was received.
  String tags = msg.typetag();

  if (tags.length() == 0) {
    return;
  }

  int result;

  // Accept a floating-point class value.
  if (tags.charAt(0) == 'f') {
    result = round(msg.get(0).floatValue());
  }

  // Or accept an integer class value.
  else if (tags.charAt(0) == 'i') {
    result = msg.get(0).intValue();
  }

  // Ignore unsupported message types.
  else {
    return;
  }

  // Ignore invalid class numbers.
  if (result < 1 || result > 4) {
    return;
  }

  // Store the latest valid class.
  latestClass = result;

  // Remember when it arrived.
  latestClassTime = millis();

  // Mark that a new prediction arrived.
  predictionSequence++;
}


// ============================================
// SECTION 12: KEYBOARD CONTROLS
// ============================================

// keyPressed() runs when a key is pressed
// while the Processing window is active.
void keyPressed() {

  // Press X to pause automatic control
  // and request Arduino to stop.
  if (key == 'x' || key == 'X') {

    paused = true;

    // Reset the confirmed classification.
    confirmedClass = 1;
    candidateClass = 0;
    candidateCount = 0;

    // Send STOP immediately if the
    // serial port has been opened.
    //
    // This does not physically
    // disconnect the servo power.
    if (arduinoConnected) {
      arduino.write("stop\n");
    }
  }

  // Press S to resume automatic control.
  else if (key == 's' || key == 'S') {

    paused = false;

    // Require fresh repeated predictions
    // before selecting another active mode.
    confirmedClass = 1;
    candidateClass = 0;
    candidateCount = 0;
  }
}
