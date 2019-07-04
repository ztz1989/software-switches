#!/bin/bash

export VHOST_SOCK_DIR=/tmp/t4p4s

sudo docker run -it --name=l2fwd-docker-t4p4s -v /dev/hugepages:/dev/hugepages -v ${VHOST_SOCK_DIR}:/tmp/t4p4s --privileged l2fwd
