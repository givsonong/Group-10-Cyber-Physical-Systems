# Test 06 — Full pipeline (Wekinator → Arduino physical output)

**Objective:** Verify that a real Wekinator prediction propagates through Processing into a physical servo output. This is the key isolated *end-to-end* test; it intentionally uses **immediate position changes** (not the final eased-motion algorithm) to make distinct outputs easy to confirm.

**Required before running:** Test 01 must show stable positional actuation. Correct external regulated servo power and common ground; ensure mechanism's full 0–30° range is safe. Resolve any previous USB overcurrent problem first.

1. Upload `EndToEndServoReceiver/EndToEndServoReceiver.ino` to Nano Every; close Arduino Serial Monitor.
2. In `EndToEndProximityTest/EndToEndProximityTest.pde`, inspect `Serial.list()` and update `ARDUINO_PORT` to the Nano Every's current `/dev/cu.*` name, which may have changed.
3. Open your **trained** Wekinator 144-input / 4-class model; configure input `6448` and output `12000`; run Wekinator. Start Processing (Video, Serial and oscP5 libraries required).
4. With camera fixed and training-distance markers, test empty → far → medium → near → medium → far → empty. Expected settled servo targets **0° → 10° → 20° → 30° → 20° → 10° → 0°**.
5. Disconnect/stop Wekinator predictions: Processing should show `WAITING` and send `stop`, returning the servo towards 0°. If Processing itself stops or USB serial drops, Arduino's 1-second message timeout should command 0°. **Neither behaviour is a hardware emergency stop**.
6. Log actual results, unstable predictions, latency, power and mechanical problems in `../TEST_RESULTS.md`.

**Diagnose from the GUI:** Raw class wrong → training/vision; confirmed class wrong → filter; GUI correct but servo not responding → serial/Arduino/wiring/power. Arduino receiver acknowledges only in code through target updates; Processing currently does not parse the acknowledgment.

**Limits:** The four labels require matching Wekinator training. A 16×9 brightness classifier cannot guarantee correct nearest-person identification when multiple people are in view. Record these limits honestly.
