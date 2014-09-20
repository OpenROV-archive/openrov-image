#!/bin/sh

# set the openrov startup
ln -s /opt/openrov/proxy/openrov-proxy.service /etc/init.d/openrov-proxy
update-rc.d openrov-proxy defaults


