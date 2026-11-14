/*
  Wekinator LED Monitor
  Adapted from the uploaded sketch_261013c.pde.

  Receives ONE three-class Wekinator classifier output at:
    OSC address: /wek/outputs
    OSC port:    12000

  Displays the predicted class, live blink preview, and a recent
  prediction history. Forwards class 1, 2, or 3 to the Arduino as
  ONE binary serial byte (the protocol used by arduino-osc-blink.ino).

  Uses the original Arduino timing:
    Class 1: 1000ms ON / 250ms OFF
    Class 2:  500ms ON / 1000ms OFF
    Class 3: 1500ms ON / 50ms OFF

  IMPORTANT: The LED on this screen is a TIMING PREVIEW, not an
  actual measurement of the physical LED. The provided Arduino
  uses delay(), so the real LED may change patterns later.
*/

import oscP5.*;
import netP5.*;
import processing.serial.*;

// ---------- USER SETTINGS ----------
final boolean SEND_TO_ARDUINO = true;  // Set false to test without an Arduino.
final int SERIAL_PORT_INDEX = 0;       // Select correct index printed in console.
final int SERIAL_BAUD = 9600;
final int WEKINATOR_OUTPUT_PORT = 12000;
// -----------------------------------

OscP5 oscP5;
Serial arduinoPort;
String serialStatus = "Not connected";
int serialReadyAt = 0;
int lastSentClass = -1;

int predictedClass = -1;                // -1: waiting for first prediction
int predictionCount = 0;
int classChanges = 0;
int invalidMessages = 0;
int lastOscAt = -1;
int lastChangedAt = -1;
int patternStartAt = 0;
float lastRawValue = Float.NaN;

final int[] onTime = {0, 1000, 500, 1500};
final int[] offTime = {0, 250, 1000, 50};

final int HISTORY_SAMPLES = 68;
int[] history = new int[HISTORY_SAMPLES];
int historyHead = 0;
int historyCount = 0;
int lastHistoryAt = -1000;

void setup() {
  size(780, 555);
  frameRate(30);
  smooth(4);
  surface.setTitle("Wekinator | Live LED Class Monitor");

  println("=== Wekinator LED Monitor ===");
  println("Available serial ports:");
  printArray(Serial.list());

  if (!SEND_TO_ARDUINO) {
    serialStatus = "Preview only (Arduino disabled)";
  } else {
    String[] ports = Serial.list();
    if (SERIAL_PORT_INDEX < 0 || SERIAL_PORT_INDEX >= ports.length) {
      serialStatus = "No Arduino at serial index " + SERIAL_PORT_INDEX;
      println("No serial port at index " + SERIAL_PORT_INDEX + ". Visual monitor remains active.");
    } else {
      try {
        arduinoPort = new Serial(this, ports[SERIAL_PORT_INDEX], SERIAL_BAUD);
        serialStatus = "Connected: " + ports[SERIAL_PORT_INDEX];
        serialReadyAt = millis() + 2000;  // Allow Arduino to reset after opening serial.
        println(serialStatus);
      } catch (Exception ex) {
        serialStatus = "Cannot open: " + ports[SERIAL_PORT_INDEX];
        println(serialStatus + " (" + ex.getMessage() + ")");
      }
    }
  }

  oscP5 = new OscP5(this, WEKINATOR_OUTPUT_PORT);
  println("Listening for /wek/outputs on UDP port " + WEKINATOR_OUTPUT_PORT);
}

void draw() {
  int now = millis();
  boolean recentOsc = (lastOscAt >= 0 && now - lastOscAt < 2500);

  // Keep the serial output in sync with the latest prediction.
  // The Arduino may take ~2 seconds to restart after Serial is opened.
  if (arduinoPort != null && predictedClass >= 1 &&
      now >= serialReadyAt && predictedClass != lastSentClass) {
    try {
      arduinoPort.write(predictedClass);  // Single byte: 1, 2, or 3.
      lastSentClass = predictedClass;
      println("Arduino <- class " + predictedClass);
    } catch (Exception ex) {
      serialStatus = "Serial write failed";
      println("Serial error: " + ex.getMessage());
      arduinoPort = null;
    }
  }

  // Take an occasional history sample so the display is easy to interpret.
  if (recentOsc && predictedClass >= 1 && now - lastHistoryAt >= 200) {
    history[historyHead] = predictedClass;
    historyHead = (historyHead + 1) % HISTORY_SAMPLES;
    historyCount = min(historyCount + 1, HISTORY_SAMPLES);
    lastHistoryAt = now;
  }

  background(13, 18, 29);
  noStroke();

  fill(243, 246, 253);
  textSize(29);
  textAlign(LEFT, BASELINE);
  text("LIVE MODEL PREDICTIONS", 28, 46);

  // OSC status: we cannot determine model accuracy from receipt alone.
  textSize(14);
  fill(recentOsc ? color(106, 233, 168) : color(249, 183, 104));
  String oscStatus = (lastOscAt < 0) ? "WAITING FOR WEKINATOR" :
                     (recentOsc ? "RECEIVING WEKINATOR OSC" : "NO RECENT WEKINATOR OSC");
  text(oscStatus, 29, 78);

  fill(166, 175, 193);
  textSize(12);
  text("/wek/outputs  |  port " + WEKINATOR_OUTPUT_PORT + "  |  " + serialStatus, 29, 101);

  // Prominent prediction readout.
  fill(168, 178, 196);
  textSize(15);
  text("CURRENT PREDICTION", 28, 132);
  fill(predictedClass >= 1 ? classColor(predictedClass) : color(240, 244, 250));
  textSize(25);
  text(predictedClass >= 1 ? "CLASS " + predictedClass : "--", 241, 133);

  for (int c = 1; c <= 3; c++) {
    int x = 28 + (c - 1) * 248;
    drawClassCard(c, x, 154, 228, 245, now);
  }

  fill(190, 197, 210);
  textSize(13);
  text("Valid predictions: " + predictionCount + "    Class switches: " + classChanges +
       "    Unexpected outputs: " + invalidMessages, 28, 430);

  if (lastChangedAt >= 0) {
    fill(154, 166, 182);
    text("Last class change: " + nf((now - lastChangedAt) / 1000.0, 0, 1) + "s ago", 28, 451);
  } else {
    fill(154, 166, 182);
    text("Last class change: --", 28, 451);
  }

  drawHistory();

  fill(128, 142, 163);
  textSize(11);
  text("On-screen LEDs are simulated; they do not confirm physical Arduino LED state.", 28, 542);
}

