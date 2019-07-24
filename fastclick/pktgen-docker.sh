#!/bin/bash

export VHOST_SOCK_DIR=/tmp/fastclick

sudo docker run -it --name=pktgen-fastclick-docker-1 -v /dev/hugepages:/dev/hugepages -v ${VHOST_SOCK_DIR}:/tmp/fastclick --privileged pktgen-3.1.1
