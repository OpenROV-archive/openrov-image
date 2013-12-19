#!/bin/sh

export DIR=${PWD#}

. $DIR/versions.sh

export NODEGIT=git://github.com/joyent/node.git
export NODE_PACKAGE_DIR=$DIR/work/step_03/node


if [ ! -d $NODE_PACKAGE_DIR ] 
then
	mkdir -p $NODE_PACKAGE_DIR
fi

$DIR/steps/step_03/nodejs.sh $DIR/work $NODEGIT v${NODE_VERSION} /opt/node $NODE_PACKAGE_DIR

mkdir -p $DIR/work/packages 
cd $DIR/work/packages
fpm -f -m info@openrov.com -s dir -t deb -a armhf \
	-n openrov-nodejs \
	-v $NODE_PACKAGE_VERSION \
	--description "OpenROV NodeJS package" \
	-C $NODE_PACKAGE_DIR .
