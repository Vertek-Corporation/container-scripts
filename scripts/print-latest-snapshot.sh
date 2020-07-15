#!/usr/local/bin/bash

# asset (first and sole argument) is from the snapshots/ context of the repo.  So, for example, 
# com/company/app

declare repo
declare asset
declare asset_type

function parse_cli {
	for arg in "$@"; do # transform long options to short ones 
		shift
		case "$arg" in
			"--repo")        set -- "$@" "-r" ;; # Maven repo (e.g. repository/snapshots)
			"--asset-type")  set -- "$@" "-t" ;; # The type of asset (e.g. war, zip)
			"--asset-path")  set -- "$@" "-a" ;; # The asset path
			*)               set -- "$@" "$arg"
		esac
	done

	# Parse command line options safely using getops
	while getopts "r:t:a:" opt; do
		case $opt in
			r) repo=$OPTARG ;;
			a) asset=$OPTARG ;;
			t) asset_type=$OPTARG ;;
			\?)
				echo "Invalid option: -$OPTARG" >&2
				;;
		esac
	done
}

function check_cli { # by making sure that the requied options are supplied, etc.
	declare -a required_opts=("repo" "asset" "asset_type")

	for opt in ${required_opts[@]};
	do
		if [[ "x${!opt}" == "x" ]]
		then
			echo "$opt is required"
			exit 1;
		fi
	done;
}

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
	local asset_basename=`basename $asset`

	cp $BASE_URL/$asset/maven-metadata-local.xml baseVersion.xml

	local latest_version=$(process_maven_metadata)

	echo $BASE_URL/$asset/$latest_version/$asset_basename-$latest_version.$asset_type
}

function find_latest_snapshot_remote {
	local BASE_URL="$MAVEN_REPO_BASE_URL/repository/snapshots"

	wget --quiet $BASE_URL/$asset/maven-metadata.xml -O baseVersion.xml
	if [ $? -ne 0 ]; then
		echo "error retrieving target assets from the repository"
		exit 1;
	fi

    local latest_version=$(process_maven_metadata)

	wget --quiet $BASE_URL/$asset/$latest_version/maven-metadata.xml -O artifactVersion.xml

	temp_component_version=`grep -m 1 \<value\> ./artifactVersion.xml`

	latest_component_version=$(echo "${temp_component_version}" | sed -e 's/<value>\(.*\)<\/value>/\1/' | sed -e 's/ //g')

	rm artifactVersion.xml

	asset_basename=`basename $asset`

	echo $BASE_URL/$asset/$latest_version/$asset_basename-$latest_component_version.$2
}

function main {
	if [ -z ${1+x} ]; then
			echo "No asset name provided"
		exit 1;
	fi

	if [ `basename $MAVEN_REPO_BASE_URL` = '.m2' ]; then
		find_latest_snapshot_local $asset, $asset_type
		exit 0;
	else 
		find_latest_snapshot_remote $asset, $asset_type
		exit 0;
	fi 
}

parse_cli $@
check_cli
main $@
