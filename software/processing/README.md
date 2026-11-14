# Processing — webcam input and proximity control

[← Main project](../../README.md) · [Final Processing sketch](FinalSG90ProximityControllerProcessing/FinalSG90ProximityControllerProcessing.pde) · [Wekinator documentation](../wekinator/README.md)

Processing connects the webcam, Wekinator and Arduino in our proximity-responsive installation. We used it both to prepare training inputs and to convert Wekinator's proximity predictions into commands for the moving structure and LED ring. The [final sketch](FinalSG90ProximityControllerProcessing/FinalSG90ProximityControllerProcessing.pde) is the version used for the four-class installation. Earlier sketches are preserved under [experiments/](experiments/) to show how the communication developed.

## 1. Processing's role in the installation

```text
Webcam → Processing (144 grayscale features) → Wekinator (class 1–4)
       → Processing (confirm class and send command) → Arduino
       → SG90 servo and WS2812B LED ring
```

Processing handles both sides of Wekinator: it sends camera inputs over OSC, then receives classification results over OSC. It does not directly set motor angles or LED brightness; the Arduino sketch interprets the serial commands and controls those outputs.

## 2. Webcam input and image processing

In `sendWebcamInputs()`, the sketch copies a camera frame, reduces it from the requested **1280 × 720 capture** to **16 × 9 pixels**, and calculates one brightness value per pixel:

```java
float brightness = (red(c) + green(c) + blue(c)) / (3.0f * 255.0f);
```

