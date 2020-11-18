#!/usr/local/bin/bash

# Containers required to run Clair server.  The order is important, the database must
# start prior to the Claire local scan server
declare clair_containers="arminc/clair-db arminc/clair-local-scan"

function is_container_running {
    local container=$1
	local container_id=$(docker ps -q --filter ancestor=$container | awk '{print $1}')

    if [[ "x$container_id" == "x" ]]; then	
		false;
	else 
		true;
	fi
}

function is_container_exists {
    local container=$1
	local container_id=$(get_container_id $container)

    if [[ "x$container_id" == "x" ]]; then	
		false;
	else 
		true;
	fi
}

function get_container_id {
    local container=$1
	echo $(docker ps -a -q --filter ancestor=$container | awk '{print $1}')
}

function start_container {
	local container=$1
	local container_id=$(get_container_id $container)
	docker start $container_id
}

function run_container {


}

function start_clair {
	for container in $clair_containers
	do
		if ! is_container_running $container; then
			# Check to see if the container exists already
			if is_container_exists $container; then
				start_container $container
			else
				run_container $container
			fi
		fi
	done
}

function stop_clair {
	for container in $clair_containers
	do
		if is_container_running $container; then
			echo "stopping $container..."
			docker stop $(get_container_id $container)
		fi
	done
}

function main {
	start_clair
	stop_clair
}

main