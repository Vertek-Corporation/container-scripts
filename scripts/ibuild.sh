#!/usr/local/bin/bash

if [ "x$CONTAINER_SCRIPT_HOME" == "x" ]; then
        echo "Please set CONTAINER_SCRIPT_HOME"
        exit 1;
fi

source $CONTAINER_SCRIPT_HOME/common.sh 
source $CONTAINER_SCRIPT_HOME/common-opts.sh 

buildDir=$BUILD_DIR_PREFIX-$(get_property_value 'environment')

if [ ! -d $buildDir ]; then
	echo Cannot find $buildDir
	exit 1;
fi

imageName=$(get_image_name);

# Prep for the build
cp $buildDir/env.properties $PWD/customization
cp $CONTAINER_SCRIPT_HOME/wildfly/execute.sh $PWD/customization

# Build
docker build -t $imageName -f $buildDir/Dockerfile $PWD

# Clean up after the build
rm $PWD/customization/env.properties
rm $PWD/customization/execute.sh

# System cleanup
docker container prune --force
docker image prune --force
