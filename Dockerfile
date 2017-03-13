
# kibana
FROM openshift/base-centos7

# TODO: Put the maintainer name in the image metadata
MAINTAINER Marisuz Derela <mariusz.derela@ing.com>

# TODO: Rename the builder environment variable to inform users about application you provide them
ENV KIBANA_VERSION=5.2.2 \
    BUILDER_VERSION=1.0 \
    JAVA_VERSION=1.8.0 \
    KIBANA_HOME=/usr/share/kibana \
    ELASTICSEARCH_URL=http://es-querybalancer:9200 \
    KIBANA_CONFIG=${KIBANA_HOME}/config/kibana.yml \
    PATH=${KIBANA_HOME}/bin:$PATH

# TODO: Set labels used in OpenShift to describe the builder image
LABEL io.k8s.description="Platform for building Kibana" \
      io.k8s.display-name="Kibana" \
      io.openshift.expose-services="5601:http" \
      io.openshift.tags="builder,kibana,elk"

# TODO: Install required packages here:
RUN rpm --rebuilddb && yum clean all && \
    yum install -y tar java-${JAVA_VERSION}-openjdk && \
    yum clean all && \
    mkdir -p ${KIBANA_HOME} && \
    cd ${KIBANA_HOME} && \
    curl -o /tmp/kibana5.tgz https://artifacts.elastic.co/downloads/kibana/kibana-5.2.2-linux-x86_64.tar.gz && \
    tar zxvf /tmp/kibana5.tgz -C ${KIBANA_HOME} --strip-components=1 && \
    rm -f /tmp/kibana5.tgz


# TODO (optional): Copy the builder files into /opt/app-root
# COPY ./<builder_folder>/ /opt/app-root/
COPY ./bin/bootstrap.sh ${KIBANA_HOME}/bin/bootstrap.sh

# TODO: Copy the S2I scripts to /usr/libexec/s2i, since openshift/base-centos7 image sets io.openshift.s2i.scripts-url label that way, or update that label
COPY ./.s2i/bin/ /usr/libexec/s2i

# TODO: Drop the root user and make the content of /opt/app-root owned by user 1001
RUN chown -R 1001:1001 /opt/app-root ${KIBANA_HOME}

# This default user is created in the openshift/base-centos7 image
USER 1001

# TODO: Set the default port for applications built using this image
EXPOSE 8080

CMD ["/usr/libexec/s2i/usage"]
