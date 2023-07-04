#!/bin/bash

JMETER_VERSION="5.4.1"

# Example build line
# --build-arg IMAGE_TIMEZONE="Europe/Amsterdam"
docker build  --build-arg JMETER_VERSION=${JMETER_VERSION} -t "github.com/afriexUK/afriex-jmeter-testbench/jmeter:${JMETER_VERSION}" .
