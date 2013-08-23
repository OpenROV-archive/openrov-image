#!/bin/bash

function checkroot() {
	if [ "$(id -u)" != "0" ]; then
	   echo "This script must be run as root or with sudo" 1>&2
	   exit 1
	fi
}
