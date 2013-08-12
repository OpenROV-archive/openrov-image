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
useradd rov -p temp -g ubuntu -G admin
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
cat >> /etc/udev/rules.d/70-persistent-net.rules << __EOF__
# BeagleBone: net device ()
SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{dev_id}=="0x0", ATTR{type}=="1", KERNEL=="eth*", NAME="eth0"

__EOF__
