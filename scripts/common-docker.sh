#!/usr/local/bin/bash

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

function assert_container_up {
    local container=$1 # name of the container
    local cmd=$2       # command to start the container
    if ! is_container_running $container; 
    then
        # Check to see if the container exists already
        if is_container_exists $container; 
        then
            start_container $container
        else
            $cmd
        fi
    fi
}