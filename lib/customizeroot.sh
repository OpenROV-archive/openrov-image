#!/bin/sh

# install node
cp -r /tmp/work/node /opt/
cp -r /tmp/work/node08 /opt/

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

# load the device tree overlay for pin 25 (RESET) and SPI
CAPEMGR=\$( find /sys/devices/ -name bone_capemgr* | head -n 1 )
echo OPENROV-RESET > \$CAPEMGR/slots
echo BB-SPI0DEV > \$CAPEMGR/slots

# setup the 'reset' GPIO configuration
/opt/openrov/linux/reset.sh

exit 0

__EOF__


#change the SPI reset pin for acrdude
sed -i 's/reset = 25/reset = 30/' /etc/avrdude.conf

#change the SPI reset pin for acrdude
sed -i 's/-c arduino/-c arduino-openrov -b 115200/' /opt/openrov/linux/arduino/firmware-upload.sh

# Include node in PATH
echo "PATH=\$PATH:/opt/node/bin/" >> /home/rov/.profile

# add swap file
bash /opt/openrov/linux/addswapfile.sh

#fix arduino version
echo 1.0.5 > /usr/share/arduino/lib/version.txt
#fix arduino library source
cd /usr/share/arduino/
rm -r libraries
tar zxf /tmp/Arduino-1.0.4-libraries.tgz
cd /tmp/

# compile the device tree files
/opt/openrov/linux/update-devicetree-oberlays.sh

#cleanup
rm -rf /tmp/*

#remove ubuntu user
userdel -r -f ubuntu

#cleanup home
cd /home
find . -type d -not -name rov -and -not -name . | xargs rm -rf
