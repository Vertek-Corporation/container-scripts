#!/usr/local/bin/bash

if [ "x$CONTAINER_SCRIPT_HOME" == "x" ]; then
        echo "Please set CONTAINER_SCRIPT_HOME"
        exit 1;
fi

source $CONTAINER_SCRIPT_HOME/common-repo.sh

if [[ $repo == *"amazonaws"* ]]; then
	eval `aws ecr get-login --profile $env --no-include-email`
else
	docker login $repo
fi
