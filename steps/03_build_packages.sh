#!/bin/bash
export DIR=${PWD#}
export IMAGE=$1
export STEP_02_IMAGE=$DIR/work/step_02/image.step_02.img
export STEP_03_IMAGE=$DIR/work/step_03/image.step_03.img

. $DIR/lib/libtools.sh
. $DIR/lib/libmount.sh

checkroot

if [ "$1" = "--no-cockpit" ]; then
	export NO_COCKPIT=1

elif [ "$1" = "--no-dashboard" ]; then
	export NO_DASHBOARD=1

elif [ "$1" = "-r" ]; then
	export REUSE=1

elif [ "$1" = "" ] && [ ! -f $STEP_02_IMAGE ]; then
	echo "Please pass the name of the Step 2 image file or make sure it exists in: $STEP_02_IMAGE"
	exit 1
fi

if [ "$2" = "--no-cockpit" ]; then
	export NO_COCKPIT=1

elif [ "$2" = "--no-dashboard" ]; then
	export NO_DASHBOARD=1
fi

echo -----------------------------
echo Step 3: creating copy of image to compile software:
echo "> $STEP_03_IMAGE"
echo -----------------------------

IMAGE_DIR_NAME=$( dirname $STEP_03_IMAGE )

if [ ! -d $IMAGE_DIR_NAME ]
then
	mkdir -p "$IMAGE_DIR_NAME"
fi
if [ ! "$REUSE" = "1" ]; then
	cp $STEP_02_IMAGE $STEP_03_IMAGE
fi
echo -----------------------------
echo done
echo -----------------------------
echo Compiling packages
echo -----------------------------

$DIR/steps/step_03/00_openrov-image.sh
$DIR/steps/step_03/01_build_nodejs.sh
if [ ! "$NO_COCKPIT" = "1" ]; then
	$DIR/steps/step_03/02_build_openrov-cockpit.sh $STEP_03_IMAGE
fi
if [ ! "$NO_DASHBOARD" = "1" ]; then
	$DIR/steps/step_03/02_build_openrov-dashboard.sh $STEP_03_IMAGE
fi
$DIR/steps/step_03/03_build_mjpegstreamer.sh $STEP_03_IMAGE
$DIR/steps/step_03/04_build_ino.sh $STEP_03_IMAGE
$DIR/steps/step_03/05_build_dtc.sh $STEP_03_IMAGE
$DIR/steps/step_03/06_build_avrdude.sh $STEP_03_IMAGE
$DIR/steps/step_03/07_build_cloud9.sh
$DIR/steps/step_03/08_setup_samba.sh
$DIR/steps/step_03/09_emmc-copy.sh

echo -----------------------------
echo Done step 3
echo -----------------------------
