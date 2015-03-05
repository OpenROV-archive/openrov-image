#!/bin/bash
set -x
set -e
export DIR=${PWD#}
export IMAGE=$1
export OUTPUT_DIR=$DIR/output

. $DIR/lib/libtools.sh
. $DIR/lib/libmount.sh
. $DIR/versions.sh

checkroot


cd $OUTPUT_DIR

mv OpenROV.img OpenROV-${IMAGE_VERSION}.img
md5sum OpenROV-${IMAGE_VERSION}.img > OpenROV-${IMAGE_VERSION}.img.md5

7zr a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on OpenROV-${IMAGE_VERSION}.img.7z OpenROV-${IMAGE_VERSION}.img
