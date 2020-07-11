#!/usr/local/bin/bash
  
source $CONTAINER_SCRIPT_HOME/common.sh
source $CONTAINER_SCRIPT_HOME/common-opts.sh

# Name of the image
imageName=$(get_image_name)
application=$(get_application)

# Environment property file for this image
environmentPropertyFile=$(get_environment_property_file)

# Save properties from config.properties becuase we'll switch config files below
env=$(get_environment)

# Start pulling properties from the environment property file instead
set_property_file $environmentPropertyFile

repo=$(get_property_value 'repo')

# Grab the tag from the environment property file, use as default
version=$(get_property_value 'version')

tag=$imageName:$version

if [ ! -z $repo ]; then
        if [[ $repo == *"amazonaws"* ]]; then
		# slightly different format for the respository tag
                tag=$repo/$application:$version
        else
                tag=$repo/$imageName:$version
        fi
fi
