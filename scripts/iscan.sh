#!/usr/local/bin/bash

function main {
	# start the container
	docker-compose --file $CONTAINER_SCRIPT_HOME/clair/docker-compose.yaml up -d
	# scan the container
	clair-scanner_darwin_amd64 --ip host.docker.internal platform/test:latest
	# spin down the clair server and database
	docker-compose --file $CONTAINER_SCRIPT_HOME/clair/docker-compose.yaml down
}

main