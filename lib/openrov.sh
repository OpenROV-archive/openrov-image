#!/bin/sh

export DIR=$1
export OPENROVGIT=$2
export OPENROVBRANCH=$3
export OPENROVDIR=$4

if [ ! -d $OPENROVDIR ]
then
 	mkdir -p $OPENROVDIR
fi
cd $OPENROVDIR

git clone $OPENROVGIT openrov || { echo >&2 "git clone $OPENROVGIT failed.  Aborting."; exit 1; }
cd openrov
git checkout $OPENROVBRANCH

SCRIPT_DIR="`dirname \"$0\"`"
cp $SCRIPT_DIR/install_openrov.sh $OPENROVDIR/install.sh 
