#!/usr/local/bin/bash

source $CONTAINER_SCRIPT_HOME/common.sh 
source $CONTAINER_SCRIPT_HOME/common-opts.sh 

function check_for_clair {
	echo "TODO"
	# TODO
}

function check_for_clair_whitelist {
	echo "TODO"
	# TODO
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

	check_for_clair
	check_for_clair_whitelist

	# start the container
	docker-compose --file $CONTAINER_SCRIPT_HOME/clair/docker-compose.yaml up -d

	# scan the container
	clair-scanner --ip $dockerHost $imageName:$version

	# spin down the clair server and database
	# docker-compose --file $CONTAINER_SCRIPT_HOME/clair/docker-compose.yaml down
}

main