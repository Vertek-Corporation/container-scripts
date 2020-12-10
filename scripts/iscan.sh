#!/usr/local/bin/bash

declare CVE_WHITELIST_FILE=cve-whitelist.yaml

source $CONTAINER_SCRIPT_HOME/common.sh 
source $CONTAINER_SCRIPT_HOME/common-opts.sh 

# Checks to see if the clair-scanner command is installed and exits when it isn't.
function check_for_clair_scanner {
	if ! command -v clair-scanner &> /dev/null
	then
		echo "clair-scanner is not in your path or isn't installed"
		exit 1
	fi
}

# Checks to make sure that a whitelist exists in the appropriate location.  If not,
# create it.
function check_for_clair_whitelist {
	if [ ! -f "$CVE_WHITELIST_FILE" ]; then
		echo "CVE whitelist didn't exist, created as $CVE_WHITELIST_FILE"
		echo "generalwhitelist: # approvals for any image (example below)"  >> $CVE_WHITELIST_FILE
		echo "    #RHSA-2020:4007: systemd"                                 >> $CVE_WHITELIST_FILE
		echo "images: # approvals for a specific image"                     >> $CVE_WHITELIST_FILE
		echo "    #platform/dev:"                                           >> $CVE_WHITELIST_FILE
		echo "        #RHSA-2020:3861: glibc"                               >> $CVE_WHITELIST_FILE
	fi
}

function main {
	# Environment property file for this image
	local environmentPropertyFile=$(get_environment_property_file)

	# Save properties from config.properties becuase we'll switch config files below
	local imageName=$(get_image_name);
	local dockerHost=$(get_docker_host)

	# Start pulling properties from the environment property file instead
	set_property_file $environmentPropertyFile

	# Grab the tag from the environment property file, use as default
	local version=$(get_property_value 'version')

	check_for_clair_scanner
	check_for_clair_whitelist

	# start the clair server containers
	docker-compose --file $CONTAINER_SCRIPT_HOME/clair/docker-compose.yaml up -d

	# scan the container
	clair-scanner -w $CVE_WHITELIST_FILE --ip $dockerHost $imageName:$version

	# spin down the clair server and database
	# docker-compose --file $CONTAINER_SCRIPT_HOME/clair/docker-compose.yaml down
}

main