#!/bin/bash

SSID=PiBroadcast
LOCAL=US
usage() { echo "Usage: \n\tsudo sh start.sh -p <PiBroadcast WiFi password> -s <Custom SSID (defaults: $SSID)> -l <ISO 3166-1 Country Code (default: $LOCAL)>"; }
while getopts "h?p:s:l:" opt; do
    case "$opt" in
      h|\?)
          usage
          exit 0
          ;;
      p)  PASSWORD=${OPTARG}
          ;;
      s)  SSID=${OPTARG}
          ;;
      l)  LOCAL=${OPTARG}
          ;;
    esac
done
shift $((OPTIND-1))

# Make sure password arg is filled
if [ -z "${PASSWORD}" ]; then
    usage
    exit 1
fi


echo "------------------------------------"
echo "Starting ProtestPi"
echo "------------------------------------"

echo "


                           @@@@@@@@@@@@@@@@@@@@@@@@@
                     %@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*
                 /@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.
              #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.
            @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%.       .@@
          @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&                 @@@@@
        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&                      @@@@@@@
       @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                          @@@@@@@@
     /@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.     #@@@                    @@@@@@@@
    *@@@@@@@@@@@                      ,@@@@@@*                     @@@@@@@
    @@@@@@@@                     (@@@  @ @@@.                       .@@@@@@
     %@@@                     @@@@@@,      .@@@@@                      @@@@@
   @@&                          #@@@&  @@@@  @@@  %@@                    @@@
  #@@@@@                           @@,      @@@@@@  /&                    @@
  &@@@@@@@%                        @% @@@@@   @@,  &@&                    @@.
  #@@@@@@@@@@                         @@@@@ *@@@@  @@@                    %@
   @@@@@@@@@@@@%                   @@(      @@@@@(  #                      @
   @@@@@@@@@@@@@@@                     @@@@%     @@*               @@@@@@@@(
    @@@@@@@@@@@@@@@@.                    @@@.  @@@           #@@@@@@@@@@@@@
     @@@@@@@@@@@@@@@@@@                                   @@@@@@@@@@@@@@@@
      @@@@@@@@@@@@@@@@@@@                              .@@@@@@@@@@@@@@@@@
       @@@@@@@@@@@@@@@@@@@@@            @@@          (@@@@@@@@@@@@@@@@@@
        @@@@@@@@@@@@@@@@@@@@@@/     &@@@@@@@/      @@@@@@@@@@@@@@@@@@@,
          @@@@@@@@@@@@@@@@@@@@@@@  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
            @@@@@@@@@@@@@@@@@@@@@@@/  @@@@@@@@@@@@@@@@@@@@@@@@@@@@#
               @@@@@@@@@@@@@@@@@@@@@@@  @@@@@@@@@@@@@@@@@@@@@@@@
                  @@@@@@@@@@@@@@@@@@@@@@/  @@@@@@@@@@@@@@@@@@
                      @@@@@@@@@@@@@@@@@@@@@  @@@@@@@@@@@@
                           .@@@@@@@@@@@@@@@@@/  @@@


"

# Give some time to see the logo
sleep 0.5



# ------------------------------------------------------------------------------
# Start Rocket Chat Setup
# ------------------------------------------------------------------------------

echo "------------------------------------"
echo "Installing RocketChat"
echo "------------------------------------"

# Skip Setup Wizard
# https://github.com/RocketChat/Rocket.Chat/issues/2233#issuecomment-459291066
sudo sh -c 'echo OVERWRITE_SETTING_Show_Setup_Wizard=completed >> /etc/environment'

sudo apt-get install snapd -y

# Start and run Rocket Chat
sudo snap install rocketchat-server

# ------------------------------------------------------------------------------
# End Rocket Chat Setup
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Start Network Config
# ------------------------------------------------------------------------------

# https://www.raspberrypi.org/documentation/configuration/wireless/access-point-bridged.md

echo "------------------------------------"
echo "Configuring Network"
echo "------------------------------------"

# Install the access point and network management software

sudo apt install hostapd -y

sudo systemctl unmask hostapd
sudo systemctl enable hostapd

sudo apt install dnsmasq -y

sudo DEBIAN_FRONTEND=noninteractive apt install -y netfilter-persistent iptables-persistent

# Define the wireless interface IP configuration
if cat /etc/dhcpcd.conf  | grep -q wlan0 ; then
  echo "Skipping wireless interface IP configuration, already completed"
else
  sudo sh -c 'echo interface wlan0 >> /etc/dhcpcd.conf'
  sudo sh -c 'echo "    static ip_address=192.168.4.1/24" >> /etc/dhcpcd.conf'
  sudo sh -c 'echo "    nohook wpa_supplicant" >> /etc/dhcpcd.conf'
fi

# Enable routing and IP masquerading
if test -f /etc/sysctl.d/routed-ap.conf ; then
  echo "Skipping routing and IP masquerading configuration, already completed"
else
  sudo sh -c 'echo net.ipv4.ip_forward=1 >> /etc/sysctl.d/routed-ap.conf'
fi

sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo netfilter-persistent save

# Configure the DHCP and DNS services for the wireless network

if cat /etc/dnsmasq.conf  | grep -q wlan0 ; then
  echo "Skipping DHCP and DNS services configuration, already completed"
else
  sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig

  sudo systemctl enable systemd-networkd

  sudo sh -c 'echo interface=wlan0 >> /etc/dnsmasq.conf'
  sudo sh -c 'echo dhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h >> /etc/dnsmasq.conf'
  sudo sh -c 'echo domain=wlan >> /etc/dnsmasq.conf'
  sudo sh -c 'echo address=/gw.wlan/192.168.4.1 >> /etc/dnsmasq.conf'
fi

# Ensure wireless operation
sudo rfkill unblock wlan

# Configure the access point software
if cat /etc/hostapd/hostapd.conf  | grep -q wlan0 ; then
  echo "Skipping AP configuration, already completed"
else
  sudo sh -c "echo country_code=$LOCAL >> /etc/hostapd/hostapd.conf"
  sudo sh -c 'echo interface=wlan0 >> /etc/hostapd/hostapd.conf'
  sudo sh -c "echo ssid=$SSID >> /etc/hostapd/hostapd.conf"
  sudo sh -c 'echo hw_mode=g >> /etc/hostapd/hostapd.conf'
  sudo sh -c 'echo channel=7 >> /etc/hostapd/hostapd.conf'
  sudo sh -c 'echo macaddr_acl=0 >> /etc/hostapd/hostapd.conf'
  sudo sh -c 'echo auth_algs=1 >> /etc/hostapd/hostapd.conf'
  sudo sh -c 'echo ignore_broadcast_ssid=0 >> /etc/hostapd/hostapd.conf'
  sudo sh -c 'echo wpa=2 >> /etc/hostapd/hostapd.conf'
  sudo sh -c "echo wpa_passphrase=$PASSWORD >> /etc/hostapd/hostapd.conf"
  sudo sh -c 'echo wpa_key_mgmt=WPA-PSK >> /etc/hostapd/hostapd.conf'
  sudo sh -c 'echo wpa_pairwise=TKIP >> /etc/hostapd/hostapd.conf'
  sudo sh -c 'echo rsn_pairwise=CCMP >> /etc/hostapd/hostapd.conf'
fi

# ------------------------------------------------------------------------------
# End Network Config
# ------------------------------------------------------------------------------

echo "------------------------------------"
echo "Done"
echo "------------------------------------"
echo ""

if sudo rfkill | grep -q 'wlan [^un]* blocked' ; then
  echo "Error: unblock wlan to continue, run the command 'sudo rfkill unblock wlan'
        and verify it's set with 'sudo rfkill'"
  echo "Once fixed ProtestPi will be ready on reboot"
else
  echo "ProtestPi will be ready on reboot."
  echo "Best of luck to you"
fi
