# Test 01 — Positional servo on Nano Every

**Objective:** Prove Arduino can command and hold four target positions without Processing or Wekinator. **Precondition:** safe independent regulated 5 V servo power with shared ground; servo horn unburdened; signal D9.

1. Open `ServoPositionTest/ServoPositionTest.ino`, choose **Arduino Nano Every** and upload.
2. Open Serial Monitor at **9600 baud**.
3. Watch the horn as each message appears. It should reach the new angle promptly and **hold** for the remainder of its 5-second interval.
4. Write down angular movement, direction, hold behaviour, vibration or unexpected rotation.

**Interpretation:** Printing target messages verifies only that the software ran; it does *not* verify that the motor moved. `delay(5000)` is a *hold period*, **not** a five-second speed ramp. If the servo spins continuously, investigate physical model, power and wiring before attributing the fault to Wekinator.
