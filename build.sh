#!/bin/bash

export IMAGE=$1

export DIR=${PWD#}

. $DIR/lib/libmount.sh
. $DIR/lib/libtools.sh

checkroot

if [ "$1" = "" ]; then
	echo "Please pass the name of the elinux ubuntu image (from http://elinux.org/BeagleBoardUbuntu) as the first argument."
	exit 1
fi

if [ "$2" = "" ] || [ "$2" = "--bone" ]; then
	build_type="--bone"

elif [ "$2" = "--black" ]; then
	build_type="--bone"
else
	echo "Currently only --bone and --black are supported as targets!"
	exit 1
fi

if [ ! -e $DIR/work/step_01/image.step_01.img ]; then
	$DIR/steps/01_build_image.sh $IMAGE $build_type
fi

if [ ! -e $DIR/work/step_02/image.step_02.img ]; then
	$DIR/steps/02_update_image.sh $DIR/work/step_01/image.step_01.img
fi

$DIR/steps/03_build_packages.sh $DIR/work/step_02/image.step_02.img
$DIR/steps/04_customize_image.sh $DIR/work/step_02/image.step_02.img
$DIR/steps/05_compress_image.sh

