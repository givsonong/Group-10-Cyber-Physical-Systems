# Tests — debugging the installation

[← Main project](../README.md) · [Processing documentation](../software/processing/README.md) · [Final Arduino controller](../software/arduino/FinalSG90ProximityController/FinalSG90ProximityController.ino)

## 1. Why we tested the parts separately

While developing our proximity-responsive installation, we used small test sketches whenever we needed to check one part of the system without involving everything else. For instance, we could test the servo directly before adding Wekinator, or send a command from Processing without using the webcam. This made it easier to tell whether a problem came from the hardware, serial communication or the classifier.

We started with basic servo and communication checks, then moved towards the complete webcam-to-Arduino interaction. The tests were mainly for debugging during development, rather than a formal performance study.

## 2. Test overview

| Test | What we were checking | Files |
|---|---|---|
| **01 — Servo position** | Whether the SG90 responds to position commands on its own | Recovered test archive (not yet uploaded) |
| **02 — Servo pulse diagnostic** | How the servo responds to different pulse-width commands | Recovered test archive (not yet uploaded) |
| **03 — Arduino serial** | Whether Arduino recognises incoming text commands | Recovered test archive (not yet uploaded) |
| **04 — Processing → Arduino** | Sending commands directly from Processing, without Wekinator | [Test 04](04-processing-to-arduino/README.md) |
| **05 — Wekinator classification** | Checking camera inputs and class predictions separately from the hardware | Recovered test archive (not yet uploaded) |
| **06 — End-to-end integration** | Checking the complete webcam → Wekinator → Arduino interaction | Recovered test archive (not yet uploaded) |
| **07 — LED ring** | Checking the 24-pixel LED ring independently | [LED test sketch](07-led-ring/RingLEDLight/RingLEDLight.ino) |

## 3. How the tests developed with the project

Our earliest Arduino tests used fixed target positions. The SG90 could move when we tested it on its own, but attaching the mechanical shell changed what we needed from the motor. With the shell fitted, we found that the servo struggled with the added load, and the assembly needed more weight or support to stay stable while moving. This became clearer during physical assembly than during the standalone tests.

We adjusted the commanded movement to suit the assembled mechanism, moving from fixed positions of 0°, 10°, 20° and 30° towards continuous sweeps with different ranges and speeds for each proximity class. This did not make the servo more powerful, but it allowed us to design the motion around the movement the structure could accommodate. We kept the original fixed-angle serial and end-to-end sketches in the recovered test archive because they show the earlier approach and how the control code developed. Those archived files have not yet been uploaded to this repository.

### Mechanical integration footage

We recorded two short videos while handling and supporting the assembled shell: `IMG_0590.mp4` and `IMG_0601.mp4`. They show the size of the moving structure and how it was handled during development. The observations about limited servo torque and stability came from our work on the mechanism, not from measured torque values in the footage.

The videos are prepared for the repository at `media/videos/mechanical-shell-assembly-0590.mp4` and `media/videos/mechanical-shell-closeup-0601.mp4`, but the video files have **not yet been uploaded to GitHub**. An earlier [mechanism assembly clip](../media/videos/mechanism-assembly-test.mp4) is already available.

The **current Test 04** uses the final four-command protocol: `stop`, `far`, `medium` and `near`. It also repeats the command every 200 ms, matching the final Processing controller. Test 06 uses the final Processing and Arduino code for checking the complete installation. The older versions of these tests are kept in the archive, rather than being mixed up with the final setup.

The LED ring was tested on its own before being combined with the servo. Its standalone [Arduino sketch](07-led-ring/RingLEDLight/RingLEDLight.ino) is kept under Test 07.

## 4. What we observed

We ran the original debugging tests during development and eventually got the components and communication working. Some of the first servo checks did not behave as expected; the original results log from our recovered test archive records those early observations. That earlier log has not yet been uploaded to this repository. We continued working on the setup after that and confirmed the debugging tests worked, although we did not keep a detailed results sheet for every later retest.

Our [test results summary](TEST_RESULTS.md) records what we checked and what was established during development. We have not added positioning-accuracy figures, measured response times or classifier-accuracy percentages that were not collected.

## 5. Reproducing a check

Open the README for the test you want to run and use the linked sketch. For Arduino tests, select the **Nano Every** and the correct port. Close the Arduino Serial Monitor before a Processing sketch opens the same serial connection. The servo and LED ring need an appropriate **external regulated 5 V supply with a common ground**; check that the moving parts have clearance before powering the mechanism.

For camera and classifier tests, Processing uses the **Video** and **oscP5** libraries, and Wekinator receives **144 grayscale inputs** on UDP **6448** and sends its class output to UDP **12000**. Run only one application listening on that output port at a time.

The individual test files explain their own settings. To run the finished installation, use the [final Processing sketch](../software/processing/FinalSG90ProximityControllerProcessing/FinalSG90ProximityControllerProcessing.pde) and [final Arduino sketch](../software/arduino/FinalSG90ProximityController/FinalSG90ProximityController.ino) together with [Wekinator Project 3](../software/wekinator/WekinatorProject3/WekinatorProject3.wekproj).