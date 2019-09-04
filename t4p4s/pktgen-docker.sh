#!/bin/bash

export VHOST_SOCK_DIR=/tmp/t4p4s

sudo docker run -it --name=t4p4s-pktgen-docker-1 -v /dev/hugepages:/dev/hugepages -v ${VHOST_SOCK_DIR}:/tmp/t4p4s --privileged pktgen-3.1.1
