#!/bin/sh
export DIR=${PWD#}


. $DIR/lib/libtools.sh

checkroot

mkdir -p $DIR/work/packages/

cd $DIR/work/packages/
fpm -f -m info@openrov.com -s empty -t deb -a armhf \
	-n openrov-image \
	-v 2.5.0-02 \
	-d 'openrov-image'