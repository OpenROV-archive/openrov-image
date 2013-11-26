#!/bin/sh
export DIR=${PWD#}

export NODEGIT=git://github.com/joyent/node.git
export NODEVERSION=v0.10.17
export NODE_PACKAGE_DIR=$DIR/work/step_03/node


if [ ! -d $NODE_PACKAGE_DIR ] 
then
	mkdir -p $NODE_PACKAGE_DIR
fi

$DIR/steps/step_03/nodejs.sh $DIR/work $NODEGIT $NODEVERSION /opt/node $NODE_PACKAGE_DIR

mkdir -p $DIR/work/packages 
cd $DIR/work/packages
fpm -f -m info@openrov.com -s dir -t deb -a armhf -n openrov-nodejs -v 0.10.17-0 -C $NODE_PACKAGE_DIR .