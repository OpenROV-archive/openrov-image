#!/bin/bash
set -x
set -e
export DIR=${PWD#}
export IMAGE=$1
export STEP_02_IMAGE=$DIR/work/step_02/image.step_02.img
export STEP_04_IMAGE=$DIR/work/step_04/image.step_04.img
export OUTPUT_IMAGE=$DIR/output/OpenROV.img
export USE_REPO=${USE_REPO:-''} # use the repository at build.openrov.com/debian as package source
export REPO=deb-repo.openrov.com

. $DIR/lib/libtools.sh
. $DIR/lib/libmount.sh
. $DIR/versions.sh

checkroot

if [ "$1" = "--reuse-step4" ] && [ ! -f $STEP_04_IMAGE ]; then
	echo "You specified --reuse-step4 but the Step 4 image does not exists in: $STEP_04_IMAGE"
	exit 1

elif [ "$1" = "" ] && [ ! -f $STEP_02_IMAGE ]; then
	echo "Please pass the name of the Step 2 image file or make sure it exists in: $STEP_02_IMAGE"
	exit 1
fi


if [ ! "$1" = "--reuse-step4" ]; then
	echo -----------------------------
	echo Step 4: creating copy of image file:
	echo "> $STEP_04_IMAGE"
	echo -----------------------------

	IMAGE_DIR_NAME=$( dirname $STEP_04_IMAGE )

	if [ ! -d $IMAGE_DIR_NAME ]
	then
		mkdir -p "$IMAGE_DIR_NAME"
	fi
	cp $STEP_02_IMAGE $STEP_04_IMAGE
	echo -----------------------------
	echo done
	echo -----------------------------
else

	echo -----------------------------
	echo using $STEP_04_IMAGE
	echo -----------------------------
fi
echo Preparing image
echo -----------------------------

# mounting
cd $DIR
mount_image $STEP_04_IMAGE

export ROOT=${PWD#}/root

chroot_mount

# copy the qemu files for chroot to arm
cp /usr/bin/qemu-arm-static $ROOT/usr/bin/qemu-arm-static

if [ "$USE_REPO" = "" ]; then

	echo -----------------------------
	echo Staging packages for install
	echo -----------------------------
	#trying to mount bind instaed of copy to save space
	if [ ! -d $ROOT/tmp/packages ]
	then
		mkdir $ROOT/tmp/packages
		mount --bind $DIR/work/packages $ROOT/tmp/packages
	fi
fi

echo -----------------------------
echo Customizing image
echo -----------------------------

cat > $ROOT/tmp/update.sh << __EOF_UPDATE__
#!/bin/bash
set -x
set -e
export REPO=$REPO
echo ------------------------------
#echo installing bower
#npm install -ddd -g bower
dpkg --list | grep 'apache2' && apt-get remove -y apache2

#may need to patch old NPM here.
sed -i '/function getLocalAddresses() {/a return' /usr/lib/node_modules/npm/node_modules/npmconf/config-defs.js || true

echo -----------------------------
echo Adding the apt-get configuration
echo -----------------------------
apt-get clean

#add code to make sure the wheezy backports are available
sed -i 's|#deb http://ftp.debian.org/debian jessie-backports|deb http://ftp.debian.org/debian jessie-backports|g'  /etc/apt/sources.list
sed -i 's|#deb http://ftp.debian.org/debian wheezy-backports|deb http://ftp.debian.org/debian wheezy-backports|g'  /etc/apt/sources.list

#cat > /etc/apt/apt.config << __EOF__
#APT::Install-Recommends "0";
#APT::Install-Suggests "0";
#__EOF__

cat > /etc/apt/sources.list.d/openrov-${BRANCH}.list << __EOF__
deb http://$REPO jessie {$BRANCH}
#deb [arch=all] http://$REPO jessie ${BRANCH}
__EOF__

#Always build images from the deb files in unstable.  Push "stable" packages to stable
#after the image has been validated.
cat > /etc/apt/sources.list.d/openrov-imageseed.list << __EOF__
deb http://$REPO jessie unstable
#deb [arch=all] http://$REPO jessie ${BRANCH}
__EOF__

echo Adding gpg key for build.openrov.com
wget -O - -q http://${REPO}/build.openrov.com.gpg.key | apt-key add -

echo -----------------------------
echo Installing packages
echo -----------------------------

rm -rf /tmp/packages

if [ "$USE_REPO" != "" ]; then
	apt-get clean
	rm -rf /var/lib/apt/lists/*
	apt-get update
	apt-get install -y \
		openrov-rov-suite
#  if [ "$MAKE_FLASH" == "true" ]; then
#		apt-get install -y \
#			openrov-emmc-copy
#  fi

#take the unstable update repo out of the list
rm /etc/apt/sources.list.d/openrov-imageseed.list

  dpkg -s openrov-rov-suite | grep Version | sed 's|Version: |OROV_VERSION=|g' > /tmp/version.txt
fi

apt-get clean
__EOF_UPDATE__

chmod +x $ROOT/tmp/update.sh

chroot $ROOT /tmp/update.sh
source $ROOT/tmp/version.txt
rm $ROOT/tmp/* -r

echo Setting up auto resize on first boot
touch $ROOT/var/.RESIZE_ROOT_PARTITION

echo ------------------------------
echo Fixing arduino

#fix arduino version
echo 1.0.5 > $ROOT/usr/share/arduino/lib/version.txt
#fix arduino library source
cd $ROOT/usr/share/arduino/
rm -r libraries
tar zxf $DIR/contrib/Arduino-1.0.4-libraries.tgz
cd $DIR

echo ------------------------------
echo Customizing boot partition

#This no longer works on debian
# change boot script for uart
#sed -i '3ioptargs=capemgr.enable_partno=BB-UART1' $DIR/boot/uEnv.txt

#mkdir $DIR/boot/Docs
#cp $DIR/contrib/openrov.ico $DIR/boot/Docs/
#cp $DIR/contrib/boot/* $DIR/boot/


echo ------------------------------
echo done
echo ------------------------------



chroot_umount
unmount_image

OUTPUT_DIR_NAME=$( dirname $OUTPUT_IMAGE )
if [ ! -d $OUTPUT_DIR_NAME ];  then
	mkdir -p $OUTPUT_DIR_NAME
fi

echo -----------------------------
echo Moving image
echo "> $OUTPUT_IMAGE"

#mv $STEP_04_IMAGE $OUTPUT_IMAGE
mv $STEP_04_IMAGE ${OUTPUT_DIR_NAME}/OpenROV-SUITE-${OROV_VERSION}-IMAGE-${IMAGE_VERSION}.img

echo -----------------------------
echo Done step 4
echo "Output can be found in: $OUTPUT_DIR_NAME"
echo -----------------------------
