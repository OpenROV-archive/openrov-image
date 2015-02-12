#!/bin/bash
set -x
set -e
DIR="$( cd "$( dirname "$0" )" && pwd )"
. $DIR/libmount.sh
. $DIR/libtools.sh

echo $DIR

if [ "$1" = "" ]; then

	echo "Please pass the name of the disk image you want to chroot into!"
	exit 1
fi


mount_image $1
