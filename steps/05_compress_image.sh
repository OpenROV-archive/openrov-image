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
for f in *.img; do
md5sum $f > $f.md5

7zr a -t7z -m0=lzma2 -mx=9 -mfb=64 -md=32m -ms=on $f.7z $f
done
