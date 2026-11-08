# Test 01 — positional servo unit test

**Aim:** Establish whether the SG90-style servo moves to requested positions and holds without webcam, Processing or Wekinator.

**Requirements:** Arduino Nano Every, Servo library, signal connected to D9, properly rated external regulated servo supply with **common ground**, unloaded servo with a free 60°–120° range. USB-supplied motor power is not acceptable.

1. Disconnect actuator power before checking wiring. Verify supply and mechanical freedom.
2. Upload [ServoPositionTest.ino](ServoPositionTest/ServoPositionTest.ino).
3. Open Serial Monitor at **9600 baud**.
4. Observe the sequence **90 → 60 → 90 → 120 degrees**, holding each position for five seconds.

**Expected:** A standard positional servo makes finite moves and then holds each position. The printed messages indicate issued commands, **not** measured shaft angles.

**If it fails:** Disconnect motor power; inspect external power, shared ground, D9 signal, motor model label, load and connections. Record observations in the main test log. Do not mark PASS merely because Serial Monitor prints.