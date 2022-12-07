#!/usr/local/bin/bash

if [ "x$CONTAINER_SCRIPT_HOME" == "x" ]; then
        echo "Please set CONTAINER_SCRIPT_HOME"
        exit 1;
fi

source $CONTAINER_SCRIPT_HOME/common-repo.sh

$CONTAINER_SCRIPT_HOME/rlogin.sh $@

echo "version: $version"
echo "tag    : $tag"

docker push $tag
