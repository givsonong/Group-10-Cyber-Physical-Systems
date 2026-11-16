# Processing — Webcam Input and Proximity Control

[← Back to Main Project](../../README.md) | [Final Processing Code](FinalSG90ProximityControllerProcessing/FinalSG90ProximityControllerProcessing.pde) | [Wekinator Documentation](../wekinator/README.md)

## 1. Overview

We used Processing to connect the webcam, Wekinator and Arduino in our proximity-responsive kinetic installation.

Processing has two main functions. First, it captures webcam images and converts them into grayscale values that Wekinator can use for classification. It then receives Wekinator's predictions and sends the corresponding commands to Arduino, which controls the servo movement and LED brightness.

Our final Processing sketch combines these functions into a single interface, allowing us to see what the webcam captures, monitor Wekinator's predictions and check which commands are being sent to Arduino.

### Software Pipeline

```text
Webcam
   ↓
Processing
   Capture and preprocess webcam image
   Convert to 144 grayscale values
   ↓
Wekinator
   Classify proximity (Classes 1–4)
   ↓
Processing
   Confirm classification
   Convert prediction to command
   ↓
Arduino Nano Every
   ├── SG90 Servo
   └── WS2812B LED Ring
```

Processing handles the communication between the different software components. The servo's movement range, speed and LED brightness are determined by the Arduino code rather than Processing itself.

---

## 2. Processing Development

We developed the Processing software through several iterations, starting with webcam input and Wekinator communication before integrating Arduino control.

We kept the earlier sketches to document how the software developed and to make it easier to isolate individual parts of the system when troubleshooting.

### Initial Experiment — Webcam to Wekinator

**File:** [WebcamToWekinator4Class.pde](experiments/WebcamToWekinator4Class/WebcamToWekinator4Class.pde)

This sketch was used to establish communication between Processing and Wekinator.

It captures the webcam image, reduces it to 144 grayscale values and sends these values to Wekinator through OSC. The sketch also receives classification results and displays them alongside the webcam preview.

At this stage, Processing was only communicating with Wekinator. It was not connected to Arduino.

Keeping this sketch separate allowed us to work on the webcam input and machine-learning classification without involving the physical outputs.

### Second Experiment — Integrating Arduino Control

**File:** [ProximityServoControl_4Class.pde](experiments/ProximityServoControl_4Class/ProximityServoControl_4Class.pde)

We subsequently integrated Arduino communication into the Processing sketch.

This version retained the webcam input and Wekinator classification while adding USB serial communication to Arduino.

It also introduced classification filtering, requiring repeated predictions before changing the active proximity class.

Commands were transmitted every 200 milliseconds to maintain communication with Arduino.

One limitation of this implementation was that a newly confirmed class would only be transmitted during the next scheduled update. This introduced a possible delay between a classification change and the corresponding Arduino command.

### Final Implementation — Proximity Controller

**File:** [FinalSG90ProximityControllerProcessing.pde](FinalSG90ProximityControllerProcessing/FinalSG90ProximityControllerProcessing.pde)

In the final version, we retained the same basic software pipeline while improving how commands were transmitted.

The main change was allowing Processing to send a command immediately whenever the confirmed proximity class changed, rather than waiting for the next 200-millisecond transmission.

We also retained the periodic transmission of commands, classification filtering and communication timeouts.

The final sketch provides a live interface showing the webcam feed, Wekinator's latest prediction, the confirmed classification and the corresponding Arduino command.

### Other Experiments

We also preserved [Wekinator_LED_Monitor.pde](experiments/Wekinator_LED_Monitor/Wekinator_LED_Monitor.pde), an earlier experiment for displaying three-class Wekinator predictions and simulating LED blinking patterns.

This sketch uses a different communication protocol from our final four-class installation and is not intended to run with the final Arduino controller.

All earlier Processing experiments can be found in the [experiments folder](experiments/).

---

## 3. Webcam Input and Image Processing

Our Processing sketch captures images from the webcam at a requested resolution of 1280 × 720 pixels.

However, rather than sending the entire image to Wekinator, we reduce it to a 16 × 9 grid, giving us 144 pixels.

Each pixel is converted into a grayscale brightness value between 0 and 1.

The conversion takes place in `sendWebcamInputs()`:

```java
float brightness =
  (red(c) + green(c) + blue(c)) /
  (3.0f * 255.0f);
```

The resulting 144 values are sent to Wekinator approximately every 125 milliseconds.

We used this lower-resolution representation to reduce the amount of information sent to the classifier while retaining broader visual changes in the webcam image.

For example, when someone approaches the webcam, their face or body occupies a larger proportion of the image. This changes the grayscale values received by Wekinator.

