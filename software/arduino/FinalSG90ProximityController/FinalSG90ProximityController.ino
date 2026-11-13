/*
  PROJECT: Four-Class Proximity Controller
  BOARD: Arduino Nano Every

  COMPONENTS:
  -----------
  1. SG90 Positional Servo (D9)
  2. WS2812B RGB LED Ring (D10, 24 LEDs)

  PURPOSE:
  --------
  Receive proximity classifications from Processing
  through USB serial communication.

  Control TWO outputs simultaneously:

  1. Servo sweeping range and speed.
  2. LED ring brightness.

  PROXIMITY BEHAVIOUR:
  --------------------

  CLASS 1: EMPTY
    Command: "stop"
    Servo: Return to 0 degrees
    LEDs: OFF

  CLASS 2: FAR
    Command: "far"
    Servo: Continuously sweep 0 to 5 degrees
    Speed: 100 milliseconds per degree
    LEDs: Blue at 33% brightness

  CLASS 3: MEDIUM
    Command: "medium"
    Servo: Continuously sweep 0 to 15 degrees
    Speed: 50 milliseconds per degree
    LEDs: Blue at 67% brightness

  CLASS 4: NEAR
    Command: "near"
    Servo: Continuously sweep 0 to 30 degrees
    Speed: 20 milliseconds per degree
    LEDs: Blue at 100% brightness

  COMMUNICATION:
  --------------
  Processing sends text commands at 9600 baud.

  Each command ends with a newline character.

  If no valid command arrives for 1000 milliseconds,
  return the servo to 0 degrees and turn off the LEDs.

  HARDWARE:
  ---------
  Use a suitable regulated external 5V power supply
  for the servo and LED ring.

  Connect the external supply GND to Arduino GND.

  Ensure the servo can safely move between 0 and 30
  degrees without mechanical obstruction.
*/


// ============================================
// SECTION 1: IMPORT LIBRARIES
// ============================================

#include <Servo.h>
#include <FastLED.h>


// ============================================
// SECTION 2: SERVO CONFIGURATION
// ============================================

// Create the servo controller.
Servo motor;

// Servo signal wire connects to D9.
const byte SERVO_PIN = 9;

// Minimum angle for all sweeping modes.
const int MIN_ANGLE = 0;

// Maximum angles for different proximity classes.
const int FAR_MAX_ANGLE = 5;
const int MEDIUM_MAX_ANGLE = 15;
const int NEAR_MAX_ANGLE = 30;


// ============================================
// SECTION 3: SERVO SPEED CONFIGURATION
// ============================================

// These values control the time between
// each 1-degree movement command.
//
// Larger interval = slower movement.
// Smaller interval = faster movement.

// FAR: Slow movement.
const unsigned long FAR_INTERVAL_MS = 100;

// MEDIUM: Moderate movement.
const unsigned long MEDIUM_INTERVAL_MS = 50;

// NEAR: Fast movement.
const unsigned long NEAR_INTERVAL_MS = 20;


// ============================================
// SECTION 4: LED RING CONFIGURATION
// ============================================

// LED ring data wire connects to Arduino D10.
#define LED_PIN 10

// Number of LEDs on the ring.
#define NUM_LEDS 24

// LED chipset.
#define LED_TYPE WS2812B

// Colour order.
#define COLOR_ORDER GRB

// Maximum brightness for initial testing.
//
// FastLED brightness ranges from 0 to 255.
//
// We use 30 as the maximum for now.
//
// Therefore:
//
// EMPTY  = 0
// FAR    = 10
// MEDIUM = 20
// NEAR   = 30
//
// These values represent 0%, 33%, 67%
// and 100% of our configured maximum.
const uint8_t MAX_BRIGHTNESS = 30;

// Create an array to store the colour
// of each LED on the ring.
CRGB leds[NUM_LEDS];


// ============================================
// SECTION 5: SERIAL COMMUNICATION
// ============================================

// If no valid command arrives for 1 second,
// automatically return to EMPTY.
const unsigned long COMMAND_TIMEOUT_MS = 1000;

// Time of the last valid serial command.
unsigned long lastValidCommandAt = 0;

// Time of the last servo movement step.
unsigned long lastStepAt = 0;

// Store incoming serial characters.
String inputLine = "";


// ============================================
// SECTION 6: DEFINE PROXIMITY MODES
// ============================================

