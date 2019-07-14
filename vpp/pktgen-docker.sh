#!/bin/bash

export VHOST_SOCK_DIR=/tmp/vpp

sudo docker run -it --name=pktgen-vpp-docker-1 -v /dev/hugepages:/dev/hugepages -v ${VHOST_SOCK_DIR}:/tmp/vpp --privileged pktgen-3.1.1
