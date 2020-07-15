#!/usr/local/bin/bash

declare asset_repo	   # Maven repo (e.g. repository/snapshots) 
declare asset		   # The asset path
declare asset_type     # The type of asset (e.g. war, zip)
declare asset_repo_url # Maven repo URL plus asset repo path

function parse_cli {
	for arg in "$@"; do # transform long options to short ones 
		shift
		case "$arg" in
			"--asset-repo")  set -- "$@" "-r" ;; 
			"--asset-type")  set -- "$@" "-t" ;; # The type of asset (e.g. war, zip)
			"--asset-path")  set -- "$@" "-a" ;; # The asset path
			*)               set -- "$@" "$arg"
		esac
	done

	# Parse command line options safely using getops
	while getopts "r:t:a:" opt; do
		case $opt in
			r) asset_repo=$OPTARG ;;
			a) asset=$OPTARG ;;
			t) asset_type=$OPTARG ;;
			\?)
				echo "Invalid option: -$OPTARG" >&2
				;;
		esac
	done
}

function check_cli { # by making sure that the requied options are supplied, etc.
	declare -a required_opts=("asset_repo" "asset" "asset_type")

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
	local asset_basename=`basename $asset`

	cp $asset_repo_url/$asset/maven-metadata-local.xml baseVersion.xml

	local latest_version=$(process_maven_metadata)

	echo $asset_repo_url/$asset/$latest_version/$asset_basename-$latest_version.$asset_type
}

function find_latest_snapshot_remote {
	wget --quiet $asset_repo_urlnn/$asset/maven-metadata.xml -O baseVersion.xml
	if [ $? -ne 0 ]; then
		echo "error retrieving target assets from the repository"
		exit 1;
	fi

    local latest_version=$(process_maven_metadata)

	wget --quiet $asset_repo_urlnn/$asset/$latest_version/maven-metadata.xml -O artifactVersion.xml

	temp_component_version=`grep -m 1 \<value\> ./artifactVersion.xml`

	latest_component_version=$(echo "${temp_component_version}" | sed -e 's/<value>\(.*\)<\/value>/\1/' | sed -e 's/ //g')

	rm artifactVersion.xml

	asset_basename=`basename $asset`

	echo $asset_repo_urlnn/$asset/$latest_version/$asset_basename-$latest_component_version.$2
}

function main {
	asset_repo_url="$MAVEN_REPO_BASE_URL/$asset_repo"

	if [ -z ${1+x} ]; then
			echo "No asset name provided"
		exit 1;
	fi

	if [ `basename $MAVEN_REPO_BASE_URL` = '.m2' ]; then
		find_latest_snapshot_local $asset, $asset_type
	else 
		find_latest_snapshot_remote $asset, $asset_type
	fi 
}

parse_cli $@
check_cli
main $@
