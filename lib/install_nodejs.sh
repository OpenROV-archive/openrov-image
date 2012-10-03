#/bin/sh

DIR="`dirname \"$0\"`"

if [ ! -d /opt/node ]; then
	mkdir -p /opt/node
fi
cp -r $DIR/* /opt/node


git clone git://github.com/creationix/nvm.git ~/.nvm
echo ". ~/.nvm/nvm.sh" >> .bashrc
echo "export LD_LIBRARY_PATH=/usr/local/lib" >> .bashrc
echo "export PATH=$PATH:/opt/node/bin" >> .bashrc


