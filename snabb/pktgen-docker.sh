#!/bin/bash

export VHOST_SOCK_DIR=/tmp/snabb

sudo docker run -it --name=snabb-pktgen-docker -v /dev/hugepages:/dev/hugepages -v ${VHOST_SOCK_DIR}:/tmp/snabb --privileged pktgen-3.1.1
