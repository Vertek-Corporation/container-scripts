#!/usr/local/bin/bash

if [ ! -d "$CONTAINER_SCRIPT_HOME" ]; then
	echo "can't find $CONTAINER_SCRIPT_HOME, set CONTAINER_SCRIPT_HOME properly"
	exit 1;
fi

# Enviornment file
EF=env.properties

# Create build directories called $BUILD_PREFIX-<my directory name> 
BUILD_DIR_PREFIX=env;

# Short hand for working directory
WD=`dirname "$0"`

if [[ "x$CONTAINER_BUILD_DIR" != "x" ]]; then
	WD=$CONTAINER_BUILD_DIR
fi

# Put properties that are needed here.  These get validated later.
REQUIRED_PROPERTIES=(application environment)

source $CONTAINER_SCRIPT_HOME/config-properties.sh

get_application() {
	echo $(get_property_value 'application')
}

get_image_name() {
	echo $(get_property_value 'application')/$(get_property_value 'environment')
}

get_environment() {
	echo $(get_property_value 'environment')
}

get_environment_dir() {
	echo $BUILD_DIR_PREFIX-$(get_environment)
}

get_environment_property_file() {
	echo $(get_environment_dir)/$EF
}

get_live_container_id() {
	echo $(docker ps -q --filter ancestor=$(get_image_name))
}

get_live_container_not_found_message() {
	echo No containers for $(get_image_name)	
}

get_last_container_id() {
	echo $(docker ps -a -q --filter ancestor=$(get_image_name)) | awk '{print $1}'
}

get_containers() {
	echo $(docker ps -a -q --filter ancestor=$(get_image_name))
}

has_containers() {
	if [[ ! -z $(get_containers) ]]; then
		return;
	fi

	false
}

has_live_container() {
	if [[ ! -z $(get_live_container_id) ]]; then
		return;
	fi

	false
}

require_property_file
require_properties ${REQUIRED_PROPERTIES[@]}
