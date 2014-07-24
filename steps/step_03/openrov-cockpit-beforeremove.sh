#!/bin/sh

rm /etc/init.d/openrov
rm /etc/init.d/dashboard

update-rc.d openrov remove
update-rc.d dashboard remove

cp /etc/rc.local_orig /etc/rc.local
