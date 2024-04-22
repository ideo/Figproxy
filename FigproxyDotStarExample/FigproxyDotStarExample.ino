/*
 Figproxy Arduino Basic Test
A companion to the Figma Figproxy Example file found at https://github.com/ideo/Figproxy
Demonstrates sending LED Colors as hex bytes to a DotStar LED strip

Created by Dave Vondle at IDEO 2024
This example code is in the public domain.
*/

#include <Adafruit_DotStar.h>
// Because conditional #includes don't work w/Arduino sketches...
#include <SPI.h>         // COMMENT OUT THIS LINE FOR GEMMA OR TRINKET
//#include <avr/power.h> // ENABLE THIS LINE FOR GEMMA OR TRINKET

#define NUMPIXELS 8 // Number of LEDs in strip

// Here's how to control the LEDs from any two pins:
#define DATAPIN    4
#define CLOCKPIN   5
Adafruit_DotStar strip(NUMPIXELS, DATAPIN, CLOCKPIN, DOTSTAR_BGR);
// The last parameter is optional -- this is the color data order of the
// DotStar strip, which has changed over time in different production runs.
// Your code just uses R,G,B colors, the library then reassigns as needed.
// Default is DOTSTAR_BRG, so change this if you have an earlier strip.

// Hardware SPI is a little faster, but must be wired to specific pins
// (Arduino Uno = pin 11 for data, 13 for clock, other boards are different).
//Adafruit_DotStar strip(NUMPIXELS, DOTSTAR_BRG);

void setup() {

#if defined(__AVR_ATtiny85__) && (F_CPU == 16000000L)
  clock_prescale_set(clock_div_1); // Enable 16 MHz on Trinket
#endif

  Serial.begin(19200);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for native USB port only
  }

  strip.begin(); // Initialize pins for output
  strip.show();  // Turn all LEDs off ASAP
}

void loop() {
  // if we get a valid byte
  if (Serial.available() > 0) {  
    // gets the first byte which we are using for the led number:
    byte ledNum = Serial.read();
    Serial.println(ledNum);
    strip.setPixelColor(ledNum, getColor());
    strip.show();   
  }
}

//this takes a set of 3 bytes and turns it into a color value
uint32_t getColor(){
  uint32_t color = 0;
  while (Serial.available() < 3); // Wait for at least 3 bytes
  for (int i = 16; i >= 0; i -= 8) { // decrement by 8 each time, starting from 16
    color += ((uint32_t)Serial.read()) << i; // Ensure the read byte is cast to uint32_t before shifting
  }
  return color;
}
