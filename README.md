# ProtestPi

A local [Rocket.Chat](https://rocket.chat/) server without need for an internet connection.

## Motivation 

The motivation behind this project was to provide people at protests or other civil unrest activites a way to locally communicate with eachother using their smart phones or other WiFi capable devices without needing to be connected to the internet. This can provide peace of mind for communication or serve as a workaround where the local internet is down or disrupted.

## Prerequisites

* A Raspberry Pi with Wifi
  * Save yourself the headache and get one that has the WiFi built in
  * I used a Raspberry Pi 4 2GB for developing and testing this guide
* A Micro SD card with the RaspberryPi OS loaded
  * This guide could also likely work with other flavors as well, they're just not tested
* A power source for the Raspberry Pi
  * Wall plug or battery
* A host machine to setup the PI via SSH or a Keyboard/Mouse and a display for the Raspberry Pi to set it up

## Installation

1. Package Manager Update and Upgrade
  * `sudo apt update -y && sudo apt upgrade -y`
2. Reboot the Raspberry Pi
  * `sudo systemctl reboot`
    * If you don't reboot now your network setup **will** fail
3. Set Enviornment Variable to skip Rocket.Chat Setup Wizard
  * `sudo sh -c 'echo OVERWRITE_SETTING_Show_Setup_Wizard=completed >> /etc/environment'`
4. Install Snap
  * `sudo apt install snapd -y`
5. Install Rocket.Chat
  * `sudo snap install rocketchat-server`
7. Setup the Raspberry Pi as a routed wireless access point
  * [Raspberry PI Offical Guide](https://www.raspberrypi.org/documentation/configuration/wireless/access-point-routed.md)

You should now be able to connect a WiFi device to your Raspberry Pi wireless access point. Navigating to `http://localhost:3000` or `http://192.168.4.1` will bring you to the Rocket.Chat server and allow you to register accounts. Dummy values can be used for the email addresses. 