// Four possible proximity classifications.
enum MotionMode {
  EMPTY,
  FAR,
  MEDIUM,
  NEAR
};

// Begin in EMPTY mode.
MotionMode mode = EMPTY;

// Current commanded servo angle.
int angle = 0;

// Servo movement direction.
//
//  1 = increasing angle.
// -1 = decreasing angle.
int direction = 1;


// ============================================
// SECTION 7: SETUP
// ============================================

void setup() {

  // ------------------------------------------
  // INITIALISE SERIAL COMMUNICATION
  // ------------------------------------------

  Serial.begin(9600);

  // Reserve memory for incoming commands.
  inputLine.reserve(20);


  // ------------------------------------------
  // INITIALISE SERVO
  // ------------------------------------------

  // Attach servo to pin D9.
  motor.attach(SERVO_PIN);

  // Start at 0 degrees.
  motor.write(MIN_ANGLE);


  // ------------------------------------------
  // INITIALISE LED RING
  // ------------------------------------------

  // Tell FastLED about the LED ring.
  FastLED.addLeds<LED_TYPE, LED_PIN, COLOR_ORDER>(
    leds,
    NUM_LEDS
  ).setCorrection(TypicalLEDStrip);

  // Start with all LEDs off.
  FastLED.clear();

  // Set initial brightness to zero.
  FastLED.setBrightness(0);

  // Update the physical LED ring.
  FastLED.show();


  // ------------------------------------------
  // STARTUP MESSAGE
  // ------------------------------------------

  Serial.println("Servo + LED Controller Ready");
}


// ============================================
// SECTION 8: GET MAXIMUM SERVO ANGLE
// ============================================

// Determine the maximum sweeping angle
// based on the current proximity mode.
int getMaxAngle() {

  if (mode == FAR) {
    return FAR_MAX_ANGLE;
  }

  else if (mode == MEDIUM) {
    return MEDIUM_MAX_ANGLE;
  }

  else if (mode == NEAR) {
    return NEAR_MAX_ANGLE;
  }

  // EMPTY does not sweep.
  return MIN_ANGLE;
}


// ============================================
// SECTION 9: GET SERVO MOVEMENT SPEED
// ============================================

// Determine how quickly the servo should
// move based on the proximity classification.
unsigned long getSweepInterval() {

  if (mode == FAR) {
    return FAR_INTERVAL_MS;
  }

  else if (mode == MEDIUM) {
    return MEDIUM_INTERVAL_MS;
  }

  else if (mode == NEAR) {
    return NEAR_INTERVAL_MS;
  }

  // Fallback interval.
  return NEAR_INTERVAL_MS;
}


// ============================================
// SECTION 10: CONTROL LED BRIGHTNESS
// ============================================

/*
  This function controls the LED ring.

  It checks the current proximity mode and
  adjusts the brightness accordingly.

  All LEDs remain BLUE.

  Only their brightness changes.

  EMPTY  -> 0%
  FAR    -> 33%
  MEDIUM -> 67%
  NEAR   -> 100%

  This function runs only when the mode changes,
  not during every servo movement step.
*/

void updateLEDs() {

  // Store the desired brightness.
  uint8_t brightness = 0;


  // ------------------------------------------
  // CLASS 1: EMPTY
  // ------------------------------------------

  if (mode == EMPTY) {

    // Nobody detected.
    // Turn off the LED ring.
    brightness = 0;
  }


  // ------------------------------------------
  // CLASS 2: FAR
  // ------------------------------------------

  else if (mode == FAR) {

    // One-third brightness.
    brightness = MAX_BRIGHTNESS / 3;
  }


  // ------------------------------------------
  // CLASS 3: MEDIUM
  // ------------------------------------------

  else if (mode == MEDIUM) {

    // Two-thirds brightness.
    brightness = MAX_BRIGHTNESS * 2 / 3;
  }


  // ------------------------------------------
  // CLASS 4: NEAR
  // ------------------------------------------

  else if (mode == NEAR) {

    // Maximum configured brightness.
    brightness = MAX_BRIGHTNESS;
  }


  // ------------------------------------------
  // UPDATE LED RING
  // ------------------------------------------

  // Set all LEDs to blue.
  fill_solid(
    leds,
    NUM_LEDS,
    CRGB::Blue
  );

  // Set the desired brightness.
  FastLED.setBrightness(brightness);

  // Send the new brightness to the LED ring.
  FastLED.show();


  // ------------------------------------------
  // DEBUGGING MESSAGE
  // ------------------------------------------

  Serial.print("LED brightness: ");
  Serial.print(brightness);

  Serial.print("/");
  Serial.println(MAX_BRIGHTNESS);
}


