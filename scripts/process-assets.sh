#!/usr/local/bin/bash

if [ "x$CONTAINER_SCRIPT_HOME" == "x" ]; then
        echo "Please set CONTAINER_SCRIPT_HOME"
        exit 1;
fi

source $CONTAINER_SCRIPT_HOME/common.sh
source $CONTAINER_SCRIPT_HOME/common-opts.sh
source $CONTAINER_SCRIPT_HOME/common-maven.sh

buildDir=$BUILD_DIR_PREFIX-$(get_property_value 'environment')

if [ ! -d $buildDir ]; then
        echo Cannot find $buildDir
        exit 1;
fi

if [ -f $buildDir/source-assets.txt ]; then
        echo "generating target assets to deploy as specified in $buildDir"
fi

sourceFile=$buildDir/source-assets.txt
targetFile=$buildDir/target-assets.txt

if [ -f $targetFile ]; then
	rm $targetFile
fi

if [ ! -f $sourceFile ]; then
	echo "can't find $sourceFile"
	exit 1;
fi 

while read line; do
	assetVersion=$(echo $line | cut -f1 -d ' ')
	assetRepo=$(echo $line | cut -f2 -d ' ')
	assetType=$(echo $line | cut -f3 -d ' ')
	assetPath=$(echo $line | cut -f4 -d ' ')

	if [ $assetVersion="latest" ]; then
		assetPath=`print-latest-snapshot.sh --asset-repo $assetRepo \
		                                    --asset-path $assetPath \
											--asset-type $assetType`
        	if [ $? -ne 0 ]; then
                	echo "can't get latest snapshot, operation aborted" 
                	exit 1;
        	fi
	else
		assetPath=$(get_maven_asset_path $assetRepo $assetPath $assetType $assetVersion)
	fi

	echo $assetPath >> $targetFile
done < $sourceFile

echo "latest snapshots of assets specified in $targetFile:"
cat $targetFile
