# Use vinsdocker base image
FROM 625194385885.dkr.ecr.eu-west-3.amazonaws.com/jmeterstresstest/jmeter-base
MAINTAINER Kodjo Baah<kodjo@afriex.co.uk>

# Ports to be exposed from the container for JMeter Slaves/Server
EXPOSE 1099 50000 8778

RUN apk add go openjdk8
RUN mkdir /data
COPY data/ /data
RUN mkdir /config
COPY config/ /config
COPY entrypoint.sh /
COPY client.jks /
COPY start.sh /
COPY ApacheJMeter.jar /opt/apache-jmeter/bin

RUN mkdir /fileupload
COPY jolokia-jvm-1.6.2-agent.jar /fileupload
COPY fileupload fileupload
WORKDIR /fileupload
ENV GO111MODULE=on
RUN go mod download
RUN go build -o upload cmd/ugcupload/main.go

ENTRYPOINT ["/entrypoint.sh"]
