#!/usr/local/bin/bash

if [ "x$CONTAINER_SCRIPT_HOME" == "x" ]; then
        echo "Please set CONTAINER_SCRIPT_HOME"
        exit 1;
fi

source $CONTAINER_SCRIPT_HOME/common.sh
source $CONTAINER_SCRIPT_HOME/common-opts.sh

if has_live_container; then
	docker stop --time 20 $(get_live_container_id)
else 
	echo $(get_live_container_not_found_message)
fi
