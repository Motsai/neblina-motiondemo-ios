



# Neblina&trade; ProMotion Development Kit iOS/OSX Swift
=========  

![ProMotion Board](http://i.imgur.com/FvKbWka.jpg)  

## Neblina&trade;
The Neblina&trade; module is a low-power self-contained [AHRS](https://en.wikipedia.org/wiki/Attitude_and_heading_reference_system), [VRU](https://en.wikipedia.org/wiki/Inertial_measurement_unit) and [IMU](https://en.wikipedia.org/wiki/Inertial_measurement_unit) with [Bluetooth&reg; SMART](https://en.wikipedia.org/wiki/Bluetooth_low_energy) connectivity developed by Motsai. The miniature board built with the latest [HDI PCB](https://en.wikipedia.org/wiki/Microvia) technology, features a high-performance patent-pending sensor fusion algorithm on-board, that makes it perfect for [wearable technology devices](https://en.wikipedia.org/wiki/Wearable_technology) in applications such as [biomechanical analysis](https://en.wikipedia.org/wiki/Biomechanics), [sports performance analytics](https://en.wikipedia.org/wiki/Sports_biomechanics), remote [physical therapy](https://en.wikipedia.org/wiki/Physical_therapy) monitoring, [quantified self](https://en.wikipedia.org/wiki/Quantified_Self) , [health and fitness tracking](https://en.wikipedia.org/wiki/Activity_tracker), among others.

## ProMotion Development Kit
The [ProMotion Development Kit](http://promotion.motsai.com/) serves as a reference design for Neblina integration; adding storage, micro-USB port, battery, and I/O expansion to the Neblina. A NOR flash recorder and an EEPROM module are also included on the ProMotion board. The development kit with the extensive software support allows system integrators and evaluators to start development within minutes.

This repository is part of the development kit that provides a Swift interface to interact with and simulate the behaviour of Neblina.



### Prerequisite

* Have on hand a Neblina module or Promotion Kit
* An iPad or iPhone and a Mac computer with Bluetooth LE capability.
* Follow the hardware [Quick Start guide](http://nebdox.motsai.com/ProMotion_DevKit/Getting_Started) to make sure that the Neblina module or Promotion kit is powered on and functionnal.
* Clone or download this repo.
* XCode 8 is required to compile

### Functionnal check  

Download or Clone this repo using the command

```
$ git clone https://github.com/Motsai/neblina-motiondemo-swift.git
```

Open the NebCtrlPanel project (iOS or OSX), compile and execute the App.  The initial screen will list all available Neblina devices.  Select one of the Neblina that shows up.  

iPhone Screen Shot | OSX Screen Shot
---|---
![iPhone Screen Shot](docs/images/IMG_2887_Overlay.jpg)|![NebCtrlPanel OSX](docs/images/OSX_ScreenShot.png)

---  

The iPhone & iPad will switch to the command screen. The "BLE Data Port" switch will be on if the communication with Neblina is successful.  Switch on the Quaternion stream.  The quaternion data should be displayed at the bottom of the screen.

iPhone Screen Shot | iPad Screen Shot
---|---
![iPhone Screen Shot](docs/images/IMG_2888.jpg)|![iPad Screen Shot](docs/images/iPad_ScreenShot.jpg)
---  

### Making your own App with Neblina  

The project NebTutorial1 is the starting point to get a feel of how to connect to the Neblina via Bluetooth and retreive data.  It is a simple iPhone App that shows a TableView with a list of detected Neblina device, a button to enable Euler Angle Stream and a TextField to display the Euler data.

<p align="center">
<img src="docs/images/iOS_Tutorial1.jpg" alt="Tutorial1 Screen Shot" width="200" />
</p>

#### Need to know when creating new project  

In order to get swift compiler to compile with C defined constant, we need to specify a bridging header.  This is done going into Build Settings and set the Object-C Bridging Header with "Neblina-Bridging-Header.h". This Neblina-Bridging-Header.h header file located in src folder of the root of this repository.  See Xcode screen shot bellow for more details.

![XCode Screen Shot](docs/images/XCode_ScreenShot.png)  

Beside the bridging head, the following files are also needed to be added to the project. They are located in src folder from the root of this repo.    

* FusionEngineDataTypes.h
* Neblina-Bridging-Header.h
* neblina.h
* Neblina.swift
* ProMotion.h  

#### API documentations

http://nebdox.motsai.com
