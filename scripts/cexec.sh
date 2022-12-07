#!/usr/local/bin/bash

if [ "x$CONTAINER_SCRIPT_HOME" == "x" ]; then
        echo "Please set CONTAINER_SCRIPT_HOME"
        exit 1;
fi

source $CONTAINER_SCRIPT_HOME/common.sh
source $CONTAINER_SCRIPT_HOME/common-opts.sh

if [ -z $1 ]; then
	echo Please provide a command to execute in the running container
	exit 1
fi

if has_live_container; then
	docker exec -it $(get_live_container_id) $1
else 
	echo $(get_live_container_not_found_message)
fi
