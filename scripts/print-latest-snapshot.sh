#!/usr/local/bin/bash

# Asset name (first and sole argument) is from the snapshots/ context of the repo.  So, for example, 
# com/company/app

declare ASSET
declare ASSET_TYPE

function process_maven_metadata {
	local latest_version
	local versions=`grep \<version\> ./baseVersion.xml `

	for version in $versions
	do
		latest_version_element=$version
	done;

	rm baseVersion.xml

	if [ -z ${latest_version_element+x} ]; then
		echo "No versions found"
		exit 2;
	else 
		latest_version=$(sed -n -e 's/<version>\(.*\)<\/version>/\1/p' <<< $latest_version_element)
	fi

	echo $latest_version
}

function find_latest_snapshot_local { 
	local BASE_URL="$MAVEN_REPO_BASE_URL/repository"
	local ASSET_BASENAME=`basename $ASSET`

	cp $BASE_URL/$ASSET/maven-metadata-local.xml baseVersion.xml

	local latest_version=$(process_maven_metadata)

	echo $BASE_URL/$ASSET/$latest_version/$ASSET_BASENAME-$latest_version.$ASSET_TYPE
}

function find_latest_snapshot_remote {
	local BASE_URL="$MAVEN_REPO_BASE_URL/repository/snapshots"

	wget --quiet $BASE_URL/$ASSET/maven-metadata.xml -O baseVersion.xml
	if [ $? -ne 0 ]; then
		echo "error retrieving target assets from the repository"
		exit 1;
	fi

    local latest_version=$(process_maven_metadata)

	wget --quiet $BASE_URL/$ASSET/$latest_version/maven-metadata.xml -O artifactVersion.xml

	temp_component_version=`grep -m 1 \<value\> ./artifactVersion.xml`

	latest_component_version=$(echo "${temp_component_version}" | sed -e 's/<value>\(.*\)<\/value>/\1/' | sed -e 's/ //g')

	rm artifactVersion.xml

	ASSET_BASENAME=`basename $ASSET`

	echo $BASE_URL/$ASSET/$latest_version/$ASSET_BASENAME-$latest_component_version.$2BASE_URL="$MAVEN_REPO_BASE_URL/snapshots"
}

function main {
	if [ -z ${1+x} ]; then
			echo "No asset name provided"
		exit 1;
	fi

	ASSET=$1
	ASSET_TYPE=$2

	if [ `basename $MAVEN_REPO_BASE_URL` = '.m2' ]; then
		find_latest_snapshot_local $ASSET, $ASSET_TYPE
		exit 0;
	else 
		find_latest_snapshot_remote $ASSET, $ASSET_TYPE
		exit 0;
	fi 
}

main $@
