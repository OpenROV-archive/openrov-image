#!/bin/bash
set -x
set -e
export KEYID=B6CE4E93 # the key ID of the GPG key to sign deb packages

export DIR=${PWD#}
export OUTPUT_DIR=$DIR/output

if [ "$DEB_CODENAME" = "" ]; then
        echo "Please set the DEB_CODENAME environment variable to define into what debian repo we should upload the .deb files."
        exit 1
fi

if [ "$DEB_COMPONENT" = "" ]; then
        echo "Please set the DEB_COMPONENT environment variable to define into what debian component we should upload the .deb files."
        exit 1
fi

if [ "$AWS_CREDENTIALS" = "" ]; then
        echo "Please set the AWS_CREDENTIALS environment variable containing the path to a file with the key/value pairs for AWSKEY and AWSSECRET"
        exit 1
fi

if [ "$GPG_PASSPHRASE_FILE" = "" ]; then
        echo "Please set the GPG_PASSPHRASE_FILE environment variable containing the filename to the passphrase used for the GPG key."
        exit 1
fi

. $DIR/lib/libtools.sh
. $DIR/lib/libmount.sh
. $DIR/versions.sh
. $AWS_CREDENTIALS # this is a environment variable that is set by the Jenkins Credentials Binding Plugin (see below)
                   # and it contains the path to a file with the AWS credentials as KEY=Value

checkroot

cd $OUTPUT_DIR/packages

docker pull openrov/debs3

# Docker command descrioption:
# -t assigns a pseudo tty, we need that for gpg (used for signing packages and the deb repo)
# -v /host/path:/container/path  mapps the host path to the container path read/write
#    The packages folder contains the debian packages
#    the $GPG_PASSPHRASE_FILE is a path to the passphrase. This file and the environment variable is created and maintained by
#    the Credentials Binding Plugin for Jenkins (https://wiki.jenkins-ci.org/display/JENKINS/Credentials+Binding+Plugin)
# -e HOME=  sets the environment variable HOME

docker run \
	-t \
  -rm \
	-v $DIR/docker/deb-repository/gnupg/:/root/.gnupg \
	-v $OUTPUT_DIR/packages:/tmp/packages \
	-v ${GPG_PASSPHRASE_FILE}:/root/passphrase.txt \
	-e HOME=/root --entrypoint dpkg-sig openrov/debs3 \
	 -k $KEYID \
		-g "--passphrase-file /root/passphrase.txt" \
		-s openrov \
		/tmp/packages/openrov*.deb

# hack: try to overwrite the file with one that is already in the repo
#       and use that as the file to upload. Prevent the same file being
#       signed a second time from breaking the existing manifests
#       in the repository. https://github.com/krobertson/deb-s3/issues/46
files=($(find $OUTPUT_DIR/packages -type f -name "openrov*.deb" -printf "%f\n"))
set +e
for item in ${files[*]}
do
  wget http://deb-repo.openrov.com/pool/o/op/${item} -O $OUTPUT_DIR/packages/${item}_tmp && mv $OUTPUT_DIR/packages/${item}_tmp $OUTPUT_DIR/packages/${item}
done
set -e
docker run \
	-t \
  -rm \
	-v $DIR/docker/deb-repository/gnupg/:/root/.gnupg \
	-v $OUTPUT_DIR/packages:/tmp/packages \
	-v ${GPG_PASSPHRASE_FILE}:/root/passphrase.txt \
	-e HOME=/root openrov/debs3 upload \
		--bucket=openrov-deb-repository \
		-c $DEB_CODENAME \
                -m $DEB_COMPONENT \
                --preserve-versions \
		--access-key-id=$AWSKEY \
		--secret-access-key=$AWSSECRET \
		--sign=$KEYID \
		--gpg-options="--passphrase-file /root/passphrase.txt" \
		/tmp/packages/openrov*.deb
