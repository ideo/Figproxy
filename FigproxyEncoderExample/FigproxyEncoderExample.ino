/*
 Figproxy Encoder Example
A companion to the Figma Figproxy Example file found at https://github.com/ideo/Figproxy
Demonstrates sending encoder positions to Figma so we can create a digital facsilile of the knob

Created by Dave Vondle at IDEO 2024
This example code is in the public domain.
*/

#include <Encoder.h>

Encoder myEnc(7, 9);       
bool ledState = LOW;

void setup() {
  pinMode(LED_BUILTIN, OUTPUT);
  Serial.begin(19200);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for native USB port only
  }
}

long oldPosition  = -999;

void loop() {
  long newPosition = myEnc.read();
  //if there is a new position to send
  // sends the character "d" followed by the position of the encoder (ex. d00 is 0, d34 is 34)
  if (newPosition != oldPosition) {
    oldPosition = newPosition;
    int dialPosition=mod((-newPosition/4),100);
    Serial.print('d'); 
    if(dialPosition>9){
      delay(5);
      Serial.print(String(dialPosition).charAt(0)); 
      delay(5); 
      Serial.print(String(dialPosition).charAt(1));
    }else{
      delay(5);
      Serial.print('0'); 
      delay(5); 
      Serial.print(String(dialPosition).charAt(0));
    }
    delay(5);
  }
}

int mod( int x, int y ){  //modulo "%" returns negative numbers. This does not.
  return x<0 ? ((x+1)%y)+y-1 : x%y;
}
