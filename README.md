<!--suppress HtmlDeprecatedAttribute -->
<img align="left" width="125" height="125" src="https://github.com/ruberVulpes/ProtestPi/blob/main/readme/protest-pi-logo-500.png?raw=true" alt="Protest Pi Logo">

# ProtestPi

A [Rocket.Chat](https://rocket.chat/) server hosted on a [Raspberry Pi](https://www.raspberrypi.org/) available only to those on a local WiFi hosted on the Raspberry Pi. No need for an internet connection.

<br></br>

## Motivation 

The motivation behind this project was to provide people at protests or other civil unrest activities a way to locally communicate with another using their smartphones or other WiFi capable devices without needing to be connected to the internet. 
This can provide peace of mind for communication or serve as a workaround where the local internet is down or disrupted.

## Support Me 

[![](https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif)](https://www.paypal.com/donate?hosted_button_id=U65R5REYQXAR8)

## Prerequisites

* A Raspberry Pi model with built in WiFi 
  * I used a Raspberry Pi 4 2 GB for developing and testing this guide
* A Micro SD card with the RaspberryPi OS loaded
  * This guide could also likely work with other flavors as well, they're just not tested
* A power source for the Raspberry Pi
  * Wall plug or battery
* A host machine to set up the PI via SSH or a Keyboard/Mouse and a display for the Raspberry Pi to set it up

## Installation

1. Package Manager Update and Upgrade
    * `sudo apt update -y && sudo apt upgrade -y`
1. Reboot the Raspberry Pi
    * `sudo shutdown -r now`
    * If you don't reboot now your network setup **will** fail
1. Clone this Repository
    * `git clone git@github.com:ruberVulpes/ProtestPi.git`
1. Navigate to the source directory 
    * `cd ProtestPi`
1. Start the installation script
    * `sudo sh install.sh -p <Password for the WiFi network>`
    * You can use the `-s` flag to customize the SSID of the network
        * This is optional and will default to `PiBroadcast`
    * You can use the `-l` flag to change the [Country Code](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) for the network
        * This is optional and will default to `US`
1. Reboot the Raspberry Pi
    * `sudo shutdown -r now`

You should now be able to connect a WiFi device to your Raspberry Pi's wireless access point. 
Navigating to `http://localhost:3000` or `http://192.168.4.1:3000` will bring you to the Rocket.Chat server and allow you to register accounts. 
Dummy values can be used for the email addresses. 
The first User registered will serve as the server Admin. 

## Future Work 

* Adjust `install.sh` to allow a User to update the SSID/Password on subsequent runs
* SSL/Domain name for the Rocket.Chat instance
* Would like to test extending the Raspberry PI's WiFi via an external Access Point connected via Ethernet
* Many User testing would be cool to see what real world performance would be like 

