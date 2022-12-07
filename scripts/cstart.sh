#!/usr/local/bin/bash

if [ "x$CONTAINER_SCRIPT_HOME" == "x" ]; then
        echo "Please set CONTAINER_SCRIPT_HOME"
        exit 1;
fi

source $CONTAINER_SCRIPT_HOME/common.sh

# Allows for some basic command line options to customize the behavior
# of the command.  This isn't mean to cover the many options that you
# could supply, say, docker run.  Use docker run directly if you have
# to do something fancy.
#
# -n forces docker to create a new container versus reusing the last
# -r instructs docker to remove the container after it is stoped

# Default behavior
#
new="false"

# Transform long options to short ones
#
for arg in "$@"; do
  shift
  case "$arg" in
    "--env")  set -- "$@" "-e" ;;
    "--new")  set -- "$@" "-n" ;;
    "--rm")   set -- "$@" "-r" ;;
    *)        set -- "$@" "$arg"
  esac
done

# Parse command line options safely using getops
#
while getopts ":nre:" opt; do
  case $opt in
    e)
      set_property_value 'environment' $OPTARG
      ;;
    n)
      new="true"
      ;;
    r)
      rm="--rm";
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

# Because of the -p port configurations we only support running one
# container at a time.  That's a design decision and not a Docker
# thing.  Docker will attach to ephemeral ports within a specified
# range.  So if you want to get fancy about running multiple
# containers you can.  But you'll need your own scripts or will need
# to use Docker commands directly.

if has_live_container; then
        echo There is already a running $(get_image_name) container
        exit 1
fi

# Execute
#
if [ $new == "true" ] || [ -z $(get_last_container_id) ] ; then
	docker run $rm -d -p 8080:8080 \
		          -p 9990:9990 \
                          -p 8443:8443 $(get_image_name)
else 
	if [[ $rm ]]; then echo Remove option ignored; fi
	echo Reusing $(get_last_container_id) for $(get_image_name); 
	docker start $(get_last_container_id)
fi
