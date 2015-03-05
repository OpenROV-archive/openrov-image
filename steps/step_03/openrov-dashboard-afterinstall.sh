#!/bin/bash
set -x
set -e
# set the openrov dashboard startup
ln -s /opt/openrov/dashboard/linux/dashboard.service /etc/init.d/dashboard
update-rc.d dashboard defaults 21

chown -R rov /opt/openrov/dashboard
chgrp -R admin /opt/openrov/dashboard
