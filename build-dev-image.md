
#creating a disk image

We are using a base image that is provided by beaglebone.org, the "console" image, and then adding serveral OpenROV debian packages that apply the customizations and additional software needed for the ROV.  You can review the many different versions of the image directly at http://elinux.org/Beagleboard:BeagleBoneBlack_Debian#Jessie_Snapshot_console.  They tend to put a new image up every couple weeks.  In the example below we are getting the image that was released on 2015-05-08.   When you generate the dev image, go ahead and grab the most recent version that is available.

From your computer that has the ability to burn a Micro SD Card, download the image and then burn it to the SD card:

On OS/X (from the terminal)
```
wget  https://rcn-ee.com/rootfs/2015-05-08/microsd/bone-debian-8.0-console-armhf-2015-05-08-2gb.img.xz
diskutil unmountdisk /dev/disk<# of the SD card>
gzip -dc bone-debian-8.0-console-armhf-2015-05-08-2gb.img.xz | dd of=/dev/rdisk<# of the SD card> bs=2m
```

On Windows:

* Need link to burning instructions

On Linux: 

* Need link to burning instructions

Eject the SD card from your computer and insert it in to the beaglebone.  Connecta and boot the beaglebone so that it will have internet access (via [linux](https://elementztechblog.wordpress.com/2014/12/22/sharing-internet-using-network-over-usb-in-beaglebone-black/), [windows](http://lanceme.blogspot.com/2013/06/windows-7-internet-sharing-for.html), [os/x](https://www.youtube.com/watch?v=Cf9hnscbSK8)).

ssh in to the image using username/pw : debian/temppwd

most revent versions of the image use mdns, so you can magically reference the beaglebone without knowing the IP it is using as such `ssh debian@arm.local or sssh beaglebone@arm.local`.  Sometimes I have found it most easy to enable internet sharing on my laptop and connect with ethernet vs trying to tunnel the internet connection down through the usb port.

```
sudo bash
cat > /etc/apt/sources.list.d/openrov-master.list << __EOF__
deb http://deb-repo.openrov.com master debian
#deb [arch=all] http://$REPO master debian
__EOF__
wget -O - -q http://deb-repo.openrov.com/build.openrov.com.gpg.key | apt-key add -
apt-get clean
rm -rf /var/lib/apt/lists/*
apt-get update
apt-get install -y --force-yes -o Dpkg::Options::="--force-overwrite" -t master openrov-rov-suite
```

At this point you have a release-canidate image.  This is an image with the latest rootfs + the most recently built packages of the OpenROV suites.  To make this in to a dev image, you will want to go to each of the package directories in \opt\openrov and do a `git pull` to get the latest code from master.  As of this writing, our packages are not pulling the full git history, so the git pull won't work.  You will have to remove and re-add the origin remote in each folder.

