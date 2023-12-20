#!/usr/local/bin/bash

if [ "x$CONTAINER_SCRIPT_HOME" == "x" ]; then
        echo "Please set CONTAINER_SCRIPT_HOME"
        exit 1;
fi

source $CONTAINER_SCRIPT_HOME/common-repo.sh
source $CONTAINER_SCRIPT_HOME/common-aws.sh

if [[ $repo == *"amazonaws"* ]]; then
	aws_ecr_login
elif [[ $repo == *"azurecr"* ]]; then
  az acr login --name $repo
else
	docker login $repo
fi
