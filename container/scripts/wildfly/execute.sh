#!/bin/bash

# Usage: execute.sh [WildFly mode] [configuration file]
#
# The default mode is 'standalone' and default configuration is based on the
# mode. It can be 'standalone.xml' or 'domain.xml'.

JBOSS_HOME=/opt/jboss/wildfly
JBOSS_CLI=$JBOSS_HOME/bin/jboss-cli.sh
JBOSS_MODE=${1:-"standalone"}
JBOSS_CONFIG=${2:-"$JBOSS_MODE.xml"}

CUSTOMIZATION_LOCK_FILE=`dirname "$0"`/customization.lock

function wait_for_server() {
  until `$JBOSS_CLI -c ":read-attribute(name=server-state)" 2> /dev/null | grep -q running`; do
    sleep 1
  done
}

echo "JBOSS_MODE  : " $JBOSS_MODE
echo "JBOSS_CONFIG: " $JBOSS_CONFIG
echo "JBOSS_CLI   : " $JBOSS_CLI

echo "=> Starting Wildfly"

if [ ! -f $CUSTOMIZATION_LOCK_FILE ]; then 
	
	$JBOSS_HOME/bin/$JBOSS_MODE.sh -b 0.0.0.0 -bmanagement 0.0.0.0 -c $JBOSS_CONFIG &

	echo "=> Waiting for the server to boot"
	wait_for_server

	cwd=`dirname "$0"`

	echo "=> Executing customization script"
	$JBOSS_CLI -c --properties=$cwd/env.properties --file=$cwd/commands.cli

	touch $CUSTOMIZATION_LOCK_FILE

	echo "=> Shutting down WildFly"
	if [ "$JBOSS_MODE" = "standalone" ]; then
  		$JBOSS_CLI -c ":shutdown"
	else
  		$JBOSS_CLI -c "/host=*:shutdown"
	fi	

	`dirname "$0"`/post-customization.sh $JBOSS_HOME

	echo "!!! SLEEPING !!!"
	sleep 5
	echo "!!! WAKING !!!"
	echo "=> Restarting WildFly"
fi

$JBOSS_HOME/bin/$JBOSS_MODE.sh -b 0.0.0.0 -bmanagement 0.0.0.0 -c $JBOSS_CONFIG

