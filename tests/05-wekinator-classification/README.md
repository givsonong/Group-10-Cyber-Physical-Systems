# Test 05 — Wekinator classification only

**Aim:** Test the webcam → 144 brightness inputs → Wekinator → OSC prediction chain **without Arduino or a servo**.

1. Disconnect motor power. In Wekinator, load your actual trained **144-input, four-class classifier**; verify class order: **1 empty, 2 far, 3 medium, 4 near**.
2. Verify Wekinator listens to **/wek/inputs :6448**, outputs **/wek/outputs :12000**, then start **Run** mode.
3. Run [FourClassProximityDebug.pde](FourClassProximityDebug/FourClassProximityDebug.pde) in Processing Java mode. Allow webcam access; ensure no other program owns OSC port 12000.
4. Hold the webcam fixed. Stand at consistent marked distances matching your training data, then test **empty → far → medium → near → medium → far → empty**. Hold each position approximately five seconds.
5. Record **Latest class**, **Confirmed class**, and **simulated serial command**, including five trials per class in TEST_RESULTS.md.

Latest is the raw model prediction. Confirmed requires **two consecutive class-1 messages** or **three consecutive messages of any other class**. If Latest is wrong, investigate training labels, frames, ambient light and clothing; if Latest is correct but Confirmed is stale, examine the filter. A 16 × 9 greyscale whole-image classifier cannot intrinsically measure depth or identify the nearest person.

The sketch **does not open Arduino serial** and cannot move the motor.