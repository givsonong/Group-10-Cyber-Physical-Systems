# Test 04 — Processing to Arduino USB serial

**Aim:** Prove that a Processing keyboard event sends a complete newline-terminated command to Arduino independently of the camera and Wekinator.

**Only perform physical servo movement after tests 01–02 and the external regulated power supply are confirmed safe.**

1. Upload [CommandServoReceiver.ino](CommandServoReceiver/CommandServoReceiver.ino) to Nano Every. The servo signal is D9. A valid command also toggles the built-in LED.
2. **Close Arduino Serial Monitor.** Stop other Processing serial sketches.
3. Run [KeyboardSerialTest.pde](KeyboardSerialTest/KeyboardSerialTest.pde) in Processing Java mode. Open Processing Console, inspect **Serial.list()**, and replace the hardcoded port if necessary.
4. Wait **2.5 seconds** for possible USB serial reset, then press **0, 1, 2, 3** to send stop/far/medium/near.
5. Expected positions: **0°, 10°, 20°, 30°**. Also watch for LED changes; the Processing display means **sent**, not acknowledged.

If there is no response, verify the USB port, line ending, 9600 baud, exclusive port access and powered Arduino. This unit test intentionally commands angles immediately; smooth easing is not part of the communication test.