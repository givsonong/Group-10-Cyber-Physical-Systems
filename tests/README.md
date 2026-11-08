# CPS proximity project — repeatable subsystem tests

This directory is the testing manual for the **webcam → Processing → Wekinator → Processing → Arduino Nano Every → SG90-style positional servo** pipeline.

The tests are **not a substitute for the final project code**. They isolate failures, state expected observations, and provide a place to record actual results. Only mark a test as PASS after your group has executed it.

## Expected model and outputs

| Trained class | Interpretation | Serial word | Target |
|---|---|---|---|
| 1 | No person | stop | 0 degrees |
| 2 | Far | far | 10 degrees |
| 3 | Medium | medium | 20 degrees |
| 4 | Near | near | 30 degrees |

These labels are **assumptions**: check that the saved Wekinator model uses this exact order. Processing sends 144 input values (16 × 9 greyscale pixel brightness values), **not** four inputs.

## Safety before powering an actuator

1. **Do not power a servo from the USB-fed Arduino 5 V pin.** Use an appropriately rated *regulated 5 V external servo supply*, and connect its negative/ground to Arduino GND (common ground). Connect the servo signal wire to Arduino D9. Never put the 5 V supply on a GPIO pin.
2. A USB overcurrent warning occurred in earlier development. Do not perform powered actuator tests until the wiring and external power are checked.
3. Disconnect motor power before rewiring. Test without mechanical load first; confirm every commanded position is mechanically safe and keep fingers clear.
4. A serial command named **stop** sets a target of 0 degrees. Neither that command nor a serial timeout is a hardware emergency power cutoff.
5. Tests 03 and 05 do **not** require a powered servo. Prefer them when hardware power is unresolved.

## Prerequisites and workflow

- Arduino IDE with Nano Every selected, Servo library, correct USB serial port, baud **9600**.
- Processing Java mode; Video, oscP5 and Serial libraries as needed.
- Wekinator trained project: **144 inputs / 1 classifier output / 4 classes**. Input OSC address **/wek/inputs**, UDP **6448**. Output **/wek/outputs**, UDP **12000**.
- **Close Arduino Serial Monitor** before running Processing with the Arduino serial port. **Stop Processing** before uploading a new Arduino sketch.
- Arduino and Processing require sketches in identically named folders (already arranged here).
- A source file existing in this repository does **not** mean its operation has been physically verified.

## Run the tests in this order

**Test 01 is the primary servo-position test. Test 02 is an optional diagnostic if Test 01 behaves unexpectedly.** Both move the servo, but they answer different questions; first check power, wiring and mechanical clearance before attempting either test.

| Test | Subsystem isolated | What you should observe | Servo required? |
|---|---|---|---|
| [01](01-servo-position/README.md) | Arduino → servo | Servo moves to several positions and holds | Yes |
| [02](02-servo-pulse-diagnostic/README.md) | Pulse-width diagnosis | Finite movements for a positional servo | Yes |
| [03](03-arduino-serial/README.md) | USB serial parser | Text command maps to the correct numeric target | No |
| [04](04-processing-to-arduino/README.md) | Processing → Arduino serial | Pressing 0–3 produces matching outputs | Yes, for physical check |
| [05](05-wekinator-classification/README.md) | Webcam → Wekinator → Processing | Latest and confirmed classes reflect each controlled scene | No |
| [06](06-end-to-end/README.md) | Whole software/hardware pipeline | Confirmed proximity class produces expected servo target | Yes |

**Failure isolation:** If 01 fails, inspect power/wiring/mechanical load before blaming ML. If 03 passes but 04 fails, inspect serial port, startup wait, line endings and baud rate. If the raw class is wrong in 05, inspect training, framing and lighting. If raw class is right but confirmed class is wrong, inspect the consecutive-prediction filter. If tests 01, 04, 05 pass but 06 fails, inspect OSC ↔ serial mapping, stale-prediction fallback, and power.

Keep raw results in [TEST_RESULTS.md](TEST_RESULTS.md), with screenshot/video filenames and test date. Do not replace failed observations with hypothetical ones.

**Attribution:** This test-suite source and prose were drafted with assistance from OpenAI ChatGPT (November 2026). The team is responsible for verifying, adapting and citing assisted code under the module's generative-AI policy.