// ============================================
// SECTION 11: CHANGE PROXIMITY MODE
// ============================================

/*
  This function controls BOTH outputs.

  Whenever Processing sends a new proximity
  classification, Arduino:

  1. Updates the movement mode.
  2. Updates LED brightness.
  3. Adjusts the servo's sweeping behaviour.

  Repeated commands of the same mode do not
  restart the servo's movement.
*/

void setMode(MotionMode nextMode) {

  // Ignore repeated commands of the same mode.
  //
  // Processing sends commands approximately
  // every 200 milliseconds.
  //
  // Repeated commands must not interrupt
  // the servo's continuous movement.
  if (mode == nextMode) {
    return;
  }


  // ------------------------------------------
  // UPDATE CURRENT MODE
  // ------------------------------------------

  mode = nextMode;


  // ------------------------------------------
  // UPDATE LED BRIGHTNESS
  // ------------------------------------------

  // Update the LED ring whenever
  // the proximity mode changes.
  updateLEDs();


  // ------------------------------------------
  // CLASS 1: EMPTY
  // ------------------------------------------

  if (mode == EMPTY) {

    // Set servo position to 0 degrees.
    angle = MIN_ANGLE;

    // Reset movement direction.
    direction = 1;

    // Return servo to 0 degrees.
    motor.write(angle);

    Serial.println(
      "MODE: EMPTY | Servo 0 | LEDs OFF"
    );

    return;
  }


  // ------------------------------------------
  // CLASSES 2, 3 AND 4
  // ------------------------------------------

  // Get the maximum sweeping angle
  // for the newly selected mode.
  int maxAngle = getMaxAngle();


  /*
    GRADUAL MOVEMENT TRANSITIONS

    Suppose the servo is at 28 degrees
    while NEAR is active.

    Processing then sends "medium".

    MEDIUM has a maximum angle of 15 degrees.

    Instead of immediately jumping from
    28 degrees to 15 degrees, the servo
    moves gradually:

    28 -> 27 -> 26 -> 25 -> ... -> 15

    The movement follows MEDIUM's
    configured 50 ms step interval.

    This prevents sudden large movements.
  */

  // If the current angle is at or above
  // the new maximum, move downwards.
  if (angle >= maxAngle) {
    direction = -1;
  }

  // If the current angle is at the minimum,
  // move upwards.
  else if (angle <= MIN_ANGLE) {
    direction = 1;
  }

  // Otherwise, preserve the current direction.


  // Reset the movement timer.
  lastStepAt = millis();


  // ------------------------------------------
  // PRINT CURRENT MODE
  // ------------------------------------------

  if (mode == FAR) {

    Serial.println(
      "MODE: FAR | Sweep 0-5 | LEDs 33%"
    );
  }

  else if (mode == MEDIUM) {

    Serial.println(
      "MODE: MEDIUM | Sweep 0-15 | LEDs 67%"
    );
  }

  else if (mode == NEAR) {

    Serial.println(
      "MODE: NEAR | Sweep 0-30 | LEDs 100%"
    );
  }
}


// ============================================
// SECTION 12: INTERPRET PROCESSING COMMANDS
// ============================================

/*
  Processing sends one of four commands:

  "stop"
  "far"
  "medium"
  "near"

  This function converts the received
  string into an Arduino movement mode.

  The movement mode determines both the
  servo behaviour and LED brightness.
*/

void handleCommand(String line) {

  // Remove unnecessary whitespace.
  line.trim();

  // Convert text to lowercase.
  line.toLowerCase();

  // Store the requested proximity mode.
  MotionMode requested;


  // ------------------------------------------
  // CLASS 1: EMPTY
  // ------------------------------------------

  if (line == "stop" || line == "0") {
    requested = EMPTY;
  }


  // ------------------------------------------
  // CLASS 2: FAR
  // ------------------------------------------

  else if (line == "far") {
    requested = FAR;
  }


  // ------------------------------------------
  // CLASS 3: MEDIUM
  // ------------------------------------------

  else if (line == "medium") {
    requested = MEDIUM;
  }


  // ------------------------------------------
  // CLASS 4: NEAR
  // ------------------------------------------

  else if (line == "near") {
    requested = NEAR;
  }


  // ------------------------------------------
  // INVALID COMMAND
  // ------------------------------------------

  else {

    // Ignore unknown commands.
    // They do not reset the timeout.
    return;
  }


  // ------------------------------------------
  // RESET COMMUNICATION TIMEOUT
  // ------------------------------------------

  // Remember when this valid command arrived.
  lastValidCommandAt = millis();


  // ------------------------------------------
  // APPLY NEW MODE
  // ------------------------------------------

  // Update servo movement and LEDs.
  setMode(requested);
}


