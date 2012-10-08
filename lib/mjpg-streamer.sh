#!/bin/sh
# call with: nodejs.sh ~/work/ https://github.com/joyent/node.git v0.8.11 ~/node_deploy/

export AR=arm-linux-gnueabihf-ar
export CC=arm-linux-gnueabihf-gcc-4.6
export CXX=arm-linux-gnueabihf-g++-4.6
export LINK=arm-linux-gnueabihf-g++-4.6

type $AR >/dev/null 2>&1 || { echo >&2 "I require $AR but it's not installed.  Aborting."; exit 1; }
type $CC >/dev/null 2>&1 || { echo >&2 "I require $CC but it's not installed.  Aborting."; exit 1; }
type $CXX >/dev/null 2>&1 || { echo >&2 "I require $CXX but it's not installed.  Aborting."; exit 1; }
type $LINK >/dev/null 2>&1 || { echo >&2 "I require $LINK but it's not installed.  Aborting."; exit 1; }

export DIR=$1
export URL=$2
export DESTINATION=$3

if [ ! -d $DIR ]
then
 	mkdir $DIR
fi
cd $DIR

wget $URL -O mjpg-streamer.tgz
tar zxf mjpg-streamer.tgz
cd mjpg-streamer
make DESTDIR=$DESTINATION install

SCRIPT_DIR="`dirname \"$0\"`"
cp $SCRIPT_DIR/install_mjpg-streamer.sh $DESTINATION/install.sh 

