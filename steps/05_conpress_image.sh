#!/bin/sh
export DIR=${PWD#}
export IMAGE=$1
export OUTPUT_DIR=$DIR/output

. $DIR/lib/libtools.sh
. $DIR/lib/libmount.sh

checkroot


cd $OUTPUT_DIR

7zr a OpenROV-image.7z OpenROV.img*
md5sum OpenROV-image.7z > OpenROV-image.7z.md5 