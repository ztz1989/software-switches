#!/bin/bash

export VHOST_SOCK_DIR=/tmp/snabb

sudo docker run -it --name=snabb-flowmon-docker -v /dev/hugepages:/dev/hugepages -v ${VHOST_SOCK_DIR}:/tmp/snabb --privileged flowmon-docker
