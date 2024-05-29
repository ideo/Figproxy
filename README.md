# What Is Figproxy?
- Figproxy is a tool that enables rapid prototyping of tangible user experiences allowing Figma prototypes to talk to the external world.  
- More specifically, it's a utility that allows bidirectional communication between Figma and physical hardware for prototyping interactions that involve screens and physical elements like motors, lights, sensors etc.  
- It's designed to talk to hardware prototyping platforms like Arduino.
- It's a nod to [serproxy](https://github.com/cetola/serproxy) by Stefano Busti & [David Mellis](https://github.com/damellis)

## Why Did You Make It?
At [IDEO](ideo.com) I work on a lot of physical product designs that incorporate displays. I commonly work with UX designers whose tool of choice for rapid iteration of experiences is Figma. This allows me to connect their designs to hardware I work on in the initial design phase, and can enable tangible experiences without having to develop software that duplicates the on-screen interactions.

## What Does it Run On? (MacOS)
- Currently, and for the forseeable future, this is a **MacOS app only**. It would have to be developed from the ground up for Linux or Windows and I don't have time to do it.  
- An iOS app is interesting but I'm not sure if it's possible.  
- I am 100% behind someone else taking this idea and porting it to another platform.

## Use Cases
- **Kiosks** - Soda Machines, Jukeboxes, Movie Ticket Printers, ATMs
- **Vehicle UI** - Control lights, radio, seats etc.
- **Museum Exhibits** - Make a button or action that changes what is on the screen
- **Home Automation** - Prototype a UI to trigger lights, locks, shades etc. And make it actually work
- **Hardware "Sketching"** - Quickly test out functionality with a physical controller and digital twin before building a more complicated physical prototype
- **Games** - Make a physical spinner or gameplay element that talks to a Figma game
- **A ton more** - I'm excited to see what you do with it!

