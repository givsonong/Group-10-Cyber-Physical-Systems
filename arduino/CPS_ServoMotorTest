/*
  PROJECT: Wekinator Servo Control
  BOARD: Arduino Nano Every
  MOTOR: SG90 positional servo

  PURPOSE:
  Receive start/stop commands from Processing.

  "start" = Servo sweeps back and forth
  "stop"  = Servo holds its current position

  SAFETY:
  Stop sweeping if Processing stops sending
  commands for more than 1000 milliseconds.
*/

#include <Servo.h>

// Create our servo object.
Servo motor;

// Servo configuration.
const int SERVO_PIN = 9;

// Keep movement within a moderate angle range.
const int MIN_ANGLE = 30;
const int MAX_ANGLE = 150;

// Current servo position.
int angle = 90;

// 1 means increasing angle.
// -1 means decreasing angle.
int direction = 1;

// Controls the movement speed.
// Increase this value for slower movement.
const unsigned long MOVE_INTERVAL = 60;

// Records when the servo last moved.
unsigned long lastMoveTime = 0;

// Is the motor supposed to be moving?
bool motorRunning = false;

// Stores commands arriving from Processing.
String command = "";

// Communication timeout.
const unsigned long TIMEOUT = 1000;

// Time of the last valid command.
unsigned long lastCommandTime = 0;


void setup() {

  // Start serial communication.
  Serial.begin(9600);

  // Configure the built-in LED for testing.
  pinMode(LED_BUILTIN, OUTPUT);

  // Attach our SG90 to pin D9.
  motor.attach(SERVO_PIN);

  // Set initial angle.
  motor.write(angle);

  Serial.println("Arduino ready!");
}


void loop() {

  // PART 1: Read commands from Processing.
  while (Serial.available() > 0) {

    char receivedChar = Serial.read();

    // A newline indicates the end of a command.
    if (receivedChar == '\n' ||
        receivedChar == '\r') {

      command.trim();
      command.toLowerCase();

      // START command.
      if (command == "start" || command == "1") {

        motorRunning = true;
        lastCommandTime = millis();
      }

      // STOP command.
      else if (command == "stop" || command == "0") {

        motorRunning = false;
        lastCommandTime = millis();
      }

      // Clear the command.
      command = "";

    } else {

      // Build up the incoming word.
      if (command.length() < 20) {
        command += receivedChar;
      }
    }
  }


  // PART 2: Check communication timeout.

  // Stop if Processing hasn't communicated.
  if (millis() - lastCommandTime > TIMEOUT) {
    motorRunning = false;
  }


  // PART 3: Update built-in LED.

  digitalWrite(
    LED_BUILTIN,
    motorRunning ? HIGH : LOW
  );


  // PART 4: Move the servo.

  if (motorRunning) {

    unsigned long currentTime = millis();

    // Only move when the interval has elapsed.
    if (currentTime - lastMoveTime >= MOVE_INTERVAL) {

      lastMoveTime = currentTime;

      // Change the angle by one degree.
      angle = angle + direction;

      // Reverse at the maximum angle.
      if (angle >= MAX_ANGLE) {
        angle = MAX_ANGLE;
        direction = -1;
      }

      // Reverse at the minimum angle.
      else if (angle <= MIN_ANGLE) {
        angle = MIN_ANGLE;
        direction = 1;
      }

      // Command the new position.
      motor.write(angle);
    }
  }

  // No delay(), so we can respond to commands
  // without blocking the program.
}

