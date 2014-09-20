#!/bin/sh

sed -i 's/^\/opt\/openrov\/cockpit\/linux\/rc.local/#\/opt\/openrov\/cockpit\/linux\/rc.local/g' /etc/rc.local
sed -i '/^exit/i \/opt\/openrov\/cockpit\/linux\/copy-to-emmc.sh || true' /etc/rc.local
sed -i '/^exit/i sync' /etc/rc.local
