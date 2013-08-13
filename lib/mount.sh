#!/bin/bash

DIR="$( cd "$( dirname "$0" )" && pwd )"
. $DIR/libmount.sh
echo $DIR

mount_image $1 