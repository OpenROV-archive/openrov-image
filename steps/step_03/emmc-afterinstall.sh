#!/bin/sh

sed -i 's/^\/opt\/openrov\/linux\/rc.local/#\/opt\/openrov\/linux\/rc.local/g' /etc/rc.local
sed -i '/^exit/i \/opt\/openrov\/linux\/copy-to-emmc.sh || true' /etc/rc.local
sed -i '/^exit/i dpkg -r openrov-emmc-copy' /etc/rc.local
sed -i '/^exit/i sync' /etc/rc.local