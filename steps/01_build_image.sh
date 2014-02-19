#!/bin/bash
export DIR=${PWD#}
export IMAGE=$1
export STEP_01_IMAGE=$DIR/work/step_01/image.step_01.img

. $DIR/lib/libtools.sh

checkroot

if [ "$1" = "" ]; then
	echo "Please pass the name of the elinux ubuntu image (from http://elinux.org/BeagleBoardUbuntu) as the first argument."
	exit 1
fi

if [ "$2" = "" ] || [ "$2" = "--bone" ]; then
	uboot=bone
	image_suffix=

elif [ "$2" = "--black" ]; then
	uboot=bone_dtb
	image_suffix=-black
else
	echo "Currently only --bone and --black are supported as targets!"
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
sed -i 's/\[1024\*800\]/\[1024*1700]/' setup_sdcard.sh

echo "Building image file!"
sleep 1
./setup_sdcard.sh --uboot $uboot --img || exit 1

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
fi

echo ------------------------------
echo step_01 done, written image to: $STEP_01_IMAGE
echo ------------------------------
