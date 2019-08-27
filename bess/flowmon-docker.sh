#!/bin/bash

export VHOST_SOCK_DIR=/tmp/bess

sudo docker run -it --name=bess-flowmon-docker -v /dev/hugepages:/dev/hugepages -v ${VHOST_SOCK_DIR}:/tmp/bess --privileged flowmon-docker
