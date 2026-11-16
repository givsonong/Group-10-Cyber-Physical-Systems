# Test 04 — Processing to Arduino serial commands

[← Processing documentation](../../software/processing/README.md) · [Test sketch](KeyboardSerialTest/KeyboardSerialTest.pde) · [Final Arduino controller](../../software/arduino/FinalSG90ProximityController/FinalSG90ProximityController.ino)

## Objective

Check that a Processing program can send the **four final control commands** to an Arduino Nano Every **without using a webcam or Wekinator**. This isolates the computer-to-microcontroller link; it is an **integration test** rather than a pure unit test of an individual function.

## Setup

- Arduino Nano Every programmed with the final servo/LED controller.
- SG90 servo signal on **D9** and 24-pixel WS2812B ring data on **D10**.
- Suitable regulated **external 5 V power** for the servo and LEDs, with grounds connected correctly.
- Processing Java mode, with its **Serial** library available.
- [`KeyboardSerialTest.pde`](KeyboardSerialTest/KeyboardSerialTest.pde), using the USB port shown in Processing's `Serial.list()`.

The sketch opens the port at **9600 baud**, allows **2.5 seconds** for Arduino startup, and repeats the selected newline-terminated command every **200 ms**. Close Arduino Serial Monitor and other Processing sketches before running the test; only one program can use the same serial port.

## Procedure and expected response

1. Confirm the wiring and power arrangements, then upload the integrated Arduino sketch.
2. Open `KeyboardSerialTest.pde` and update `ARDUINO_PORT` if needed.
3. Run the Processing sketch. Check that it reports the serial port as open after the startup wait.
4. Press each key and watch the physical outputs for several seconds before moving to the next command.

| Key | Sent command | Expected servo behaviour | Expected LED behaviour |
|---|---|---|---|
| **0** | `stop\n` | Return to **0°** | Off |
| **1** | `far\n` | Repeated **0–5°** sweep, 100 ms/degree | Blue, brightness **10/30** |
| **2** | `medium\n` | Repeated **0–15°** sweep, 50 ms/degree | Blue, brightness **20/30** |
| **3** | `near\n` | Repeated **0–30°** sweep, 20 ms/degree | Blue, brightness **30/30** |

These intervals are **commanded servo steps**, not measurements of actual mechanical speed. The small FAR sweep can be difficult to see without a visible reference marker.

## Troubleshooting

| Observation | Check |
|---|---|
| `PORT ERROR` in Processing | Confirm the USB port path and close other programs using it |
| Processing displays a command but no movement | Check that Arduino is programmed with the **four-command** controller, wiring, supply and common ground |
| Servo moves briefly then stops | Check the 200 ms heartbeat; Arduino times out after about 1 second without valid commands |
| Servo moves but LEDs remain off | Check LED data on D10, external supply and LED connection |
| LED response changes but servo does not | Check servo signal on D9, external power, obstruction and mechanical travel |

This test is separate from the full **webcam → Processing → Wekinator → Processing → Arduino** demonstration. The keyboard input bypasses machine learning so serial communication can be investigated independently.
