#!/bin/bash

export VHOST_SOCK_DIR=/tmp/bess

sudo docker run -it --name=l2fwd-docker-bess -v /dev/hugepages:/dev/hugepages -v ${VHOST_SOCK_DIR}:/tmp/bess --privileged l2fwd