This approach allows us to classify apparent proximity without using a dedicated distance sensor.

However, because the classifier receives information from the entire image, its predictions can also be influenced by changes in the background and lighting.

We encountered this limitation during Wekinator training, which led us to collect additional examples across different environments.

The development of the classifier is documented separately in our [Wekinator README](../wekinator/README.md).

---

## 4. Communication Between Processing, Wekinator and Arduino

Processing uses two communication methods: OSC for communicating with Wekinator and USB serial for communicating with Arduino.

### OSC Communication

Processing sends the 144 grayscale values to Wekinator using the OSC address `/wek/inputs`.

Wekinator then returns a classification through `/wek/outputs`.

| Communication | OSC Address | UDP Port |
|---|---|---|
| Processing → Wekinator | `/wek/inputs` | 6448 |
| Wekinator → Processing | `/wek/outputs` | 12000 |

The `sendWebcamInputs()` function prepares and sends the webcam data.

The `oscEvent()` function receives Wekinator's prediction and checks whether it corresponds to one of our four classes.

### Serial Communication

After Processing confirms a classification, it converts the class number into a text command that Arduino can understand.

| Wekinator Class | Proximity | Serial Command |
|---|---|---|
| 1 | EMPTY — No Person | `stop` |
| 2 | FAR | `far` |
| 3 | MEDIUM | `medium` |
| 4 | NEAR | `near` |

These commands are transmitted to the Arduino Nano Every through USB serial communication at **9600 baud**.

Each command ends with a newline character.

For example:

```java
arduino.write(command + "\n");
```

The Arduino receives the command and determines the corresponding servo movement and LED brightness.

This separation allows Processing to handle the webcam input and classification while Arduino manages the physical outputs.

---

## 5. Classification and Control Logic

One aspect we needed to consider was how frequently the system should respond to changes in Wekinator's predictions.

Because the classifier continuously receives new webcam inputs, its predictions can change even when a person has not significantly moved.

If every prediction were immediately sent to Arduino, brief classification changes could cause the servo and LEDs to switch between behaviours unnecessarily.

We addressed this through several control mechanisms.

### Classification Filtering

Rather than accepting every prediction immediately, Processing requires consecutive matching predictions before confirming a class.

| Classification | Required Consecutive Predictions |
|---|---:|
| EMPTY | 2 |
| FAR | 3 |
| MEDIUM | 3 |
| NEAR | 3 |

This helps reduce unwanted changes between proximity modes.

We use fewer confirmations for EMPTY so the system can return to its resting state more quickly when Wekinator predicts that nobody is present.

Processing displays both the latest Wekinator prediction and the confirmed class, allowing us to observe the effect of this filtering.

### Immediate Command Updates

In the earlier Processing implementation, Arduino commands were sent at fixed 200-millisecond intervals.

For the final implementation, we changed the code so that a newly confirmed command is sent immediately.

This reduces the additional delay between confirming a new proximity class and transmitting the corresponding command.

The 200-millisecond interval is still used to resend the active command when the classification remains unchanged.

### Communication Timeout

The Arduino controller is programmed to return to EMPTY if it does not receive a valid command for approximately one second.

To support this, Processing continues sending the current command every 200 milliseconds.

Processing also monitors whether new webcam frames and Wekinator predictions are being received.

If either becomes unavailable for more than one second, Processing selects `stop` rather than continuing to use an outdated prediction.

### Manual Controls

We included two keyboard controls:

| Key | Function |
|---|---|
| X | Force the system into STOP mode |
| S | Resume automatic proximity control |

These controls allowed us to pause automatic operation without closing Processing.

The STOP command is software-based and does not physically disconnect power from the servo or LEDs.

---

## 6. Testing and Observations

During development, we separated the different software components so that we could investigate communication problems without running the entire installation.

For example, the initial webcam-to-Wekinator sketch allowed us to examine classification results without connecting Arduino.

We also developed a separate Processing sketch for testing serial communication.

### Processing-to-Arduino Serial Test

**File:** [KeyboardSerialTest.pde](../../tests/04-processing-to-arduino/KeyboardSerialTest/KeyboardSerialTest.pde)

This test allows us to send commands to Arduino using the keyboard, without requiring the webcam or Wekinator.

| Keyboard Input | Command | Expected Behaviour |
|---|---|---|
| 0 | `stop` | Servo returns to 0°, LEDs off |
| 1 | `far` | Servo sweeps 0–5°, low LED brightness |
| 2 | `medium` | Servo sweeps 0–15°, medium LED brightness |
| 3 | `near` | Servo sweeps 0–30°, highest LED brightness |

The sketch sends the selected command every 200 milliseconds, matching the periodic communication used in our final Processing implementation.

