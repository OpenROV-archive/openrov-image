#!/bin/sh
export KEYID=B6CE4E93 # the key ID of the GPG key to sign deb packages
export DOCKER_IMAGE=openrov/debian-repository

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../..
OUTPUT=${DIR}/output

if [ ! -f "/usr/lib/cmdarg.sh" ]; then
	echo This script needs 'cmdarg' from https://github.com/akesterson/cmdarg/tree/build%2C2.0%2C2
	exit 1
fi

source /usr/lib/cmdarg.sh
export DEFAULT_CODENAME=stable
export DEFAULT_COMPONENT=debian

cmdarg_info "header" "Script to delete a package from the OpenROV S3 debian repository"
cmdarg_info "author" "Dominik Fretz | OpenROV Inc. <dominik@openrov.com>"
cmdarg_info "copyright" "OpenROV (C) 2014"

cmdarg 'c:' 'credentials' 'File that contains the AWS credentials (AWS key, AWS secret) and the GPG passphrase'
cmdarg 'p' 'production' 'Use the production bucket/path'
cmdarg 'n?:' 'codename' 'Debian codename to use when deleting files' ${DEFAULT_CODENAME}
cmdarg 'o?:' 'component' 'Debian component to use when deleting files' ${DEFAULT_COMPONENT}
cmdarg 'f' 'force' 'Force the "production" flag'
cmdarg 't?:' 'prefix' 'Path prefix for deleting, defaults to "test" if the "-p|--production" is not specified' 'test'

cmdarg 'v:' 'version' 'The package version you want to delete.'
cmdarg 'a:' 'arch' 'The package architecture you want to delete.'

cmdarg_parse "$@"

if [ "${cmdarg_cfg['prefix']}" = "" ]; then
	echo "Empty value for -t|--prefix!"
	exit 1
fi

PREFIX="--prefix=${cmdarg_cfg['prefix']}"
if [ "${cmdarg_cfg['production']}" = "true" ]; then
	if [ "${cmdarg_cfg['force']}" = "" ]; then
		echo "Are you sure you want to delete from production? (yes/no)"
		read input
		if [ "${input}" != "yes" ]; then
			echo "Aborting"
			exit 1
		fi
	fi
	if [ "${cmdarg_cfg['prefix']}" != "test" ]; then
		echo "Cannot specify -p|--production and -t|--prefix at the same time!"
	fi
	PREFIX=""
fi

if [ "${cmdarg_cfg['credentials']}" = "" ]; then
	echo "No credentials specified!"
	exit 1
fi

if [ ! -f "${cmdarg_cfg['credentials']}" ]; then
	echo "Could not find credentials file ${cmdarg_cfg['credentials']} or it is not a valid file!"
	exit 1
fi
. ${cmdarg_cfg['credentials']}

if [ "${AWSKEY}" = "" ]; then
	echo "The environment variable AWSKEY is empty. please make sure that the credentials file contains the definition for AWSKEY."
fi
if [ "${AWSSECRET}" = "" ]; then
	echo "The environment variable AWSSECRET is empty. please make sure that the credentials file contains the definition for AWSSECRET."
fi
if [ "${GPG_SECRET}" = "" ]; then
	echo "The environment variable GPG_SECRET is empty. please make sure that the credentials file contains the definition for GPG_SECRET."
	exit 1
fi

echo "${GPG_SECRET}" > "${OUTPUT}/.passphrase"

PACKAGENAME="${cmdarg_argv[0]}"
PACKAGEVERSION="${cmdarg_cfg['version']}"
ARCH="${cmdarg_cfg['arch']}"

DEB_CODENAME=${cmdarg_cfg['codename']} 
DEB_COMPONENT=${cmdarg_cfg['component']} 
GPG_PASSPHRASE_FILE="${OUTPUT}/.passphrase" 
AWSKEY=${AWSKEY} 
AWSSECRET=${AWSSECRET} 


docker run \
	-t \
	-v $DIR/docker/deb-repository/gnupg/:/root/.gnupg \
	-v ${GPG_PASSPHRASE_FILE}:/root/passphrase.txt \
	-e HOME=/root \
	${DOCKER_IMAGE} \
	/tmp/deb-s3/bin/deb-s3 delete \
		-a $ARCH \
		--versions "${PACKAGEVERSION}" \
		--bucket=openrov-deb-repository \
		-c $DEB_CODENAME \
        -m $DEB_COMPONENT \
        ${PREFIX} \
		--access-key-id=$AWSKEY \
		--secret-access-key=$AWSSECRET \
		--sign=$KEYID \
		--gpg-options="--passphrase-file /root/passphrase.txt" \
		"${PACKAGENAME}"

# docker run \
# 	-t \
# 	-v $DIR/docker/deb-repository/gnupg/:/root/.gnupg \
# 	-v ${GPG_PASSPHRASE_FILE}:/root/passphrase.txt \
# 	-e HOME=/root \
# 	${DOCKER_IMAGE} \
# 	/tmp/deb-s3/bin/deb-s3 verify \
# 		-f \
# 		--bucket=openrov-deb-repository \
# 		-c $DEB_CODENAME \
#         -m $DEB_COMPONENT \
#         ${PREFIX} \
# 		--access-key-id=$AWSKEY \
# 		--secret-access-key=$AWSSECRET \
# 		--sign=$KEYID \
# 		--gpg-options="--passphrase-file /root/passphrase.txt" 

rm -rf $GPG_PASSPHRASE_FILE