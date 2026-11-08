# Test 06 — complete webcam-to-servo pipeline

**Aim:** Verify the entire system from camera through Wekinator classification, Processing OSC and serial communication to Arduino's D9 servo.

**Do not proceed until tests 01, 03, 04 and 05 pass and the servo has a suitable independent regulated supply with common ground.** Ensure the mechanism is free across 0°–30°. The serial "stop" action is *not* a hardware emergency stop.

1. Upload [EndToEndServoReceiver.ino](EndToEndServoReceiver/EndToEndServoReceiver.ino) to Arduino Nano Every. The sketch maps stop/far/medium/near to 0/10/20/30 degrees and returns to 0 if no valid serial message arrives for 1 second.
2. Close Arduino Serial Monitor; check the serial port printed by Processing's Serial.list() against the value in the Processing sketch.
3. Load the trained four-class Wekinator project (144 inputs, input UDP 6448, output UDP 12000) and start its **Run** mode.
4. Run [EndToEndProximityTest.pde](EndToEndProximityTest/EndToEndProximityTest.pde) in Processing Java mode; allow camera access and wait at least 2.5 seconds for serial startup.
5. Hold each scene **empty → far → medium → near → medium → far → empty**, allowing predictions to settle. Observe **Latest raw class**, **Confirmed class**, **Serial command**, and **actual motor position**. Log every discrepancy.
6. With servo mechanically clear, interrupt Processing or the OSC pipeline and observe whether software returns the target to 0. This checks the *software* fallback only, not emergency power cutoff.

**Troubleshooting:** Raw class wrong → check training, lighting, 16×9 image. Confirmed class wrong → inspect confirmation logic. Correct command but wrong motion → check serial port, external power and servo test. No OSC output → check Wekinator Run mode, ports and address.

The end-to-end test commands **immediate target changes**, not the team's final eased movement. Confirm smooth-motion behaviour separately in final application code.