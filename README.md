# Group 10 — Proximity-Responsive Kinetic Installation

**Cyber Physical Systems · 2026**

We built an installation that responds to how close someone appears to a webcam. A machine-learning model classifies the camera view into four proximity states. Those states change the movement of a servo-driven kinetic structure and the brightness of a blue LED ring positioned above a metal basin of water. A standalone vibrator inside the plywood enclosure, beneath the basin, creates ripples and patterns in the water.

![The finished installation during our demonstration](media/images/final-prototype-overview.jpg)

*The assembled installation during our final demonstration.*

[See the prototype](#the-prototype) · [Development](development/development-process.md) · [Hardware and mechanical design](#hardware-and-mechanical-design) · [How it works](#how-it-works) · [Interaction modes](#interaction-modes) · [Source code](#source-code) · [Testing](#testing) · [Setup](#running-the-project)

## The prototype

[**Watch a short demonstration**](media/videos/final-demonstration.mp4)

| Interaction around the light | Kinetic structure and base |
|:---:|:---:|
| ![Participant interacting near the ring](media/images/interaction-closeup.jpg) | ![Kinetic structure above the illuminated basin](media/images/kinetic-structure.jpg) |

The installation combines a plywood enclosure, servo-driven kinetic shell, 24-pixel LED ring and metal water basin. We placed a standalone vibrator inside the enclosure, beneath the basin, to generate ripples in the water while the LED ring illuminates the moving surface. The webcam provides proximity input, which controls the shell's movement and the LEDs' brightness through Processing, Wekinator and Arduino.

We initially planned to use a speaker beneath the water basin to generate ripple patterns through sound vibrations. However, the speaker component did not arrive in time for our final demonstration. Instead, we used a standalone vibrator to create movement in the water. It operated independently of the Arduino-controlled system, which continued to control the kinetic shell and LED ring based on proximity.

### Development in brief

| Exploring the form | Building the mechanism |
|:---:|:---:|
| ![Early concept sketch](media/development/ConceptSketch.jpg) | ![Kinetic structure being assembled](media/development/kinetic-assembly.jpg) |

We explored the installation through sketches and physical mock-ups before fabricating the plywood base and integrating the servo, LED ring, and control electronics. [See our development photographs and short clips](development/development-process.md).


## Hardware and Mechanical Design

Our installation brings together a nautilus-inspired kinetic shell, a supporting structure, an illuminated water basin and a plywood enclosure housing the electronics. The annotated CAD assembly below shows how these components were designed to fit together.

The metal basin was supported by its rim around the plywood enclosure's top opening, keeping the water in a separate vessel from the control electronics housed below. Further assembly and electrical details are documented in the [development process](development/development-process.md#4-building-the-kinetic-structure-and-enclosure) and [Arduino hardware section](software/arduino/README.md#water-basin-and-electrical-separation).

![Annotated CAD assembly of the installation](media/development/full-project-annotated-assembly.jpg)

*Figure: Annotated CAD assembly showing the kinetic mechanism, SG90 servo and mounting bracket, support pipe, LED ring, water basin and enclosure.*

### Kinetic mechanism

We developed the shell's opening and closing mechanism in Fusion 360, drawing inspiration from the linkages used in Louvre windows. Before attaching the servo motor, we explored how the connected arms and pivot points could move the overlapping shell panels together.

| Closed mechanism | Open mechanism |
|:---:|:---:|
| ![Closed mechanism](media/development/NautilusShellClosed.png) | ![Open mechanism](media/development/NautilusShellOpen.png) |

We 3D-printed the mechanism and tried adding wire scaffolding, paper and fabric to give the shell a fuller shape. However, the extra weight and friction made it harder for the SG90 servo to move the structure. For the final demonstration, we left these add-ons off so the mechanism could move more freely.

**Design development:** [View the mechanical design and fabrication process](development/development-process.md#3-cadding-the-kinetic-structure)

### CAD and fabrication files

We kept 3D printing to a minimum, using it only for the kinetic mechanism, the SG90 servo mounting bracket and the LED ring mounting bracket. These custom parts provided the shapes and attachment points needed to assemble the moving mechanism and mount the electronics. We used other materials for the rest of the structure, including the support pipe and plywood enclosure. Wire scaffolding, paper and fabric were explored during prototyping but left off for the final demonstration.

The STEP files are available for inspecting the geometry or adapting the parts.

| Component | CAD file |
|---|---|
| Kinetic mechanism | [Mechanism assembly (STEP)](media/development/Nautilus-Shell-Mechanism-CAD.step) |
| SG90 servo mounting bracket | [Servo mounting bracket (STEP)](media/cad/SG90-Servo-Mounting-Bracket.step) |
| LED ring mounting bracket | [LED ring mounting bracket (STEP)](media/cad/LED-Ring-Mounting-Bracket.step) |

### Electronics and physical components

| Component | Role |
|---|---|
| **Arduino Nano Every** | Receives commands from Processing and controls the servo and LEDs |
| **SG90 servo motor** | Drives the movement of the kinetic shell |
| **3D-printed kinetic mechanism** | Uses interconnected linkages to open and close the shell |
| **3D-printed servo mounting bracket** | Holds the SG90 servo in position for actuation |
| **3D-printed LED ring mounting bracket** | Positions the LED ring above the water basin |
| **Support pipe** | Supports the structure and provides a route for wiring |
| **24-pixel WS2812B LED ring** | Illuminates the moving water with varying levels of blue light, making ripple patterns more visible |
| **Breadboard** | Provides connection points and power rails for assembling the electronics |
| **Imperial DSDE Power Board (Rev. A2)** | Provides external power using its 5V and GND connections; the board has an ON/OFF switch and selectable current limiting |
| **Portable USB battery (power bank)** | Provides the external power source for the Imperial DSDE Power Board |
| **Metal water basin** | Holds the water in which vibrations create ripples and patterns |
| **Standalone vibrator (containing a vibration motor)** | Placed inside the enclosure beneath the basin; creates water ripples using its own power source, independently of Arduino |
| **Plywood enclosure** | Houses the control electronics and the separate standalone vibrator while supporting the basin |

The Arduino controls the servo through **D9** and the LED ring through **D10**. Both respond to the proximity states identified by Wekinator. The standalone vibrator has its own power source and is not connected to the Arduino or the Imperial DSDE Power Board.

For further details, see the [Arduino hardware, wiring and power documentation](software/arduino/README.md#3-hardware-connections-and-power).

## How it works

```mermaid
flowchart TD
    A["Webcam"] --> B["Processing<br/>16 × 9 grayscale features"]
    B -->|"144 floats · OSC /wek/inputs · 6448"| C["Wekinator<br/>4-class k-NN (k = 1)"]
    C -->|"Class 1–4 · OSC /wek/outputs · 12000"| D["Processing<br/>Confirm class + send command"]
    D -->|"USB serial · 9600 baud"| E["Arduino Nano Every"]
    E --> F["SG90 servo · D9"]
    E --> G["WS2812B LED ring · D10"]
```

Processing captures the webcam image, reduces it to a **16 × 9 grayscale grid**, and sends its **144 normalised pixel values** to Wekinator. Wekinator returns a class prediction. Processing checks for consecutive matching predictions before sending `stop`, `far`, `medium`, or `near` to the Arduino.

We use the same serial command for both outputs, so the servo motion and light level change together.

### Interaction modes

| Class | Camera scene | Command | Servo movement | LED brightness |
|---|---|---|---|---|
| 1 | **EMPTY** — no person | `stop` | Returns to 0° | Off |
| 2 | **FAR** | `far` | Repeats 0°–5°; 100 ms per 1° step | Blue, 33% |
| 3 | **MEDIUM** | `medium` | Repeats 0°–15°; 50 ms per 1° step | Blue, 67% |
| 4 | **NEAR** | `near` | Repeats 0°–30°; 20 ms per 1° step | Blue, 100% |

The LED percentages are relative to a deliberately limited **FastLED brightness setting of 30/255**: the four modes use values **0, 10, 20, and 30**. Servo times describe commanded steps rather than measured physical speed.

## Source code

| File | What it does |
|---|---|
| [**Arduino — FinalSG90ProximityController.ino**](software/arduino/FinalSG90ProximityController/FinalSG90ProximityController.ino) | Receives serial commands; sets sweep ranges and timings; controls LED brightness using FastLED |
| [**Processing — FinalSG90ProximityControllerProcessing.pde**](software/processing/FinalSG90ProximityControllerProcessing/FinalSG90ProximityControllerProcessing.pde) | Reads the camera; prepares 144 inputs; exchanges OSC messages with Wekinator; filters classes; sends serial commands |
| [**Wekinator — WekinatorProject3**](software/wekinator/WekinatorProject3/WekinatorProject3.wekproj) | Saved classifier, training data, and model configuration |
| [**Standalone LED test — RingLEDLight.ino**](tests/07-led-ring/RingLEDLight/RingLEDLight.ino) | Checks that the LED ring can be controlled independently |

[**Processing implementation, earlier experiments and serial test**](software/processing/README.md) document how the webcam-to-Wekinator-to-Arduino interface developed and how its communication can be checked separately.

For historical context, we also preserved the [early two-command Processing-to-Arduino servo receiver](tests/08-early-servo-serial/README.md). It is an archived experiment, not the controller used by the finished installation.

The Arduino sweep uses `millis()` instead of blocking delays. Processing sends commands when the confirmed class changes and repeats the active command approximately every 200 ms. If Arduino receives no valid command for more than one second, it returns to the empty state and turns off the LEDs.

## Machine learning

We trained Wekinator using a **1-nearest-neighbour classifier (k = 1)** and examples recorded for four camera scenes. The saved model compares each incoming 144-value input with the recorded examples and predicts the class of its closest neighbour. We chose this straightforward approach because it is easy to train and update during prototyping.

The final saved dataset contains **2,029 examples**:

| EMPTY | FAR | MEDIUM | NEAR | Total |
|---:|---:|---:|---:|---:|
| 551 | 671 | 505 | 302 | **2,029** |

### Classification in Processing

These screenshots show three of the four proximity states captured during classifier testing. Processing displays the Wekinator prediction, the confirmed class, and the corresponding control command.

| EMPTY — Class 1 | MEDIUM — Class 3 | NEAR — Class 4 |
|:---:|:---:|:---:|
| [![Empty scene, class 1](media/images/classification/classification-empty.jpg)](media/images/classification/classification-empty.jpg) | [![Medium proximity, class 3](media/images/classification/classification-medium.jpg)](media/images/classification/classification-medium.jpg) | [![Near proximity, class 4](media/images/classification/classification-near.jpg)](media/images/classification/classification-near.jpg) |
| `stop` | `medium` | `near` |

*These captures document classification in Processing. The Arduino status reads NOT READY, so they are evidence of camera and machine-learning behaviour rather than of physical actuation.*

### FAR classification with Arduino connected

We also tested the FAR proximity state with the Arduino connected. In this screenshot, Wekinator predicts Class 2, Processing confirms FAR and sends the `far` command over the serial connection.

[![FAR classification (Class 2) in Processing, with Arduino connected](media/images/classification/classification-far-connected.jpg)](media/images/classification/classification-far-connected.jpg)

*FAR classification (Class 2) in Processing, with Wekinator running and the Arduino connected.*

The model does **not** measure distance in metres. It identifies visual patterns associated with our training scenes, so camera angle, background, lighting, clothing, and other people in frame can change the result. The figures above describe the training data, not classification accuracy. A further evaluation would compare predictions across new people and environments and explore alternative models or more balanced training data.

## Testing

We tested individual components during development before combining them into a camera-to-output system. The test procedures and recorded evidence are kept separately from this overview:

- [**Test procedures**](tests/README.md)
- [**Test results and observations**](tests/TEST_RESULTS.md)

The tests cover servo position, serial communication, Wekinator classification, and end-to-end behaviour. We also used a [standalone LED sketch](tests/07-led-ring/RingLEDLight/RingLEDLight.ino) before integrating the ring with the servo controller.

![Development setup with exposed wiring and structural components](media/images/prototype-assembly.jpg)

*An earlier build stage, before the final installation was assembled.*

## Running the project

**You will need:** an Arduino Nano Every, SG90 positional servo, 24-pixel WS2812B LED ring, webcam, a suitable regulated external 5 V supply for the servo and LEDs, and a shared ground with the Arduino. The software uses Arduino IDE (`Servo`, `FastLED`), Processing Java mode (`Video`, `Serial`, `oscP5`), and Wekinator.

1. **Connect the hardware.** Servo signal goes to **D9** and LED data input to **D10**. Verify the supply and ground connections before powering anything.
2. **Upload the [Arduino sketch](software/arduino/FinalSG90ProximityController/FinalSG90ProximityController.ino).** Select *Arduino Nano Every* and the correct USB port. Close Processing and Arduino Serial Monitor during the upload.
3. **Open the [Wekinator project](software/wekinator/WekinatorProject3/WekinatorProject3.wekproj).** It expects 144 inputs, one four-class output, and OSC ports **6448** (input) and **12000** (output).
4. **Run the [Processing sketch](software/processing/FinalSG90ProximityControllerProcessing/FinalSG90ProximityControllerProcessing.pde).** Set `ARDUINO_PORT` to the port listed on your computer. Start Wekinator's **Run** mode to receive class predictions.
5. **Try the four proximity scenes.** Watch the latest and confirmed classes in Processing and check the servo and LED responses. Press **X** to request software stop or **S** to resume.

The software stop is not a power cut-off. The ring and servo should not be powered through the Arduino's USB connection to the laptop.

## What we would improve

Stability of the mechanism would improve if it were not directly mounted onto the servo motor. Additionally, a higher torque motor may be used in order to turn the fully loaded mechanism. With more time, we would also test the model on new participants and locations, measure response time, and refine how it handles changing scenes.

## Team

**Group 10**

Julia Becker · Givson Ong · Sejal Mittal

### Acknowledgements

We used **OpenAI ChatGPT (GPT-6)** during development to help draft and troubleshoot portions of the Arduino and Processing code and to edit documentation. We reviewed and adapted those suggestions for our prototype.

**AI tool reference:** OpenAI. (2026). *ChatGPT (GPT-6)* [Generative AI assistant]. https://chatgpt.com/ (used October–November 2026).

Our software also uses the Arduino Servo and FastLED libraries, Processing and oscP5, and Wekinator.
