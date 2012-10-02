#!/bin/sh
# call with: nodejs.sh ~/work/ https://github.com/joyent/node.git v0.8.11 ~/node_deploy/
export AR=arm-linux-gnueabi-ar
export CC=arm-linux-gnueabi-gcc
export CXX=arm-linux-gnueabi-g++
export LINK=arm-linux-gnueabi-g++

type $AR >/dev/null 2>&1 || { echo >&2 "I require $AR but it's not installed.  Aborting."; exit 1; }
type $CC >/dev/null 2>&1 || { echo >&2 "I require $CC but it's not installed.  Aborting."; exit 1; }
type $CXX >/dev/null 2>&1 || { echo >&2 "I require $CXX but it's not installed.  Aborting."; exit 1; }
type $LINK >/dev/null 2>&1 || { echo >&2 "I require $LINK but it's not installed.  Aborting."; exit 1; }

export DIR=$1
export NODEGIT=$2
export NODEVERSION=$2
export NODEDIR=$4

if [ ! -d $DIR ]
then
 	mkdir $DIR
fi
cd $DIR

git clone $2 || { echo >&2 "git clone $NODEGIT failed.  Aborting."; exit 1; }
git checkout -b $NODEVERSION
cd node

./configure --without-snapshot --dest-cpu=arm --dest-os=linux  --prefix=$NODEDIR || { echo >&2 "Tried to configure NodeJS but it failed.  Aborting."; exit 1; }

make --jobs=8 || { echo >&2 "Tried to compile NodeJS but it failed.  Aborting."; exit 1; }
make install || { echo >&2 "Tried to install node to $NODEDIR but it failed. Aborting."; exit 1; }


