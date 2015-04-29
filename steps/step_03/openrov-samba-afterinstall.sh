#!/bin/bash
set -x
set -e

echo "Ensure samaba lock folder exists"
mkdir -p /var/run/samba

echo "Setting up OpenROV samba configuration"
testparm -s /etc/samba/smb.conf.openrov > /etc/samba/smb.conf

echo "Disable samba startup on system startup"
update-rc.d samba disable
