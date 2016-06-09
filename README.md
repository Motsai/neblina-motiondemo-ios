
![ProMotion Board](http://i.imgur.com/FvKbWka.jpg)  


Neblina 9 axis sensor fusion iOS & OSX demo applciations
=========  

This repository contains example code to communicate with the Motsai Neblina via Bluetooth Smart (Low Energy).  The examples are written in Swift for both iOS & OSX


Quick Start
-----------

### Prerequisite

* Have on hand a Neblina module or Promotion Kit
* An iPad or iPhone or a MAC with Bluetooth LE capability.
* Follow the hardware quickstart guide to makesure that the Neblina module or Promotion kit is powered on and functionnal.
* Clone or download this repo.

### Functionnal check

Open the NebCtrlPanel project (iOS or OSX), compile and execute the App.  The initial screen will list all available Neblina devices.  Select one of the Neblina that showed up.

iPhone Screen Shot | OSX Screen Shot
---|---
![Imgur](http://i.imgur.com/yOCMsVQ.jpg)|![NebCtrlPanel OSX](http://i.imgur.com/RnfRS5b.png)

---

The iPhone & iPad will switch to the command screen. The "BLE Data Port" switch will be on if the communication with Neblina is successful.  Switch on the Quaternion stream.  The quaternion data should be displayed at the bottom of the screen. 

iPhone Screen Shot | iPad Screen Shot
---|---
![Imgur](http://i.imgur.com/sde4YFf.jpg)|![Imgur](http://i.imgur.com/Mf73hrb.jpg)
---
  
### Making your own App with Neblina

The project NebTurorial1 is the starting point to get a feel of how to connect to the Neblina via Bluetooth and retreive data. 

![Imgur](http://i.imgur.com/CrLCeoW.png)

