# Test 02 — servo pulse-width diagnostic

**Aim:** Help distinguish a positional servo from one responding to pulse-width as continuous rotation, while investigating no-motion or unexpected-spin observations.

**Prerequisites:** Safe external regulated 5 V servo power, shared Arduino ground, signal D9, servo unloaded. Do not test if the earlier USB overcurrent issue is unresolved.

Upload [ServoPulseTest.ino](ServoPulseTest/ServoPulseTest.ino), open Serial Monitor at 9600 baud, and observe **1500 µs → 1400 µs → 1500 µs → 1600 µs → 1500 µs**.

For a **positional SG90**, commands generally yield small **finite** angular movements followed by holding. The difference may be hard to see. For a **continuous-rotation** servo, 1500 µs may be near neutral and 1400/1600 µs may produce opposite directions of ongoing rotation; exact neutral varies.

If there is no visible motion, do not conclude the test passed. Record whether the horn moves, holds, jitters or rotates continuously, then inspect supply, ground and connections.