#!/bin/bash

export VHOST_SOCK_DIR=/tmp/vpp

sudo docker run -it --name=flowmon-docker-vpp -v /dev/hugepages:/dev/hugepages -v ${VHOST_SOCK_DIR}:/tmp/vpp --privileged flowmon-docker
