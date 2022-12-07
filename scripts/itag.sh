#!/usr/local/bin/bash

if [ "x$CONTAINER_SCRIPT_HOME" == "x" ]; then
        echo "Please set CONTAINER_SCRIPT_HOME"
        exit 1;
fi

source $CONTAINER_SCRIPT_HOME/common-repo.sh

echo "repo   : $repo"
echo "version: $version"
echo "image  : $imageName"
echo "tag    : $tag"

# Tag
echo "tagging $tag..."
docker tag $imageName $tag

# System cleanup
echo "cleaning up images..."
docker image prune --force 2>&1  >/dev/null

echo "done"
