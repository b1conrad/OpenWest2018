# OpenWest2018
Booth demo for OpenWest 2018

## Setup
The components are:
1. a registration kiosk
2. a personal cloud host
3. a multitude of smart phones

### The registration kiosk
A small machine at the booth, running a pico engine.

It has a pico with the OpenWest2018.kiosk ruleset installed.

For this pico, make a new channel (kiosk/application) and note the ECI.

Launch a browser in kiosk mode with localhost:8080/sky/cloud/ECI/OpenWest2018.kiosk/index.html

A visitor comes to the booth and touches the screen to get a QR Code,
and upon scanning the code she becomes the owner of a personal cloud.

### The personal cloud host
A sufficiently powerful machine in the cloud, running a pico engine.

It is set up to provide owner picos.

The root pico has the the io.picolabs.rewrite ruleset installed.

A child pico, OpenWest 2018, has these ruleset installed:
1. OpenWest2018.keys
2. OpenWest2018.tags

It also has a new channel (/id rewrite), with the corresponding ECI
registered with the root pico's rewrite ruleset to handle events from the kiosk.

This pico has a child pico, Attendees, with these rulesets installed:
1. io.picolabs.subscription
2. io.picolabs.collection
3. OpenWest2018.collection

It also has a new channel (/qr rewrite), with the corresponding ECI
registered with the root pico's rewrite ruleset to handle events from owners.

### The smart phones
Each visitor scans a QR Code at the kiosk using her smart phone.

Her unique code is stored as a cookie, and a personal page is displayed, showing:
1. a DID (distributed identifier) of her personal cloud pico
2. a pin for ownership recovery
3. a QR Code allowing her to introduce her personal cloud to other personal clouds
