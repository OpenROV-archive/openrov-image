#!/bin/bash
# call with: nodejs.sh ~/work/ https://github.com/joyent/node.git v0.8.11 ~/node_deploy/
set -x
set -e
export AR=arm-linux-gnueabihf-ar
export CC=arm-linux-gnueabihf-gcc-4.8
export CXX=arm-linux-gnueabihf-g++-4.8
export LINK=arm-linux-gnueabihf-g++-4.8

type $AR >/dev/null 2>&1 || { echo >&2 "I require $AR but it's not installed.  Aborting."; exit 1; }
type $CC >/dev/null 2>&1 || { echo >&2 "I require $CC but it's not installed.  Aborting."; exit 1; }
type $CXX >/dev/null 2>&1 || { echo >&2 "I require $CXX but it's not installed.  Aborting."; exit 1; }
type $LINK >/dev/null 2>&1 || { echo >&2 "I require $LINK but it's not installed.  Aborting."; exit 1; }

export DIR=$1
export NODEGIT=$2
export NODEVERSION=$3
export NODEDIR=$4
export NODETEMPDIR=$5

if [ "$DIR" = "" ]
then
	DIR=${PWD#}/work
fi

if [ "$NODEGIT" = "" ]
then
	NODEGIT=git://github.com/joyent/node.git
fi

if [ "$NODEVERSION" = "" ]
then
	NODEVERSION=v0.10.17
fi

if [ "$NODEDIR" = "" ]
then
	NODEDIR=/opt/node
fi

if [ "$NODETEMPDIR" = "" ]
then
	NODETEMPDIR=$DIR/nodejs
fi


if [ ! -d $DIR ];
then
 	mkdir -p $DIR
fi
cd $DIR

if [ ! -d node ] #we don't have node yet, clone it
then
	git clone $NODEGIT || { echo >&2 "git clone $NODEGIT failed.  Aborting."; exit 1; }
fi
cd node
if [ ! -f node ] #we don't have node compiled, compile it
then

	git checkout $NODEVERSION

	./configure --without-snapshot --dest-cpu=arm --dest-os=linux --with-arm-float-abi=hard --prefix=$NODEDIR || { echo >&2 "Tried to configure NodeJS but it failed.  Aborting."; exit 1; }

	#GYP_DEFINES="armv7=0" CXXFLAGS='-mfpu=vfp -mfloat-abi=hard -DUSE_EABI_HARDFLOAT' CCFLAGS='-mfpu=vfp -mfloat-abi=hard -DUSE_EABI_HARDFLOAT' make --jobs=8
	make
fi
make install DESTDIR=$NODETEMPDIR

# fix the path to node in the npm script
#sed '1 c #!/opt/node/bin/node' $NODEDIR/bin/npm > /tmp/npm
#cat /tmp/npm > $NODEDIR/lib/node_modules/npm/bin/npm-cli.js
#rm /tmp/npm
