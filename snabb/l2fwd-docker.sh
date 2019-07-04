#!/bin/bash

export VHOST_SOCK_DIR=/tmp/snabb

sudo docker run -it --name=l2fwd-docker-snabb -v /dev/hugepages:/dev/hugepages -v ${VHOST_SOCK_DIR}:/tmp/snabb --privileged l2fwd
