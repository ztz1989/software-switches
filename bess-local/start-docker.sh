#!/bin/bash

export VHOST_SOCK_DIR=/tmp/bess

sudo docker run -it --name=bess-docker -v /dev/hugepages:/dev/hugepages -v ${VHOST_SOCK_DIR}:/tmp/bess --privileged dpdk-docker
