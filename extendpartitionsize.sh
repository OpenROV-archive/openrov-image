#!/bin/bash
set -e

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root or with sudo" 1>&2
   exit 1
fi

echo "d
n
p
1

+8G
p
w
" | fdisk /dev/sda1

touch /var/_RESIZE_ROOT_
