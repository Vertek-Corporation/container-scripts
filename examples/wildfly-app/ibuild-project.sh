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

if [ -f $buildDir/source-assets.txt ]; then
	process-assets.sh $@
	if [ $? -ne 0 ]; then
    		echo "error retrieving target assets"
    		exit 1;
	fi
fi

ASSET_DIR=asset-dir

echo "Enter your repo credentials..."
read -p    "User name: " USER_NAME
read -s -p "Password:  " PASSWORD

mkdir $ASSET_DIR
wget -i $buildDir/target-assets.txt --directory-prefix=$ASSET_DIR --user=$USER_NAME --password=$PASSWORD --content-disposition

mv $ASSET_DIR/app*.war $ASSET_DIR/app.war
mv $ASSET_DIR/app-ui*.zip $ASSET_DIR/app-ui.zip

$CONTAINER_SCRIPT_HOME/ibuild.sh $@

# Cleanup
rm -rf $ASSET_DIR
rm $buildDir/target-assets.txt
