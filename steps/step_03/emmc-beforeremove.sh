#!/bin/sh

sed -i 's/^#\/opt\/openrov\/linux\/rc.local/\/opt\/openrov\/linux\/rc.local/g' /etc/rc.local
sed -i '/\/opt\/openrov\/linux\/copy-to-emmc.sh || true/d ' /etc/rc.local
sed -i '/dpkg -r openrov-emmc-copy/d ' /etc/rc.local
sed -i '/^sync/d ' /etc/rc.local