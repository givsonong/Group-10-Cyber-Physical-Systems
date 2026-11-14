# Test results — development summary

We used these tests to work through problems while building the installation. Some of our early servo checks did not behave as expected. We continued working through those issues and eventually got the debugging tests working. We did not record detailed measurements or dates for every retest, so this page summarises what we learned during development rather than presenting a formal performance evaluation.

| Test | What we checked during development | Outcome |
|---|---|---|
| **01 — Servo position** | Basic servo positioning and holding a commanded angle | Worked after debugging the servo setup |
| **02 — Servo pulse diagnostic** | Servo response to 1400, 1500 and 1600 µs commands | Used successfully during servo troubleshooting |
| **03 — Arduino serial** | Reading and interpreting incoming commands | Worked in the original debugging setup |
| **04 — Processing → Arduino** | Sending commands from Processing over USB serial | Communication worked during development |
| **05 — Wekinator classification** | Receiving webcam data and returning four proximity classes | Worked during development; consistency varied with environment |
| **06 — End-to-end integration** | Linking webcam input, classification and Arduino output | The system worked during development |
| **07 — LED ring** | Standalone illumination of the 24-pixel ring | The LED ring worked during standalone debugging |

## What changed after the first tests

When we tested the SG90 independently, it could move between the commanded positions. Once we attached the mechanical shell, we found that it struggled with the added load. The structure also needed more weight or support to stay stable during movement. This was an important difference between testing the servo on its own and testing it as part of the installation.

As we worked on the assembled mechanism, we changed the commanded movement from the early fixed positions of **0°, 10°, 20° and 30°** to continuous sweeps of **0–5°, 0–15° and 0–30°**, with different step intervals for each proximity state. The LED ring was also integrated into those modes. The earlier fixed-angle sketches show how our control approach developed before we arrived at the final movement.

We recorded short videos while handling the mechanical shell. They provide visual context for the structure and support arrangement, but do not measure servo torque or establish a numerical load limit.

We initially encountered unexpected servo behaviour, but later debugging helped us get the setup working. Both the early problems and the adjustments we made were part of developing the installation.

We did not measure exact servo positioning accuracy, end-to-end latency or long-term reliability as part of these debugging checks. Likewise, Wekinator's live classifications were observed during development but were not evaluated using a held-out accuracy test. Our [main project README](../README.md) links to photographs and demonstrations of the installation.