#!/usr/bin

sed -i '/exit/i \/opt\/openrov\/linux\/copy-to-emmc.sh' /etc/rc.local
sed -i '/exit/i dpkg -r openrov-emmc-copy' /etc/rc.local