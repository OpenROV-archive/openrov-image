#!/bin/sh

export DIR=$1
export URL=$2
export DESTINATION=$3/

if [ ! -d $DESTINATION ]; then
	mkdir -p $DESTINATION
fi
if [ ! -d $DIR ]
then
 	mkdir -p $DIR
fi
cd $DESTINATION

git clone $URL mjpg-streamer

SCRIPT_DIR="`dirname \"$0\"`"
cp $SCRIPT_DIR/install_mjpg-streamer.sh $DESTINATION/install.sh 

