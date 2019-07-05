#!/bin/bash

export VHOST_SOCK_DIR=/tmp/t4p4s

sudo docker run -it --name=pktgen-t4p4s-docker -v /dev/hugepages:/dev/hugepages -v ${VHOST_SOCK_DIR}:/tmp/t4p4s --privileged pktgen-3.1.1
