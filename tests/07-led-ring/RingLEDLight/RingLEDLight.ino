
#include <FastLED.h>

// LED ring configuration
#define DATA_PIN     10
#define NUM_LEDS     24
#define BRIGHTNESS   10
#define LED_TYPE     WS2812B
#define COLOR_ORDER  GRB

CRGB leds[NUM_LEDS];

void setup() {

  // Initialise the LED ring.
  FastLED.addLeds<LED_TYPE, DATA_PIN, COLOR_ORDER>(
    leds, NUM_LEDS
  );

  // Keep brightness low for initial testing.
  FastLED.setBrightness(BRIGHTNESS);

  // Turn ALL 24 LEDs red.
  fill_solid(leds, NUM_LEDS, CRGB::Blue);

  // Send the colour information to the ring.
  FastLED.show();
}

void loop() {

  // Nothing needed here.
  // All LEDs remain illuminated.
}
