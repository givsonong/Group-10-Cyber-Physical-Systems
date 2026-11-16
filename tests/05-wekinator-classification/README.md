# Test 05 — Camera + Wekinator classifier only

**Objective:** Distinguish errors in Wekinator's *raw* prediction from errors in Processing's confirmation filter. **No Arduino needed; motor electrically disconnected.**

1. Set Wekinator to 144 inputs, one 4-class classifier, OSC input port **6448**, OSC output port **12000**. Load trained model, then start **Run** mode. Only one app should listen on output port 12000.
2. Open and run `FourClassProximityDebug/FourClassProximityDebug.pde` in Processing (Java mode; Video and oscP5 libraries required). Check camera permission and webcam selection in the Processing Console. Model inputs are **16×9 grayscale**, not a geometric distance sensor.
3. Keep the camera stationary. At positions corresponding to the training classes, hold **EMPTY**, **FAR**, **MEDIUM** and **NEAR** for approximately five seconds each, then reverse the sequence. Observe the **latest class**, **confirmed class** and **simulated command** in Processing.
4. The expected classes are **1, 2, 3 and 4**, corresponding to `stop`, `far`, `medium` and `near`. Processing requires two consecutive matching predictions to confirm EMPTY and three for the other classes.

**Failure interpretation:** If no predictions, check ports, whether model is running, and whether 144 input packets arrive. If the **latest** class is wrong, inspect labeling/training, lighting and limited image information. If latest is correct but **confirmed** lags, consider the repetition filter. Correct *latest* classifications do not prove classifier accuracy on new scenes.
