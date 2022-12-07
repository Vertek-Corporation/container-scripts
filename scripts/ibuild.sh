#!/usr/local/bin/bash

if [ "x$CONTAINER_SCRIPT_HOME" == "x" ]; then
        echo "Please set CONTAINER_SCRIPT_HOME"
        exit 1;
fi

source $CONTAINER_SCRIPT_HOME/common.sh 
source $CONTAINER_SCRIPT_HOME/common-opts.sh 

buildDir=$WD/$BUILD_DIR_PREFIX-$(get_property_value 'environment')

if [ ! -d $buildDir ]; then
	echo Cannot find $buildDir
	exit 1;
fi

imageName=$(get_image_name);
imageName=${imageName//[[:space:]]/} # removes trailing space if any

# Prep for the build
cp $buildDir/env.properties $WD/customization
cp $CONTAINER_SCRIPT_HOME/wildfly/execute.sh $WD/customization

# Build
docker build -t $imageName -f $buildDir/Dockerfile $WD

# Clean up after the build
rm $WD/customization/env.properties
rm $WD/customization/execute.sh

# System cleanup
docker container prune --force
docker image prune --force
