JBOSS_HOME=$1

# Get rid of the default welcome content
rm -f $JBOSS_HOME/welcome-content/*

# Unzip the contents of noc-ui.zip to the welcome-content directory
unzip $JBOSS_HOME/asset-dir/noc-ui.zip -d $JBOSS_HOME/welcome-content

# Put the war in the wildfly deployments directory where the deployment scanner will pick it up
mv $JBOSS_HOME/asset-dir/*.war $JBOSS_HOME/standalone/deployments

# Hide the evidence
rm -rf $JBOSS_HOME/asset-dir
