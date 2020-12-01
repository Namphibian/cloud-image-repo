# ActiveMQ Artemis
FROM openjdk:11-jre
LABEL maintainer="Cornelius Franken <ncjfranken@gmail.com>"
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
WORKDIR /opt
ENV ARTEMIS_USER=artemis
ENV ARTEMIS_PASSWORD=artemis
ENV ANONYMOUS_LOGIN=false
ENV EXTRA_ARGS --http-host 0.0.0.0 --relax-jolokia
ENV ACTIVEMQ_ARTEMIS_VERSION=2.16.0
ENV JMX_EXPORTER_VERSION=0.3.1
ENV JGROUPS_KUBERNETES_VERSION=0.9.3
RUN groupadd -g 1000 -r artemis && useradd -r -u 1000 -g artemis artemis \
 && apt-get -qq -o=Dpkg::Use-Pty=0 update && \
  apt-get -qq -o=Dpkg::Use-Pty=0 install -y --no-install-recommends \
    libaio1 \
    xmlstarlet \
    jq \
    ca-certificates\
    wget && \
  rm -rf /var/lib/apt/lists/*
RUN wget -O "artemis.tar" "https://www.apache.org/dyn/closer.cgi?filename=activemq/activemq-artemis/${ACTIVEMQ_ARTEMIS_VERSION}/apache-artemis-${ACTIVEMQ_ARTEMIS_VERSION}-bin.tar.gz&action=download"
RUN tar -xvf ./artemis.tar -C /opt
RUN mv /opt/apache-artemis-${ACTIVEMQ_ARTEMIS_VERSION} /opt/activemq-artemis

WORKDIR /opt/jgroupskubernetes
RUN wget -O ivy-2.4.0.jar http://search.maven.org/remotecontent?filepath=org/apache/ivy/ivy/2.4.0/ivy-2.4.0.jar && \
  java -jar ivy-2.4.0.jar -dependency org.jgroups.kubernetes kubernetes "${JGROUPS_KUBERNETES_VERSION}" -retrieve "[artifact]-[revision](-[classifier]).[ext]" -types jar && \
  java -jar ivy-2.4.0.jar -dependency org.jgroups.kubernetes dns "${JGROUPS_KUBERNETES_VERSION}" -retrieve "[artifact]-[revision](-[classifier]).[ext]" -types jar && \
  rm ivy-2.4.0.jar
# TODO: Add JMX prometheus here

WORKDIR /opt/jmx-exporter
RUN wget "https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/${JMX_EXPORTER_VERSION}/jmx_prometheus_javaagent-${JMX_EXPORTER_VERSION}.jar" && \
  wget "https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/${JMX_EXPORTER_VERSION}/jmx_prometheus_javaagent-${JMX_EXPORTER_VERSION}.jar.sha1" && \
  echo "$(cat "jmx_prometheus_javaagent-${JMX_EXPORTER_VERSION}.jar.sha1")" "jmx_prometheus_javaagent-${JMX_EXPORTER_VERSION}.jar" | sha1sum -c - && \
  rm "jmx_prometheus_javaagent-${JMX_EXPORTER_VERSION}.jar.sha1" && \
  ln -s "/opt/jmx-exporter/jmx_prometheus_javaagent-${JMX_EXPORTER_VERSION}.jar" "/opt/jmx-exporter/jmx_prometheus_javaagent.jar"

COPY assets/jmx-exporter-config.yaml /opt/jmx-exporter/etc/
# Web Server
EXPOSE 8161 \
# JMX Exporter
    9404 \
# Port for CORE,MQTT,AMQP,HORNETQ,STOMP,OPENWIRE
    61616 \
# Port for HORNETQ,STOMP
    5445 \
# Port for AMQP
    5672 \
# Port for MQTT
    1883 \
#Port for STOMP
    61613
RUN mkdir /var/lib/artemis && chown -R artemis.artemis /var/lib/artemis
COPY ./docker-run.sh /
USER artemis
WORKDIR /var/lib/artemis
ENTRYPOINT ["/docker-run.sh"]
CMD ["run"]
