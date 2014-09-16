#!/bin/sh

/etc/init.d/openrov-proxy stop

update-rc.d openrov-proxy remove
rm /etc/init.d/openrov-proxy

