# Archived Processing experiments

[← Processing README](../README.md)

These sketches help trace how the Processing side of the installation developed. **They are not the sketch used in the final demonstration.** Open each sketch from its own folder in Processing Java mode; do not run multiple sketches listening on OSC port **12000** at the same time.

| Sketch | What it was used to explore | Notes |
|---|---|---|
| [WebcamToWekinator4Class](WebcamToWekinator4Class/WebcamToWekinator4Class.pde) | Sampling a webcam frame into **144 grayscale features** and receiving four-class Wekinator predictions | No Arduino serial control. Useful for isolating the camera/ML link. |
| [ProximityServoControl_4Class](ProximityServoControl_4Class/ProximityServoControl_4Class.pde) | Combining camera inputs, filtered four-class predictions and Arduino text commands | Earlier serial implementation with 200 ms scheduled sends; USB path may differ from the final file. |
| [Wekinator_LED_Monitor](Wekinator_LED_Monitor/Wekinator_LED_Monitor.pde) | Monitoring a **three-class** Wekinator output and previewing blinking LED timing | Different project and binary serial protocol. **Do not use with the final four-class servo/LED firmware.** |

The three-class LED monitor states in its header that it was adapted from `sketch_261013c.pde`, an example attributed in the supplied source to Becky Stewart (2022). It is archived to distinguish that earlier exercise from our final implementation, not as evidence that the final controller uses three classes.

The standalone [KeyboardSerialTest](../../../tests/04-processing-to-arduino/KeyboardSerialTest/KeyboardSerialTest.pde) belongs under **tests/** rather than experiments because it isolates one connection in the final four-class system. The [final Processing sketch](../FinalSG90ProximityControllerProcessing/FinalSG90ProximityControllerProcessing.pde) is the one to use with Wekinator Project 3 and the integrated Arduino controller.
