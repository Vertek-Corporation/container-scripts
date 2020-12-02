# Overview

These scripts automate the build of Docker images.  For example, you could build containers that
run wildfly with configurations for the entire development lifecycle.  

# Configurations

These scripts have been tested in the following configuration:

## Wildfly Java-based backend with a JavaScript UI

* base OS and wildfly installation
* access to HTTP, HTTPS, and the management interface
* required system properties
* MySQL module and driver
* Datasources
* Correct JAVA_OPTS

# Scripts

It also includes several scripts to automate common commands. You don't have to use these.

* ibuild.sh to build an image from scratch
* cstart.sh to start a container
* cstop.sh to stop a container or containers
* crm.sh to remove containers
* cattach.sh to attach to the container / console
* cexec.sh to execute a command on the container
* itag.sh tags the image with the version number in env.properties or whatever is provided
* rlogin.sh to log into a docker repo
* rpush.sh to push to a docker repo
* rpull.sh to pull a docker image from the repo
* iscan.sh to scan images for vulnerabilities

# Setup

## System Requirements

For shell scripts you'll need Bash 4.  On MacOS use 'brew install bash' to get it.  Then
add /usr/local/bin/bash to /etc/shells.  You can use the usual unix command line to make
this your default shell if you'd like.  All of the scripts included reference this path.

## Environment Variables

* Set your CONTAINER_SCRIPT_HOME to wherever you locate the scripts
* Add an environment variable called MAVEN_REPO_BASE_URL as shown below
* Make sure that your path includes the scripts

Here’s my configuration as an example:

```
# Container scripts will need to know where to find themselves
export CONTAINER_SCRIPT_HOME=~/projects/container-scripts/scripts
export MAVEN_REPO_BASE_URL=https://nexus.vertek.com
export PATH=$PATH: $CONTAINER_SCRIPT_HOME
```

## Clair (vulnerability scanning) support

To utlize Clair you must install the Clair scanner (https://github.com/arminc/clair-scanner) 
locally.  The scripts will automatically install the Clair server via Docker. You'll want 
to make sure you have the resources for this.  The server side utilizes clair-local-scan, 
https://github.com/arminc/clair-local-scan, which deploys a Postgress instance and Clair
server that are already populated with the latest CVEs.  Otherwise, Clair will take a fair
amount of time to download them from scratch.

Install per the instructions and make sure "clair-scanner" is in your path.  Our scripts 
will check for it and notify you if it hasn't been installed.  Note: this is optional 
but strongly recommended.

This requires the dockerHost configuration property in config.properties to be set properly.

# Getting started

1.  ibuild.sh 
2.  cstart.sh && cattach.sh &
3.  mvn wildfly:redeploy on your project, use the credentials from your docker file
4.  https://localhost:8443/context
5.  cstop.sh to stop the container when you're done

cstart.sh will reuse the last container on the next run, so it will keep your deployments.
Use cstart.sh --new to force creation of a new container if desired.  Specify --rm if you
want to destroy the container after it shuts down.

If you want to run against a specific environment (e.g. env-local) without updating your
config.property file you can pass --env.  For example cstart.sh --env local.

# Customizing the build

Multiple build directories are supported.  Create a file called evn-<my env> and put your
Dockerfile, etc, in it.  Then pass it as a parameter to ibuild.  Make sure to exclude it
from source control.

# Configuration Files

* config.properties has the global configuration (app name, environment default)
* env.properties under the specific environment directory has environment-specific conig

Note the .dockerignore file.  We avoid sending most files to the Docker server.
