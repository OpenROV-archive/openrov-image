#/bin/sh
echo currently in:
echo `pwd`
DIR="`dirname \"$0\"`"

if [ ! -d /opt/openrov ]; then
	mkdir -p /opt/openrov
fi
cd $DIR
cp -r *.tgz /opt/openrov/
cd /opt/openrov/
tar zxf openrov.tgz
cp -r openrov/* openrov/.git* .
rm -rf openrov

echo "rov ALL=NOPASSWD: /opt/openrov/linux/" >> /etc/sudoers

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

sh /opt/openrov/linux/setuart.sh
sh /opt/openrov/linux/reset.sh #reset arduino to make sure the GPIO is set correctly

exit 0

__EOF__

#enable a fixed IP address on the network interface
cat >> /etc/network/interfaces << __EOF__


auto eth0:0
iface eth0:0 inet static
name Ethernet alias LAN card
address 192.168.254.1
netmask 255.255.255.0
broadcast 192.168.254.255
network 192.168.254.0


__EOF__


ln -s /opt/openrov/linux/openrov.service /etc/init.d/openrov
chmod +x /opt/openrov/linux/openrov.service

if [ -f '/etc/init.d/openrov' ]; then
	update-rc.d openrov defaults
fi  

