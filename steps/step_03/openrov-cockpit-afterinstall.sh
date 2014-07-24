#!/bin/sh

# compile the device tree files
/opt/openrov/cockpit/linux/update-devicetree-oberlays.sh

# set the openrov startup
ln -s /opt/openrov/cockpit/linux/openrov.service /etc/init.d/openrov
chmod +x /opt/openrov/cockpit/linux/openrov.service
update-rc.d openrov defaults

# set the openrov dashboard startup
ln -s /opt/openrov/cockpit/linux/dashboard.service /etc/init.d/dashboard
update-rc.d dashboard defaults 21

chmod +x /opt/openrov/linux/rc.local

chown -R rov /opt/openrov/cockpit
chgrp -R admin /opt/openrov/cockpit

# setup reset and uart for non black BB
cp /etc/rc.local /etc/rc.local_orig
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

/opt/openrov/cockpit/linux/rc.local

exit 0

__EOF__