## Installation
- Download the Figproxy App from [the github releases](https://github.com/ideo/Figproxy/releases) also found on the right of this page →
- Open "Figproxy.pkg" and follow the prompts. This will install Figproxy in your Applications Folder
- Find Figproxy in your Applications and open it.
- You will get this prompt, hit OK
  <img width="413" alt="Screen Shot 2024-04-16 at 11 35 21 PM" src="https://github.com/ideo/Figproxy/assets/915950/a9fc3260-8203-4ecb-a4b9-b564d2ce2f8f">
- If the system asks you to choose a default browser, select "Figproxy" as your default. 
- After Figproxy is set as the system default, Select the browser that was currently your default browser when this window pops up (For example Google Chrome)
  <img width="912" alt="Screen Shot 2024-04-16 at 11 36 50 PM" src="https://github.com/ideo/Figproxy/assets/915950/2804e028-47e5-4b3d-b23a-45b04962416f">
- You will also need to give it Accessibility Access:

  <img width="529" alt="Screen Shot 2024-04-16 at 11 35 29 PM" src="https://github.com/ideo/Figproxy/assets/915950/b907964e-a5f0-4fbc-aaa6-cfa2a5326707">
- Click "Open System Preferences" and make sure Figproxy has a check next to it:
  <img width="780" alt="Screen Shot 2024-04-16 at 11 36 05 PM" src="https://github.com/ideo/Figproxy/assets/915950/2d680510-df14-4d34-ae14-67a130930f79">
- That's it!

## How It Works
Figma does not support communication to other software in its API. Because we can't go the official route, Figproxy uses two different "hacks" to achieve communication.
### Speaking Out (Figma → Arduino) 
_Note: I will be using "Arduino" as shorthand for any hardware that can speak over a serial connection as it is by far the most common platform for this usage_  
  
When you specify for Figma to go to a link, Figproxy looks at the link and if it starts with "send" (and not, for instance "http://") we know it is intended to be routed to hardware.  
  
In Figma you can set up an interaction like this: (this sends the character "a")  
<img width="480" alt="send a Figma" src="https://github.com/ideo/Figproxy/assets/915950/138a6e50-0dcb-4b5f-869d-2351696df3e6">  
  
In Arduino, you can listen for a character and perform some action like this:  
~~~
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
~~~
  
If there is more complex data you need to send you can send a string like "hello world!:  
<img width="480" alt="send hello world!" src="https://github.com/ideo/Figproxy/assets/915950/89f5eacc-eb52-443c-9703-dcf7c1fa2754">  
  
You can even send hexadecimal characters by preceding the string with "0x"  
<img width="242" alt="send hex data" src="https://github.com/ideo/Figproxy/assets/915950/22e9ba67-f5e6-416b-a33a-c337a6249921">  
  
### Speaking In (Arduino → Figma) 
In Arduino, you can send a character like this:
~~~
Serial.print('c');
~~~
  
To get data into Figma, Figproxy sends characters as keypress events.  
<img width="480" alt="keypress event example" src="https://github.com/ideo/Figproxy/assets/915950/9d98ad93-9602-4344-bf9e-8c81ee278eba">  

## Software Options & Debugging
- Serial Port: This is the serial port the Arduino is connected to. It will usually look something like "usbmodem101" It will not populate in the list until it is plugged in or connected.
- Baud Rate: The speed that it talks. This needs to match the speed specified in your Arduino code. As a default 19200 is a good choice.
- Browser Setup: Use this to set your secondary default browser again.
- Data Options: These are options in how the serial data is formatted. For Arduino, you should not need to change these.
- Test Send and Receive: you can type in characters to send to Arduino here to test without Figma. You can also see what the Arduino sends to Figma in both UTF-8 (character) encoding and hexadecimal encoding.
- Toggle Pin States: Arduino uses [RTS (Ready to Send)](https://en.wikipedia.org/wiki/RS-232) by default, and [DTR (Data Terminal Ready)](https://en.wikipedia.org/wiki/Data_Terminal_Ready) is needed for sending multiple characters to Arduino.  These are on by default.

## Examples
If you want to try out examples yourself you can [find example Arduino Sketches in this repo](https://github.com/ideo/Figproxy/tree/main/Arduino%20Examples) and the [Figma files here](https://www.figma.com/community/file/1364647996816473533/figproxy-examples)

### Figproxy Arduino Basic Test
Demonstrates sending and receiving data from Figma using the Figproxy utility.  
![1_basic](https://github.com/ideo/Figproxy/assets/915950/b08d2b44-bffc-4c11-acfb-595776d28bb6)  
[![Figproxy Arduino Basic Test](https://img.youtube.com/vi/f7j1NB-l-T4/0.jpg)](https://www.youtube.com/watch?v=f7j1NB-l-T4)  
[_Video Link_](https://www.youtube.com/watch?v=f7j1NB-l-T4)

### Figproxy Dotstar Example
This allows you to control the colors of an LED strip from Figma. It also shows off raw hex-value data sending.  
![2_dotstar](https://github.com/ideo/Figproxy/assets/915950/28d2647d-03be-4e93-a216-1448d19bc0a4)  
[![Figproxy Dotstar Example](https://img.youtube.com/vi/d6X2Jo2njD4/0.jpg)](https://www.youtube.com/watch?v=d6X2Jo2njD4)  
[_Video Link_](https://www.youtube.com/watch?v=d6X2Jo2njD4)

### Figproxy Encoder Example
This pushes the limits of Arduino→Figma communication - where we make a digital twin of a knob that has 100 different positions and make a "locker combo simulator" to show how we can use Figproxy to make complex interactive dynamic prototypes.  
![3_encoder](https://github.com/ideo/Figproxy/assets/915950/f4829b09-2af7-477a-81ef-0133627f0841)  
[![Figproxy Encoder Example](https://img.youtube.com/vi/kLc0z3UV_Xo/0.jpg)](https://www.youtube.com/watch?v=kLc0z3UV_Xo)  
[_Video Link_](https://www.youtube.com/watch?v=kLc0z3UV_Xo)
