#!/bin/bash
set -x
set -e
export DIR=${PWD#}

. $DIR/versions.sh

export EMMCCOPY_PACKAGE_DIR=$DIR/work/step_03/emmc-copy

. $DIR/lib/libtools.sh
. $DIR/lib/libmount.sh

cd $DIR/work/packages/
fpm -f -m info@openrov.com -s empty -t deb -a armhf \
	-n openrov-emmc-copy \
	-v $EMMCCOPY_VERSION \
	-d 'openrov-cockpit' \
   --after-install=$DIR/steps/step_03/emmc-afterinstall.sh \
	--before-remove=$DIR/steps/step_03/emmc-beforeremove.sh \
   --description "Package to copy the content of the image to the bbb eMMC"
