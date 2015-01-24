#!/bin/bash
set -x
set -e
rm /etc/init.d/cloud9
update-rc.d cloud9 remove
