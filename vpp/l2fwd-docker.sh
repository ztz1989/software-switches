#!/bin/bash

export VHOST_SOCK_DIR=/tmp/vpp

sudo docker run -it --name=l2fwd-docker-vpp -v /dev/hugepages:/dev/hugepages -v ${VHOST_SOCK_DIR}:/tmp/vpp --privileged l2fwd
