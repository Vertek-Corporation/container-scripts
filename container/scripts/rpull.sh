#!/bin/bash

if [ "x$CONTAINER_SCRIPT_HOME" == "x" ]; then
        echo "Please set CONTAINER_SCRIPT_HOME"
        exit 1;
fi

source $CONTAINER_SCRIPT_HOME/common-repo.sh

$CONTAINER_SCRIPT_HOME/rlogin.sh

if [ -z $1 ]; then
	echo "Please pass the image and version as an argument to $0 (e.g. platform/dev:v1)"
	exit 1;
fi

docker pull $repo/$1
