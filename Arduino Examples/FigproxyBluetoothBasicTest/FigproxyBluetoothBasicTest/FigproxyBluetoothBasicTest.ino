/*
 Figproxy Arduino Wireless Test

Tested with the Adafruit Feather Huzzah32 board.
 
A companion to the Figma file of the same name found at https://github.com/ideo/Figproxy
Demonstrates sending and recieving data from Figma using the Figproxy utility

Connects to The Basic Test file here:
https://www.figma.com/community/file/1364647996816473533

Make sure to connect to the bluetooth device created by this sketch on the mac - "ESP32_Feather" 
and choose this in the serial port selector in Figproxy

TROUBLESHOOTING NOTES: If you try to connect and it kicks you off immediately. Open the connection in Figproxy, and then reconnect.
If the bluetooth menu doesn't show "connect" next to the item. close settings and open it again.

Created by Dave Vondle at IDEO 2025
This example code is in the public domain.
*/

#include "BluetoothSerial.h"

// set pin 12 as the button input.
#define BUTTON 12

BluetoothSerial SerialBT;
bool buttonIsPressed=false;

void setup() {
  // set LED to output - Feather Huzzah32 Arduino boards have this on pin 13
  pinMode(LED_BUILTIN, OUTPUT);
  //set the button to be an input. "INPUT_PULLUP" allows you to connect a button to the pin and ground only.
  pinMode(BUTTON, INPUT_PULLUP);
  // start bluetooth serial port 

  // I think this helps MacOS not boot it off after pairing
  SerialBT.setPin("1234",4);   // enforce pairing PIN
  //Start Bluetooth Serial
  if (!SerialBT.begin("ESP32_Feather")) {
    Serial.println("An error occurred initializing Bluetooth");
  } else {
    Serial.println("Bluetooth started. Pair with 'ESP32_Feather'");
  }
}

void loop() {
  // Communicate connection status here
  //if (SerialBT.hasClient()) {

  //}

  // Echo between USB serial and Bluetooth
  if (SerialBT.available()) {
    // get incoming byte:
    char incomingByte = SerialBT.read();
    //in Figma the "Turn LED On" button sends "a",  "Turn LED Off" sends "b"
    if(incomingByte=='a'){
      digitalWrite(LED_BUILTIN, HIGH);
    }else if(incomingByte=='b'){
      digitalWrite(LED_BUILTIN, LOW);
    }
  }

  ///////////////////////////////Look for Button Press and send to Figma//////////////////////////
  //if the last state of the button is not pressed, and we see that it is pressed now
  if (buttonIsPressed==false && digitalRead(BUTTON)==LOW){
    //send "c" keypress to Figma when a button is pressed
    SerialBT.print('c');
    buttonIsPressed=true;
    //simple debounce
    delay(50);
  }
  //if the last state of the button is pressed, and we see that it is not pressed now
  if (buttonIsPressed==true && digitalRead(BUTTON)==HIGH){
    //send "c" keypress to Figma when a button is pressed
    SerialBT.print('d');
    buttonIsPressed=false;
    //simple debounce
    delay(50);
  }
}
