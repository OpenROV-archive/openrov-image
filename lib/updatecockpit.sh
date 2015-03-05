#!/bin/bash
set -x
set -e
DIR="$( cd "$( dirname "$0" )" && pwd )"
. $DIR/libmount.sh
. $DIR/libtools.sh
current_dir=$(pwd)

commandfile=$(tempfile)
commandfile="${commandfile}.sh"

if [ "$1" = "" ]; then

	echo "Please pass the name of the disk image you want to chroot into!"
	exit 1
fi

cat > $commandfile << __EOF__
#!/bin/bash

cd /opt/openrov/cockpit

echo Rebuilding node modules
/opt/node/bin/npm rebuild

__EOF__


$DIR/mount.sh $1
cd root/opt/openrov/cockpit
rm -rf node_modules
npm install --arch=arm

cd $current_dir

$DIR/umount.sh

$DIR/chroot.sh $1 $commandfile

echo ""
echo Update done!
