#!/bin/sh

# install node
cp -r /tmp/work/node /opt/

# update
sudo apt-get -y update
sudo apt-get -y upgrade

# apache gets updated and then started, so we need to stop it again
apache2ctl stop

sudo apt-get -y install linux-firmware devmem2 python-software-properties python-configobj python-jinja2 python-serial gcc g++ make libjpeg-dev picocom zip unzip dhcpd vim ethtool arduino-core avr-libc avrdude binutils-avr

cd /opt/openrov
/opt/node/bin/npm rebuild

# ino
cd /tmp/work/ino
python ez_setup.py
make install

#mjg-streamer
cd /tmp/work/mjpg-streamer/mjpg-streamer
make install


#fix user
useradd rov -m -s /bin/bash -g ubuntu -G admin
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

cat > /etc/network/interfaces.std << __EOF__
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
name Ethernet alias LAN card
address 192.168.254.1
netmask 255.255.255.0
broadcast 192.168.254.255
network 192.168.254.0
# Example to keep MAC address between reboots
#hwaddress ether DE:AD:BE:EF:CA:FE

auto eht0:0
iface eth0:0 inet dhcp

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
# By default this script does nothing.

/opt/openrov/linux/reset.sh
/opt/openrov/linux/setuart.sh

exit 0

__EOF__


#cleanup
rm -rf /tmp/*

