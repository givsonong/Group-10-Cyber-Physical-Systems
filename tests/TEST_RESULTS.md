# Test results — development summary

We used these tests to work through problems while building the installation. The original test log captured some early servo issues and still contained `PENDING` entries. We continued debugging after those entries were written, and the group has since confirmed that the original tests worked during development. We did not record a new set of detailed measurements or dates for each later check, so this page is a summary of the debugging work rather than a measured performance report.

| Test | What we checked during development | Outcome |
|---|---|---|
| **01 — Servo position** | Basic servo positioning and holding a commanded angle | Worked after debugging the servo setup |
| **02 — Servo pulse diagnostic** | Servo response to 1400, 1500 and 1600 µs commands | Used successfully during servo troubleshooting |
| **03 — Arduino serial** | Reading and interpreting incoming commands | Worked in the original debugging setup |
| **04 — Processing → Arduino** | Sending commands from Processing over USB serial | Communication worked during development |
| **05 — Wekinator classification** | Receiving webcam data and returning four proximity classes | Worked during development; consistency varied with environment |
| **06 — End-to-end integration** | Linking webcam input, classification and Arduino output | The system worked during development |
| **07 — LED ring** | Standalone illumination of the 24-pixel ring | The test sketch is preserved; its result was not separately entered in the recovered results log |

## What changed after the first tests

When we tested the SG90 independently, it could move between the commanded positions. Once we attached the mechanical shell, we found that it struggled with the added load. The structure also needed more weight or support to stay stable during movement. This was an important difference between testing the servo on its own and testing it as part of the installation.

As we worked on the assembled mechanism, we changed the commanded movement from the early fixed positions of **0°, 10°, 20° and 30°** to continuous sweeps of **0–5°, 0–15° and 0–30°**, with different step intervals for each proximity state. The LED ring was also integrated into those modes. We kept the original sketches in the recovered fixed-angle test archive to show how the control system evolved; that archive has not yet been added to the repository.

We recorded two short videos while handling the mechanical shell (`IMG_0590.mp4` and `IMG_0601.mp4`). They provide visual context for the structure and support arrangement, but do not measure servo torque or establish a numerical load limit. The files are awaiting upload to `media/videos/`.

The original results log is preserved in the recovered test archive but has not yet been uploaded to this repository. It records the early problems we were investigating, including unexpected servo behaviour. The later confirmation that the debugging checks worked does not change what was written at that earlier point.

We did not measure exact servo positioning accuracy, end-to-end latency or long-term reliability as part of these debugging checks. Likewise, Wekinator's live classifications were observed during development but were not evaluated using a held-out accuracy test. Our [main project README](../README.md) links to photographs and demonstrations of the installation.