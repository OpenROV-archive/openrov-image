#/bin/sh

DIR="`dirname \"$0\"`"

if [ ! -d /opt/openrov ]; then
	mkdir -p /opt/openrov
fi
cp -r $DIR/openrov /opt/openrov

echo "rov ALL=NOPASSWD: /opt/openrov/linux/*.sh" >> /etc/sudoers

ln -s /opt/openrov/linux/openrov.service /etc/init.d/openrov

update-rc.d openrov defaults

