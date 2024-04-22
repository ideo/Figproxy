/*
 Figproxy Arduino Basic Test
A companion to the Figma Figproxy Example file found at https://github.com/ideo/Figproxy
Demonstrates sending and recieving data from Figma using the Figproxy utility

Created by Dave Vondle at IDEO 2024
This example code is in the public domain.
*/

// set pin 12 as the button input.
#define BUTTON 12
bool buttonIsPressed=false;

void setup() {
  // set LED to output - traditional Arduino boards have this on pin 13
  pinMode(LED_BUILTIN, OUTPUT); 
  //set the button to be an input. "INPUT_PULLUP" allows you to connect a button to the pin and ground only.
  pinMode(BUTTON, INPUT_PULLUP);
  // start serial port at 19200 bps:
  Serial.begin(19200);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for native USB port only
  }
}

void loop() {
  ///////////////////////////////Look for messages from Figma and set LED//////////////////////////
  // if we get a valid byte
  if (Serial.available() > 0) {  
    // get incoming byte:
    char incomingByte = Serial.read();
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
    Serial.print('c');
    buttonIsPressed=true;
    //simple debounce
    delay(50);
  }
  //if the last state of the button is pressed, and we see that it is not pressed now
  if (buttonIsPressed==true && digitalRead(BUTTON)==HIGH){
    //send "c" keypress to Figma when a button is pressed
    Serial.print('d');
    buttonIsPressed=false;
    //simple debounce
    delay(50);
  }
}
