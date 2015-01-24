#!/bin/bash
set -x
set -e
/etc/init.d/openrov-proxy stop

update-rc.d openrov-proxy remove
rm /etc/init.d/openrov-proxy
