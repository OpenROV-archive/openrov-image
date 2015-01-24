#!/bin/bash
set -x
set -e
rm /etc/init.d/dashboard

update-rc.d dashboard remove
