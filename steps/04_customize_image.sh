#!/bin/bash
set -x
set -e
export DIR=${PWD#}
export IMAGE=$1
export STEP_02_IMAGE=$DIR/work/step_02/image.step_02.img
export STEP_04_IMAGE=$DIR/work/step_04/image.step_04.img
export OUTPUT_IMAGE=$DIR/output/OpenROV.img
export USE_REPO=${USE_REPO:-''} # use the repository at build.openrov.com/debian as package source
export REPO=openrov-deb-repository.s3.amazonaws.com

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

echo ------------------------------
echo installing bower
#npm install -ddd -g bower

echo Setting up users
echo -----------------------------

echo Adding user 'rov'
#ROV already exists at this point
#useradd rov -m -s /bin/bash -g admin
echo rov:OpenROV | chpasswd
# Include node in PATH
echo "PATH=\$PATH:/opt/node/bin" >> /home/rov/.profile

echo remove ubuntu user
#already deleted by this point
#userdel -r -f ubuntu

echo "rov ALL=NOPASSWD: /opt/openrov/cockpit/linux/" >> /etc/sudoers
echo "rov ALL=NOPASSWD: /opt/openrov/dashboard/linux/" >> /etc/sudoers

echo -----------------------------
echo Adding the apt-get configuration
echo -----------------------------
apt-get clean
cat > /etc/apt/sources.list.d/openrov-stable.list << __EOF__
deb http://$REPO stable debian
deb [arch=all] http://$REPO stable debian
__EOF__
cat > /etc/apt/sources.list.d/openrov-master.list << __EOF__
deb http://$REPO master debian
#deb [arch=all] http://$REPO master debian
__EOF__
cat > /etc/apt/sources.list.d/openrov-pre-release.list << __EOF__
deb http://$REPO pre-release debian
#deb [arch=all] http://$REPO pre-release debian
__EOF__

cat > /etc/apt/preferences.d/openrov-master-300 << __EOF__
Package: *
Pin: release n=master, origin build.openrov.com
Pin-Priority: 300
__EOF__
cat > /etc/apt/preferences.d/openrov-pre-release-400 << __EOF__
Package: *
Pin: release n=pre-release, origin build.openrov.com
Pin-Priority: 400
__EOF__


echo Adding gpg key for build.openrov.com
wget -O - -q http://($REPO)build.openrov.com.gpg.key | apt-key add -

echo -----------------------------
echo Installing packages
echo -----------------------------

rm -rf /tmp/packages

if [ "$USE_REPO" != "" ]; then
	apt-get update
	apt-get install -y --force-yes -o Dpkg::Options::="--force-overwrite" \
		-t $BRANCH openrov-rov-suite
fi
apt-get clean

echo -----------------------------
echo Cleanup home directory
echo -----------------------------
cd /home
find . -type d -not -name rov -and -not -name . | xargs rm -rf

echo -----------------------------
echo Setting up network
echo -----------------------------

#fix hostname
echo OpenROV > /etc/hostname

cat > /etc/hosts << __EOF__
127.0.0.1       localhost
127.0.1.1       OpenROV

__EOF__

## fix dhcp
cat >> /etc/dhcp/dhclient.conf << __EOF__
timeout 30;
lease {
interface "eth0";
fixed-address 192.168.254.1;
option subnet-mask 255.255.255.0;
option routers 192.168.254.1;
renew 2 2037/1/12 00:00:01;
rebind 2 2037/1/12 00:00:01;
expire 2 2037/1/12 00:00:01;
}

__EOF__


## fix network

cat > /etc/network/interfaces << __EOF__
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp

auto eth0:0
iface eth0:0 inet static
name Ethernet alias LAN card
address 192.168.254.1
netmask 255.255.255.0
broadcast 192.168.254.255
network 192.168.254.0

# Example to keep MAC address between reboots
#hwaddress ether DE:AD:BE:EF:CA:FE

# WiFi Example
#auto wlan0
#iface wlan0 inet dhcp
#    wpa-ssid "essid"
#    wpa-psk  "password"

# Ethernet/RNDIS gadget (g_ether)
# ... or on host side, usbnet and random hwaddr
iface usb0 inet static
    address 192.168.7.2
    netmask 255.255.255.0
    network 192.168.7.0
    gateway 192.168.7.1


__EOF__

echo -------------------------
echo Installing new kernel
cd /tmp/
wget http://rcn-ee.net/deb/wheezy-armhf/v3.15.5-bone4/install-me.sh
bash install-me.sh



__EOF_UPDATE__
chmod +x $ROOT/tmp/update.sh

chroot $ROOT /tmp/update.sh

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

# change boot script for uart
sed -i '3ioptargs=capemgr.enable_partno=BB-UART1' $DIR/boot/uEnv.txt

mkdir $DIR/boot/Docs
cp $DIR/contrib/openrov.ico $DIR/boot/Docs/
cp $DIR/contrib/boot/* $DIR/boot/



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
mv $STEP_04_IMAGE $OUTPUT_IMAGE

echo -----------------------------
echo Done step 4
echo "Output can be found in: $OUTPUT_DIR_NAME"
echo -----------------------------
