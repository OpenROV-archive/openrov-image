#!/bin/sh
export DIR=${PWD#}

. $DIR/lib/libtools.sh
. $DIR/versions.sh

checkroot

mkdir -p $DIR/work/packages/

cd $DIR/work/packages/
fpm -f -m info@openrov.com -s empty -t deb -a armhf \
	-n openrov-image \
	-v $IMAGE_VERSION \
	-d 'openrov-image'