#!/bin/sh

echo "Setting up OpenROV samba configuration"
testparm -s /etc/samba/smb.conf.openrov > /etc/samba/smb.conf

echo "Disable samba startup on system startup"
sed -i 's/start on.*/#start on (local-filesystems and net-device-up)/' /etc/init/smbd.conf
sed -i 's/start on.*/#start on (local-filesystems and net-device-up IFACE!=lo)/' /etc/init/nmbd.conf