# Test 02 — Pulse-width diagnosis

**Objective:** Distinguish finite position changes from unintended continuous spinning and identify dead/unstable power conditions. **This does not by itself identify the exact servo model.**

Run `ServoPulseTest/ServoPulseTest.ino` on the Nano Every with a mechanically unloaded, independently powered servo (shared ground, D9 signal), then observe each stage. A positional servo should move **a small amount** to each pulse-specified position and hold. A continuous-rotation servo might spin in either direction at 1400/1600 µs and stop around neutral. If *nothing* visibly moves, verify supply voltage/current capacity, wiring, servo condition and whether the range is too small to notice; do not infer that the servo is automatically continuous-rotation. The Serial Monitor text proves command execution only.
