#/bin/sh
echo currently in:
echo `pwd`
DIR="`dirname \"$0\"`"

if [ ! -d /opt/openrov ]; then
	mkdir -p /opt/openrov
fi
cd $DIR
cp -r *.tgz /opt/openrov/
cd /opt/openrov/
tar zxf OpenROV*.tgz
cp -r package/* .
rm OpenROV*.tgz
rm -rf package

/opt/node/bin/npm rebuild

echo "rov ALL=NOPASSWD: /opt/openrov/linux/" >> /etc/sudoers

echo > /etc/rc.local << __EOF__
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.

sh /opt/openrov/linux/seturat.sh

exit 0

__EOF__





ln -s /opt/openrov/linux/openrov.service /etc/init.d/openrov
chmod +x /opt/openrov/linux/openrov.service

if [ -f '/etc/init.d/openrov' ]; then
	update-rc.d openrov defaults
fi  

