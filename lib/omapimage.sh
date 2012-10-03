#!/bin/sh

#type $LINK >/dev/null 2>&1 || { echo >&2 "I require $LINK but it's not installed.  Aborting."; exit 1; }

export DIR=$1
export OMAPGIT=$2
export OMAPBRANCH=$3

if [ ! -d $DIR ]
then
 	mkdir $DIR
fi
cd $DIR

git clone $2 || { echo >&2 "git clone $NODEGIT failed.  Aborting."; exit 1; }
cd omap-image-builder
echo "Checking out $OMAPBRANCH $DIR"
git checkout $OMAPBRANCH
touch release

export ADDITIONS_FOLDER=$DIR/additions/
./build_image.sh


