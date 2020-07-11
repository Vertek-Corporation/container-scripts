FROM jboss/wildfly:14.0.1.Final

RUN /opt/jboss/wildfly/bin/add-user.sh admin admin01 --silent

ADD  --chown=jboss:root customization /opt/jboss/wildfly/customization/
ADD  --chown=jboss:root asset-dir     /opt/jboss/wildfly/asset-dir/

# Sets JAVA_OPTS, etc. 
COPY --chown=jboss:root customization/standalone.conf /opt/jboss/wildfly/bin/

EXPOSE 8443
EXPOSE 8080
EXPOSE 9990

CMD ["/opt/jboss/wildfly/customization/execute.sh", "standalone", "standalone-full.xml"]
