#!/bin/sh


#!/bin/sh

export DIR=${PWD#}

export CLOUD9_PACKAGE_DIR=$DIR/work/step_03/cloud9
export CLOUD9_DIR=$CLOUD9_PACKAGE_DIR/opt/cloud9

. $DIR/lib/libtools.sh
. $DIR/lib/libmount.sh

checkroot


if [ ! -d $CLOUD9_DIR ]; then
	mkdir -p $CLOUD9_DIR
fi

cd $CLOUD9_DIR
git clone https://github.com/ajaxorg/cloud9.git .
git checkout 5b62a7c83445ccba9f50592d41a7128b1f1fe868 #latest known working version
npm install --arch=armhf

cd $DIR/work/packages/
fpm -f -m info@openrov.com -s dir -t deb -a armhf -n openrov-cloud9 -v 0.7.0-0 -C $CLOUD9_PACKAGE_DIR .
