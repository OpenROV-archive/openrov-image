#!/bin/bash
set -x
set -e
# set the openrov startup
ln -s /opt/cloud9/cloud9.service /etc/init.d/cloud9

update-rc.d cloud9 stop 20 0 1 6 .
