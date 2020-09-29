#!/usr/local/bin/bash

declare -A properties
declare WD=`pwd`

# Short hand for container build dir
if [[ ! -z $CONTAINER_BUILD_DIR ]]; then
	WD=$CONTAINER_BUILD_DIR
fi

# Main configuration property file
CF=config.properties

# Allows the caller to switch the property file from one to another.  Usefule 
# because we have global properties and environment specific properties.
#
set_property_file() {
	CF=$1

	if [ ! -f $CF ]; then
        	echo Cannot find $CF
        	exit 1;
	fi
}

# Gets a property value from the property map.  First checks to see if a property
# is set by the currently executing script.  If so it will return it.  Otherwise,
# it will return a value from a property file.  Otherwise, it will return an 
# empty value.  $1 is the property name.
#
get_property_value() {  

	if [[ -v $1 ]]; then
		return;
	fi

	if [[ ${properties[$1]} ]]; then
		echo ${properties[$1]}
	else 
        	value=`grep $1 $WD/$CF`
        	echo ${value##*=}
	fi
}

# Sets a property for the duration of script execution.  Note that this doesn't 
# persist a property to the property file.  $1 is the name, $2 is the value.
#
set_property_value() { 
	
	if [[ -v $1 ]] || [[ -v $2 ]]; then
		return;
	fi

	properties[$1]=$2
}

require_property_file() {

	if [[ ! -f $WD/$CF ]]; then
		echo Could not find $WD/$CF
		exit 1
	fi

}

require_properties() {
        for i in $@;
        do      
                if [[ ! $(get_property_value $i) ]]; then
                        echo Missing configuration property "'$i'"
                        exit 1;
                fi
        done
}
