#!/bin/bash
set -x
set -e
export DIR=${PWD#}

. $DIR/versions.sh

export CLOUD9_PACKAGE_DIR=$DIR/work/step_03/cloud9
export CLOUD9_DIR=$CLOUD9_PACKAGE_DIR/opt/cloud9

. $DIR/lib/libtools.sh
. $DIR/lib/libmount.sh

checkroot

if [ -d $CLOUD9_DIR ]; then
	sudo rm -rf $CLOUD9_DIR
fi
if [ ! -d $CLOUD9_DIR ]; then
	mkdir -p $CLOUD9_DIR
fi

cd $CLOUD9_DIR
git clone https://github.com/ajaxorg/cloud9.git .
git pull
git checkout $CLOUD9_GITHASH
npm install --arch=armhf

cp $DIR/contrib/cloud9.service $CLOUD9_DIR

cd $DIR/work/packages/
fpm -f -m info@openrov.com -s dir -t deb -a armhf \
	-n openrov-cloud9 \
	-v $CLOUD9_VERSION \
	--after-install=$DIR/steps/step_03/openrov-cloud9-afterinstall.sh \
	--before-remove=$DIR/steps/step_03/openrov-cloud9-beforeremove.sh \
	--description "OpenROV Cloud9 IDE package" \
	-C $CLOUD9_PACKAGE_DIR .
