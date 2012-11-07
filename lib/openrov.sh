#!/bin/sh

export DIR=$1
export OPENROVGIT=$2
export OPENROVBRANCH=$3
export OPENROVDIR=$4
export NPM_CACHE=`npm config get cache`

if [ ! -d $OPENROVDIR ]
then
 	mkdir -p $OPENROVDIR
fi
cd $OPENROVDIR

git clone $OPENROVGIT openrov || { echo >&2 "git clone $OPENROVGIT failed.  Aborting."; exit 1; }
cd openrov
git checkout $OPENROVBRANCH

export AR=arm-linux-gnueabihf-ar
export CC=arm-linux-gnueabihf-gcc-4.6
export CXX=arm-linux-gnueabihf-g++-4.6
export LINK=arm-linux-gnueabihf-g++-4.6
export npm_config_arch=arm
export npm_config_nodedir=$DIR/node

npm install
cd ..
tar zcf openrov.tgz openrov
rm -rf openrov

SCRIPT_DIR="`dirname \"$0\"`"
cp $SCRIPT_DIR/install_openrov.sh $OPENROVDIR/install.sh 