void drawClassCard(int c, int x, int y, int w, int h, int now) {
  boolean selected = (predictedClass == c);
  boolean on = selected && blinkIsOn(c, now);
  color accent = classColor(c);

  stroke(selected ? accent : color(56, 67, 85));
  strokeWeight(selected ? 3 : 1);
  fill(selected ? color(30, 41, 57) : color(24, 31, 44));
  rect(x, y, w, h, 15);
  noStroke();

  textAlign(CENTER, CENTER);
  fill(selected ? color(249, 251, 255) : color(149, 163, 184));
  textSize(21);
  text("CLASS " + c, x + w/2, y + 36);

  // A large virtual LED, blinking to match the class's configured timing.
  fill(on ? accent : color(51, 61, 78));
  ellipse(x + w/2, y + 112, 100, 100);
  if (on) {
    fill(255, 255, 255, 90);
    ellipse(x + w/2 - 18, y + 96, 26, 26);
  }

  fill(selected ? color(240, 244, 252) : color(146, 158, 175));
  textSize(16);
  text(selected ? (on ? "LED ON" : "LED OFF") : "NOT SELECTED", x + w/2, y + 183);

  fill(149, 161, 181);
  textSize(12);
  text(onTime[c] + "ms on  /  " + offTime[c] + "ms off", x + w/2, y + 214);
  textAlign(LEFT, BASELINE);
}

boolean blinkIsOn(int c, int now) {
  int cycle = onTime[c] + offTime[c];
  int elapsed = max(0, now - patternStartAt);
  return (elapsed % cycle) < onTime[c];
}

color classColor(int c) {
  if (c == 1) return color(72, 209, 145);    // green
  if (c == 2) return color(255, 184, 77);    // amber
  if (c == 3) return color(100, 164, 255);   // blue
  return color(160, 168, 182);
}

void drawHistory() {
  fill(189, 199, 217);
  textSize(12);
  text("RECENT PREDICTIONS  (one sample every 0.2s; about 14s when full)", 28, 478);

  float gap = 3;
  float barW = (724.0 - (HISTORY_SAMPLES - 1) * gap) / HISTORY_SAMPLES;
  for (int i = 0; i < HISTORY_SAMPLES; i++) {
    int x = round(28 + i * (barW + gap));
    int cls = 0;
    if (i >= HISTORY_SAMPLES - historyCount) {
      int logical = i - (HISTORY_SAMPLES - historyCount);
      int start = (historyHead - historyCount + HISTORY_SAMPLES) % HISTORY_SAMPLES;
      cls = history[(start + logical) % HISTORY_SAMPLES];
    }
    noStroke();
    fill(cls == 0 ? color(35, 44, 60) : classColor(cls));
    rect(x, 490, max(3, barW), 22, 2);
  }
}

// The same OSC address and 1-classifier output format as your original code.
void oscEvent(OscMessage msg) {
  if (!msg.checkAddrPattern("/wek/outputs")) return;
  lastOscAt = millis();

  float raw;
  if (msg.checkTypetag("f")) {
    raw = msg.get(0).floatValue();
  } else if (msg.checkTypetag("i")) {
    raw = float(msg.get(0).intValue());
  } else {
    invalidMessages++;
    println("Unexpected OSC type: " + msg.typetag());
    return;
  }

  lastRawValue = raw;
  int nextClass = round(raw);
  if (nextClass < 1 || nextClass > 3 || abs(raw - nextClass) > 0.01) {
    invalidMessages++;
    println("Unexpected model output " + raw + "; expected class 1, 2, or 3.");
    return;
  }

  predictionCount++;
  if (nextClass != predictedClass) {
    if (predictedClass >= 1) classChanges++;
    predictedClass = nextClass;
    patternStartAt = millis();
    lastChangedAt = patternStartAt;
    println("WEKINATOR PREDICTED CLASS " + predictedClass);
  }
}