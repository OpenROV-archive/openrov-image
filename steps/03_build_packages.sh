#!/bin/bash
export DIR=${PWD#}
export IMAGE=$1
export STEP_02_IMAGE=$DIR/work/step_02/image.step_02.img
export STEP_03_IMAGE=$DIR/work/step_03/image.step_03.img

. $DIR/lib/libtools.sh
. $DIR/lib/libmount.sh

checkroot

if [ "$1" = "" ] && [ ! -f $STEP_02_IMAGE ]; then
	echo "Please pass the name of the Step 2 image file or make sure it exists in: $STEP_02_IMAGE"
	exit 1
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
#cp $STEP_02_IMAGE $STEP_03_IMAGE
echo -----------------------------
echo done
echo -----------------------------
echo Compiling packages
echo -----------------------------

$DIR/steps/step_03/01_build_nodejs.sh
$DIR/steps/step_03/02_build_openrov-cockpit.sh $STEP_03_IMAGE
$DIR/steps/step_03/03_build_mjpegstreamer.sh $STEP_03_IMAGE
$DIR/steps/step_03/04_build_ino.sh $STEP_03_IMAGE
$DIR/steps/step_03/04_build_dtc.sh $STEP_03_IMAGE
$DIR/steps/step_03/05_build_avrdude.sh $STEP_03_IMAGE