// ============================================
// SECTION 13: MAIN ARDUINO LOOP
// ============================================

void loop() {

  // ------------------------------------------
  // TASK 1: RECEIVE SERIAL COMMANDS
  // ------------------------------------------

  // Read incoming characters from Processing.
  while (Serial.available() > 0) {

    // Read one character.
    char ch = Serial.read();


    // ----------------------------------------
    // COMPLETE COMMAND RECEIVED
    // ----------------------------------------

    // A newline marks the end of a command.
    if (ch == '\n') {

      // Process only non-empty commands.
      if (inputLine.length() > 0) {

        handleCommand(inputLine);
      }

      // Clear the buffer for the next command.
      inputLine = "";
    }


    // ----------------------------------------
    // COLLECT COMMAND CHARACTERS
    // ----------------------------------------

    else if (ch != '\r' &&
             inputLine.length() < 20) {

      inputLine += ch;
    }
  }


  // ------------------------------------------
  // TASK 2: COMMUNICATION TIMEOUT
  // ------------------------------------------

  // If no valid command arrives for more
  // than 1000 milliseconds, return to EMPTY.
  if (millis() - lastValidCommandAt >
      COMMAND_TIMEOUT_MS &&
      mode != EMPTY) {

    Serial.println(
      "TIMEOUT: Returning to EMPTY"
    );

    // Return servo to 0 degrees
    // and switch off the LED ring.
    setMode(EMPTY);
  }


  // ------------------------------------------
  // TASK 3: CHECK SERVO MOVEMENT MODE
  // ------------------------------------------

  // EMPTY means the servo remains at 0 degrees.
  if (mode == EMPTY) {
    return;
  }


  // ------------------------------------------
  // TASK 4: SELECT MOVEMENT SPEED
  // ------------------------------------------

  // Get the movement interval associated
  // with the current proximity class.
  unsigned long intervalMs =
    getSweepInterval();


  // ------------------------------------------
  // TASK 5: CONTINUOUS SERVO MOVEMENT
  // ------------------------------------------

  // Only update the servo angle when the
  // required interval has elapsed.
  //
  // Using millis() rather than delay()
  // allows Arduino to continue receiving
  // serial commands while the servo moves.
  if (millis() - lastStepAt >= intervalMs) {

    // Update the movement timer.
    lastStepAt = millis();

    // Get the maximum sweeping angle.
    int maxAngle = getMaxAngle();


    // ----------------------------------------
    // TRANSITION TO A SMALLER SWEEP RANGE
    // ----------------------------------------

    // If the current servo angle exceeds
    // the new maximum, move down gradually.
    //
    // Example:
    //
    // NEAR at 28 degrees
    // changes to MEDIUM (maximum 15).
    //
    // Move 28, 27, 26 ... 15.
    if (angle > maxAngle) {

      // Decrease the angle by one degree.
      angle--;

      // Continue moving towards 0.
      direction = -1;
    }


    // ----------------------------------------
    // NORMAL CONTINUOUS SWEEP
    // ----------------------------------------

    else {

      // Move one degree in the
      // current movement direction.
      angle += direction;


      // --------------------------------------
      // REVERSE AT UPPER BOUNDARY
      // --------------------------------------

      if (angle >= maxAngle) {

        angle = maxAngle;

        // Begin moving towards 0.
        direction = -1;
      }


      // --------------------------------------
      // REVERSE AT LOWER BOUNDARY
      // --------------------------------------

      else if (angle <= MIN_ANGLE) {

        angle = MIN_ANGLE;

        // Begin moving towards the maximum.
        direction = 1;
      }
    }


    // ----------------------------------------
    // COMMAND SERVO POSITION
    // ----------------------------------------

    // Send the new target angle to the servo.
    motor.write(angle);
  }

  // No additional LED updates are needed here.
  //
  // The LEDs maintain their brightness
  // until the proximity mode changes.
}