This test helps isolate problems with serial communication from problems with webcam processing or Wekinator classification.

The full procedure and expected responses are documented in [Test 04 — Processing to Arduino](../../tests/04-processing-to-arduino/README.md).

### Monitoring the Final Processing Interface

The final Processing sketch displays several pieces of information that were useful during development:

- **Latest Wekinator class:** The most recent class received from Wekinator.
- **Confirmed class:** The classification accepted after filtering.
- **Command:** The corresponding command selected for Arduino.
- **Packets:** The number of webcam input packets sent to Wekinator.
- **Arduino status:** Whether the serial connection has been established and the startup delay has elapsed.

These indicators allowed us to distinguish between problems with the webcam, Wekinator and Arduino communication.

For instance, Processing can continue receiving and displaying Wekinator classifications even when Arduino is disconnected.

We used this separation when examining our classification behaviour in different environments.

The classification screenshots included in the [main project README](../../README.md) show examples of the EMPTY, MEDIUM and NEAR states.

These screenshots demonstrate the software classifications and selected commands. They do not, by themselves, confirm that the servo and LED ring responded correctly.

Physical output behaviour must be evaluated through the corresponding hardware and integration tests.

---

## 7. Running Processing

### Software Requirements

The final sketch uses Processing in Java mode with the following libraries:

| Library | Purpose |
|---|---|
| Video | Webcam capture |
| Serial | USB communication with Arduino |
| oscP5 | Sending and receiving OSC messages |

The installation also requires Wekinator and an Arduino Nano Every running the corresponding controller code.

### Setup Instructions

**1. Connect Arduino**

Connect the Arduino Nano Every to the computer and ensure the servo and LED ring are wired correctly.

The servo and LEDs should use a suitable regulated external 5 V power supply, with a shared ground connection to Arduino.

**2. Check the Serial Port**

Open the [final Processing sketch](FinalSG90ProximityControllerProcessing/FinalSG90ProximityControllerProcessing.pde).

The saved sketch currently uses:

```java
final String ARDUINO_PORT =
  "/dev/cu.usbmodem11401";
```

This port is specific to the computer used during development.

Check the available ports in the Processing console and update the value if necessary.

**3. Open Wekinator**

Load the final [Wekinator Project 3](../wekinator/WekinatorProject3/WekinatorProject3.wekproj).

Check that the project uses 144 inputs, one classification output with four classes, and the correct OSC ports.

**4. Run Processing**

Start the Processing sketch.

The webcam preview should appear, and Processing should begin sending the 144 grayscale values to Wekinator.

**5. Start Classification**

Start Wekinator's Run mode.

Processing should begin displaying the latest and confirmed proximity classifications.

**6. Check Arduino Responses**

Move between the EMPTY, FAR, MEDIUM and NEAR conditions.

Observe whether Arduino responds with the corresponding servo movement and LED brightness.

Press **X** to request STOP or **S** to resume automatic control.

### Known Limitations

Our Processing implementation depends on the webcam, Wekinator and Arduino communicating correctly.

Because the image-processing method uses the entire webcam frame, changes in lighting and background can still affect classification.

The Arduino serial port also needs to be configured manually when using a different computer.

Finally, the Processing display confirms that the serial port has opened, but it does not independently verify the physical movement of the servo or the illumination of the LED ring.

Further development could include automatically identifying the correct serial port, improving communication diagnostics and measuring the response time between a change in proximity and the resulting physical output.

---

## Source Files

| File | Description |
|---|---|
| [FinalSG90ProximityControllerProcessing.pde](FinalSG90ProximityControllerProcessing/FinalSG90ProximityControllerProcessing.pde) | Final Processing implementation |
| [WebcamToWekinator4Class.pde](experiments/WebcamToWekinator4Class/WebcamToWekinator4Class.pde) | Webcam input and Wekinator communication prototype |
| [ProximityServoControl_4Class.pde](experiments/ProximityServoControl_4Class/ProximityServoControl_4Class.pde) | Earlier four-class Processing and Arduino integration |
| [Wekinator_LED_Monitor.pde](experiments/Wekinator_LED_Monitor/Wekinator_LED_Monitor.pde) | Earlier three-class LED monitoring experiment |
| [KeyboardSerialTest.pde](../../tests/04-processing-to-arduino/KeyboardSerialTest/KeyboardSerialTest.pde) | Standalone Processing-to-Arduino serial communication test |

**Related documentation:**

[Main Project README](../../README.md) · [Wekinator Development](../wekinator/README.md) · [Processing Experiments](experiments/README.md) · [Serial Communication Test](../../tests/04-processing-to-arduino/README.md)
