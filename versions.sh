#!/bin/sh

if [ "$IMAGE_VERSION" = "" ]; then
	export IMAGE_VERSION=2.5-custom
fi

if [ "$COCKPIT_VERSION" = "" ]; then
	export COCKPIT_VERSION=2.5.0-custom
fi

if [ "$DASHBOARD_VERSION" = "" ]; then
	export DASHBOARD_VERSION=1.0.0-custom
fi

export NODE_VERSION=0.10.17
export NODE_PACKAGE_VERSION=${NODE_VERSION}-1

export MJPG_VERSION=2.0-1
export INO_VERSION=0.3.6-3
export DTC_VERSION=1.4-1
export AVRDUDE_VERSION=6.0.1-1
export CLOUD9_VERSION=0.7.0-2
export SAMBA_CONFIG_VERSION=0.1-1
export EMMCCOPY_VERSION=0.1-0
export OROV_ARDUINO_FIRMWARE_VERSION=latest-master
