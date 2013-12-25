#!/usr/bin


sed -i '/\/opt\/openrov\/linux\/copy-to-emmc.sh/d ' /etc/rc.local
sed -i '/dpkg -r openrov-emmc-copy/d ' /etc/rc.local