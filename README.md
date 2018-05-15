# OpenWest2018
Booth demo for OpenWest 2018

# Setup
The components are:
1. a registration kiosk
2. a personal cloud host
3. a multitude of smart phones

## The registration kiosk
A small machine at the booth, running a pico engine.

It has a pico with the OpenWest2018.kiosk ruleset installed.

For this pico, make a new channel (kiosk/application) and note the ECI.

Launch a browser in kiosk mode with localhost:8080/sky/cloud/ECI/OpenWest2018.kiosk/index.html

A visitor comes to the booth and touches the screen to get a QR Code,
and upon scanning the code she becomes the owner of a personal cloud.


