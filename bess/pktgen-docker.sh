#!/bin/bash

export VHOST_SOCK_DIR=/tmp/bess

sudo docker run -it --name=bess-pktgen-docker-1 -v /dev/hugepages:/dev/hugepages -v ${VHOST_SOCK_DIR}:/tmp/bess --privileged pktgen-3.1.1
