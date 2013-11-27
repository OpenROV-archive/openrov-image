#!/bin/sh
export DIR=${PWD#}
export IMAGE=$1	
export OUTPUT_DIR=$DIR/output
export VERSION=2.5-02


. $DIR/lib/libtools.sh
. $DIR/lib/libmount.sh

checkroot


cd $OUTPUT_DIR

mv OpenROV.img OpenROV-$(VERSION).img
md5sum OpenROV-$(VERSION).img > OpenROV-$(VERSION).img.md5 

7zr a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on OpenROV-$(VERSION).img.7z OpenROV-$(VERSION).img