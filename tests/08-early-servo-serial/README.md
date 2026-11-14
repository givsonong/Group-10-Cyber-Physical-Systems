# Archived experiment 08 — early servo serial control

[← Tests overview](../README.md) · [Original Arduino sketch](CPS_ServoMotorTest/CPS_ServoMotorTest.ino) · [Final Arduino controller](../../software/arduino/FinalSG90ProximityController/FinalSG90ProximityController.ino)

## Purpose and context

This is an early Arduino Nano Every sketch for experimenting with **Processing-to-Arduino serial control of an SG90 servo**. The original file was committed on 4 November 2026 as `arduino/CPS_ServoMotorTest` without an `.ino` extension. It has been relocated into the tests archive and given the Arduino sketch extension; **the code itself has not been changed**.

The sketch could have served as the Arduino receiving end of a preliminary **webcam/Wekinator → Processing → Arduino** experiment, *if* Processing translated a Wekinator output into its `start` and `stop` commands. However, this Arduino file contains no Wekinator or OSC communication, does not identify a companion Processing sender, and is not by itself evidence that the complete pipeline was successfully tested.

## What the code does

- Runs at **9600 baud**, receives newline- or carriage-return-terminated serial messages, and recognises `start` / `1` and `stop` / `0`.
- Uses a positional **SG90 servo on D9**, initialised at **90°**.
- While running, increments or decrements the commanded position by **1° every 60 ms**, reversing at **30°** and **150°**.
- `stop` **holds the current commanded position**; it does not return the servo to 0°.
- If no valid command refreshes the link for more than **1,000 ms**, sweeping stops. The built-in Arduino LED indicates the running state.
- Does **not** control the 24-pixel external LED ring or implement the final four-class `stop`, `far`, `medium`, `near` protocol.

## Opening and checking the original sketch

Open [`CPS_ServoMotorTest.ino`](CPS_ServoMotorTest/CPS_ServoMotorTest.ino) in Arduino IDE, select **Arduino Nano Every**, and confirm the relevant USB serial port. Arduino sketches normally reside in a folder with the same name as their `.ino` file, as arranged here.

**Safety:** This historical sketch commands a much wider **30°–150°** range than the final assembled mechanism. **Do not run it with the finished kinetic shell attached.** For any isolated servo check, verify clear movement, use an appropriate regulated external 5 V supply for the servo with a common ground, and avoid mechanical obstruction. Close the Arduino Serial Monitor before a Processing application opens the same serial port.

To keep the servo sweeping, a compatible sender must transmit `start\n` (or `1\n`) **more often than once per second**; a one-off `start` will time out. Send `stop\n` to hold position. These are code-derived behaviours, not a newly recorded test result.

## Relationship to later tests

This historical receiver is **not the same as** [Test 01 — servo position](../01-servo-position/README.md), [Test 04 — four-command Processing-to-Arduino communication](../04-processing-to-arduino/README.md), or [Test 06 — four-class end-to-end integration](../06-end-to-end/README.md). They examine different aspects or later versions of the project. The [Processing experiments](../../software/processing/experiments/README.md) document the evolving sender side, but no specific Processing file is asserted here to be an exact companion to this two-command receiver.

**Evidence status:** The original code and its Git history are preserved. No standalone result log or verification of this exact sketch running through Wekinator was found in the repository, so we do not claim a successful end-to-end test for it.
