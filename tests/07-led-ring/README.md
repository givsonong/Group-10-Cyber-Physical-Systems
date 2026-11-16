# Test 07 — Standalone LED Ring Test

[← Tests overview](../README.md) · [Arduino test sketch](RingLEDLight/RingLEDLight.ino) · [Final Arduino controller](../../software/arduino/FinalSG90ProximityController/FinalSG90ProximityController.ino)

## Objective

Check that the Arduino Nano Every can control the 24-pixel WS2812B LED ring independently, before integrating it with the servo motor and Wekinator.

This test uses a simple Arduino sketch to illuminate all 24 LEDs in blue at a fixed, low brightness.

## Setup

- Arduino Nano Every connected to a computer through USB.
- WS2812B LED ring with its data input (DIN) connected to Arduino **D10**.
- Suitable regulated external **5V power supply** for the LED ring, with a common ground shared with the Arduino.
- Arduino IDE with the **FastLED** library installed.
- [`RingLEDLight.ino`](RingLEDLight/RingLEDLight.ino) uploaded to the Arduino.

The sketch is configured for 24 WS2812B LEDs with a GRB colour order and a FastLED brightness value of **10/255**.

## Procedure and Expected Response

1. Check the LED ring's power, ground and DIN connections before switching on the external supply.
2. Open `RingLEDLight.ino` in Arduino IDE and select **Arduino Nano Every** and the correct USB port.
3. Upload the sketch.
4. Once the program starts, all 24 LEDs should illuminate in blue and remain continuously lit.

The program sets the LEDs during `setup()`. The `loop()` function is empty, so there is no animation or change in brightness.

This test checks basic LED illumination and data communication separately from the rest of the installation. The different brightness levels used in the final proximity-responsive system are controlled by the integrated Arduino program.

## Troubleshooting

| Observation | What to check |
|---|---|
| LED ring does not light up | Check the external 5V supply, ground connections and whether D10 is connected to DIN rather than DOUT |
| Only some LEDs illuminate | Check the data connection, supply stability and the LED ring itself |
| LEDs display an unexpected colour | Check the `COLOR_ORDER` setting and the LED ring's specifications |
| LEDs flicker or behave inconsistently | Check the power supply, shared ground and data connection |

This test does not require Processing or Wekinator. Once the LED ring works independently, the [final Arduino controller](../../software/arduino/FinalSG90ProximityController/FinalSG90ProximityController.ino) can be used to test how its brightness changes with the four proximity states.
