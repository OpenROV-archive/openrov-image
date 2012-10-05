openrov-image
=============

Automated BeagleBone image creation for OpenROV

If you got a fresh Ubuntu install, you can execute 'setup-system.sh' to fullfil all the requirements.
But you might want to check what it installs, quite a lot...

You will need the ARM compiler toolchain as described here: 
http://elinux.org/Toolchains#Linaro_.28ARM.29


How to build?
=============

Once you have all what you need (node, cross compilers) you can run:
     ./build.sh


What happens?
=============


First of all, a directory called 'work' is created.

Then, we get NodeJS from github and patch it so we can compile it for arm.
Once the node is built, it is copied to work/additions/node_deploy.

We get the OpenROV software from github and put it to work/additions/openrov.

Then we get a special fork of the 'omap-image-builder' for OpenROV. 
This project will get a few other things from github and other sources and actually build a complete Ubuntu Image for ARM from scratch.
During that process, we copy what is in the work/additions folder over to the image to /tmp/additions.
Once the image is done (and still mounted through the loopback device' all top level folders in tmp/additions are searched for 'install.sh' files. Every file is executed in turn and can do changes (as root) on the image.



