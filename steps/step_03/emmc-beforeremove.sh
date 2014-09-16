#!/bin/sh

sed -i 's/^#\/opt\/openrov\/cockpit\/linux\/rc.local/\/opt\/openrov\/linux\/rc.local/g' /etc/rc.local
sed -i '/\/opt\/openrov\/cockpit\/linux\/copy-to-emmc.sh || true/d ' /etc/rc.local
sed -i '/^sync/d ' /etc/rc.local
