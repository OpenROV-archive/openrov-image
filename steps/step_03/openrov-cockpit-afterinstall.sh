#!/bin/sh

# compile the device tree files
/opt/openrov/linux/update-devicetree-oberlays.sh

# set the openrov startup
ln -s /opt/openrov/linux/openrov.service /etc/init.d/openrov
chmod +x /opt/openrov/linux/openrov.service
update-rc.d openrov defaults

# set the openrov dashboard startup
ln -s /opt/openrov/linux/dashboard.service /etc/init.d/openrov.dashboard
update-rc.d openrov.dashboard defaults

chmod +x /opt/openrov/linux/rc.local

chown -R rov /opt/openrov
chgrp -R admin /opt/openrov

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

/opt/openrov/linux/rc.local

exit 0

__EOF__
