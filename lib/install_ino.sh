#/bin/sh
echo currently in:
echo `pwd`
DIR="`dirname \"$0\"`"

cd /tmp/additions/ino/ino 

echo Installing ino 
make install