This gives **144 values between 0 and 1** for each sampled frame, sent approximately every **125 ms** (subject to Processing's frame timing). The live display also includes a small grayscale preview showing what goes into the model. Working with a 16 × 9 representation reduces the number of features substantially, while retaining broad patterns such as how much of the image a person occupies. It does **not** produce a direct measurement of distance.

The webcam preview can still be displayed at higher resolution; the 16 × 9 image is the classifier input, not the displayed video resolution.

## 3. Communication between applications

| Direction | Protocol / message | Setting |
|---|---|---|
| Processing → Wekinator | OSC `/wek/inputs` | UDP **6448**, 144 float arguments |
| Wekinator → Processing | OSC `/wek/outputs` | UDP **12000**, class 1–4 |
| Processing → Arduino Nano Every | USB serial | **9600 baud**, newline-terminated `stop`, `far`, `medium`, `near` |

`sendWebcamInputs()` constructs the OSC input message. `oscEvent()` reads Wekinator's output, accepts an integer or float class, and ignores messages with another address or a class outside 1–4. `commandForClass()` converts the confirmed class into the text sent to Arduino.

Only **one** sketch or application should listen on OSC port 12000 or hold the Arduino serial port at a time. In particular, do not run the archived prototypes alongside the final sketch.

## 4. Classification and control logic

| Class | Wekinator scene | Processing command | Arduino response |
|---|---|---|---|
| 1 | **EMPTY** — no person | `stop` | Return servo to 0°; LEDs off |
| 2 | **FAR** | `far` | Sweep 0–5°; low blue brightness |
| 3 | **MEDIUM** | `medium` | Sweep 0–15°; medium blue brightness |
| 4 | **NEAR** | `near` | Sweep 0–30°; highest blue brightness |

The final sketch does not act on each prediction immediately. It waits for **two consecutive matching predictions for EMPTY**, or **three for FAR, MEDIUM and NEAR**, before changing the confirmed class. This reduces short-lived switches between modes. The code processes newly received OSC predictions rather than counting the same prediction repeatedly during display refreshes.

The **latest class** is Wekinator's most recent prediction; the **confirmed class** is the value accepted by the filter. The display also shows the selected command and how many camera packets Processing has sent.

## 5. Implementation decisions and earlier experiments

We developed the software in stages rather than beginning with the full physical installation:

| Sketch | Role in development | What it does **not** establish |
|---|---|---|
| [`WebcamToWekinator4Class.pde`](experiments/WebcamToWekinator4Class/WebcamToWekinator4Class.pde) | Webcam → 144 grayscale inputs → Wekinator; on-screen class feedback | No Arduino or servo control |
| [`ProximityServoControl_4Class.pde`](experiments/ProximityServoControl_4Class/ProximityServoControl_4Class.pde) | Adds USB serial commands, prediction filtering and periodic resending | Earlier version: sends changes on the next scheduled heartbeat rather than immediately |
| [`FinalSG90ProximityControllerProcessing.pde`](FinalSG90ProximityControllerProcessing/FinalSG90ProximityControllerProcessing.pde) | Final combined sketch with immediate command updates and status interface | Physical responses still need testing with the connected Arduino |
| [`Wekinator_LED_Monitor.pde`](experiments/Wekinator_LED_Monitor/Wekinator_LED_Monitor.pde) | Separate earlier **three-class** OSC/LED timing monitor | Different serial protocol; **not compatible** with the final four-class Arduino controller |

The main final additions are:

- **Immediate updates on a changed command.** Once the class has been confirmed, the new command is sent without waiting for the next 200 ms heartbeat.
- **200 ms command heartbeat.** Processing regularly repeats the active command because Arduino is configured to return to EMPTY if it receives no valid command for 1 second.
- **1-second stale-data fallback.** If the webcam or Wekinator stops supplying fresh data, Processing selects `stop` rather than continuing from an old prediction.
- **2.5-second serial startup wait.** Opening a serial port can reset the Nano Every; the sketch waits before its ordinary command transmissions.
- **Manual controls.** Press **X** to request `stop`, or **S** to resume automatic classification. This is a **software stop, not an electrical power cut-off**.

These features are implementation choices visible in the sketches; they do not, by themselves, prove performance or safety under every condition.

## 6. Testing and observations

The Processing interface can demonstrate whether webcam packets are being sent and whether Wekinator returns valid classes. It can also show whether the expected command has been **selected**. That is different from confirming that the Arduino received the command or that the servo and LEDs moved correctly.

We kept a standalone [keyboard serial test](../../tests/04-processing-to-arduino/KeyboardSerialTest/KeyboardSerialTest.pde) to isolate Processing → Arduino communication **without requiring a webcam or Wekinator**. Its [test procedure](../../tests/04-processing-to-arduino/README.md) describes the expected response to each command and provides a place to record actual observations. This complements the complete camera-to-output test.

| Check | Expected evidence | What it does not prove |
|---|---|---|
| Camera input | Grayscale preview visible; packet count increases | Wekinator classification accuracy |
| OSC classification | Latest and confirmed classes update | Arduino is connected |
| Command mapping | `stop`, `far`, `medium`, `near` displayed appropriately | Servo or LED response |
| Serial integration | Keyboard test transmits the four commands | Full camera/ML pipeline works |
| Communication fallback | Selected mode becomes `stop` when fresh input is lost | A physical emergency stop |

We observed that some scene classifications became more consistent after collecting Wekinator training data in different environments. The discussion of the three model versions belongs in the [Wekinator README](../wekinator/README.md), not in the Processing code documentation. These observations were not a formal measurement of accuracy or response time.

## 7. Running Processing and known limitations

**Requirements:** Processing in Java mode with the **Video**, **Serial** and **oscP5** libraries, a working webcam, the saved [Wekinator Project 3](../wekinator/WekinatorProject3/WekinatorProject3.wekproj), and—when testing the physical installation—the Arduino Nano Every running the matching [Arduino sketch](../arduino/FinalSG90ProximityController/FinalSG90ProximityController.ino).

1. Connect and safely power the Arduino hardware. The servo and LED ring require a suitable **external regulated 5 V supply with common ground**; do not power them through a microcontroller signal pin.
2. In the final Processing sketch, change `ARDUINO_PORT` to the port printed by `Serial.list()` on your computer. The saved sketch currently uses `/dev/cu.usbmodem11401`, which is machine-specific.
3. Open Wekinator Project 3. Confirm **144 inputs**, four output classes, input UDP port **6448** and output UDP port **12000**.
4. Run the final Processing sketch. Its console lists available cameras and serial ports. Start Wekinator's **Run** mode; Processing can still send training inputs without Arduino connected.
5. Check the displayed latest/confirmed classes, commands and the physical responses for EMPTY, FAR, MEDIUM and NEAR. Use **X** for software stop and **S** to resume.

**Limitations:** The first available camera is chosen by default; a different webcam may need to be selected. Lighting and background changes affect the 144 grayscale values. The displayed **Arduino: CONNECTED** status only means the port opened and the startup delay elapsed—it does not acknowledge movement or illumination. Likewise, **Arduino: NOT READY** does not invalidate the Wekinator classification shown on screen. The archived experiments may use other USB paths and protocols and are not substitutes for the final sketch.

---

**Final sketch:** [`FinalSG90ProximityControllerProcessing.pde`](FinalSG90ProximityControllerProcessing/FinalSG90ProximityControllerProcessing.pde) · **Archived experiments:** [experiments/](experiments/) · **Serial integration test:** [Test 04](../../tests/04-processing-to-arduino/README.md)
