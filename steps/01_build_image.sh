#!/bin/bash
set -x
set -e
export DIR=${PWD#}
export IMAGE=$1
export STEP_01_IMAGE=$DIR/work/step_01/image.step_01.img

. $DIR/lib/libtools.sh

checkroot

if [ "$1" = "" ]; then
	echo "Please pass the name of the elinux ubuntu image (from http://elinux.org/BeagleBoardUbuntu) as the first argument."
	exit 1
fi

IMAGE_FULLNAME=$(basename "$IMAGE")
IMAGE_NAME=$( basename $IMAGE_FULLNAME .tar.xz )

#
echo Extract the image: $IMAGE${IMAGE}
if which pv > /dev/null ; then
		echo Image ${IMAGE}
			pv "${IMAGE}" | tar -xJf -
		else
			echo "pv: not installed, using tar verbose to show progress"
			tar xvf "${IMAGE}"
		fi

cd $IMAGE_NAME

# fix the size of the image file
sed -i 's/\[1024\*1700\]/\[1024*1900]/' setup_sdcard.sh

# Add docker aware kpart command
sed -ie 's/kpartx -av \${media_loop}/\
kpartx -av \${media_loop}\
# If running inside Docker, make our nodes manually, because udev will not be working\
if [[ -f \/.dockerenv ]]; then\
	dmsetup --noudevsync mknodes\
fi/g' setup_sdcard.sh

echo "Building image files!"
sleep 1
bash -xe ./setup_sdcard.sh --dtb beaglebone --boot_label OPENROV --emmc-flasher --enable-systemd --bbb-old-bootloader-in-emmc --img || exit 1
cp image-2gb.img image-flash-2gb.img
bash -xe ./setup_sdcard.sh --dtb beaglebone --boot_label OPENROV --enable-systemd --bbb-old-bootloader-in-emmc --img || exit 1


IMAGE_DIR_NAME=$( dirname $STEP_01_IMAGE )

if [ ! -d $IMAGE_DIR_NAME ]
then
	mkdir -p "$IMAGE_DIR_NAME"
fi

if [ -f image.img ]
then
	cp image.img $STEP_01_IMAGE
elif [ -f image-2gb.img ]
then
	cp image-2gb.img $STEP_01_IMAGE
	cp image-flash-2gb.img ${STEP_01_IMAGE}.flasher.img
fi

echo ------------------------------
echo step_01 done, written image to: $STEP_01_IMAGE
echo ------------------------------
