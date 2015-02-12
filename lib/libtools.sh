#!/bin/bash

function checkroot() {
	if [ "$(id -u)" != "0" ]; then
	   echo "This script must be run as root or with sudo" 1>&2
	   exit 1
	fi
}

_umount() {
	[[ $# -lt 2 ]] && {
	echo "Usage: ${FUNCNAME} <timeout_secs> <mnt_point>"; return 1
}
timeout=$(($(date +%s) + ${1}))
until umount -R "${2}" 2>/dev/null || ( mountpoint "${2}" | grep 'is not a mountpoint' ||[[ $(date +%s) -gt $timeout ]]); do
	:
done
}
