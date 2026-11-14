# Test 05 — Camera + Wekinator classifier only

**Objective:** Distinguish errors in Wekinator's *raw* prediction from errors in Processing's confirmation filter. **No Arduino needed; motor electrically disconnected.**

1. Set Wekinator to 144 inputs, one 4-class classifier, OSC input port **6448**, OSC output port **12000**. Load trained model, then start **Run** mode. Only one app should listen on output port 12000.
2. Open and run `FourClassProximityDebug/FourClassProximityDebug.pde` in Processing (Java mode; Video and oscP5 libraries required). Check camera permission and webcam selection in the Processing Console. Model inputs are **16×9 grayscale**, not a geometric distance sensor.
3. Keep camera stationary. At matching training positions, hold **empty**, **far**, **medium**, **near** for ~5 seconds each; reverse the sequence. Capture **latest class**, **confirmed class**, and **simulated command** for each.
4. Expected stable classes are **1, 2, 3, 4**, with simulated commands `stop`, `far`, `medium`, `near`. Repeated predictions are needed to confirm class 1 (2 messages) and classes 2–4 (3 messages).
5. Record at least five trials for each class in the `../TEST_RESULTS.md` table, including lighting, distance markers, and variation across people and clothing.

**Failure interpretation:** If no predictions, check ports, whether model is running, and whether 144 input packets arrive. If the **latest** class is wrong, inspect labeling/training, lighting and limited image information. If latest is correct but **confirmed** lags, consider the repetition filter. Correct *latest* classifications do not prove classifier accuracy on new scenes.
