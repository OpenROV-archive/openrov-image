#!/bin/sh

export DIR=$1
export INOGIT=$2
export INODIR=$3

if [ ! -d $INODIR ]
then
 	mkdir -p $INODIR
fi
cd $INODIR

git clone $INOGIT ino || { echo >&2 "git clone $INOGIT failed.  Aborting."; exit 1; }

SCRIPT_DIR="`dirname \"$0\"`"
cp $SCRIPT_DIR/install_ino.sh $INODIR/install.sh 
