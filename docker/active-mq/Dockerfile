FROM openjdk:8-jre-alpine
# THE OFFICIAL REPO BELOW CAN BE SLOW THUS USE AN AUSTRALIAN MIRROR
#RUN wget -O activemq.tar.gz http://archive.apache.org/dist/activemq/5.15.11/apache-activemq-5.15.11-bin.tar.gz
RUN wget -O activemq.tar.gz http://apache.mirror.serversaustralia.com.au/activemq/5.16.0/apache-activemq-5.16.0-bin.tar.gz
RUN tar -xzf activemq.tar.gz
RUN mkdir /jmx
COPY /lib/*.jar /apache-activemq-5.16.0/lib/
COPY /agent/* /jmx/
CMD ["apache-activemq-5.16.0/bin/activemq", "console" ]
