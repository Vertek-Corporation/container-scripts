#!/usr/local/bin/bash

# Transform long options to short ones
#
for arg in "$@"; do
  shift
  case "$arg" in
    "--env")      set -- "$@" "-e" ;;
    "--version")  set -- "$@" "-v" ;;
    "--token")  set -- "$@" "-o" ;;
    *)            set -- "$@" "$arg";
  esac
done

# Parse command line options safely using getops
#
while getopts ":e:v:o:" opt; do
  case $opt in
    e)
      set_property_value 'environment' $OPTARG
      ;;
    v)
      set_property_value 'version' $OPTARG
      ;;
    o)
      set_property_value 'token' $OPTARG
      ;;
    \?)
      echo "Invalid command line: $@" >&2
      exit 1;
      ;;
  esac
done

