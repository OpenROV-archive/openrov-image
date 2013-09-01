#!/bin/sh

# install node
cp -r /tmp/work/node /opt/

# update
sudo apt-get -y update
sudo apt-get -y upgrade

# apache gets updated and then started, so we need to stop it again
apache2ctl stop

echo Installing additional packages
sudo apt-get -y install linux-firmware devmem2 python-software-properties python-configobj python-jinja2 python-serial gcc g++ make libjpeg-dev picocom zip unzip dhcpd vim ethtool arduino-core avr-libc avrdude binutils-avr bison flex autoconf libftdi-dev libusb-dev

echo Rebuilding node modules
cd /opt/openrov
/opt/node/bin/npm rebuild

# ino
echo Builing ino
cd /tmp/work/ino
python ez_setup.py
make install

#mjg-streamer
echo Building mjg-streamer
cd /tmp/work/mjpg-streamer/mjpg-streamer
make install

# dtc
echo Building dtc
cd /tmp/work/dtc/
make PREFIX=/usr/ CC=gcc CROSS_COMPILE= all
echo "Installing dtc into: /usr/bin/"
sudo make PREFIX=/usr/ install

# avrdude
echo Building avrdude
cd /tmp/work/avrdude
PATH=/usr/:$PATH
cd avrdude
./bootstrap
./configure --prefix=/usr/ --localstatedir=/var/ --sysconfdir=/etc/ --enable-linuxgpio
make
sudo make install

#fix user
useradd rov -m -s /bin/bash -g admin
echo rov:OpenROV | chpasswd

# set the openrov startup
ln -s /opt/openrov/linux/openrov.service /etc/init.d/openrov
chmod +x /opt/openrov/linux/openrov.service
update-rc.d openrov defaults

#fix hostname
echo OpenROV > /etc/hostname

cat > /etc/hosts << __EOF__
127.0.0.1       localhost
127.0.1.1       OpenROV

__EOF__

## fix dhcp
cat >> /etc/dhcp/dhclient.conf << __EOF__
lease {
interface "eth0";
fixed-address 192.168.254.1;
option subnet-mask 255.255.255.0;
option routers 192.168.254.1;
renew 2 2037/1/12 00:00:01;
rebind 2 2037/1/12 00:00:01;
expire 2 2037/1/12 00:00:01;
}

__EOF__


## fix network

cat > /etc/network/interfaces << __EOF__
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp

auto eth0:0
iface eth0:0 inet static
name Ethernet alias LAN card
address 192.168.254.1
netmask 255.255.255.0
broadcast 192.168.254.255
network 192.168.254.0

# Example to keep MAC address between reboots
#hwaddress ether DE:AD:BE:EF:CA:FE

# WiFi Example
#auto wlan0
#iface wlan0 inet dhcp
#    wpa-ssid "essid"
#    wpa-psk  "password"

# Ethernet/RNDIS gadget (g_ether)
# ... or on host side, usbnet and random hwaddr
iface usb0 inet static
    address 192.168.7.2
    netmask 255.255.255.0
    network 192.168.7.0
    gateway 192.168.7.1


__EOF__

# setup reset and uart for non black BB
cat > /etc/rc.local << __EOF__
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#

# load the device tree overlay for pin 25 (RESET)
echo OPENROV-RESET > /sys/devices/bone_capemgr.7/slots

# setup the 'reset' GPIO configuration
/opt/openrov/linux/reset.sh

exit 0

__EOF__

# create device tree overlay
cd /home/rov/
cat > OPENROV-RESET-00A0.dts << __EOF__
/* 

#compile 
dtc -O dtb -o OPENROV-RESET-00A0.dtbo -b 0 -@ OPENROV-RESET-00A0.dts  
cp OPENROV-RESET-00A0.dtbo /lib/firmware

echo OPENROV-RESET > /sys/devices/bone_capemgr.7/slots

export SLOTS=/sys/devices/bone_capemgr.7/slots
export PINS=/sys/kernel/debug/pinctrl/44e10800.pinmux/pins


*/
/dts-v1/;
/plugin/;

/{
       compatible = "ti,beaglebone", "ti,beaglebone-black";
       part-number = "OPENROV-RESET";
       version = "00A0";

       fragment@0 {
             target = <&am33xx_pinmux>;
            
             __overlay__ {
                  pinctrl_test: openrov_reset_pin {
            pinctrl-single,pins = <

                0x000 0x07  /* P8_25 is the first GPIO pin, therefore offset 0x000 */

                   /* OUTPUT  GPIO(mode7) 0x07 pulldown, 0x17 pullup, 0x?f no pullup/down */
                   /* INPUT   GPIO(mode7) 0x27 pulldown, 0x37 pullup, 0x?f no pullup/down */

            >;
          };
             };
       };

       fragment@1 {
        target = <&ocp>;
        __overlay__ {
            test_helper: helper {
                compatible = "bone-pinmux-helper";
                pinctrl-names = "default";
                pinctrl-0 = <&pinctrl_test>;
                status = "okay";
            };
        };
    };
};

__EOF__
dtc -O dtb -o OPENROV-RESET-00A0.dtbo -b 0 -@ OPENROV-RESET-00A0.dts  
cp OPENROV-RESET-00A0.dtbo /lib/firmware


#cleanup
rm -rf /tmp/*

#remove ubuntu user
userdel -r -f ubuntu

#cleanup home
cd /home
find . -type d -not -name rov -and -not -name . | xargs rm -rf
